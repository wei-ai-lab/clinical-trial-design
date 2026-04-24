# IMpower150 (2018) — atezolizumab + bev + chemo in first-line non-squamous NSCLC

**Family:** group-sequential-nph · **Endpoint:** TTE PFS + OS · **N:** 1,202 · **Design feature:** three-arm ABCP vs ACP vs BCP with complex hierarchical testing

## Why this case is in the corpus

- **Three-arm combo design** — A (atezo) + B (bevacizumab) + C (carbo) + P (pac) vs BCP vs ACP. Each pairwise comparison carries its own α-allocation via a graphical multiplicity scheme.
- **EGFR/ALK+ subgroup inclusion** — allowed for patients after TKI progression, contributing to NPH due to heterogeneous prior-treatment response.
- Teaching case for **multi-arm graphical α-propagation** under NPH.

## Citation

Socinski MA, Jotte RM, Cappuzzo F, et al. *Atezolizumab for first-line treatment of metastatic nonsquamous NSCLC.* N Engl J Med. 2018;378(24):2288-2301. doi:10.1056/NEJMoa1716948. NCT02366143.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Open-label, 1:1:1, GS |
| Population | Untreated stage IV non-squamous NSCLC, including EGFR/ALK+ post-TKI |
| Arms | ABCP (atezo + bev + carbo + pac) · ACP · BCP |
| Primary endpoints | PFS + OS in ITT-WT (EGFR/ALK WT), hierarchical ABCP vs BCP |
| α / power | 0.05 (two-sided), split across ITT-WT and Teff-high subgroups, ~0.85 power per primary |
| Assumed HR | PFS 0.70 · OS 0.78 |
| Spending | Lan-DeMets OBF α per primary; graphical α-recycling |
| Planned looks | 2 PFS + 3 OS |
| Planned N | 1,200 |
| Target PFS events | ~570 ITT-WT |

## Reproducing the design

```r
library(gsDesign)
d_pfs <- gsSurv(
  k = 2, test.type = 2,
  alpha = 0.025, beta = 0.15,
  sfu = sfLDOF,
  hr = 0.70, hr0 = 1,
  lambdaC = -log(0.5)/7,
  R = 18, minfup = 18, ratio = 1   # 1:1 ABCP vs BCP (ITT-WT)
)
# events ≈ 570, N per comparison ≈ 800
```

## What the trial found

- PFS ITT-WT (ABCP vs BCP): HR **0.62** (95% CI 0.52–0.74), median 8.3 vs 6.8 mo.
- OS ITT-WT: HR **0.78** (95% CI 0.64–0.96), median 19.2 vs 14.7 mo.
- EGFR/ALK+ subgroup (not formally alpha-protected but pre-specified): HR improvements observed.
- Approved in US/EU for ABCP regimen.

## Caveats & teaching points

- **Graphical multiplicity with Bretz-Maurer-style α-recycling** — unused α from failed tests cascades to downstream tests per a pre-specified graph. Allows complex multi-arm / multi-endpoint / multi-population designs to maintain strong family-wise type I error control.
- **Three-arm design complicates NPH reasoning** — each pairwise comparison may have different NPH pattern. Bev+chemo vs chemo comparison approximates PH; adding atezo makes it delayed-effect.
- **Subgroup benefit reporting** — EGFR/ALK+ observed benefit driving label expansion, but formal α-control for that subgroup was weaker.

## How this case validates designr

- Multi-arm Phase 3 IO combo with complex graphical α.
- Graphical multiplicity benchmark.
- Subpopulation testing within an all-comers trial.
