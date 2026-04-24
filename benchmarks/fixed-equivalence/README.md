# fixed-equivalence

Two-sided equivalence designs (TOST — two one-sided tests). The goal is to demonstrate the experimental treatment differs from the reference by no more than a pre-specified tolerance Δ in **either direction**.

## When this family is the right choice

- **Biosimilars** — regulatory pathway requires demonstration of equivalent efficacy to the originator.
- **Formulation changes** — ER vs IR, new excipient, new manufacturing site.
- **Dose-equivalence** — showing a new regimen is neither worse nor *implausibly better* than the reference.
- **Lot-consistency** — manufacturing lot-to-lot consistency (common for vaccines).

## Distinction from non-inferiority

| Aspect | NI | Equivalence |
|---|---|---|
| Directionality | One-sided (can't be much worse) | Two-sided (can't be much worse OR better) |
| Margin | One Δ | Symmetric ±Δ (or asymmetric −Δ_L, +Δ_U) |
| α | Usually 0.025 one-sided | 0.05 two-sided split into 2 × 0.025 one-sided |
| Power | Lower at given N | Approximately same as NI at H₁: δ = 0 |

## TOST logic

Reject H₀ (non-equivalence) if **both**:
- Lower 95% CI bound > −Δ (rule out clinically meaningful inferiority)
- Upper 95% CI bound < +Δ (rule out clinically meaningful superiority)

Equivalent to testing both one-sided hypotheses at α = 0.025 and rejecting both.

## Margin conventions

- **Biosimilars (EMA/FDA):** typically ±15% on relative scale for response-rate endpoints. ±12–13% common for continuous. Justified from historical precision of originator's response.
- **Formulation (bioequivalence, Phase 1):** 80-125% on log scale for AUC/Cmax (not in this family — covered in crossover).
- **Lot-consistency (vaccines):** ±0.5× on log GMT ratio (i.e. 2/3 to 3/2 on the ratio scale).

## Common pitfalls

- **Underpowering for equivalence.** N for equivalence at H₁: δ = 0 equals N for NI at H₁: δ = 0 (approximately). But as the *true* δ approaches Δ, equivalence power drops fast.
- **Asymmetric margins** — sometimes biosimilar regulators allow tighter upper bound than lower (preferring sponsors to err on the "not better" side).
- **Three-arm biosimilar designs** — biosimilar vs US-licensed originator vs EU-licensed originator, with equivalence tested pairwise.

## R packages

| Endpoint | Preferred packages |
|---|---|
| Continuous | `stats::power.t.test` (×2 for TOST adjustment), `PowerTOST`, `rpact::getSampleSizeMeans` with `thetaA = 0`, two-sided equivalence |
| Binary | `gsDesign::nBinomial` (two-sided with symmetric deltas), `PowerTOST::power.TOST` |

## Cases

See `cases/`.
