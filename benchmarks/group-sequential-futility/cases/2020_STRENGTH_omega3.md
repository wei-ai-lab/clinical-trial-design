# STRENGTH (2020) — omega-3 CA vs corn oil in high-risk CVD

**Family:** group-sequential-futility · **Endpoint:** TTE MACE · **N:** 13,078 · **Design feature:** stopped for futility via conditional power

## Why this case is in the corpus

- **Futility-stopped modern CVOT** via conditional power < 5% — the increasingly standard futility trigger.
- **Counter-example to REDUCE-IT** with different placebo (corn oil vs mineral oil) — fueling the placebo-bioactivity debate in CV lipid trials.
- Large and well-powered; futility stop came late (IF ~0.90) after the trajectory was clearly flat.

## Citation

Nicholls SJ, Lincoff AM, Garcia M, et al. *Effect of high-dose omega-3 fatty acids vs corn oil on major adverse cardiovascular events in patients at high cardiovascular risk: the STRENGTH randomized clinical trial.* JAMA. 2020;324(22):2268-2280. doi:10.1001/jama.2020.22258. NCT02104817.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, GS with non-binding futility |
| Arms | Omega-3 CA 4 g · Corn oil placebo |
| Primary endpoint | 5-component MACE |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.85 |
| Control rate | ~5.5% per year |
| Spending | Lan-DeMets OBF + HSD β (non-binding) + DSMB-discretion CP monitoring |
| Planned looks | 2 interim + final |
| Planned N | 13,078 |
| Target events | ~1,600 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 3, test.type = 4,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF,
  sfl = sfHSD, sflpar = -2,
  hr = 0.85, hr0 = 1,
  lambdaC = -log(1 - 0.055),
  R = 36, minfup = 42, ratio = 1
)
# N ≈ 13,000, events ≈ 1,600
```

## What the trial found

- Stopped at IF ~0.90 for futility.
- HR primary = **0.99** (95% CI 0.90–1.09), p = 0.84 at stop.
- Conditional power for reaching efficacy at final analysis < 5% under observed trend.
- No benefit for omega-3 CA on MACE — contrasted sharply with REDUCE-IT (HR 0.75 for icosapent ethyl vs mineral oil).

## Caveats & teaching points

- **Two trials, two placebos, opposite results.** REDUCE-IT showed 25% RRR with mineral oil placebo; STRENGTH showed no benefit with corn oil placebo. Interpretation: at least one of (a) mineral oil is pro-inflammatory harming placebo arm or (b) omega-3 CA ≠ icosapent ethyl pharmacologically. Active dispute remains.
- **Conditional power criterion.** CP < 5% under assumed HR is a reasonable futility trigger; under observed HR it's often stricter (becomes futile faster). Sponsor should pre-specify *which* CP.
- **Late futility stop is still valuable.** At IF = 0.90, stopping saved ~10% of trial cost and final months of exposure. Earlier-futility signals would have saved more but risk type-II error.

## How this case validates designr

- Conditional-power-based futility (vs β-spending-boundary).
- Agent reasoning about placebo-choice sensitivity across apparently-similar trials.
- Cross-trial benchmark comparison (REDUCE-IT vs STRENGTH) on a shared hypothesis.
