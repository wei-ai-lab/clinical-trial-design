# multiplicity-graphical

Phase 3 designs with **multiple hypotheses controlled by a graphical multiplicity procedure** (Maurer-Bretz alpha-recycling). Initial alpha weights split family-wise α across hypotheses; a transition matrix re-allocates alpha to other hypotheses upon rejection.

## When this family is the right choice

- Trials with **mixed primary + secondary hypotheses** that would naïvely require α-split, but where structural relationships between hypotheses (e.g., dose-response, parent endpoint → derived endpoint) allow alpha to be recycled with full α-control.
- Designs where the sponsor wants more than 2-3 hypotheses tested with a coherent procedure that doesn't punish all of them with the same Bonferroni discount.
- Regulatory contexts (especially EMA) where graphical procedures are increasingly the default for multi-hypothesis confirmatory trials.

## Common pitfalls

- **Transition matrix Rule-3 violation.** A row's transitions must sum to ≤ 1 AND must not route alpha to a hypothesis whose prerequisites haven't been met. Our `validate_transition_matrix(tm, gate_prereqs)` enforces both.
- **Initial weights on secondaries.** Secondary hypotheses typically start at α=0 — they only become testable after primary rejection releases alpha to them. Starting them with non-zero initial weight is usually a mis-encoding.
- **Worst-case sample sizing.** Sample size for a hypothesis must be computed at the smallest α that hypothesis could be tested at across all rejection paths. The closure-principle worst-case is what determines power.

## R packages that can reproduce this family

| Procedure | Preferred R package(s) |
|---|---|
| Graphical (Maurer-Bretz) | `graphicalMCP::graph_create` + `graph_test_closure` |
| Graphical (legacy / rich diagrams) | `gMCP::gMCP`, `gMCP::graphGUI` |
| Closed testing (general) | `multcomp` |

## Cases in this directory

See `cases/` for individual benchmark cases. Each is a `<id>.md` + `<id>.yaml` pair.
