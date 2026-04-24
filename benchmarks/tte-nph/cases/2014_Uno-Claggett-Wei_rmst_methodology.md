# Uno-Claggett-Wei (2014) — RMST design methodology

**Family:** tte-nph · **Endpoint:** RMST difference at τ · **Design feature:** model-free NPH estimand

## Why this case is in the corpus

- **Canonical NPH methodology paper** for restricted mean survival time (RMST).
- Model-free causal estimand with interpretable units (months of survival gained).
- Near-equivalent power to log-rank under PH; superior under delayed effect.

## Citation

Uno H, Claggett B, Tian L, et al. *Moving beyond the hazard ratio in quantifying the between-group difference in survival analysis.* J Clin Oncol. 2014;32(22):2380-2385. doi:10.1200/JCO.2014.55.2208.

## Design summary

| | |
|---|---|
| Framework | Worked example — 2-arm RMST design |
| Primary estimand | Δ_RMST(τ) = RMST_E(τ) − RMST_C(τ) |
| τ | Pre-specified clinically meaningful horizon |
| Test statistic | Uno-Tian-Wei variance or perturbation resampling |
| α / power | 0.05 (two-sided) / 0.80 |
| Example RMST_C(36mo) | 18 months |
| Example RMST_E(36mo) | 22 months (Δ = 4 months) |
| Example N | ~550 (balanced 1:1) |

## Reproducing the design

```r
library(survRM2)
# Worked example uses simulation-based power calibration
set.seed(1)
# Simulate under piecewise-exponential with delayed effect
# Size by iterating N until power hits 0.80
```

Or `nphDesign` direct:

```r
library(nphDesign)
# Enrollment & hazard specification
# → RMST-based power and sample size
```

## Key methodology points

- **RMST advantage**: interpretable (months of life), valid under any NPH.
- **τ constraint**: τ ≤ min of last event times per arm; trial-level pre-specification matters.
- **Variance**: Uno et al. closed-form; or resampling/perturbation for robustness.
- **Under PH**: RMST power ≈ log-rank power.
- **Under delayed effect**: RMST power > log-rank power — delayed-effect signal fully captured by late cumulative difference.

## How this case validates designr

- Reference implementation for the RMST design family.
- Model-free NPH estimand — increasingly standard in regulatory submissions (ICH E9(R1) estimand framework).
- Provides worked-example numbers for sample-size validation.
