# König-Brannath-Bretz-Posch (2008) — Adaptive Dunnett Test

**Family:** adaptive-selection · **Kind:** foundational methodology · **Scope:** multi-arm confirmatory with interim arm dropping + strong FWER control

## Why this case is in the corpus

- **The** paper combining Dunnett's multiple-comparison correction with Bauer-Kohne conditional error function for adaptive arm selection.
- Generalizes drop-the-losers (single winner) to **multiple winners** with strong FWER control.
- Foundation for modern multi-dose seamless Phase 2/3 trials that can establish multiple doses simultaneously.
- Builds on Posch-Koenig 2005 (in corpus) and underlies Magirr-Jaki-Whitehead 2012 MAMS framework (also in corpus).
- Allows arbitrary pre-specified adaptation rules (arm dropping, SSR) while preserving α.

## Citation

- König F, Brannath W, Bretz F, Posch M. *Adaptive Dunnett tests for treatment selection.* Statistics in Medicine. 2008;27(10):1612-1625.
- Related: Posch M, Koenig F, Branson M, Brannath W, Dunger-Baldauf C, Bauer P. *Testing and estimation in flexible group sequential designs with adaptive treatment selection.* Stat Med. 2005;24(24):3697-3714.

## Framework

**Combines two classical ideas**:

1. **Dunnett test (1955)**: multi-comparison vs common control with FWER control via Dunnett correlation.

2. **Adaptive combination tests (Bauer-Kohne 1994)**: conditional error function allows arbitrary adaptation between stages while preserving α.

**Result**: adaptive Dunnett test allowing arm dropping, sample-size re-estimation, and other pre-specified adaptations with **strong FWER control**.

## Stage structure

**Stage 1** (selection):
- Randomize across K experimental arms + control.
- Compute Dunnett-style statistics Z_k^(1) for k = 1, ..., K.

**Adaptation decision** (pre-specified rule):
- Drop arms below threshold.
- Keep top m arms.
- Continue all.
- Drop for futility.
- Modify n per retained arm.

**Stage 2** (confirmation):
- Continue with retained arms per adaptation.
- Compute stage-2 Dunnett statistics Z_k^(2) for retained arms.

**Final testing** — closed testing across 2^K − 1 intersection hypotheses with combination of stage-1 and stage-2 p-values.

## Closed testing across K arms

For **each subset J ⊆ {1, ..., K}**:

1. Compute stage-1 Dunnett statistic D_J^(1) = max_{k ∈ J} Z_k^(1).
2. Conditional error function A_J(D_J^(1)) determines stage-2 critical value.
3. Compute stage-2 statistic D_J^(2) for retained arms in J.
4. Reject intersection H_0^J iff combined test > c_J.

**Strong FWER control**: individual H_0^k rejected iff ALL intersections containing k are rejected.

Number of intersections grows as 2^K − 1 — practical for K ≤ 5-6; larger K uses hierarchical gatekeeping.

## Multiple winners — the key advantage

| Design | Winners rejected | Use case |
|---|---|---|
| Drop-the-losers (Sampson-Sill) | 1 | Pick best dose |
| **Adaptive Dunnett** | **≥ 1** | **Establish multiple doses** |

Adaptive Dunnett can reject multiple H_0^k > 0 simultaneously, supporting dose-response labels spanning multiple doses.

## Conditional error function

Central concept (Bauer-Kohne 1994, Müller-Schäfer 2001):

```
A(D_1) = P(reject H_0 at final | stage 1 observed D_1, under H_0)
```

Pre-specified A(·) preserves α under any adaptation:
```
E_{H_0}[A(D_1)] = α
```

Koenig et al. extended this to Dunnett's multi-comparison structure — adaptation rule can drop arms, modify n, etc., as long as rule is pre-specified.

## Numerical example

K = 3 experimental arms + control, normal endpoint, n_1 = 30 per arm:

**Stage 1**:
- Z_1^(1) = 2.1, Z_2^(1) = 1.3, Z_3^(1) = 0.4.

**Decision**: drop arm 3 (lowest), continue arms 1 and 2.

**Stage 2** (n_2 = 60 per retained arm):
- Z_1^(2) = 2.4, Z_2^(2) = 1.8.

**Closed testing**:

| Intersection | Stage-1 stat | Stage-2 stat | Reject? |
|---|---|---|---|
| H_0^{1,2,3} | max(2.1, 1.3, 0.4) = 2.1 | max(Z_1^(2), Z_2^(2)) = 2.4 | ? |
| H_0^{1,2} | max(2.1, 1.3) = 2.1 | max(2.4, 1.8) = 2.4 | ? |
| H_0^{1,3} | max(2.1, 0.4) = 2.1 | Z_1^(2) = 2.4 | ? |
| H_0^{2,3} | max(1.3, 0.4) = 1.3 | Z_2^(2) = 1.8 | ? |
| H_0^1 | 2.1 | 2.4 | ? |
| H_0^2 | 1.3 | 1.8 | ? |
| H_0^3 | 0.4 | — | ? |

