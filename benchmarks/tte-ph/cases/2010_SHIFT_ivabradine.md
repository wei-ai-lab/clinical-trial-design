# SHIFT (2010) — ivabradine in HFrEF with elevated heart rate

**Family:** tte-ph · **Endpoint:** TTE composite CV death + HF hospitalization · **N:** 6,558 · **Design feature:** heart rate as enrichment criterion

## Why this case is in the corpus

- **Physiological enrichment** — enrolled only HFrEF patients with HR ≥ 70 bpm, where ivabradine's HR-lowering mechanism is expected to work.
- Classic PH-TTE design in HF with a composite primary.
- Teaching case for **biomarker-like enrichment** at entry (not adaptive).

## Citation

Swedberg K, Komajda M, Böhm M, et al. *Ivabradine and outcomes in chronic heart failure (SHIFT): a randomised placebo-controlled study.* Lancet. 2010;376(9744):875-885. doi:10.1016/S0140-6736(10)61198-1. NCT02441218.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1 |
| Population | HFrEF LVEF ≤ 35%, NYHA II-IV, HR ≥ 70 bpm sinus rhythm |
| Arms | Ivabradine titrated to HR 50-60 bpm · Placebo |
| Primary endpoint | Composite: CV death + HF hospitalization |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.82 |
| Control annual rate | ~15% |
| Planned N | 6,500 |
| Target events | ~1,580 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(0.85), hr = 0.82,
  alpha = 0.025, beta = 0.10,
  R = 30, minfup = 22
)
```

## Trial outcome

- Median follow-up 22.9 months.
- Primary: HR **0.82** (95% CI 0.75-0.90), p < 0.0001 — matched design assumption exactly.
- HF hospitalization HR 0.74 was primary driver; CV death HR 0.91 was NS.

## How this case validates designr

- PH-TTE with composite endpoint.
- Baseline enrichment by physiological marker (HR).
- Design-to-outcome precision (observed HR = assumed HR).
