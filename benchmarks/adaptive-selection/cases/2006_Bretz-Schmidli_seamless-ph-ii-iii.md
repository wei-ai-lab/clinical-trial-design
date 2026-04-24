# Bretz-Schmidli (2006) — confirmatory seamless Phase II/III with hypothesis selection

**Family:** adaptive-selection · **Endpoint:** any · **Design feature:** combination test framework for flexible hypothesis selection; strong FWER control

## Why this case is in the corpus

- **General framework** for combining hypothesis selection with confirmatory Phase 3 — not limited to single-best-arm selection; supports selecting subsets of arms, doses, or hypotheses.
- **Combination test** with closure principle rigorously controls strong FWER across all possible selections.
- Widely cited as the canonical reference for regulatory-acceptable seamless Phase II/III.

## Citation

Bretz F, Schmidli H, König F, Racine A, Maurer W. *Confirmatory seamless phase II/III clinical trials with hypotheses selection at interim: general concepts.* Biometrical Journal. 2006;48(4):623-634. doi:10.1002/bimj.200510232.

## The framework

Let H = {H₁, H₂, ..., H_K} be K hypotheses (e.g., arm k vs control for k = 1...K). Design proceeds:

1. **Stage 1** — randomize to all K arms + control. Observe partial data.
2. **Hypothesis selection at interim** — based on any pre-specified data-driven rule, select a subset S ⊆ {1,...,K} of hypotheses to continue.
3. **Stage 2** — randomize to selected arms + control.
4. **Final test for each H_k ∈ S**:
   - Compute weighted p-value combining stage-1 and stage-2 data.
   - Apply **closed testing principle**: reject H_k only if all intersection hypotheses containing H_k are rejected at α.
   - This guarantees strong FWER ≤ α regardless of selection rule.

## Illustrative Phase 3 design

| | |
|---|---|
| Endpoint | Continuous change from baseline |
| K arms | 4 doses + placebo |
| α / power | 0.05 (two-sided), 0.85 for max-dose vs placebo |
| Selection | Drop ≥ 2 lowest-performing doses at stage 1 |
| Stage 1 N | 200 (40 per arm × 5 arms) |
| Stage 2 N | 200 (retained arms + placebo) |
| Combination weights | Inverse-normal, w₁ = w₂ = √(1/2) |

## Reproducing the design

```r
library(rpact)
d <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.15,
  typeOfDesign = "OF"
)
# At interim, use getDataSet to combine stage-1 + stage-2 data for retained arms
# Apply closed testing for strong FWER
```

## α-control mechanics

For K = 3 arms and closed testing, 2³ − 1 = 7 intersection hypotheses must be tested. Each uses the combination p-value (inverse-normal weighted) and is rejected at α = 0.025 (one-sided). Strong FWER ≤ α.

With graphical multiplicity (Bretz-Maurer 2009), α can be recycled between hypotheses when one is rejected, improving power without sacrificing FWER.

## What the framework enables

- **Flexible selection** — not just "pick best"; any pre-specified rule (drop-worst, top-2, posterior probability, etc.) is acceptable.
- **Strong FWER** — guaranteed regardless of selection outcome.
- **Confirmatory status** — regulators accept this as a pivotal Phase 3 since α is strictly controlled.

## Caveats & teaching points

- **Closed testing is computationally heavy** — for K arms, 2^K − 1 intersection tests are required. Simplifications exist for specific selection rules.
- **Weights must be pre-specified** — changing weights post-interim inflates α. Most practical choices: w₁ = w₂ = √(1/2) for equal stages, or w₁ = √(n₁/N), w₂ = √(n₂/N) for planned-N weights.
- **Selection rule should be simple and justifiable** — sponsors writing "DSMB discretion" get pushback; pre-specified deterministic rules (pick arm with max z) are accepted.

## How this case validates designr

- Canonical reference for seamless Phase II/III with flexible selection.
- Benchmark for combination test + closed testing workflow.
- Foundation for rpact's multi-arm adaptive design support.
