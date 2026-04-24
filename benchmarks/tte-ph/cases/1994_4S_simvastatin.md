# 4S (1994) — Scandinavian Simvastatin Survival Study

**Family:** tte-ph · **Endpoint:** TTE all-cause mortality · **N:** 4,444 · **Design feature:** landmark PH design establishing statin survival benefit

## Why this case is in the corpus

- **First Phase 3 to prove mortality reduction with lipid lowering** — changed cardiology practice worldwide.
- Classic PH-assumption secondary-prevention trial.
- Teaching case for **mortality as primary endpoint with TTE-PH design**.

## Citation

Scandinavian Simvastatin Survival Study Group. *Randomised trial of cholesterol lowering in 4444 patients with coronary heart disease: the Scandinavian Simvastatin Survival Study (4S).* Lancet. 1994;344(8934):1383-1389.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1 |
| Population | CHD (prior MI or angina), total cholesterol 5.5-8.0 mmol/L |
| Arms | Simvastatin 20-40 mg · Placebo |
| Primary endpoint | All-cause mortality |
| α / power | 0.05 (two-sided) / 0.95 |
| Assumed HR | 0.70 |
| Assumed 5-yr mortality | 10.5% placebo |
| Spending | None (single end-of-study, planned median 5 y follow-up) |
| Planned N | 4,400 |
| Target deaths | 440 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(1 - 0.10)/5, hr = 0.70,
  alpha = 0.025, beta = 0.05,
  R = 24, minfup = 36
)
# events ≈ 440, N ≈ 4400
```

## Trial outcome

- Median follow-up 5.4 years.
- All-cause mortality: **HR 0.70** (95% CI 0.58-0.85), 30% relative reduction.
- CHD mortality: HR 0.58. Revascularization: HR 0.63.
- Became SOC for secondary prevention.

## How this case validates designr

- Foundational PH-mortality benchmark.
- Simple single-analysis TTE design.
