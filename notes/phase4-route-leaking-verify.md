# Phase 4 — Route leaking + summarization: Verification Log

**Date:**
**Objective:** Leak 4.4.4.4/32 from L2 into L1 on R2/R3 so R1 gets the specific route and the optimal path. Understand the down bit.
**Result:** ⬜ Not yet run

---

## Commands run

```
! ON R1, after applying 'propagate level 2 into level 1' on R2/R3:
show route 4.4.4.4                    ! now a SPECIFIC /32, not just default
show route isis | include 4.4.4.4
traceroute 4.4.4.4 source 1.1.1.1    ! confirm optimal path
! Confirm the down bit on the leaked route (loop prevention):
show isis database level-1 detail | include 4.4.4.4
```

## Expected

- Before: R1 had only 0.0.0.0/0 for R4.
- After: R1 has 4.4.4.4/32 as an L1 route; path is now the true shortest, not the default.
- The leaked route carries the **down bit** so R2/R3 won't re-inject it into L2.

## Summarization (optional sub-experiment)

```
! On R2/R3 boundary, advertise an aggregate into L2:
router isis CORE
 address-family ipv4 unicast
  summary-prefix 172.16.0.0/16 level 2
show route isis      ! fewer specifics, one aggregate
```

## Captured output

```
(paste here)
```

## Can I explain it?
Why is L2→L1 blocked by default but L1→L2 isn't? → Loop prevention; leaked-down routes carry a down bit so a boundary router won't push them back up.
