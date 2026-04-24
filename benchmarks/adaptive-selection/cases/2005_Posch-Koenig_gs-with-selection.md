# Posch-Koenig-Branson-Brannath-Dunger-Bauer (2005) — GS + Adaptive Selection

**Family:** adaptive-selection · **Kind:** methodology-paper · **Scope:** unified combination-test framework for GS multi-arm trials with selection

## Why this case is in the corpus

- **Canonical unified reference** for adaptive treatment-selection within a group-sequential trial.
- Integrates Bauer-Kieser combination tests, Stallard-Todd selection, and Lan-DeMets spending into one framework.
- Cited by essentially every subsequent adaptive-selection paper, including Magirr-Jaki-Whitehead 2012 (generalized Dunnett).
- Strong FWER proof under *any* data-driven selection rule — key regulatory-relevant property.

## Citation

Posch M, Koenig F, Branson M, Brannath W, Dunger-Baldauf C, Bauer P. *Testing and estimation in flexible group sequential designs with adaptive treatment selection.* Stat Med. 2005 Dec 30;24(24):3697-714.

## Core design

| Element | Value |
|---|---|
| Arms | k experimental + control; subset continues after interim |
| Interim looks | Typically 1-2, one with a selection decision |
| Combination function | Fisher, inverse-normal, or weighted |
| Multiplicity | Closed testing across k elementary hypotheses (arm i vs control) |
| FWER | Strong control ≤ α under arbitrary selection rules |
| Estimation | Bias-reduced estimators for selected-winner effect |

## Algorithm

```r
# Posch-Koenig 2005 schematic for k = 3 experimental arms + control
# Stage 1: randomize to all 4 arms, observe interim.
# For each elementary H_i (arm i vs control):
#   compute p_i^{(1)} = stage-1 p-value from arm i only data
# For each intersection in closed-test family {H_1 ∩ H_2, H_1 ∩ H_3, ...}:
#   compute combined p-value via inverse-normal or Fisher.
# Decide which arms to drop (e.g., lowest observed effect).
# Stage 2: continue remaining arms (+ control), observe final data.
# For each retained H_i:
#   combine p_i^{(1)} with p_i^{(2)} via chosen combination function.
#   reject H_i if combined p-value ≤ α closed-test-adjusted.

library(asd)
# Simulate a 3-stage Posch-Koenig-style design with drop-the-loser
# at interim 1, GS at interim 2.
res <- asd.sim(
  nsim = 10000,
  early.eff.efficacy = "none",
  select = "pocock",   # approximates Posch-Koenig closed-test w/ O'Brien-Fleming
  nsamppg1 = 100, nsamppg2 = 200,
  nPatsPerStageArm = c(50, 50)
)
```

## Typical magnitudes

- α = 0.025 one-sided, power 0.90.
- 2-3 experimental arms + control at baseline.
- Keep top-1 or top-2 at interim.
- Combination-function power loss vs pure GS: ~3-8% — meaningful but acceptable given flexibility.
- Selection-bias in winner's effect estimate: typically 10-25% inflated without correction.

## Historical / scientific role

- Built on Bauer-Kieser combination-test machinery (1999 Biometrika) + Stallard-Todd (2003).
- Extended by Bretz-Schmidli (2006, in corpus) to seamless Phase 2/3 with short-term and long-term endpoints.
- Magirr-Jaki-Whitehead (2012, in corpus) added the generalized Dunnett correlation structure.
- Basis for the `asd` R package (Parsons-Friede-Stallard) and significant parts of `rpact`.

## How this case validates designr

- Adds the **foundational GS + selection methodology** that underpins the other four cases in the adaptive-selection corpus.
- Closed-testing + combination-test machinery is a cross-cutting requirement — `designr` should expose Fisher and inverse-normal combination for multi-stage multi-arm designs via `asd`/`rpact` composition.
- Bias-reduced estimation after selection is a distinct capability that the design API should expose alongside sample-size/power.
