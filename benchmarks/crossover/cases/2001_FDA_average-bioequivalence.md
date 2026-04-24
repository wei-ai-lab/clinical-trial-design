# FDA (2001) — Statistical Approaches to Establishing Bioequivalence

**Family:** crossover · **Endpoint:** log-AUC + log-Cmax geometric mean ratio · **Design feature:** 2×2 crossover with TOST

## Why this case is in the corpus

- **Canonical regulatory crossover design** for generic drug bioequivalence.
- TOST (two one-sided tests) framework standard across FDA, EMA, ICH M13.
- Backbone design for thousands of ANDA generic approvals annually.

## Citation

U.S. Food and Drug Administration. *Guidance for Industry: Statistical Approaches to Establishing Bioequivalence.* CDER, January 2001.

## Design summary

| | |
|---|---|
| Design | 2-period 2-sequence 2×2 crossover |
| Subjects | Healthy adult volunteers (fasted standard) |
| Periods | T → R (sequence 1); R → T (sequence 2) |
| Washout | ≥ 5 elimination half-lives |
| Primary PK | log-AUC_inf and log-Cmax |
| Analysis | ANOVA with period + sequence + treatment + subject(sequence) |
| Success criterion | 90% CI for GMR within (0.80, 1.25) |
| α (TOST) | 0.05 one-sided × 2 |
| Power target | ≥ 0.80 |
| Typical N | 24-48 for CV_w 20-30% |

## Reproducing the design

```r
library(PowerTOST)
# Sample size for 2x2 BE
sampleN.TOST(
  CV = 0.25,          # within-subject CV on log-scale
  theta0 = 0.95,      # expected GMR
  theta1 = 0.80,      # lower BE limit
  theta2 = 1.25,      # upper BE limit
  targetpower = 0.80,
  design = "2x2"
)
```

Returns:
- Sample size N ≈ 26 per standard parameters.
- Expected power ≈ 0.80.

## Analysis recipe

```r
# Log-transform PK parameters
df$logAUC <- log(df$AUC)

library(nlme)
fit <- lme(
  logAUC ~ period + sequence + treatment,
  random = ~ 1 | subject,
  data = df
)
# 90% CI for treatment effect → back-transform to GMR scale
# GMR_CI = exp(CI_on_log)
```

## Key regulatory points

- **Acceptance limits** (0.80, 1.25) for both log-AUC and log-Cmax, each tested at 5% one-sided.
- **Narrow-therapeutic-index (NTI) drugs** (e.g., warfarin, digoxin): (0.90, 1.1111) with reference-scaled method.
- **Highly-variable drugs** (CV_w > 30%): scaled average bioequivalence (SABE) with widened limits proportional to σ_w,R.
- **Replicate designs** (2×3 partial, 2×4 full) for highly-variable drugs to estimate σ_w,R.
- **Pre-specified population**: fasted adults typically, fed separately if absorption impact.

## How this case validates designr

- Core regulatory crossover design reference.
- TOST sample-size formula backbone for `PowerTOST` R package.
- Bridges design framework to ICH M13, EMA, FDA guidance for BE.
