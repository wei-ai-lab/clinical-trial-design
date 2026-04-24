# ALCYONE (2017) — dara-VMP in newly diagnosed transplant-ineligible MM

**Family:** tte-nph · **Endpoint:** PFS · **N:** 706 · **Design feature:** anti-CD38 deep-response tail

## Why this case is in the corpus

- **Deep-response NPH** — anti-CD38 daratumumab produces MRD-negative subpopulation with long-tail PFS.
- Newly diagnosed transplant-ineligible MM 1L setting.
- Observed HR substantially below designed HR due to late-follow-up divergence.

## Citation

Mateos MV, Dimopoulos MA, Cavo M, et al. *Daratumumab plus bortezomib, melphalan, and prednisone for untreated myeloma.* N Engl J Med. 2018;378(6):518-528. doi:10.1056/NEJMoa1714678. NCT02195479.

## Design summary

| | |
|---|---|
| Design | Open-label RCT 1:1 |
| Population | Newly diagnosed MM, transplant-ineligible |
| Intervention | Dara + VMP (9 cycles) → dara maintenance |
| Control | VMP (9 cycles) |
| Primary | PFS |
| α / power | 0.05 (two-sided) / 0.85 |
| Assumed HR | 0.65 |
| Target events | ~330 |
| Planned N | ~700 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = log(2)/24, hr = 0.65,
  alpha = 0.025, beta = 0.15,
  R = 24, minfup = 30
)
```

## Trial outcome

- Median PFS: **not reached vs 18.1 months**; HR 0.50 (95% CI 0.38-0.65), p < 0.001.
- 18-month PFS rate: 71.6% vs 50.2%.
- MRD-negativity (10⁻⁵): 22% vs 6%.
- FDA approval May 2018.

## How this case validates designr

- Hematologic malignancy NPH archetype — deep-response tail divergence.
- Illustrates HR under-estimate conservatism under late-tail NPH.
- Newly diagnosed MM 1L reference design.
