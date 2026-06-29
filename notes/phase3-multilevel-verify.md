# Phase 3 — Multi-level areas: Verification Log

**Date:**
**Objective:** Split into areas (R1 L1-only/49.0001; R2,R3 L1-2; R4 in 49.0002). Confirm R1 sees only a default route to reach R4, and the ATT bit is set on R2/R3.
**Result:** ⬜ Not yet run

---

## Commands run

```
show isis neighbors                  ! note the LEVEL of each adjacency
show isis database level-1           ! R1's area-only view
show isis database level-2           ! backbone view
! ON R1:
show route isis                       ! expect 0.0.0.0/0 (default), NOT 4.4.4.4/32
show isis database level-1 detail | include ATT   ! attached bit from R2/R3
```

## Expected adjacency levels

| Link | Level |
|------|-------|
| R1–R2, R1–R3 | L1 |
| R2–R3 (cross) | L1 + L2 |
| R2–R4, R3–R4 | L2-only |

Expected on R1: a **default route** via R2 and R3 (ATT bit), and **no** 4.4.4.4/32 yet. Traffic to R4 follows the default (possibly suboptimal) — the setup for Phase 4.

## Captured output

```
(paste here)
```

## Can I explain it?
What does the attached bit do, and why doesn't R1 see 4.4.4.4 yet? → ATT = "default to me for other areas"; L2→L1 specifics aren't leaked by default.
