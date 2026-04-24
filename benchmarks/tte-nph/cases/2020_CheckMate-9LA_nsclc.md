# CheckMate 9LA (2020) — nivo+ipi+chemo in 1L NSCLC

**Family:** tte-nph · **Endpoint:** OS · **N:** 719 · **Design feature:** IO+chemo dual-mechanism to mitigate delayed effect

## Why this case is in the corpus

- **Dual-mechanism design** — 2 cycles chemo provide early cytotoxic effect while IO kicks in after typical 3-6 month delay.
- Pragmatically powered on log-rank despite anticipated NPH.
- **"Early + late"** coverage is a now-common strategy in 1L IO trials.

## Citation

Paz-Ares L, Ciuleanu TE, Cobo M, et al. *First-line nivolumab plus ipilimumab combined with two cycles of chemotherapy in patients with non-small-cell lung cancer (CheckMate 9LA).* Lancet Oncol. 2021;22(2):198-211. doi:10.1016/S1470-2045(20)30641-0. NCT03215706.

## Design summary

| | |
|---|---|
| Design | Open-label RCT 1:1 |
| Population | 1L stage IV NSCLC, no EGFR/ALK |
| Intervention | Nivo + ipi + 2 cycles chemo |
| Control | 4 cycles chemo ± pemetrexed maintenance |
| Primary | Overall survival |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.74 |
| Target events | ~435 |
| Planned N | ~719 |
| Interim | Pre-planned at ~75% info |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = log(2)/12, hr = 0.74,
  alpha = 0.025, beta = 0.10,
  R = 24, minfup = 18
)
# GS with Lan-DeMets OBF at 75% info
```

## Trial outcome

- Median OS: **15.8 vs 11.0 months** → HR 0.69 (95% CI 0.55-0.87), p = 0.00065.
- Superiority met at pre-planned interim (Oct 2019 data cutoff).
- PFS HR 0.70; ORR 38% vs 25%.
- FDA approval May 2020 (accelerated for all-comer NSCLC 1L).

## How this case validates designr

- NPH design powered on log-rank with dual-mechanism rationale.
- 1L NSCLC reference case for IO+chemo combo trials.
- Group-sequential with OBF at OS interim.
