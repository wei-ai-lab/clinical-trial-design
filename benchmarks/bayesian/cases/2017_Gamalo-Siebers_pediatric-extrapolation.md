# Gamalo-Siebers (2017) — Bayesian pediatric extrapolation

**Family:** bayesian · **Endpoint:** any · **Design feature:** power / commensurate prior borrowing from adult data

## Why this case is in the corpus

- **Field-standard methodology review** for Bayesian pediatric extrapolation.
- Power prior and commensurate prior frameworks for adult-to-pediatric borrowing.
- Enables small pediatric Phase 3 (N ~ 30-100) after borrowing.

## Citation

Gamalo-Siebers M, Savic J, Basu C, et al. *Statistical modeling for Bayesian extrapolation of adult clinical trial information in pediatric drug evaluation.* Pharm Stat. 2017;16(4):232-249. doi:10.1002/pst.1807.

## Design summary

| | |
|---|---|
| Framework | Bayesian adult-to-pediatric extrapolation |
| Power prior | π(θ \| adult) ∝ L(θ \| adult)^α · π₀(θ) |
| Commensurate prior | Adaptive α based on adult-pediatric heterogeneity |
| Typical α | 0.3 - 0.7 (pre-specified) |
| Pediatric N | ~30-100 after borrowing (vs 300+ without) |
| Required evidence | PK similarity + exposure-response + disease comparability |

## Reproducing the design

```r
library(RBesT)
# Step 1: MAP prior from adult Phase 3 data
adult_map <- gMAP(
  cbind(r, n - r) ~ 1,
  data = adult_data, family = binomial
)

# Step 2: Apply α weight (power prior)
# Effective prior for pediatric control arm:
#   dose the ESS to 0.5 × adult ESS (i.e., α = 0.5)

# Step 3: Design pediatric trial
library(bayesDP)
# Simulate pediatric trial operating characteristics
# under both "adult-pediatric similar" and "diverge" scenarios
```

## Key methodology points

- **Decision ladder**:
  1. Full borrowing (α = 1) when full extrapolation justified (same disease, PK match).
  2. Partial borrowing (α ∈ (0, 1)) when moderate similarity.
  3. No borrowing (α = 0) when developmental differences impact efficacy.
- **Commensurate prior**: data-driven α via hierarchical model with adult-pediatric commensurability parameter.
- **Regulatory simulation**: must report frequentist Type I error under prior-data conflict scenarios.
- **Operational bridge**: PK sameness → exposure matching → efficacy extrapolation → safety confirmed prospectively.

## How this case validates designr

- Framework for pediatric extrapolation design.
- Power prior / commensurate prior specifications.
- Regulatory-aligned approach (EMA 2018, FDA 2018 guidance).
