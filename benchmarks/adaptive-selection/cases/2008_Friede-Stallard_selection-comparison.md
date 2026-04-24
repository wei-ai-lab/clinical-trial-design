# Friede-Stallard (2008) — Comparison of Adaptive-Selection Methods

**Family:** adaptive-selection · **Kind:** methodology-paper · **Scope:** head-to-head comparison of Dunnett GS, drop-the-loser, Stallard-Todd, and combination-test methods

## Why this case is in the corpus

- **Canonical comparative reference** for adaptive-selection methods — simulation-based head-to-head across FWER, power, expected N, and estimation bias.
- The single most-cited paper when teams must *choose* a method, complementing the individual methodology papers (Thall 1988, Stallard-Todd 2003, Bauer-Kieser, Posch-Koenig 2005).
- Informs FDA 2019 Adaptive Designs guidance recommendations on method selection.
- Provides pragmatic design guidance beyond individual methodology papers.

## Citation

Friede T, Stallard N. *A comparison of methods for adaptive treatment selection.* Biom J. 2008 Oct;50(5):767-81.

## Methods compared

| Method | Selection rule | Power | Bias |
|---|---|---|---|
| Dunnett GS | None (parallel all arms) | Medium | Large upward |
| Drop-the-loser (Thall 1988) | Drop lowest at interim | Medium | Moderate |
| Stallard-Todd (2003) | Pre-specified | High | Small (sufficient-stat) |
| Bauer-Kieser / Posch-Koenig | Arbitrary | Low-Medium | Small with correction |

## Algorithm — simulation setup

```r
# Friede-Stallard 2008 comparison setup
# 3 experimental arms + control, 2-stage design with selection at stage 1.
# Configurations: null, LFC, equal effects, one superior arm.

library(asd)
library(rpact)

# (1) Dunnett GS benchmark
design_dunnett <- getDesignGroupSequential(
  kMax = 2, alpha = 0.025, beta = 0.1, sided = 1,
  typeOfDesign = "OF"
)
# design_dunnett provides closed-testing-corrected boundaries for
# 3 experimental arms vs control

# (2) Stallard-Todd sufficient-stat
# (3) Bauer-Kieser combination test
design_comb <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.1, sided = 1
)

# Simulate each under the same configurations and compare:
# - FWER (should be ≤ 0.025 for all)
# - Power (reject with best arm)
# - Expected N (total and per arm)
# - Bias of effect estimate for the selected "winner"
```

## Key findings (paraphrased)

- **FWER**: all methods control at nominal α.
- **Power**: Stallard-Todd > Dunnett ≈ drop-the-loser > combination test by ~5%.
- **Expected N**: combination test wins if selection is aggressive; Stallard-Todd competitive.
- **Bias**: smallest for combination test with conditional-error adjustment; largest for naive Dunnett.
- **Practical recommendation**: use Stallard-Todd when selection rule is simple and pre-specified; combination test when flexibility is needed.

## How this case validates designr

- Adds the **method-comparison perspective** to the adaptive-selection corpus — the other five cases cover individual methods.
- A real-world design API must let users simulate-compare across methods; this case is the reference implementation target for that capability.
- Cross-family: bias-reduction for selected winners is a common need also in MAMS and adaptive-enrichment — `designr` should expose it as a shared utility.
