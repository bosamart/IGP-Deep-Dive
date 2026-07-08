# IS-IS vs OSPF — side by side

Both are link-state IGPs running Dijkstra over a synchronized database. If you know one, you're 80%
of the way to the other. This maps the concepts and explains the SP preference for IS-IS. Read with
Phase 6.

## Concept map (same idea, different name)

| Concept | IS-IS | OSPF |
|---------|-------|------|
| Topology advertisement | LSP (Link-State PDU) | LSA (Link-State Advertisement) |
| Database | LSDB | LSDB |
| Path computation | SPF (Dijkstra) | SPF (Dijkstra) |
| Router identity | NET / system-id | Router-ID (IPv4-formatted) |
| Backbone | Level 2 (contiguous) | Area 0 (everything must touch it) |
| Non-backbone | Level 1 area | Non-zero area |
| Area boundary | **on the link** (router is in one area) | **on the router** (ABR is in many areas) |
| Boundary router | L1-2 | ABR |
| External redistribution pt | L2 / redistribute | ASBR |
| LAN optimization | DIS + pseudonode | DR / BDR |
| Point-to-point | no DIS | no DR |
| Interface cost | metric (use wide) | cost (ref-bw / bw) |
| "Default to backbone" signal | ATT bit | default route from ABR / stub areas |
| Runs on | Layer 2 directly | inside IP (proto 89) |
| IPv6 | same instance (TLV) | needs OSPFv3 (separate) |

## The differences that actually matter

**1. One protocol for everything.** IS-IS carries IPv4, IPv6, and Segment Routing in a *single*
instance because routes are just TLVs in the LSP. OSPFv2 is IPv4-only; for IPv6 you run a *second*
protocol (OSPFv3). In a dual-stack SP core, that's one IS-IS vs two OSPFs to design, secure, and
troubleshoot.

**2. Area boundaries: link vs router.** In IS-IS each router belongs to exactly one area and the
*link* is L1 or L2. In OSPF the *router* (the ABR) straddles areas. The IS-IS model makes the
backbone easier to grow — you don't have to keep every area physically attached to area 0.

**3. Backbone flexibility.** OSPF is strict: every area must connect to area 0 (or use a virtual
link — a smell). IS-IS L2 just has to be contiguous among L2 routers, which is more forgiving as the
network grows.

**4. Extensibility.** New capability in IS-IS = a new TLV, ignored by routers that don't understand
it. OSPF's more rigid LSA formats make extensions heavier. This is a big reason SR and TE
extensions landed cleanly in IS-IS.

**5. Stability/scale at the very top end.** IS-IS tends to flood less and is widely regarded as
slightly more stable in very large flat domains — part of why most large SPs and the biggest content
networks run it.

## Where OSPF wins

- **Ubiquity / familiarity.** Far more engineers know OSPF; more enterprise gear and docs assume it.
- **Granular area types.** Stub / totally-stubby / NSSA give fine control over what enters an area.
  IS-IS achieves similar outcomes via leaking/summarization but with less built-in vocabulary.
- **Enterprise fit.** For a single-stack IPv4 enterprise with lots of OSPF-trained staff, OSPF is
  often the pragmatic choice.

## The bottom line for you

You're heading into a service-provider carrier on IOS-XR. **IS-IS is the SP-core default**
— single instance for v4/v6/SR, transport-agnostic, flexible areas. Master IS-IS deeply; keep OSPF
solid enough to design, troubleshoot, and pass interviews/certs. This lab gives you both on one map
so the comparison is concrete, not theoretical.

## Try it

After pasting `configs/ospf/`, line these up against your IS-IS captures:

```
show ospf neighbor          vs   show isis neighbors
show ospf database          vs   show isis database
show route ospf             vs   show route isis
show ospf border-routers    vs   (the L1-2 routers / ATT bit)
```

Same shortest paths, same diamond — different machinery. Seeing it twice is what makes it stick.
