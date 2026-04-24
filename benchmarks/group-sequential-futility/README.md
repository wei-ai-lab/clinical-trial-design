# group-sequential-futility

GS designs with **futility boundaries** that allow stopping for lack of benefit before the final analysis. Complements efficacy-only GS by reducing expected cost and exposure when the experimental treatment is unlikely to succeed.

## Why add futility

- **Ethical**: stop exposing patients to an ineffective (or possibly harmful) experimental arm.
- **Economic**: programs typically cost $10s-100s M beyond interim; stopping saves the remainder.
- **Informational**: clean null result informs field faster; frees resources for alternative mechanisms.

## Binding vs non-binding futility

| Aspect | Non-binding | Binding |
|---|---|---|
| DSMB override | Allowed (recommendation only) | Not allowed |
| α impact | None — full α preserved | α can be relaxed slightly |
| Sample size impact | None at design | Smaller at same α/β |
| Power impact at H₁ | Preserved | Slightly reduced (futility can stop truly-effective trials) |
| Practical use | Overwhelmingly preferred | Rare — requires sponsor commitment to stop |

**Non-binding is standard** in modern pivotal trials. Binding futility is used mainly in adaptive designs with pre-committed stopping.

## Common futility rules

### 1. Conditional-power-based
Stop for futility if CP(observed | H₁) < threshold (typically 10-20%).

### 2. β-spending functions
Analogous to α-spending. Allocate β across analyses; if test statistic crosses lower boundary, declare futility.
- **Hwang-Shih-DeCani (HSD)** β-spending with γ between −2 and 0.
- **O'Brien-Fleming-like** β-spending: stricter early, relaxes later.

### 3. Simple z-threshold
Stop if z < threshold (e.g. z < 0 at IF=0.33). Simple to communicate; lacks formal α/β balance.

### 4. Bayesian predictive probability
Stop if posterior predictive probability of success at final analysis < threshold.

## Spending function pairing

Typical designs combine:
- **α-spending**: Lan-DeMets OBF (standard efficacy)
- **β-spending**: HSD with γ = −2 to +1, or Bayesian predictive

See `gsDesign::gsDesign(test.type = 4)` for asymmetric (non-binding) futility; `test.type = 3` for binding.

## Common pitfalls

- **Over-stopping for futility.** Futility at very low CP threshold (< 5%) is operationally rare but not zero-harm; real treatments occasionally rebound on later data.
- **Conditional power based on observed effect.** Conditional power "assuming observed trend continues" is the conservative choice; CP under H₁ is more optimistic.
- **Asymmetric α-β spending has a learning curve.** Teams unfamiliar with gsDesign test.type=4 sometimes misinterpret boundaries.

## R packages

| Task | Package |
|---|---|
| Symmetric asymmetric GS | `gsDesign::gsDesign(test.type = 3 or 4)` |
| Non-binding asymmetric | `rpact::getDesignGroupSequential(typeBetaSpending = "bsHSD")` |
| Conditional power | `gsDesign::gsCP`, `rpact::getConditionalPower` |
| Predictive probability | `BDP2`, custom Bayesian |

## Cases

See `cases/`.
