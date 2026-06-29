# Phase 1 — Single-area baseline: Verification Log

**Date:**
**Objective:** Flat single-area IS-IS (all L2), 5 adjacencies up, synchronized LSDB, all loopbacks reachable.
**Result:** ⬜ Not yet run

---

## Commands run (per router)

```
show isis neighbors
show isis adjacency detail
show isis database
ping 4.4.4.4 source 1.1.1.1
```

## Expected adjacency map (point-to-point, no DIS)

| Router | Neighbors (interface) | Count |
|--------|------------------------|-------|
| R1 | R2 (Gi0/0/0/1), R3 (Gi0/0/0/3) | 2 |
| R2 | R1 (Gi0/0/0/0), R3 (Gi0/0/0/1), R4 (Gi0/0/0/3) | 3 |
| R3 | R1 (Gi0/0/0/2), R2 (Gi0/0/0/0), R4 (Gi0/0/0/4) | 3 |
| R4 | R2 (Gi0/0/0/2), R3 (Gi0/0/0/3) | 2 |

Expected: all Up; `show isis database` identical (same LSP count) on every router; R1 pings 4.4.4.4.

## Captured output

```
(paste here)
```

## What I learned / gotchas

- (e.g. duplicate system-id? mismatched MTU? interface not point-to-point?)
