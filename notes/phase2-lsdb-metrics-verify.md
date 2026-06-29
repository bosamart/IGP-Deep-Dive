# Phase 2 — LSDB + metric design: Verification Log

**Date:**
**Objective:** Read the LSDB; confirm wide metrics; demonstrate ECMP and then steer the path by changing a metric.
**Result:** ⬜ Not yet run

---

## Commands run

```
show isis database detail            ! each router's links + metrics inside its LSP
show isis route
show isis topology
show route 4.4.4.4                    ! ECMP via R2 and R3? (cost 20 each)
```

## Experiment: steer the path

```
! On R1, raise the R3-facing link metric:
router isis CORE
 interface GigabitEthernet0/0/0/3
  address-family ipv4 unicast
   metric 100
! Re-check — path to R4 should collapse to R1->R2->R4
show route 4.4.4.4
traceroute 4.4.4.4 source 1.1.1.1
```

## Expected

- All links metric 10 → R1→R4 ECMP (two next-hops in `show route 4.4.4.4`).
- After metric 100 on R1–R3 → single path via R2.
- `metric-style wide` confirmed (no "narrow" warnings; metrics > 63 accepted).

## Captured output

```
(paste here)
```

## Can I explain it?
Two routers disagree on a path — what do I check first? → Whether their `show isis database` actually matches (desync).
