# UPLIFT (2008) — tiotropium in moderate-to-severe COPD

**Family:** recurrent-events · **Endpoint:** annual exacerbation rate (NB) · **N:** 5,992 · **Design feature:** 4-year COPD exacerbation + FEV1 slope co-primary

## Why this case is in the corpus

- **Canonical COPD exacerbation design** — negative binomial rate as secondary, time-to-first as primary.
- 4-year follow-up, dual co-primary with FEV1 slope.
- Large N (~6000) powered on modest annual rate ratio.

## Citation

Tashkin DP, Celli B, Senn S, et al. *A 4-year trial of tiotropium in chronic obstructive pulmonary disease (UPLIFT).* N Engl J Med. 2008;359(15):1543-1554. doi:10.1056/NEJMoa0805800. NCT00144339.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1, 4-year follow-up |
| Population | GOLD II-IV COPD, FEV1 ≤ 70% predicted |
| Intervention | Tiotropium 18 μg daily |
| Co-primary 1 | Rate of FEV1 decline |
| Co-primary 2 | Time-to-first exacerbation |
| Key secondary | Annual exacerbation rate (NB) |
| α / power | 0.05 (two-sided) / 0.80 |
| Assumed rate ratio | 0.85 |
| Planned N | ~6,000 |

## Reproducing the design

```r
library(MASS)
# NB sample size (approximate):
# n per arm ≈ (z_{α/2} + z_β)^2 · [1/λ_C + 1/λ_E + k(1/λ_C² + 1/λ_E²)] / (log(RR))²
# where k = over-dispersion

library(rpact)
design_counts <- getSampleSizeCounts(
  alpha = 0.025, beta = 0.20,
  lambda1 = 0.85, lambda2 = 1.00,
  overdispersion = 1.5,
  accrualTime = 24, followUpTime = 48
)
```

## Trial outcome

- **FEV1 slope co-primary NOT met** (pre- and post-bronchodilator).
- **Exacerbation rate**: 0.73 vs 0.85 events/yr; RR 0.86 (95% CI 0.81-0.91), p < 0.001.
- Time-to-first exacerbation HR 0.86.
- Mortality secondary endpoint: HR 0.89 at 4 yr (NS).

## How this case validates designr

- COPD exacerbation NB design reference.
- Dual co-primary (continuous FEV1 slope + recurrent events).
- Long follow-up + modest effect size sample-size archetype.
