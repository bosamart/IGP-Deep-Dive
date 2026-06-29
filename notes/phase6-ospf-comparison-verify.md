# Phase 6 — OSPF comparison build: Verification Log

**Date:**
**Objective:** Build OSPF on the same diamond (area 0 backbone + area 1), reach FULL on every p2p link, and map each OSPF concept back to its IS-IS equivalent.
**Result:** ⬜ Not yet run

---

## Setup

Remove IS-IS (or use a fresh snapshot) and paste configs/ospf/R1..R4.txt.
Area mapping: L2 backbone → area 0; L1 area 49.0001 → area 1; R2/R3 → ABRs; R4 → area 0.

## Commands run

```
show ospf neighbor                   ! FULL on each p2p link (no DR on p2p)
show ospf database                   ! LSA types 1/2/3
show ospf border-routers             ! the ABRs (R2, R3)
show route ospf                       ! inter-area routes via ABRs
```

## Side-by-side to capture

| Question | IS-IS answer | OSPF answer |
|----------|--------------|-------------|
| How does R1 reach R4? | L1 default + leaked /32 | inter-area (type-3) via ABR |
| Backbone | L2 (contiguous) | area 0 |
| Boundary router | L1-2 | ABR |
| IPv6 in same instance? | yes (TLV) | no (needs OSPFv3) |

## Captured output

```
(paste here)
```

## Can I explain it?
Name one concrete reason a greenfield SP core picks IS-IS. → Single instance for IPv4+IPv6+SR; runs on L2, transport-agnostic; flexible backbone.
