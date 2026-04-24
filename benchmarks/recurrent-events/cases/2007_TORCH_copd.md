# TORCH (2007) — salmeterol/fluticasone in COPD

**Family:** recurrent-events · **Endpoint:** OS primary, exacerbation rate key secondary · **N:** 6,184 · **Design feature:** 4-arm, dual-outcome design

## Why this case is in the corpus

- **Four-arm RCT** with OS primary and recurrent-event exacerbation rate as key secondary.
- Shows tradeoff between TTE and rate-ratio endpoint choice.
- Primary OS missed by narrow margin (p = 0.052); exacerbation rate strongly positive.

## Citation

Calverley PMA, Anderson JA, Celli B, et al. *Salmeterol and fluticasone propionate and survival in chronic obstructive pulmonary disease (TORCH).* N Engl J Med. 2007;356(8):775-789. doi:10.1056/NEJMoa063070. NCT00268216.

## Design summary

| | |
|---|---|
| Design | RDBPC, 4-arm, 3-year follow-up |
| Population | Moderate-severe COPD, FEV1 < 60% |
| Arms | salm/flut · salmeterol · fluticasone · placebo |
| Primary | All-cause mortality over 3 years |
| Key secondary | Annual exacerbation rate |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.77 (salm/flut vs placebo) |
| Assumed rate ratio | 0.75 |
| Planned N | ~6,200 |

## Reproducing the design

```r
library(gsDesign)
# OS primary — Schoenfeld sizing with 4-arm adjustment
d_os <- nSurv(
  lambdaC = -log(0.83)/3, hr = 0.77,
  alpha = 0.025, beta = 0.10,
  R = 12, minfup = 36
)

# Exacerbation secondary — NB/Poisson rate ratio
library(rpact)
d_exac <- getSampleSizeCounts(
  alpha = 0.0125, beta = 0.10,  # adjusted for multiple comparison
  lambda1 = 0.75, lambda2 = 1.00,
  overdispersion = 1.2
)
```

## Trial outcome

- **OS primary**: salm/flut vs placebo HR 0.825 (95% CI 0.68-1.00), **p = 0.052** (narrowly missed).
- **Exacerbation rate**: RR 0.75 (salm/flut vs placebo), p < 0.001 — significant.
- Health status (SGRQ): all active arms > placebo.
- Overall a key COPD trial despite formally negative primary.

## How this case validates designr

- Multi-arm (4-arm) design with rate-ratio secondary.
- Illustrates primary-endpoint tradeoff: TTE mortality vs rate-ratio exacerbation.
- Poisson/NB rate analysis reference for COPD.
