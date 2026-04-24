# SOLVD-Treatment (1991) — enalapril in symptomatic HFrEF

**Family:** tte-ph · **Endpoint:** TTE all-cause mortality · **N:** 2,569 · **Design feature:** foundational HF mortality trial establishing ACEi benefit

## Why this case is in the corpus

- **First large mortality trial for ACEi in HF** — defined SOC for HFrEF for decades.
- Classic PH-assumption TTE design.
- Teaching reference for HF mortality endpoint trials.

## Citation

SOLVD Investigators. *Effect of enalapril on survival in patients with reduced left ventricular ejection fractions and congestive heart failure.* N Engl J Med. 1991;325(5):293-302. doi:10.1056/NEJM199108013250501.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1 |
| Population | Symptomatic HF, LVEF ≤ 0.35 |
| Arms | Enalapril 2.5-20 mg bid · Placebo |
| Primary endpoint | All-cause mortality |
| α / power | 0.05 (two-sided) / 0.80 |
| Assumed HR | 0.78 |
| Control 3-yr mortality | ~40% |
| Planned N | 2,500 |
| Target deaths | ~900 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(0.60)/3, hr = 0.78,
  alpha = 0.025, beta = 0.20,
  R = 18, minfup = 36
)
```

## Trial outcome

- Mean follow-up 41 months.
- All-cause mortality: HR **0.84** (95% CI 0.74-0.95), 16% relative reduction.
- HF hospitalization: 26% reduction.
- Established ACEi as standard HFrEF therapy.

## How this case validates designr

- Foundational HF mortality PH-TTE trial.
- Historical reference for mortality-event-rate assumptions in HF design.
