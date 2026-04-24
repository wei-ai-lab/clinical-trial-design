# Pampallona-Tsiatis (1994) — Binding futility in group-sequential trials

**Family:** group-sequential-futility · **Kind:** methodology-canonical · **Scope:** theoretical framework for optimal binding inner-outer boundaries

## Why this case is in the corpus

- **Canonical methodology paper** for binding futility group-sequential designs.
- Establishes the power-family inner-outer boundary framework.
- Theoretical reference for optimal (most-powerful) binding futility boundary under given α, β.
- Implemented in `gsDesign` (sfupper/sflower), `rpact` (futilityBounds), `ldbounds`.

## Citation

Pampallona S, Tsiatis AA. *Group sequential designs for one-sided and two-sided hypothesis testing with provision for early stopping in favor of the null hypothesis.* J Stat Plan Inference. 1994;42:19-35. doi:10.1016/0378-3758(94)90187-2.

## Framework summary

| | |
|---|---|
| Boundary type | Power-family inner (futility) + outer (efficacy) |
| Shape parameter Δ | Δ = 0.25 ≈ Pocock; Δ = -0.5 ≈ O'Brien-Fleming |
| Binding | Yes — α-spending assumes trial stops if futility crossed |
| Typical information fractions | 0.33, 0.67, 1.00 (3-look) or other |
| Joint calibration | α, β, Δ, K, information fractions → boundaries + N |

## Reproducing the framework

```r
library(gsDesign)
# Pampallona-Tsiatis binding futility with power-family boundaries
d <- gsDesign(
  k = 3,
  test.type = 3,                  # binding futility
  alpha = 0.025,
  beta = 0.20,
  sfu = sfPower, sfupar = 0.5,    # efficacy boundary
  sfl = sfPower, sflpar = 0.5,    # futility boundary (inner)
  timing = c(0.33, 0.67, 1.0)
)
d$upper$bound          # efficacy boundaries on z-scale
d$lower$bound          # futility boundaries on z-scale
d$n.I                  # information at each look
```

```r
library(rpact)
# Equivalent in rpact
design <- getDesignGroupSequential(
  kMax = 3,
  alpha = 0.025,
  beta = 0.20,
  typeOfDesign = "WT",            # Wang-Tsiatis (power family)
  deltaWT = 0.5,
  typeBetaSpending = "bsP",        # power β-spending (binding)
  bindingFutility = TRUE,
  informationRates = c(0.33, 0.67, 1.0)
)
```

## Key features

- **Binding** futility: if z < futility boundary at any look, trial stops; α-spending assumes this.
- **Non-binding** (practical) variant: inner boundary is DSMB guidance only, α preserved if overridden.
- Power-family parametrization: single Δ controls both efficacy and futility shape (conceptually symmetric).
- N efficiency: binding < non-binding < no-futility; typical N savings 2-5% vs no-futility design.

## How this case validates designr

- Theoretical benchmark for Phase 3 GS designs with futility stopping.
- Calibration reference for the `gsDesign` / `rpact` futility boundary APIs.
- Teaching reference: binding vs non-binding tradeoff relevant to any `designr`-generated GS design.
- Complements real-trial futility corpus entries (ILLUMINATE, ACCORD, AIM-HIGH, TOPCAT, STRENGTH).
