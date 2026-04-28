# multiplicity-multi-population

Phase 3 designs that test **the same endpoint in multiple populations** (e.g., biomarker-positive subgroup + ITT, multiple nested biomarker strata) with multiplicity control across the population tests.

## When this family is the right choice

- Targeted-therapy trials with a biomarker-defined subgroup where the sponsor wants to claim both the subgroup and the broader population.
- Diseases with established prognostic strata where the regulator expects evidence in each sub-population.
- Designs that pre-specify hierarchical population testing rather than relying on post-hoc subgroup analysis.

## Common pitfalls

- **Subgroup α-split is usually wrong.** Most published multi-population designs use fixed-sequence (test strongest-effect subgroup first; on rejection, test broader strata at full α). Splitting α between populations is conservative.
- **Nested vs disjoint populations.** Nested (TPS≥50 ⊂ TPS≥20 ⊂ ITT): patients overlap, total N driven by the broadest stratum. Disjoint (e.g., HR-positive vs HR-negative): total N is sum of per-stratum N. The agent must distinguish.
- **Prevalence assumption.** The events available within a subgroup depend on its prevalence in the overall enrolled population. A 20% biomarker subgroup needs 5× the overall enrollment to reach the same per-subgroup event count as the overall population.

## R packages that can reproduce this family

| Procedure | Preferred R package(s) |
|---|---|
| Hierarchical (fixed-sequence) | `gsDesign` per population; `graphicalMCP::graph_create` chain |
| α-split (parallel) | `gsDesign` per population at weighted α; `graphicalMCP` with no recycling |
| Closed-testing | `multcomp::glht`, custom closure principle implementation |
| Graphical (with population gates) | `graphicalMCP` |

## Cases in this directory

See `cases/` for individual benchmark cases. Each is a `<id>.md` + `<id>.yaml` pair.
