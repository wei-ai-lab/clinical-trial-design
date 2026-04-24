# FOURIER (2017) — evolocumab in atherosclerotic CVD

**Family:** group-sequential · **Endpoint:** TTE MACE composite · **N:** 27,564 · **Design feature:** 3-look OBF, ran to final

## Why this case is in the corpus

- Modern **large-scale secondary-prevention** CVOT with textbook GS design.
- Ran to final analysis — contrasts with early-stopped GS (RALES, JUPITER).
- Observed effect matched planned (HR 0.85) — teaching case for "well-calibrated assumption" outcomes.

## Citation

Sabatine MS, Giugliano RP, Keech AC, et al. *Evolocumab and clinical outcomes in patients with cardiovascular disease.* N Engl J Med. 2017;376(18):1713-1722. doi:10.1056/NEJMoa1615664. NCT01764633.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, GS |
| Arms | Evolocumab · Placebo (both on statin) |
| Primary endpoint | 5-component MACE |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.85 |
| Assumed control rate | ~4.5% per year |
| Spending | Lan-DeMets OBF, 3 looks at IF 0.50, 0.75, 1.0 |
| Target events | 1,630 |
| Planned N | 27,564 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k         = 3,
  test.type = 1,
  alpha     = 0.025, beta = 0.10,
  sfu       = sfLDOF,
  timing    = c(0.50, 0.75, 1.0),
  hr        = 0.85, hr0 = 1,
  lambdaC   = -log(1 - 0.045),
  R         = 24, minfup = 26, ratio = 1
)
# events ≈ 1,630; N ≈ 27,500
```

## What the trial found

- HR primary MACE = **0.85** (95% CI 0.79–0.92), p < 0.001.
- HR key secondary (CV death + MI + stroke) = 0.80.
- No mortality benefit in primary analysis (underpowered for mortality alone at this sample size and follow-up).

## Caveats & teaching points

- **Plan = truth here.** Designed HR 0.85 and observed HR 0.85 → textbook-calibrated assumption. Not common; most trials see either surprise benefit (stop early) or disappointment (fail).
- **Secondary endpoint hierarchy.** Key secondary (3-component MACE) provides sharper signal because of cleaner adjudication; often what drives guideline adoption.
- **Follow-up drives N.** At 4.5%/y × 26-month median follow-up, per-subject event probability ~10% — 27,500 subjects needed for 1,630 events under HR 0.85.

## How this case validates designr

- 3-look OBF GS running to completion.
- Large secondary-prevention scale.
- Benchmarks sample-size inflation cost over fixed design at matched HR/alpha/power.
