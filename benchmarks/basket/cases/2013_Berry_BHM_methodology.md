# Berry-Broglio-Groshen-Berry (2013) — Bayesian hierarchical model for baskets

**Family:** basket · **Endpoint:** per-basket response rate · **Design feature:** hierarchical borrowing with shrinkage prior

## Why this case is in the corpus

- **Foundational methodology** for Bayesian hierarchical basket designs.
- Introduces the trade-off: borrowing efficiency vs per-basket Type I error.
- Anchor for EXNEX, CBHM, and other modern basket methods.

## Citation

Berry SM, Broglio KR, Groshen S, Berry DA. *Bayesian hierarchical modeling of patient subpopulations: efficient designs of phase II oncology clinical trials.* Clin Trials. 2013;10(5):720-734. doi:10.1177/1740774513497539.

## Design summary

| | |
|---|---|
| Framework | Bayesian hierarchical model (BHM) |
| Structure | logit(p_k) = μ + γ_k, γ_k ~ N(0, τ²) |
| Shrinkage controlled by | τ (between-basket SD) |
| Small τ | Strong borrowing |
| Large τ | Near-independent baskets |
| Prior on τ | Half-Cauchy or Half-Normal |
| Posterior decision | Pr(p_k > null_rate \| data) > threshold |
| Example | k=6 baskets, n=20 each |

## Reproducing the design

```r
library(basket)
# Example: 6 baskets, 20 patients each
resp <- c(5, 7, 8, 6, 9, 4)
n <- rep(20, 6)
baskets <- c("A", "B", "C", "D", "E", "F")

fit <- mem_exact(responses = resp, size = n, name = baskets)
summary(fit)
```

Or BHM via Stan:

```r
library(rstan)
# logit(p_k) = μ + γ_k, γ_k ~ N(0, τ²)
# τ ~ Half-Cauchy(0, 1)
# μ ~ Normal(0, 10)
```

## Key methodology points

- **Shrinkage trade-off**:
  - **Homogeneous baskets**: BHM gains power vs no-borrowing.
  - **Heterogeneous baskets (one inactive)**: BHM can inflate per-basket Type I error to ~20-30% at nominal 10%.
- **EXNEX (Neuenschwander 2016)**: mixture prior with non-exchangeable component to opt-out:
  ```
  γ_k ~ w · N(0, τ²) + (1-w) · N(0, σ²_nex)
  ```
- **CBHM (Chu & Yuan 2018)**: calibrated τ via pre-trial simulation.
- **Regulatory**: pre-specify τ hyperprior and simulate operating characteristics under homogeneous / heterogeneous truth.

## How this case validates designr

- BHM foundational reference for basket trial family.
- Baseline for EXNEX and CBHM extensions.
- Backbone of `basket`, `bhmbasket`, `RBesT` R packages.
