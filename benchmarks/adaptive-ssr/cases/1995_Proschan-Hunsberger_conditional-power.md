# Proschan-Hunsberger (1995) — Conditional-Power SSR

**Family:** adaptive-ssr · **Kind:** methodology-paper · **Scope:** foundational CP-based two-stage adaptive SSR with type-I-error-preserving boundary

## Why this case is in the corpus

- **Foundational methodology paper** for conditional-power-based sample size re-estimation (CP-SSR) — one of the two principal SSR lines alongside Cui-Hung-Wang weighted statistics (1999).
- Introduces the type-I-error-preserving boundary function A(z₁) that makes any N₂(z₁) rule valid.
- Predecessor to Chen-DeMets-Lan 2004 and Mehta-Pocock 2011 promising-zone (both in corpus), which simplify practical implementation.
- Canonical foundational entry for the adaptive-ssr family.

## Citation

Proschan MA, Hunsberger SA. *Designed extension of studies based on conditional power.* Biometrics. 1995 Dec;51(4):1315-24.

## Core framework

| Element | Value |
|---|---|
| Design | Two-stage adaptive with interim CP assessment |
| Interim statistic | z₁ (standardized test statistic from stage 1) |
| Target CP | typical 0.80 |
| Decision rule | n₂(z₁) chosen to achieve CP(z₁) ≥ 0.80 subject to n_max cap |
| Final test | z_final ≥ A(z₁) (custom boundary for type I control) |
| n_max cap | typical 2-3× original stage-2 N |

## Algorithm

```r
# Proschan-Hunsberger 1995 CP-SSR (normal endpoint)
# Stage 1: observe z₁ from n₁ subjects.
# Conditional power at the assumed δ (or at δ̂₁):
#   CP(z₁, n₂) = 1 - Φ(c_α * sqrt((n₁+n₂)/n₂) - z₁ * sqrt(n₁/n₂) - δ * sqrt(n₂)/σ)

library(rpact)
# Design object with conditional power SSR
design <- getDesignInverseNormal(kMax = 2, alpha = 0.025, beta = 0.1,
                                 sided = 1, typeOfDesign = "asOF")

# Compute CP given interim data
cp_result <- getConditionalPower(
  design = design,
  conditionalPower = 0.80,
  nPlanned = 200  # projected stage-2 N
)

# Proschan-Hunsberger-style final test (adjusted boundary)
# rpact handles the boundary adjustment automatically for the
# inverse-normal combination test framework
```

## Typical design parameters

- α = 0.025 one-sided, baseline power 0.80-0.90.
- Stage-1 fraction of information: 0.30-0.60.
- Target CP*: 0.80 (most common).
- n₂(z₁) cap: 2-3× original planned stage-2 N to limit operational burden.
- Power recovery: if interim CP is 0.40-0.60, post-SSR design recovers ~0.80 power under the assumed effect.

## Historical / scientific role

- First formal CP-SSR design preserving type I error.
- Showed that flexibility to adapt N has a principled mathematical solution via boundary adjustment.
- Motivated two decades of refinement:
  - Lehmacher-Wassmer 1999 — weighted inverse-normal combination test.
  - Müller-Schäfer 2001 — conditional error function generalization.
  - Chen-DeMets-Lan 2004 (in corpus) — restricted-rule simplification.
  - Mehta-Pocock 2011 (in corpus) — promising-zone practical design.

## How this case validates designr

- Adds the **foundational CP-SSR methodology** to the adaptive-ssr corpus, complementing the five later-generation papers.
- The Proschan-Hunsberger boundary A(z₁) is a concrete computation any SSR design API must expose (via rpact's inverse-normal combination).
- Teaching-case value: `designr` should be able to demonstrate, for the same stage-1 z₁, how n₂ and final-test boundary evolve across the Proschan-Hunsberger vs Chen-DeMets-Lan vs Cui-Hung-Wang frameworks.
