# Dichlorphenamide in periodic paralysis (2016) — rare-disease crossover

**Family:** crossover · **Endpoint:** attack rate per week · **N:** 65 (hypokalemic) + 44 (hyperkalemic) · **Design feature:** rare-disease AB/BA crossover enabling small-N pivotal

## Why this case is in the corpus

- **Rare-disease pivotal crossover** — enabled feasible trial in genetic disorder with ~1/100,000 prevalence.
- Within-subject efficiency made small N tractable.
- FDA approval (Keveyis) 2015 based on crossover design.

## Citation

Sansone VA, Burge J, McDermott MP, et al. *Randomized, placebo-controlled trials of dichlorphenamide in periodic paralysis.* Neurology. 2016;86(15):1408-1416. doi:10.1212/WNL.0000000000002416. NCT00094081.

## Design summary

| | |
|---|---|
| Design | Two parallel 2×2 AB/BA crossover studies |
| Diseases | Hypokalemic PP (n=65) · Hyperkalemic PP (n=44) |
| Genes | CACNA1S, SCN4A, KCNJ2 (confirmed) |
| Intervention | Dichlorphenamide 50 mg BID |
| Control | Placebo |
| Period | 9 weeks each |
| Washout | 9 weeks |
| Primary | Attack rate per week (within-subject) |
| α / power | 0.05 (two-sided) / 0.80 |

## Reproducing the design

```r
library(MASS)
# Within-subject NB rate-ratio analysis
fit <- glm.nb(
  attacks ~ treatment + period + offset(log(weeks_in_period)),
  data = df,
  subset = analysis_set == "completers"
)
# Treatment effect → within-subject rate ratio

# Sample size: analogous to NB rate ratio with correlation ρ within subject
# N = 2*(z_{α/2}+z_β)² * (1-ρ²) * [σ²_w / (log RR)²]
```

## Trial outcome

- **Hypokalemic PP**: attack rate RR 0.37 (95% CI 0.20-0.72), p = 0.002.
- **Hyperkalemic PP**: attack rate RR 0.15 (95% CI 0.05-0.43), p = 0.009.
- Secondary: quality of life improved.
- Open-label extension confirmed durable effect.
- FDA approval August 2015 (Keveyis) for primary periodic paralysis.

## How this case validates designr

- Rare-disease crossover pivotal design.
- Within-subject NB rate-ratio analysis reference.
- Long washout pattern (9 weeks) for pharmacology + biology rebound.
- Orphan drug approval precedent.
