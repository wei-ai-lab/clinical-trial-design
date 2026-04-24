# CheckMate-057 (2015) — nivolumab vs docetaxel in non-squamous NSCLC

**Family:** group-sequential-nph · **Endpoint:** TTE OS · **N:** 582 · **Design feature:** crossing hazards (early harm + late benefit)

## Why this case is in the corpus

- **Crossing-curves NPH** — KM curves cross around 6-7 months, violating PH assumption stringently.
- **Post-hoc subgroup analysis** showed PD-L1 ≥ 1% drove benefit, with PD-L1 < 1% having essentially no effect or early harm.
- Teaching case for **pre-specified test selection** mattering to trial interpretation.

## Citation

Borghaei H, Paz-Ares L, Horn L, et al. *Nivolumab versus docetaxel in advanced nonsquamous non-small-cell lung cancer.* N Engl J Med. 2015;373(17):1627-1639. doi:10.1056/NEJMoa1507643. NCT01673867.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Open-label, 1:1, GS (single planned interim) |
| Population | Pre-treated non-squamous NSCLC, progression after platinum |
| Arms | Nivolumab 3 mg/kg q2w · Docetaxel 75 mg/m² q3w |
| Primary endpoint | OS |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.70 |
| Spending | Lan-DeMets OBF α |
| Planned looks | 1 interim + final |
| Planned N | 582 |
| Target events | 413 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 2, test.type = 2,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF,
  hr = 0.70, hr0 = 1,
  lambdaC = -log(0.5)/8,    # control median OS 8 months
  R = 18, minfup = 18, ratio = 1
)
# events ≈ 413, N ≈ 582
```

## What the trial found

- Overall HR **0.73** (95% CI 0.59–0.89), median OS 12.2 vs 9.4 mo.
- **KM crossing** at ~6 months — docetaxel did better in the first months, then nivolumab pulled ahead with a long tail.
- PD-L1 ≥ 1%: HR 0.59 (strong benefit); PD-L1 < 1%: HR 0.90 (borderline, early harm dominant).
- Log-rank was marginally positive; had weighted log-rank (Fleming-Harrington G(0,1), upweighting late events) been used, the p-value would have been stronger.

## Caveats & teaching points

- **Crossing hazards + log-rank = under-powered.** If the design team had anticipated crossing, a Fleming-Harrington weighted log-rank or max-combo test would have been more powerful and less equivocal at interim.
- **Biomarker enrichment emerged post-hoc.** Ideally the trial would have been powered within PD-L1 ≥ 1% subgroup, or required co-primary testing across PD-L1 strata. CheckMate-057 design pre-dated consensus on PD-L1-based selection.
- **Interim at IF = 0.75 was not triggered** — DSMB could not confidently stop given crossing-curves pattern, deferred to final.

## How this case validates designr

- NPH crossing-curves design and test-selection decision.
- Post-hoc biomarker subgroup analysis and its impact on labeling.
- Agent reasoning about when weighted LR or max-combo should be pre-specified.
