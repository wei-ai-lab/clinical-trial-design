# IDNT (2003) — irbesartan in type 2 diabetic nephropathy

**Family:** tte-ph · **Endpoint:** TTE renal composite · **N:** 1,715 · **Design feature:** 3-arm renal endpoint trial (ARB vs CCB vs placebo)

## Why this case is in the corpus

- **Three-arm PH-TTE design** — irbesartan vs amlodipine vs placebo — with pairwise PH superiority testing.
- Companion to RENAAL for ARB renoprotection; together established class effect in diabetic nephropathy.

## Citation

Lewis EJ, Hunsicker LG, Clarke WR, et al. *Renoprotective effect of the angiotensin-receptor antagonist irbesartan in patients with nephropathy due to type 2 diabetes.* N Engl J Med. 2001;345(12):851-860. doi:10.1056/NEJMoa011303.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1:1 |
| Population | T2D with nephropathy |
| Arms | Irbesartan 300 mg · Amlodipine 10 mg · Placebo |
| Primary endpoint | Composite: doubling of serum Cr + ESRD + death |
| α / power | 0.05 (two-sided) with Hochberg multiplicity across 2 comparisons |
| Assumed HR | 0.70 (irbesartan vs placebo) |
| Planned N | 1,700 |
| Target events | ~700 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(0.55)/3.5, hr = 0.70,
  alpha = 0.025, beta = 0.10,
  R = 18, minfup = 30
)
```

## Trial outcome

- Mean follow-up 2.6 years.
- Irbesartan vs placebo: HR **0.80** (95% CI 0.66-0.97), 20% RRR.
- Amlodipine vs placebo: HR 1.04 (no benefit).
- ARB-class effect confirmed renoprotection beyond BP.

## How this case validates designr

- Three-arm PH design with Hochberg multiplicity.
- Renal composite endpoint pattern.
