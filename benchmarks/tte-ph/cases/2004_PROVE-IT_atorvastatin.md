# PROVE-IT (2004) — atorvastatin 80 vs pravastatin 40 post-ACS

**Family:** tte-ph · **Endpoint:** TTE composite MACE · **N:** 4,162 · **Design feature:** intensive vs moderate statin head-to-head

## Why this case is in the corpus

- **Active-active head-to-head** design — intensive (atorvastatin 80) vs moderate (pravastatin 40) statin after ACS.
- Established "lower is better" LDL principle.
- Post-ACS high-event-rate design enables smaller N.

## Citation

Cannon CP, Braunwald E, McCabe CH, et al. *Intensive versus moderate lipid lowering with statins after acute coronary syndromes.* N Engl J Med. 2004;350(15):1495-1504. doi:10.1056/NEJMoa040583. NCT00382460.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1 active-active |
| Population | Post-ACS (< 10 days), stable |
| Arms | Atorvastatin 80 mg · Pravastatin 40 mg |
| Primary endpoint | Composite MACE: death + MI + UA + revasc + stroke |
| α / power | 0.05 (two-sided) / 0.95 |
| Design goal | Non-inferiority margin 17% RRR, upgraded to superiority if observed |
| Assumed HR | 0.80 (intensive vs moderate) |
| Planned N | 4,000 |
| Target events | ~925 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(0.75)/2, hr = 0.80,
  alpha = 0.025, beta = 0.05,
  R = 18, minfup = 18
)
```

## Trial outcome

- Median follow-up 24 months.
- Primary: HR **0.84** (95% CI 0.74-0.95), p = 0.005 (superiority met).
- LDL at 30 d: atorvastatin 62 vs pravastatin 95 mg/dL.
- Result established intensive statin as post-ACS SOC.

## How this case validates designr

- Active-active head-to-head PH design.
- Pre-specified NI-to-superiority pathway.
- High-event-rate ACS population trial sizing.
