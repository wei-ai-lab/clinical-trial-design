# multiplicity-co-primary

Phase 3 designs with **two or more co-primary endpoints** that share the family-wise type I error α. The hypotheses are tested with a multiplicity-control procedure (alpha-split, fixed-sequence / hierarchical, or graphical).

## When this family is the right choice

- Confirmatory trials where the regulator requires positive results on more than one endpoint to grant the indication (oncology PFS+OS, CV death + HHF + composite).
- Trials where the sponsor wants to claim multiple labelled benefits (e.g., PFS for accelerated approval and OS for the full label).
- Designs that would be conservative under naïve Bonferroni — fixed-sequence in particular preserves the full family-wise α with no per-test adjustment.

## Common pitfalls

- **Mistaking hierarchical for alpha-split.** "Co-primary, must hit both" usually means fixed-sequence (each tested at full α conditional on the prior rejecting), not Bonferroni-split. Splitting α on a hierarchical design leaves power on the table.
- **Sample size driven by the slowest endpoint.** Total N = max(N required per endpoint), not sum. Frequently the second endpoint in a fixed-sequence chain (e.g., OS after PFS) has the larger N requirement.
- **Operational alignment of interim timing.** PFS and OS interim analyses do not necessarily occur at the same calendar times — agents must allow per-endpoint interim schedules.

## R packages that can reproduce this family

| Procedure | Preferred R package(s) |
|---|---|
| Fixed-sequence / hierarchical | `gsDesign::gsSurv` per endpoint, alpha-pass-through manually; `graphicalMCP::graph_create` with chain transitions |
| Alpha-split (Bonferroni / weighted) | `gsDesign::gsDesign` per endpoint at α/k; `graphicalMCP` with no recycling |
| Graphical (Maurer-Bretz) | `graphicalMCP::graph_create` + `graph_test_closure`, `gMCP::gMCP` |

## Cases in this directory

See `cases/` for individual benchmark cases. Each is a `<id>.md` + `<id>.yaml` pair.
