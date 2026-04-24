# RENAAL (2001) — losartan in type 2 diabetic nephropathy

**Family:** tte-ph · **Endpoint:** TTE renal composite · **N:** 1,513 · **Design feature:** renal endpoint with PH assumption

## Why this case is in the corpus

- **Renal progression endpoint** — PH-TTE design for doubling of serum creatinine, ESRD, or death.
- Landmark trial for ARBs in diabetic nephropathy.
- Non-cardiovascular PH endpoint.

## Citation

Brenner BM, Cooper ME, de Zeeuw D, et al. *Effects of losartan on renal and cardiovascular outcomes in patients with type 2 diabetes and nephropathy.* N Engl J Med. 2001;345(12):861-869. doi:10.1056/NEJMoa011161. NCT00308347.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1 |
| Population | T2D + nephropathy (proteinuria ≥ 0.5 g/d, serum Cr 1.3-3.0 mg/dL) |
| Arms | Losartan 50-100 mg · Placebo (both on antihypertensives as needed) |
| Primary endpoint | Composite: doubling of serum creatinine + ESRD + death |
| α / power | 0.05 (two-sided) / 0.92 |
| Assumed HR | 0.75 |
| Assumed control event rate | ~47% at 3.5 y |
| Planned N | 1,500 |
| Target events | ~660 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(0.53)/3.5, hr = 0.75,
  alpha = 0.025, beta = 0.08,
  R = 18, minfup = 24
)
```

## Trial outcome

- Primary: HR **0.84** (95% CI 0.72-0.98), 16% relative reduction.
- ESRD alone: HR 0.72.
- Became SOC for T2D nephropathy; established renoprotection beyond BP effect.

## How this case validates designr

- Renal TTE-PH benchmark.
- Composite endpoint (renal + mortality) handling.
