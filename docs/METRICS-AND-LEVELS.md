# Metrics, Levels, and Route Leaking

The three things that actually decide IS-IS paths in a multi-area network. Read after Phase 2.

## Metric design

IS-IS path cost = sum of **outgoing** interface metrics along the path. Default metric is 10 on
every interface — which means by default *every link is equal* and paths are decided by hop count.
That's rarely what you want.

**Design metrics on purpose:**
- Make them proportional to something real — inverse of bandwidth is the classic (10G cheaper than
  1G to traverse), or latency for latency-sensitive cores.
- Keep a consistent reference so the numbers mean something network-wide.
- Always `metric-style wide` — narrow's max-63 ceiling makes real design impossible.

**On the lab diamond** (all links 10):
- R1→R4 costs 20 via R2 **and** 20 via R3 → equal-cost multipath (ECMP), traffic load-shares.
- Raise R1–R3 to 100 → R1→R4 via R3 now costs 110, via R2 still 20 → path collapses to R1→R2→R4.
- This is the whole game: you place metrics, SPF places traffic.

```
 interface GigabitEthernet0/0/0/3
  address-family ipv4 unicast
   metric 100        ! steer traffic off this link
```

## Levels recap (the part people get wrong)

| | Level 1 | Level 2 |
|---|---------|---------|
| Knows | Its own area in detail | The inter-area backbone |
| Reaches other areas via | **default route** to nearest ATT L1-2 router | direct (it *is* the backbone) |
| Must be contiguous? | within the area | **yes** — backbone can't be partitioned |

**The attached (ATT) bit:** an L1-2 router sets ATT in its **L1** LSP to announce "I can reach
other areas." L1 routers install a default route toward the nearest ATT-setting router. That's how
an L1-only router (R1 in this lab) reaches anything outside area 49.0001 — by default, *without*
seeing any external specifics.

## Why default routing can be suboptimal

R1 sees R2 and R3 both setting ATT at equal cost, so it default-routes to both. But the actual best
path to R4's loopback might be clearly via one of them. Following the default, R1 might send some
flows the long way. The fix is **route leaking**.

## Route leaking (L2 → L1)

- **L1 → L2 is automatic** — area specifics naturally populate the backbone.
- **L2 → L1 is blocked by default** to prevent loops. You opt in, selectively.
- When you leak, IOS-XR marks the route with a **down bit** so an L1-2 router won't take a
  leaked-down route and push it *back up* into L2 (that's the loop the default block prevents).

```
prefix-set LEAKED-FROM-L2
  4.4.4.4/32                 ! only the specifics L1 actually benefits from
end-set
!
route-policy LEAK-L2-TO-L1
  if destination in LEAKED-FROM-L2 then pass else drop endif
end-policy
!
router isis CORE
 address-family ipv4 unicast
  propagate level 2 into level 1 route-policy LEAK-L2-TO-L1
```

Leak **sparingly** — leaking everything defeats the point of having levels (you've just rebuilt a
flat network with extra steps).

## Summarization (the opposite lever)

At an L1-2 boundary, advertise an aggregate instead of many specifics:

```
router isis CORE
 address-family ipv4 unicast
  summary-prefix 172.16.0.0/16 level 2
```

Smaller LSDB, fewer SPF triggers, less flooding churn — at the cost of path detail (you might
hide a better specific path). **Scale vs optimality** is the core area-design trade-off, and
knowing when to leak (more detail) vs summarize (less) is exactly the judgment of a real engineer.
