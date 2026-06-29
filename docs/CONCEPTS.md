# Concepts — IS-IS

The theory behind the lab. IS-IS feels alien at first because it comes from the OSI world, not IP —
but that "alienness" is exactly why it's powerful. Read this before Phase 2.

## What IS-IS is

IS-IS (Intermediate System to Intermediate System) is a **link-state** IGP, like OSPF. Every router
describes its own links in a **link-state PDU (LSP)**, floods it, and every router builds an
identical **link-state database (LSDB)**. Each then runs **Dijkstra/SPF** on that database to find
shortest paths. Same family as OSPF — the differences are in packaging and scaling.

**The key oddity:** IS-IS runs *directly on Layer 2* (its own protocol, not inside IP). That's why
it doesn't care whether it's carrying IPv4, IPv6, or MPLS/SR labels — they're just TLVs (type-length-
value fields) inside the LSP. One protocol, every address family. OSPFv2 lives inside IP and is
IPv4-only.

## Addressing: the NET

IS-IS routers are identified by a **NET (Network Entity Title)**, not an IP. Example:

```
49.0001.0000.0000.0001.00
└┬┘ └─┬┘ └──────┬──────┘ └┬┘
 │    │         │         └ NSEL — always 00 on a router
 │    │         └ system-id — 6 bytes, MUST be unique in the domain
 │    └ area-id — routers with the same area-id are in the same L1 area
 └ AFI — 49 = private/locally-administered (like RFC1918 for IS-IS)
```

Common convention (used in this lab): encode the loopback into the system-id, e.g. loopback
`1.1.1.1` → system-id `0000.0000.0001` (or `0010.0100.1001` if you pad the octets). Pick a scheme
and stay consistent — a duplicate system-id is a nasty, subtle outage.

## Levels — the scaling mechanism

| Level | Scope | Analogy |
|-------|-------|---------|
| **L1** | Intra-area (knows its own area only) | OSPF non-backbone area, totally stubby-ish |
| **L2** | Inter-area backbone (must be contiguous) | OSPF area 0 — but more flexible |
| **L1-2** | Both — the boundary router | OSPF ABR |

- An **L1 router** reaches other areas via a **default route** to the nearest L1-2 router that has
  the **attached (ATT) bit** set in its L1 LSP.
- The **L2 backbone** must be contiguous, but unlike OSPF there's no rule that every area physically
  touches it — L2 just has to be unbroken among the L2 routers.
- Adjacency level is negotiated per link: two L1 routers in the same area → L1; routers in different
  areas → L2 only; two L1-2 routers in the same area → both.

## LSPs and flooding

- Each router originates an **LSP** (fragment 0, plus more fragments if it has lots to say).
- LSPs are flooded reliably: **CSNP** (complete sequence number PDU) is a database summary used to
  sync; **PSNP** (partial SNP) acknowledges/requests specific LSPs.
- The **DIS (Designated Intermediate System)** is elected **only on broadcast (LAN) circuits** to
  create a pseudonode and reduce flooding adjacencies. On **point-to-point** links (this whole lab)
  there's no DIS — simpler, and the SP norm.

## SPF

Each router runs Dijkstra on the LSDB to build its shortest-path tree, then installs routes.
Triggers: a changed LSP, a new/lost adjacency, a metric change. **Throttling** (`spf-interval`)
prevents a flapping link from melting the CPU; **incremental SPF (iSPF)** recomputes only the
affected part of the tree.

## Metrics

- **Narrow** (legacy): 6-bit interface metric, max 63; total path max 1023. Too small for modern
  networks and incompatible with TE/SR. Avoid.
- **Wide** (`metric-style wide`): 24-bit interface, 32-bit total. **Always use this.** Required for
  MPLS-TE and Segment Routing extensions.

## Why SPs love it

One protocol for IPv4 + IPv6 + SR; runs on L2 so it's transport-agnostic; flexible area design;
proven at internet scale. The trade-off is it's less commonly taught than OSPF, so the talent pool
is smaller — which is exactly why knowing it well is valuable to you.
