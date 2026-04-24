# GBM AGILE (2019) — adaptive Bayesian platform in glioblastoma

**Family:** platform · **Endpoint:** OS · **Design feature:** two-stage funnel (screening + confirmatory) with common concurrent control

## Why this case is in the corpus

- **First adaptive platform trial in glioblastoma** — disease with dismal outcomes and decades of Phase 3 failures.
- Two-stage funnel: Stage 1 screening with RAR, Stage 2 fixed confirmatory.
- Common control within calendar window to manage time trends.

## Citation

Alexander BM, Ba S, Berger MS, et al. *Adaptive Global Innovative Learning Environment for Glioblastoma: GBM AGILE.* Clin Cancer Res. 2018;24(4):737-743. doi:10.1158/1078-0432.CCR-17-0764. NCT03970447.

## Design summary

| | |
|---|---|
| Design | Adaptive Bayesian platform (FACTS / Berry Consultants) |
| Disease | Newly dx or recurrent GBM |
| Biomarker | MGMT methylation (covariate) |
| Stage 1 | Screening — RAR allocation, ~100 per arm |
| Stage 2 | Confirmatory — fixed allocation, ~120-150 per arm |
| Primary | OS |
| Superiority | Pr(HR < 1 \| data) > 0.975 |
| Futility | Pr(HR < 1 \| data) < 0.025 |
| Common control | TMZ + RT, concurrent within calendar window |

## Reproducing the design

```r
library(FACTS)  # commercial

# Stage 1: Bayesian RAR
# Per-arm posterior: HR ~ Weibull or piecewise-exponential
# Allocation prob ∝ Pr(arm is promising | data)

# Stage 2: fixed allocation, Bayesian OS primary
# Superiority: Pr(HR < 1 | data) > 0.975
# Futility: Pr(HR < 1 | data) < 0.025
```

## Trial outcome

- Launched July 2019 with regorafenib, paxalisib, VAL-083.
- Additional arms added over time.
- Registrational pathway — designed with FDA pre-submission.
- Multiple arm-specific readouts expected through 2024-2025.
- First GBM Phase 3 platform with FDA registration-enabling design.

## How this case validates designr

- Two-stage (screening → confirmatory) platform architecture.
- Common concurrent control pattern.
- MGMT-covariate-aware sample sizing.
- Bayesian posterior-probability decision rules for platform decisions.
