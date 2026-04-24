# RALES (1999) — spironolactone in severe heart failure

**Family:** group-sequential · **Endpoint:** TTE all-cause mortality · **N:** 2,500 · **Design feature:** Lan-DeMets OBF, stopped at 2nd interim

## Why this case is in the corpus

- **Classic group-sequential trial** stopped early for efficacy — one of the most-cited examples of successful GS stopping in heart failure.
- Established mineralocorticoid-receptor antagonists as standard of care in severe HFrEF.
- Teaching case for Lan-DeMets OBF spending and interpreting early-stop results.

## Citation

Pitt B, Zannad F, Remme WJ, et al. *The effect of spironolactone on morbidity and mortality in patients with severe heart failure.* N Engl J Med. 1999;341(10):709-717. doi:10.1056/NEJM199909023411001.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, group-sequential |
| Arms | Spironolactone 25 mg · Placebo |
| Primary endpoint | All-cause mortality |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.80 |
| Assumed control mortality rate | ~25% per year |
| Spending function | Lan-DeMets approximation of O'Brien-Fleming |
| Planned analyses | 3 total (2 interim + 1 final) at IF 0.33, 0.67, 1.0 |
| Target events | ~690 |
| Planned N | 2,500 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k        = 3,
  test.type = 1,                      # efficacy-only
  alpha    = 0.025,
  beta     = 0.10,
  sfu      = sfLDOF,                  # Lan-DeMets OBF
  hr       = 0.80, hr0 = 1,
  lambdaC  = -log(1 - 0.25),          # 25%/y
  R        = 24, minfup = 12,
  ratio    = 1
)
summary(d)
# Expect ~690 events total, boundaries ~z = 3.71 / 2.62 / 2.03
```

## What the trial found

- Stopped at the second planned interim analysis based on DSMB recommendation.
- HR for all-cause mortality = **0.70** (95% CI 0.60–0.82), p < 0.001.
- 30% reduction in all-cause mortality — a dramatic effect.
- Established spironolactone as standard of care in NYHA III-IV HFrEF.

## Caveats & teaching points

- **Effect larger than assumed.** Designed for HR 0.80, observed 0.70. This made the OBF boundary easier to cross at the second look despite the conservative spending.
- **Stopping boundary shape.** OBF z-boundaries start very high (3.71 at IF=0.33) and relax toward the final (2.03 at IF=1.0). Stopping at IF=0.67 requires z > 2.62 — still a high bar.
- **Point estimate after early stop is biased.** Observed HR = 0.70 likely overestimates the true effect due to selection by the stopping rule. Unbiased estimation requires adjustment (e.g. repeated-CI, bias-corrected estimator).

## How this case validates designr

- Canonical Lan-DeMets OBF design.
- Agent interpretation of early-stop results and the bias issue in point-estimation.
- Connection between assumed and observed effects in GS outcomes.
