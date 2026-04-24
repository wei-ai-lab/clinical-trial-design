# Neuenschwander MAP prior (2010) — meta-analytic-predictive historical borrowing

**Family:** bayesian · **Endpoint:** any · **Design feature:** MAP prior on control arm from historical trials

## Why this case is in the corpus

- **Foundational methodology** for historical-control Bayesian borrowing.
- Meta-Analytic-Predictive (MAP) prior — hierarchical model of historical trials.
- Robust extension (Schmidli 2014) protects against prior-data conflict.

## Citation

Neuenschwander B, Capkun-Niggli G, Branson M, Spiegelhalter DJ. *Summarizing historical information on controls in clinical trials.* Clin Trials. 2010;7(1):5-18. doi:10.1177/1740774509356002.

Schmidli H, Gsteiger S, Roychoudhury S, et al. *Robust meta-analytic-predictive priors in clinical trials with historical control information.* Biometrics. 2014;70(4):1023-1032.

## Design summary

| | |
|---|---|
| Framework | Hierarchical Bayesian historical borrowing |
| Hierarchical model | θ_k ~ Normal(μ, τ²) |
| Between-trial SD prior | τ ~ Half-Normal(0, 1) or Half-Cauchy |
| MAP prior on new trial | π(θ_new) = p(θ \| historical) |
| Robust mixture | w · MAP + (1-w) · vague |
| Effective sample size | Data-driven, typically 5-50 equivalent subjects |

## Reproducing the MAP prior

```r
library(RBesT)
# Historical trials — binary control response rates
hist_data <- data.frame(
  study = paste0("S", 1:5),
  r = c(15, 23, 18, 12, 20),
  n = c(80, 100, 90, 70, 95)
)

# Fit MAP via hierarchical model
map_fit <- gMAP(
  cbind(r, n - r) ~ 1 | study,
  data = hist_data, family = binomial,
  tau.dist = "HalfNormal", tau.prior = c(0, 1),
  beta.prior = 2
)

# Parametric MAP
map <- automixfit(map_fit)

# Robust version
map_robust <- robustify(map, weight = 0.2, mean = 0.5)
```

## Key methodology points

- **Prior-data conflict**: if new control diverges from historical, robust mixture component takes over (via Bayesian model averaging).
- **Effective sample size (ESS)**: `ess(map)` returns data-equivalent prior sample size.
- **Regulatory simulation**: pre-specify scenarios where prior aligns vs conflicts; report Type I error under both.
- **Pediatric extrapolation**: MAP from adult data is canonical approach endorsed by EMA 2018 reflection paper.

## How this case validates designr

- Core reference for Bayesian historical-control borrowing.
- Backbone of `RBesT` package specifications.
- Widely used in pediatric extrapolation, rare disease, device trials.
