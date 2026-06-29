# Fast Convergence

"It converges" isn't enough for a carrier — *how fast* is the SLA. Convergence has three separate
delays, and each has its own tool. Confusing them is why people throw BFD at everything and wonder
why traffic still drops. Read after Phase 4.

## The three delays

```
  link fails
      │
      ▼
  (1) DETECT the failure ........... hellos time out (seconds)  →  BFD (~ms)
      │
      ▼
  (2) COMPUTE the new path ......... SPF runs  →  throttling + incremental SPF
      │
      ▼
  (3) FORWARD during the gap ....... blackhole until FIB updated  →  LFA / TI-LFA
```

You need all three. BFD with no LFA = you detect fast but still blackhole until SPF+FIB finish.

## (1) Detection — BFD

Without BFD, IS-IS notices a dead neighbor only when **hold-time** expires (hello-interval ×
multiplier — typically several seconds). **BFD (Bidirectional Forwarding Detection)** is a tiny,
dedicated hello protocol that detects a dead path in tens of milliseconds and signals IS-IS to drop
the adjacency *immediately*.

```
 interface GigabitEthernet0/0/0/1
  bfd fast-detect ipv4
  bfd minimum-interval 50      ! 50ms
  bfd multiplier 3             ! dead after 3 misses ≈ 150ms
```

BFD runs in hardware/forwarding-plane on real gear, so it's cheap and fast. Tune the interval to
what the platform supports — too aggressive on a soft router (or EVE-NG) causes false drops.

## (2) Computation — SPF and LSP throttling

A flapping link could trigger SPF over and over. **Exponential backoff** keeps the CPU sane: run
fast for the first event, then back off if events keep coming.

```
 address-family ipv4 unicast
  spf-interval     maximum-wait 5000 initial-wait 50 secondary-wait 200
  lsp-gen-interval maximum-wait 5000 initial-wait 50 secondary-wait 200
```

- `initial-wait 50` — react in 50ms to the first change.
- `secondary-wait 200` — if more changes arrive, wait 200ms.
- `maximum-wait 5000` — cap the backoff at 5s during a storm.

**Incremental SPF (iSPF)** recomputes only the affected branch of the tree instead of the whole
thing — big saving in large topologies. Enabled/automatic on modern IOS-XR.

## (3) Forwarding during the gap — LFA / TI-LFA

Even with fast detection and fast SPF, there's a window where the FIB still points at the dead link.
**Loop-Free Alternate (LFA)** pre-computes a backup next-hop *ahead of time* and pre-installs it, so
the linecard switches to it the instant BFD says "down" — before SPF even runs.

```
 interface GigabitEthernet0/0/0/1
  address-family ipv4 unicast
   fast-reroute per-prefix       ! pre-install a loop-free backup next-hop
```

**The LFA limitation:** a "loop-free alternate" must be a neighbor that won't send the packet back
to you. In some topologies no such neighbor exists → those prefixes are **unprotected**. On the lab
diamond, R1 losing its R2 link *does* have a loop-free alternate (R3), so LFA works here.

**TI-LFA** (Topology-Independent LFA) removes the limitation: it uses **Segment Routing** to source-
route the repair packet along the post-convergence path to *any* destination — guaranteed coverage,
and it pre-computes the *same* path SPF will choose, so there's no second micro-reroute. You built
this in the [SR-MPLS lab](https://github.com/bosamart/sr-mpls-iosxr-eveng-lab). Same problem (forward during the gap), better solution
(SR labels instead of hoping a loop-free neighbor exists).

## Authentication (not convergence, but Phase 5's other half)

Signing LSPs stops a rogue/misconfigured device from injecting false topology:

```
key chain ISIS-KEY
 key 1
  key-string cisco123
  cryptographic-algorithm HMAC-MD5
!
router isis CORE
 lsp-password keychain ISIS-KEY level 2
```

**Gotcha:** mismatched keys silently drop the adjacency. When an adjacency won't form after you add
auth, check both ends' keychain and level first.

## Verify it all

```
show bfd session                     ! state Up, your sub-second interval
show isis fast-reroute summary       ! how many prefixes are LFA-protected
show isis fast-reroute detail        ! per-prefix backup next-hop
! proof: continuous ping, shut a link, count the loss
ping 4.4.4.4 source 1.1.1.1 count 100000
```
