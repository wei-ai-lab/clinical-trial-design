# Thall-Simon (1994) — Bayesian Continuous Monitoring

**Family:** bayesian · **Kind:** methodology-paper · **Scope:** foundational framework for Bayesian continuous interim monitoring in Phase 2

## Why this case is in the corpus

- **Foundational paper** for Bayesian continuous interim monitoring — decades-long standard for MD Anderson Phase 2 program.
- Posterior probability stopping rules without frequentist α-spending penalty.
- Foundation for I-SPY2 (in corpus), BATTLE (in corpus), and most modern Bayesian Phase 2 oncology trials.
- Canonical methodology entry complementing Spiegelhalter (2004), Berry (2010), FDA Bayesian Devices (2010), and Neuenschwander MAP (2010).

## Citation

- Thall PF, Simon R. *Practical Bayesian guidelines for phase IIB clinical trials.* Biometrics. 1994 Jun;50(2):337-49.
- Thall PF, Simon R, Estey EH. *Bayesian sequential monitoring designs for single-arm clinical trials with multiple outcomes.* Stat Med. 1995 Feb 15;14(4):357-79.

## Core framework

| Element | Value |
|---|---|
| Setting | Single-arm Phase 2 (oncology) or 2-arm small randomized |
| Endpoint | Binary response (base case); extends to TTE, continuous |
| Prior | Conjugate beta (often sceptical or mildly informative) |
| Monitoring | After each new patient (continuous) |
| Futility rule | P(p > p0 | data) < δ_fut (e.g., < 0.05) |
| Superiority rule | P(p > p0 | data) > δ_sup (e.g., > 0.95) |
| Calibration | Simulation for target type I + power |

## Algorithm

```r
# Thall-Simon Bayesian monitoring for single-arm Phase 2
library(ph2bayes)

# Design parameters
p0 <- 0.10    # null/uninteresting response rate
p1 <- 0.30    # target response rate
alpha_prior <- 0.5    # sceptical Beta(0.5, 4.5) prior
beta_prior  <- 4.5
delta_fut   <- 0.05   # futility threshold
delta_sup   <- 0.90   # superiority threshold
max_n       <- 40

# Continuous monitoring
simulate_one <- function(true_p) {
  n <- 0; r <- 0; decision <- "continue"
  while (decision == "continue" && n < max_n) {
    n <- n + 1
    r <- r + rbinom(1, 1, true_p)
    post_a <- alpha_prior + r
    post_b <- beta_prior + n - r
    p_sup  <- 1 - pbeta(p1, post_a, post_b)
    p_fut  <- 1 - pbeta(p0, post_a, post_b)
    if (p_fut < delta_fut) decision <- "futility"
    else if (p_sup > delta_sup) decision <- "success"
  }
  list(n = n, r = r, decision = decision)
}

# Operating characteristics via simulation
sims_null <- replicate(10000, simulate_one(p0), simplify = FALSE)
mean(sapply(sims_null, function(x) x$decision == "success"))  # type I error
sims_alt <- replicate(10000, simulate_one(p1), simplify = FALSE)
mean(sapply(sims_alt, function(x) x$decision == "success"))  # power
```

## Operating characteristics

| Scenario | Expected N | Probability of success |
|---|---|---|
| True p = p0 (null) | 25-35 | ~ 0.05 (type I) |
| True p = p1 (target) | 35-40 | ~ 0.85 (power) |
| Interim early futility | N ~ 10-20 | Most protective |

## Extensions (Thall-Simon-Estey 1995)

- **Bivariate monitoring**: response AND toxicity (beta-binomial with correlation).
- **Toxicity-efficacy trade-off**: dose-finding with joint monitoring.
- **Response-adaptive randomization**: combined with monitoring.

## Historical / methodology role

- Standard MD Anderson Phase 2 design for ~30 years.
- Foundation for posterior predictive probability (PPP) monitoring (Lee-Liu 2008).
- Informs I-SPY2 (in corpus) and BATTLE (in corpus) adaptive frameworks.
- Incorporated into FDA 2010 Bayesian Devices Guidance (in corpus).

## How this case validates designr

- Adds the **foundational Bayesian monitoring methodology** to the bayesian corpus complementing Spiegelhalter textbook, Berry textbook, FDA Bayesian Devices, and Neuenschwander MAP.
- `designr` should expose Bayesian continuous monitoring (via `ph2bayes`, `bayesDP`, `RBesT`, or `bhmbasket`) as a design class alongside frequentist GS.
- Sample-size calibrated via simulation — `designr` should provide simulation utilities for prior-specification sensitivity.
- Teaching case: continuous Bayesian monitoring is not 'data peeking' when properly pre-specified and calibrated.
