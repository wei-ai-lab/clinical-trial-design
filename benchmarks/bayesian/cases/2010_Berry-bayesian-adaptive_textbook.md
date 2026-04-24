# Berry et al. (2010) — Bayesian Adaptive Methods for Clinical Trials

**Family:** bayesian · **Endpoint:** any · **Design feature:** posterior-probability decision rules + RAR + predictive probability

## Why this case is in the corpus

- **Canonical textbook** for Bayesian adaptive clinical trial design.
- Unified framework across Phase 1/2/3 via posterior-probability rules.
- Informs FDA CDRH Bayesian guidance (2010) and many platform trial designs.

## Citation

Berry SM, Carlin BP, Lee JJ, Müller P. *Bayesian Adaptive Methods for Clinical Trials.* Chapman & Hall/CRC, 2010. ISBN 9781439825488.

## Design summary

| | |
|---|---|
| Framework | Textbook — Bayesian adaptive across phases |
| Phase 1 | CRM (O'Quigley), EffTox |
| Phase 2 | Predictive probability graduation |
| Phase 3 | Pre-specified posterior decision rules |
| RAR | Allocation ∝ Pr(arm is best \| data) |
| Stopping | Success (PP > 0.95), futility (PP < 0.05) |
| Example decision | Pr(θ_E > θ_C + δ \| data) > 0.95 |
| α / power example | 0.025 / 0.90 (frequentist-calibrated) |

## Reproducing design elements

```r
# Posterior probability success rule (binary)
library(rstan)
# Beta-binomial posterior: θ | r, n ~ Beta(α + r, β + n - r)

# Response-adaptive randomization
# p_alloc[arm] ∝ Pr(arm is best | data)^c
# where c ∈ [0, 1] controls aggressiveness

# Predictive probability of eventual success
# ∫ Pr(final p < α | data, future) × p(future | data) d(future)

library(BayesCT)
# Simulate operating characteristics
```

## Key framework elements

- **Posterior decision rules** as unified foundation:
  - Pr(θ > δ | data) > T_success for go
  - Pr(θ > δ | data) < T_futility for stop
- **Response-adaptive randomization** (RAR): multi-arm allocation update.
- **Predictive probability** for interim stopping / Phase 2 graduation.
- **Hierarchical modeling** for subgroup borrowing.
- **Decision-theoretic framework**: expected gain / loss under utility functions.

## Regulatory use

- CDRH Bayesian adaptive guidance (2010 final) drew on this textbook.
- Many pivotal device trials (e.g., SYNERGY, LEADLESS II) used Bayesian decision rules sourced from this framework.
- Pharma Phase 2 platform trials (I-SPY2, BATTLE) directly use these tools.

## How this case validates designr

- Reference textbook for the full Bayesian adaptive design family.
- Anchors the corpus in canonical methodology.
- Connects Bayesian specifications to R tooling (`BayesCT`, `RBesT`, `rstan`).
