# HPS (2002) — Heart Protection Study simvastatin

**Family:** tte-ph · **Endpoint:** TTE all-cause mortality + vascular events · **N:** 20,536 · **Design feature:** large PH trial in broad at-risk population

## Why this case is in the corpus

- **Largest statin Phase 3** — 20,536 patients, broad at-risk population (CAD, diabetes, PVD, stroke).
- Established **benefit across baseline LDL** — even patients with LDL < 100 mg/dL benefited.
- Factorial arm for antioxidants (vitamin E + C + β-carotene) tested simultaneously.

## Citation

Heart Protection Study Collaborative Group. *MRC/BHF Heart Protection Study of cholesterol lowering with simvastatin in 20,536 high-risk individuals: a randomised placebo-controlled trial.* Lancet. 2002;360(9326):7-22.

## Design summary

| | |
|---|---|
| Design | RDBPC, 2×2 factorial |
| Population | Adults 40-80 at high CV risk (CHD, stroke, PVD, or diabetes) |
| Arms | Simvastatin 40 mg ± antioxidants · Placebo ± antioxidants |
| Primary endpoints | (1) all-cause mortality (statin); (2) CHD death (antioxidants) |
| α / power | 0.01 statin primary (pre-specified stringent) / 0.95 |
| Assumed HR | 0.80 statin |
| Planned N | 20,000 |
| Planned follow-up | 5 y |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(0.88)/5, hr = 0.80,
  alpha = 0.005, beta = 0.05,
  R = 24, minfup = 60
)
```

## Trial outcome

- Mean follow-up 5 y.
- All-cause mortality: HR **0.87** (95% CI 0.81-0.94), 13% relative reduction.
- Major vascular events: HR 0.76, 24% RRR.
- Antioxidants: no benefit.
- Changed secondary prevention for all at-risk patients.

## How this case validates designr

- Large-scale PH design.
- Factorial design with separate α-allocation to each arm's primary.
- Stringent α (0.01) to ensure robust claim.
