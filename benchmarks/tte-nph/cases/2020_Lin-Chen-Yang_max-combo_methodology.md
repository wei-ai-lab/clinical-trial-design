# Lin-Chen-Yang (2020) — max-combo test for NPH

**Family:** tte-nph · **Endpoint:** OS under unknown NPH shape · **Design feature:** Z_max = max(LR, FH(0,1), FH(1,0))

## Why this case is in the corpus

- **Cross-industry NPH working group** recommendation for IO Phase 3.
- **Max-combo** adapts to unknown NPH shape without pre-specifying weighting.
- Power never worst, often best vs individual weighted tests.

## Citation

Lin RS, Lin J, Roychoudhury S, et al. *Alternative analysis methods for time to event endpoints under nonproportional hazards: a comparative analysis.* Stat Biopharm Res. 2020;12(2):187-198. doi:10.1080/19466315.2019.1697738.

## Design summary

| | |
|---|---|
| Framework | Phase 3 OS, 2-arm 1:1, max-combo primary |
| Primary test | Z_max = max(Z_LR, Z_FH(0,1), Z_FH(1,0)) |
| α-control | Asymptotic joint normality across weightings |
| α / power | 0.05 (two-sided) / 0.85 |
| Example effect | 6-month delay, then HR 0.65 |
| Example events | ~430 |
| Example N | ~620 |

## Reproducing the design

```r
library(simtrial)
# simtrial::sim_pw_surv for piecewise-exponential simulation
# → power under max-combo across NPH scenarios
```

Or for closed-form (approximate):

```r
library(nphDesign)
# Weighted log-rank sample size under delayed effect
```

## Key methodology points

- **Max-combo** handles six NPH patterns: PH, delayed, crossing, middle-only, late-only, diminishing.
- **Alpha control**: joint distribution of (Z_LR, Z_FH(ρ,γ)) is asymptotically multivariate normal → critical value via numerical integration (e.g., `mvtnorm::pmvnorm`).
- **Weight choice**: default cross-industry recommendation: FH(0,0) + FH(0,1) + FH(1,0) — covers most shapes.
- **Regulatory note**: pre-specification of weight set in SAP is required; post-hoc weight selection invalidates α.

## How this case validates designr

- Weighted log-rank family reference.
- Max-combo implementation in `simtrial` and `nphDesign`.
- Cross-industry consensus design choice for IO NPH trials.
