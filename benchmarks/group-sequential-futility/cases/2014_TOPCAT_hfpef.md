# TOPCAT (2014) — spironolactone in HFpEF

**Family:** group-sequential-futility · **Endpoint:** TTE composite · **N:** 3,445 · **Design feature:** GS with futility that was never crossed; regional conduct controversy

## Why this case is in the corpus

- GS with pre-specified futility but **trial ran to final** despite marginal trajectory.
- **Regional-conduct controversy** (Russia/Georgia adherence issues) — illustrates that design integrity ≠ trial integrity.
- Teaching case for the limits of pre-specified analysis when regional heterogeneity arises post-hoc.

## Citation

Pitt B, Pfeffer MA, Assmann SF, et al. *Spironolactone for heart failure with preserved ejection fraction.* N Engl J Med. 2014;370(15):1383-1392. doi:10.1056/NEJMoa1313731. NCT00094302.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, GS with non-binding futility |
| Population | HFpEF, LVEF ≥ 45% |
| Arms | Spironolactone · Placebo |
| Primary endpoint | CV death + aborted cardiac arrest + HF hospitalization |
| α / power | 0.05 (two-sided) / 0.80 |
| Assumed HR | 0.80 |
| Assumed control rate | ~7%/y |
| Spending | Lan-DeMets OBF (α) + HSD γ=−2 (β, non-binding) |
| Planned N | 3,445 |
| Target events | 631 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 3, test.type = 4,
  alpha = 0.025, beta = 0.20,
  sfu = sfLDOF, sfl = sfHSD, sflpar = -2,
  hr = 0.80, hr0 = 1,
  lambdaC = -log(1 - 0.07),
  R = 48, minfup = 39, ratio = 1
)
# N ≈ 3,400, events ≈ 630
```

## What the trial found

- HR primary = **0.89** (95% CI 0.77–1.04), p = 0.14 — primary negative.
- Regional analysis: Americas HR 0.82 (95% CI 0.69–0.98); Russia/Georgia HR 1.10 (0.79–1.51).
- Subsequent metabolite-level analyses showed plausible non-adherence in Russia/Georgia sites.
- Regulators refused HFpEF label expansion.

## Caveats & teaching points

- **Futility not crossed.** Pre-specified futility z-boundary at IF=0.75 was ~1.35; observed statistic near 2.0 → no futility stop, trial continued.
- **Regional heterogeneity ≠ design question.** GS design does not pre-specify regional subgroup analyses at the efficacy-stopping level. Post-hoc regional patterns do not trigger α adjustment.
- **Conduct risk matters more than design refinement.** TOPCAT illustrates that a beautifully designed GS can still produce ambiguous regulatory outcomes if conduct varies.

## How this case validates designr

- Asymmetric GS with futility that never fires.
- Agent reasoning about when regional heterogeneity should prompt design-stage mitigation (stratification, site quality requirements) vs post-hoc analysis.
- Handling marginal results: how to interpret primary p = 0.14 when pre-specified subgroup patterns emerge.
