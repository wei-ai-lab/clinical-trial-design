# McAlister et al. (2003) — Factorial trial analysis & reporting

**Family:** factorial · **Kind:** methodology-canonical · **N:** n/a (systematic review of 44 trials) · **Design feature:** at-the-margins vs inside-the-table; interaction power

## Why this case is in the corpus

- **Canonical methodology reference** for factorial design analysis choices.
- Defines the at-the-margins vs inside-the-table distinction that governs N.
- Quantifies the ~4× N cost of detecting interaction at the same α/β as main effects.
- Influenced the CONSORT factorial extension (Piaggio 2021).

## Citation

McAlister FA, Straus SE, Sackett DL, Altman DG. *Analysis and reporting of factorial trials: a systematic review.* JAMA. 2003;289(19):2545-2553. doi:10.1001/jama.289.19.2545.

## Methodological summary

| | |
|---|---|
| Scope | Systematic review of 44 factorial RCTs (1976-2001) |
| Primary analysis options | (a) at-the-margins — pool across other factor, assume no interaction; (b) inside-the-table — cell-specific; (c) stratified |
| Interaction power | N_interaction ≈ 4 × N_main for same effect magnitude |
| Common deficiencies found | ~1/3 did not report interaction test; many reported only main effect when interaction plausible; inconsistent partial-interaction handling |
| Recommendations | Pre-specify primary analysis; report all four cells with CIs |

## Reproducing the design logic

```r
# At-the-margins: size as two independent 2-arm trials
library(gsDesign)
n_main <- nBinomial(p1 = 0.12, p2 = 0.108,
                    alpha = 0.025, beta = 0.10, sided = 1)

# Inside-the-table (interaction detection) ~ 4x
n_interaction <- 4 * n_main
```

## Key conclusions

- Factorial is N-efficient **only** when interaction is assumed absent.
- Pre-specification of at-the-margins vs inside-the-table is required for valid inference.
- Interactions cost ~4× N to detect at the same α/β.
- Reporting all four cells with CIs enables reader-level interaction assessment.
- Regulatory practice has largely adopted pre-specified at-the-margins primary with interaction as pre-specified sensitivity.

## How this case validates designr

- Canonical reference for factorial analysis choice.
- Establishes the interaction-power cost that explains why most factorial trials do not formally power for interaction.
- Justifies the at-the-margins primary-analysis convention used in HOPE-3, COMMIT, and most modern factorial CVOTs.