Reject H_0^1 iff H_0^{1,2,3}, H_0^{1,2}, H_0^{1,3}, H_0^1 all rejected.

## Arm-dropping rules (all pre-specified, all valid)

- **Threshold**: drop arm k if T_k < threshold.
- **Rank-based**: keep top m arms.
- **Futility**: drop if conditional power < threshold.
- **Clinical**: drop based on safety or biomarker.

Bauer-Kohne machinery preserves FWER for **any** pre-specified rule.

## Comparison to other adaptive-selection methods

| Method | Year | Multi-winner | FWER |
|---|---|---|---|
| Thall-Simon-Ellenberg (in corpus) | 1988 | ✗ | weak |
| Stallard-Todd (in corpus) | 2003 | ✗ | strong |
| Sampson-Sill (in corpus) | 2005 | ✗ (DTL) | strong |
| Posch-Koenig (in corpus) | 2005 | ✗ | strong |
| Bretz-Schmidli (in corpus) | 2006 | ✓ | strong |
| **König et al. (this case)** | **2008** | **✓** | **strong** |
| Friede-Stallard (in corpus) | 2008 | ✓ | strong |
| Magirr-Jaki-Whitehead (in corpus) | 2012 | ✓ | strong (MAMS) |

## R implementation — asd package

```r
library(asd)

# K = 3 experimental + control, adaptive Dunnett
sim <- sim.adaptive.dunnett(
  K = 3,
  n1 = 30, n2 = 60,
  alpha = 0.025,
  delta_true = c(0.5, 0.3, 0.0),
  sigma = 1,
  adaptation = "drop_worst",
  n_sim = 10000
)

sim$fwer
sim$power_by_arm
```

**Other packages**:
- `MAMS`: multi-arm multi-stage with Dunnett corrections.
- `rpact`: combination tests + closed testing.
- `AdaptiveDesign`: general adaptive methodology.
- `mvtnorm`: Dunnett correlation structure.

## Operating characteristics illustration

K = 3, n_1 = 30, n_2 = 60, α = 0.025:

| Scenario | DTL single | Adaptive Dunnett |
|---|---|---|
| All arms Δ = 0 | FWER 0.025 | FWER 0.025 |
| Arm 1 Δ = 0.5, others 0 | P(reject H_0^1) = 0.80 | 0.80 |
| Arm 1 Δ = 0.5, arm 2 Δ = 0.3, arm 3 = 0 | P(reject H_0^1) = 0.80, P(reject H_0^2) ~ 0 | 0.80, 0.45 |

Adaptive Dunnett can claim multiple effective doses; DTL cannot.

## Regulatory context

- **FDA 2019 Adaptive Designs Guidance**: multi-arm adaptive with FWER explicitly addressed.
- **EMA 2007 CHMP Reflection Paper**: Bauer-Kohne framework explicitly acknowledged.
- **Key requirement**: strong FWER control.

Adaptation rules, stage-1 critical values, and combination weights all **pre-specified** in protocol.

## Modern applications

- **STAMPEDE** (prostate cancer platform, in corpus): multi-arm adaptive uses Dunnett-like logic across substudies.
- **RECOVERY** (COVID platform): multiple drugs evaluated simultaneously.
- **Multi-dose oncology Phase 2b/3**: establish dose-response for labeling.
- **RA/IBD biologic trials**: low + high dose simultaneously.

## Limitations & caveats

- **Closed testing complexity**: 2^K − 1 intersections grows exponentially; practical for K ≤ 6.
- **Dunnett correlation assumption**: stratified analysis may slightly violate; simulation verification recommended.
- **Normal-case derivation**: exact for normal; binary/TTE use asymptotic approximations.
- **Pre-specification**: ALL rules locked upfront; no post-hoc modifications.
- **Information fraction**: combination weights (equal, or √n-based) pre-specified.

## How this case validates designr

- Adds the **adaptive Dunnett methodology** — key generalization enabling multi-winner adaptive selection.
- `designr` should support adaptive Dunnett with closed testing, conditional error function, and pre-specified adaptation rules.
- Teaches: strong vs weak FWER, closed testing structure, conditional error function principle, multi-winner advantage.
- Paired with 6 other adaptive-selection methodology cases in corpus — now covers drop-the-losers, GS+selection, closed-testing combination, and MAMS.
- `asd` package by Parsons/Friede is canonical R reference for designr to wrap.
