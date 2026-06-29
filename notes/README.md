# IGP Deep Dive — Lab Notes

## Lab Goals
- Stop treating the IGP as "the thing that makes loopbacks ping" — understand the LSDB, levels, and convergence
- Read `show isis database` and explain why every route is where it is
- Design metrics and areas deliberately; leak/summarize with intent
- Hit sub-second convergence with BFD + LFA; understand the difference from detection
- Compare IS-IS and OSPF on the same map and articulate the SP choice

## Topics Covered
- [ ] Phase 1 — Single-area baseline (adjacencies, LSDB, no DIS on p2p)
- [ ] Phase 2 — LSDB + metric design (wide metrics, ECMP, steering)
- [ ] Phase 3 — Multi-level areas (L1/L2, attached bit, default routing)
- [ ] Phase 4 — Route leaking + summarization
- [ ] Phase 5 — Fast convergence (BFD, LFA, SPF throttle, auth)
- [ ] Phase 6 — OSPF comparison build

## Lab Topology
> Same diamond as the BGP/MPLS-TE/SRv6 labs. R1 = L1-only (area 49.0001); R2/R3 = L1-2 boundary
> (area 49.0001); R4 = area 49.0002 reached over the L2 backbone. See ../diagrams/topology.md

## How to use these notes
Each phase note is a verification log — fill in the Date, paste what you saw, record gotchas. The
expected results are pre-filled so you know what "good" looks like. Don't mark a phase ✅ until the
README's "Can I explain it?" question is answered.

## Related
- This is the FOUNDATION lab — do it before ../BGP-Advanced/ (iBGP rides this IGP).
- LFA here → TI-LFA in the SR-MPLS lab (https://github.com/bosamart/sr-mpls-iosxr-eveng-lab) — same problem, SR solution.
- Roadmap: ../../../LEARNING-ROADMAP.md

## Session Log
| Date | Phase | Topic | Outcome |
|------|-------|-------|---------|
|  | Phase 1 | Single-area baseline |  |
|  | Phase 2 | LSDB + metrics |  |
|  | Phase 3 | Multi-level areas |  |
|  | Phase 4 | Route leaking |  |
|  | Phase 5 | Fast convergence |  |
|  | Phase 6 | OSPF comparison |  |
