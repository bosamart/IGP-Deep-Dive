# Phase 5 — Fast convergence (BFD, LFA, throttle, auth): Verification Log

**Date:**
**Objective:** BFD sub-second detection up; LFA backups pre-installed; link failure reroutes in <50ms; LSP authentication active.
**Result:** ⬜ Not yet run

---

## Commands run

```
show bfd session                     ! state Up, interval ~50ms x3
show isis fast-reroute summary       ! count of LFA-protected prefixes
show isis fast-reroute detail        ! per-prefix backup next-hop
show isis interface | include Auth   ! authentication active
show isis adjacency                  ! adjacencies survive after auth applied
```

## Failover proof

```
ping 4.4.4.4 source 1.1.1.1 count 100000
! mid-stream, shut R1's link to R2:
interface GigabitEthernet0/0/0/1
 shutdown
! expect near-zero loss — LFA reroutes via R3 before SPF completes
! restore:
 no shutdown
```

Record: packets lost during the switch; BFD detection time; whether LFA covered the prefix.

## Expected / gotchas

- BFD too aggressive in EVE-NG can flap — loosen interval if so (softrouter, not hardware BFD).
- Mismatched keychain/level → adjacency drops. Check both ends.
- A prefix with no loop-free alternate shows unprotected (LFA limitation → TI-LFA in SR lab).

## Captured output

```
(paste here)
```

## Can I explain it?
Why doesn't BFD alone give sub-second convergence? → It gives sub-second *detection*; you still need a pre-computed backup (LFA) to forward during the SPF/FIB gap.
