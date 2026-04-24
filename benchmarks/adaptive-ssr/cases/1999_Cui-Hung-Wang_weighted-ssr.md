# Cui-Hung-Wang (1999) — weighted statistic for unblinded SSR

**Family:** adaptive-ssr · **Endpoint:** continuous (any) · **Design feature:** pre-specified weights preserve α under any N₂ choice

## Why this case is in the corpus

- **Canonical methodology** for unblinded SSR with strict Type-I preservation.
- The CHW weighted test is the foundation for modern unblinded SSR (including Mehta-Pocock promising zone and most rpact workflows).
- Cited in FDA adaptive-designs guidance as a Type-I-preserving approach.

## Citation

Cui L, Hung HMJ, Wang S-J. *Modification of sample size in group sequential clinical trials.* Biometrics. 1999;55(3):853-857. doi:10.1111/j.0006-341X.1999.00853.x.

## The method

Let `Z₁` be the first-stage z-statistic based on `n₁` subjects, and `Z₂*` be the second-stage z-statistic on the actual `n₂*` subjects after SSR. The CHW weighted statistic is:

```
Z = w₁ · Z₁ + w₂ · Z₂*
```

where `w₁ = √(n₁ / (n₁ + n₂))` and `w₂ = √(n₂ / (n₁ + n₂))` are **pre-specified** weights based on the *originally planned* `n₂`, not the actually-used `n₂*`.

By preserving the pre-specified weights, the null distribution of `Z` remains standard normal regardless of how `n₂*` was chosen — Type-I error is rigorously protected.

## Illustrative design (Phase 3 continuous endpoint)

| | |
|---|---|
| Endpoint | Mean Δ, SD σ (unknown) |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed Δ / σ | 0.5 / 1.0 (standardized effect 0.5) |
| Planned N | 86 (n₁ = 43, n₂ = 43) |
| Interim trigger | After n₁ = 43 subjects complete |
| SSR rule | If observed effect in "promising zone" (0.3–0.5 SD), increase n₂* up to a cap of 2× original |
| Test | CHW weighted z with weights √(43/86) on each stage |

## Reproducing the design

```r
library(rpact)
d <- getDesignGroupSequential(
  kMax = 2, alpha = 0.025, beta = 0.10,
  typeOfDesign = "OF"
)
ss <- getSampleSizeMeans(
  design = d,
  alternative = 0.5,
  stDev = 1.0,
  groups = 2
)
# getDataset + getAnalysisResults supports CHW-style continuation
```

## What the method guarantees

- **Type-I error preservation:** Under H₀, Z ~ N(0,1) exactly, regardless of the second-stage sample size.
- **Power recovery:** If interim data suggest effect is smaller than assumed, increasing n₂* up to a pre-specified cap recovers conditional power to a target (e.g., 80%).

## Caveats & teaching points

- **Loss of efficiency when effect is as-planned.** CHW weights are not optimal when the interim estimate matches the design assumption — the weighted test has slightly worse power than the unweighted test with the same final N.
- **Promising-zone refinement** (Mehta-Pocock 2011) addresses this by restricting SSR to cases where it actually helps — unpromising interim = stop or stay the course, not increase.
- **Regulators require** full pre-specification of the SSR rule including the promising-zone boundary, max N, and conditional-power target.

## How this case validates designr

- Core methodology benchmark — any designr SSR recommendation must honor CHW weighting.
- Reference implementation in `rpact::getAnalysisResults` and `rpact::getSampleSizeMeans`.
- Foundation for more modern methods in the corpus (Mehta-Pocock, Chen-DeMets-Lan).
