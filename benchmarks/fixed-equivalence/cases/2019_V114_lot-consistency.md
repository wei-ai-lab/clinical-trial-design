# V114 lot-consistency (2019) — pneumococcal vaccine three-lot equivalence

**Family:** fixed-equivalence · **Endpoint:** continuous log-GMC ratio · **N:** 1,710 · **Design feature:** three-arm pairwise equivalence, vaccine lot-consistency

## Why this case is in the corpus

- **Three-arm pairwise-equivalence design** — a structure unique to vaccine lot-consistency trials.
- **Log-scale GMC ratio** endpoint with multiplicative margin [2/3, 3/2].
- **Multiplicity across serotypes** — V114 has 15 serotypes, each tested for consistency pairwise across 3 lots = 45 comparisons, all must pass.

## Citation

Hammitt LL, Quinn D, Janczewska E, et al. *Phase 3 randomized trial to evaluate lot-to-lot consistency of V114, a 15-valent pneumococcal conjugate vaccine, in healthy adults.* Vaccine. 2022;40(36):5326-5332. doi:10.1016/j.vaccine.2022.07.040. NCT03950856.

## Design summary

| | |
|---|---|
| Phase | 3 (manufacturing) |
| Design | Randomized, double-blind, three-arm 1:1:1 |
| Arms | Three manufacturing lots (A, B, C) of V114 |
| Primary endpoint | Serotype-specific IgG GMC at 30 days post-vaccination |
| Comparison | Pairwise equivalence on log GMC ratio, bounds ±log(1.5) ≈ [2/3, 3/2] |
| α / power | 0.05 (two-sided) / 0.90 per pairwise test per serotype |
| Multiplicity | Bonferroni across serotypes within pairwise; all pairs must meet |
| Planned N | 1,710 (570 per lot) |

## Reproducing the calculation

For log-scale TOST, margin ±log(1.5), SD(log GMC) ≈ 0.8, two-arm comparison:

```r
library(PowerTOST)
sampleN.TOST(alpha = 0.05, targetpower = 0.90,
             theta0 = 0, theta1 = -log(1.5), theta2 = log(1.5),
             CV = 0.8, design = "parallel")
# n per arm ≈ 150
```

Three-arm pairwise requires full N per arm contributing to each of 3 comparisons (A-B, A-C, B-C); N per arm ≈ 570 enables ~0.90 power per comparison after Bonferroni across serotypes.

## What the trial found

- All 45 pairwise serotype-specific GMC ratios had 90% CI bounds within [2/3, 3/2].
- Lot consistency demonstrated.
- Supported BLA for V114 (Vaxneuvance, approved 2021).

## Caveats & teaching points

- **Multiplicity is expensive.** 45 comparisons at Bonferroni α' = 0.05/45 ≈ 0.001 per test — dramatically inflates required per-arm N vs a single-serotype TOST.
- **Efficient alternatives exist but are rarely accepted.** Max-type global tests or hierarchical testing chains could preserve α with less N, but regulators typically prefer the conservative Bonferroni for CMC/manufacturing consistency.
- **Lot-consistency ≠ vaccine efficacy.** This trial demonstrates manufacturing reproducibility; a separate Phase 3 efficacy trial demonstrates vaccine performance.

## How this case validates designr

- Multi-arm pairwise equivalence design.
- Log-scale TOST with multiplicative margins.
- Bonferroni multiplicity handling across an endpoint panel (multiple serotypes).
