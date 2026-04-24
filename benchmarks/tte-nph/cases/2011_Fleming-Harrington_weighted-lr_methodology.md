# Fleming-Harrington FH(ρ,γ) — weighted log-rank methodology

**Family:** tte-nph · **Endpoint:** FH-weighted log-rank · **Design feature:** late / early / middle event up-weighting

## Why this case is in the corpus

- **Foundational NPH methodology reference** for weighted log-rank tests.
- Direct inputs to `nphDesign`, `gsDesign2`, `simtrial` weight specifications.
- G(ρ,γ) family covers early, middle, late, and uniform weighting.

## Citation

Fleming TR, Harrington DP. *Counting Processes and Survival Analysis.* Wiley, 1991 (reprint 2011), Ch. 7.

## Design summary

| | |
|---|---|
| Framework | Methodology — weighted log-rank family |
| Weight | w(t) = Ŝ(t)^ρ · (1 − Ŝ(t))^γ |
| FH(0,0) | Unweighted log-rank |
| FH(1,0) | Peto-Prentice — early-weighted |
| FH(0,1) | Late-weighted — delayed effect optimal |
| FH(1,1) | Middle-weighted |
| FH(0.5,0.5) | Balanced |
| α / power | 0.05 (two-sided) / 0.90 design convention |

## Reproducing a test

```r
library(survival)
# FH(0,1) — late-weighted log-rank
survdiff(Surv(time, event) ~ arm, data = df, rho = 0)
# note: survival::survdiff uses G(rho,0) only; for full FH(ρ,γ) use
# nphDesign or simtrial weighting.
```

For design sizing:

```r
library(nphDesign)
# Specify piecewise hazard and FH weights
# → sample size / events for target power
```

## Key methodology points

- **H0 validity**: weighted log-rank has correct Type I error under null of identical hazards.
- **H1 efficiency**: FH(0,1) best for delayed effect; FH(1,0) best for early effect; FH(1,1) for middle-concentrated effect.
- **Crossing hazards**: FH(0,1) can LOSE power vs unweighted log-rank when late-direction effect reverses.
- **Pre-specification**: ρ, γ must be fixed in SAP; post-hoc selection inflates α.
- **Relation to proportional-odds model**: FH(0,1) is approximately score test for proportional odds.

## How this case validates designr

- Reference specification for weighted log-rank family.
- Backbone of max-combo designs (which compose multiple FH weights).
- Canonical NPH methodology source for design family.
