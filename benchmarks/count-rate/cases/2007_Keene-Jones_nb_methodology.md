# Keene-Jones (2007) — NB exacerbation rate methodology

**Family:** count-rate · **Endpoint:** annualized exacerbation rate · **Design feature:** NB with over-dispersion sample-size formula

## Why this case is in the corpus

- **Field-standard methodology paper** for respiratory exacerbation designs.
- Derives NB sample-size formula with over-dispersion correction.
- Warns against Poisson in over-dispersed data (Type I error inflation).

## Citation

Keene ON, Jones MRK, Lane PW, Anderson J. *Analysis of exacerbation rates in asthma and chronic obstructive pulmonary disease: example from the TRISTAN study.* Pharm Stat. 2007;6(2):89-97. doi:10.1002/pst.250.

## Design summary

| | |
|---|---|
| Framework | Methodology — NB rate-ratio with over-dispersion |
| Model | NB GLM: log(λ) = β₀ + β_arm + log(exposure) |
| Rate ratio | exp(β_arm) |
| Dispersion φ | Var(Y) = μ + φμ² |
| α / power | 0.05 (two-sided) / 0.90 example |
| Example RR | 0.75 (25% rate reduction) |
| Example rate_C | 1.2 events/year |
| Example φ | 1.5 |

## Sample size formula

```
n per arm ≈ (z_{α/2} + z_β)² · [1/(λ_C·T) + 1/(λ_E·T) + 2φ] / (log RR)²
```

where T = mean follow-up per subject in years.

```r
library(rpact)
d <- getSampleSizeCounts(
  alpha = 0.025, beta = 0.10,
  lambda1 = 0.90, lambda2 = 1.20,
  overdispersion = 1.5,
  accrualTime = 12, followUpTime = 12
)
```

Analysis:

```r
library(MASS)
fit <- glm.nb(events ~ arm + offset(log(exposure_yr)), data = df)
```

## Key methodology points

- **Over-dispersion** is almost universal in respiratory exacerbations (φ > 0.5 typical).
- **Poisson Type I error**: inflated to ~0.15 at nominal α = 0.05 when φ = 2.
- **Sample size impact**: ignoring φ under-estimates N by factor 1 + 2φ · (log RR)² / [1/(λ·T)-based term].
- **Regulatory expectation**: SAPs should specify NB primary with Poisson sensitivity, not vice versa.

## How this case validates designr

- Reference formula for NB rate-ratio sample size in respiratory trials.
- Backbone of `rpact::getSampleSizeCounts` and `gsDesign2` count-rate design.
- Standard citation in SAPs for asthma / COPD exacerbation designs.
