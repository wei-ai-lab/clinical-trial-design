# Maurer-Bretz (2009) — canonical four-hypothesis graphical multiplicity example

**Family:** multiplicity-graphical · **Endpoints:** 4 (2 primary + 2 secondary) · **N per arm:** 235 · **Methodology paper**

## Why this case is in the corpus

- **Canonical graphical multiplicity example** from Bretz, Maurer, Brannath, Posch (Stat Med 2009) — the foundational paper for graphical alpha-recycling procedures.
- Four hypotheses: two primary dose-vs-placebo comparisons and two secondary endpoint comparisons. Non-trivial transition matrix with alpha recycling between primaries and from primaries to their respective secondaries.
- Tests the **Rule-3 validator** (transition matrix must not route alpha to a hypothesis that has not had its prerequisites met).
- Single methodology anchor, not tied to a specific trial — chosen because the paper publishes the exact transition matrix and initial weights, so reproducibility is unambiguous.

## Citation

Bretz F, Maurer W, Brannath W, Posch M. *A graphical approach to sequentially rejective multiple test procedures.* Statistics in Medicine. 2009;28(4):586-604. DOI: 10.1002/sim.3495.

## Design summary

| | |
|---|---|
| Setting | Methodology — three-arm dose-finding, two endpoints |
| Hypotheses | H1: dose-low vs placebo (endpoint A) |
| | H2: dose-high vs placebo (endpoint A) |
| | H3: dose-low vs placebo (endpoint B, secondary) |
| | H4: dose-high vs placebo (endpoint B, secondary) |
| Initial α weights | (0.0125, 0.0125, 0, 0) — primaries split 0.025; secondaries gated |
| Transition matrix | See yaml `multiplicity.transition_matrix` |
| Power per primary | 80% at δ = 0.40, σ = 1.0, α = 0.0125 (after potential recycling) |

## Transition matrix (alpha recycling)

```
     H1    H2    H3    H4
H1 [ 0   0.5   0.5   0  ]   ← if H1 rejected: 50% to H2, 50% to H3
H2 [0.5   0    0    0.5 ]   ← if H2 rejected: 50% to H1, 50% to H4
H3 [ 0    0    0    1.0 ]   ← if H3 rejected: 100% to H4
H4 [ 0    0   1.0   0   ]   ← if H4 rejected: 100% to H3
```

## Reproducing the calculation

```r
library(graphicalMCP)

# Build the graph
g <- graph_create(
  hypotheses = c(H1 = 0.0125, H2 = 0.0125, H3 = 0, H4 = 0),
  transitions = matrix(c(0,   0.5, 0.5, 0,
                         0.5, 0,   0,   0.5,
                         0,   0,   0,   1,
                         0,   0,   1,   0), nrow = 4, byrow = TRUE,
                       dimnames = list(c("H1","H2","H3","H4"),
                                       c("H1","H2","H3","H4")))
)

# Sample size for primary (H2 at delta=0.40, alpha=0.0125 worst-case)
library(gsDesign)
nNormal(delta = 0.40, sd = 1.0, alpha = 0.0125, beta = 0.20, sided = 1)
# n per arm ≈ 235 → total 705 across 3 arms
```

## Caveats & teaching points

- **Initial weights sum to α (0.025).** They do NOT include the secondaries because secondaries start at 0 weight and become testable only after their primary prerequisites are rejected and alpha is recycled.
- **Rule-3 validator check.** The transition matrix must NOT route alpha to an already-rejected hypothesis. Our `validate_transition_matrix()` function applies this check; the canonical Maurer-Bretz example passes (alpha recycles forward, never backward to rejected nodes).
- **Worst-case α for sample-size calc.** The smallest alpha any one primary hypothesis is tested at is its initial weight (0.0125). Sample size is computed at this worst-case alpha to ensure power is preserved regardless of which path through the graph is taken.

## How this case validates clinical-trial-design

- Tests `design_graphical_multiplicity` with a 4-hypothesis transition matrix.
- Tests the Rule-3 transition-matrix validator (`validate_transition_matrix`).
- Validates that the agent recognizes a graphical procedure (vs alpha-split or fixed-sequence) and uses `graphicalMCP::graph_create`.
