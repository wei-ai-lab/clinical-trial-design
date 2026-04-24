# MONALEESA-7 (2017) — ribociclib in premenopausal HR+/HER2- advanced BC

**Family:** tte-nph · **Endpoint:** PFS · **N:** 672 · **Design feature:** CDK4/6i delayed-separation NPH

## Why this case is in the corpus

- **CDK4/6 inhibitor signature NPH** — cytostatic mechanism produces characteristic delayed separation.
- First Phase 3 of a CDK4/6i in premenopausal setting.
- Powered on PH-based HR despite known NPH pattern from PALOMA-2 class precedent.

## Citation

Tripathy D, Im SA, Colleoni M, et al. *Ribociclib plus endocrine therapy for premenopausal women with hormone-receptor-positive, advanced breast cancer (MONALEESA-7).* Lancet Oncol. 2018;19(7):904-915. doi:10.1016/S1470-2045(18)30292-4. NCT02278120.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1 |
| Population | Premenopausal HR+/HER2- advanced BC, 1L |
| Intervention | Ribociclib + NSAI/tam + goserelin |
| Control | Placebo + NSAI/tam + goserelin |
| Primary | Investigator-assessed PFS |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.67 (median PFS 12 → 17.9 mo) |
| Target events | ~329 |
| Planned N | ~672 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = log(2)/12, hr = 0.67,
  alpha = 0.025, beta = 0.10,
  R = 24, minfup = 24
)
```

## Trial outcome

- Investigator-assessed PFS: median **23.8 vs 13.0 months**; HR 0.553 (95% CI 0.441-0.694), p < 0.0001.
- BICR-assessed PFS: HR 0.427.
- OS at 42 months: HR 0.71, 95% CI 0.54-0.95 (significant at later analysis).
- Consistent across premenopausal/perimenopausal subgroups.

## How this case validates designr

- CDK4/6i NPH archetype — delayed separation with sustained divergence.
- Illustrates PH-based sizing that still yields conservative events under NPH.
- Premenopausal BC 1L reference.
