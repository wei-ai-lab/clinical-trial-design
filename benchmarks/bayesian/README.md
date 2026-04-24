# bayesian — Bayesian Phase 3 designs

## Family overview

Phase 3 / late-phase trial designs that use **Bayesian inference** as the primary (or co-primary) decision framework — not just Bayesian sensitivity. Common threads:

1. **Posterior-probability success rule** — e.g., Pr(θ > 0 | data) > 0.95 as success criterion.
2. **Posterior-predictive probability** for adaptive go/no-go and interim stopping.
3. **Informative priors** from prior trials, real-world data, or external controls — power priors, meta-analytic-predictive (MAP) priors, robust mixture priors.
4. **Response-adaptive randomization** (RAR) — allocation probabilities updated by posterior of arm efficacy.
5. **Pediatric / rare-disease extrapolation** — formal Bayesian borrowing from adult data or historical studies.
6. **Hierarchical models across subgroups** — basket trials and multi-indication extrapolation.

## Common design pitfalls

- **Frequentist Type I error under priors**: informative priors can inflate frequentist Type I error unless explicitly calibrated. Regulators expect simulation-based operating characteristics.
- **Power-prior / MAP miscalibration**: if historical data differs in population/endpoint, borrowing injects bias; robust mixtures (vague component) mitigate.
- **Prior mining**: post-hoc prior choice is unacceptable; priors must be pre-specified.
- **Adaptive randomization drift**: RAR can imbalance confounders if time trends present.
- **Decision threshold ≠ significance**: Pr(θ > 0 | data) > 0.95 is not 1-sided α = 0.025 under general priors; calibration matters.

## Regulatory frameworks

- **FDA guidance** on Bayesian adaptive designs (2010 CDRH, 2019 CDER/CBER draft on complex innovative designs).
- **EMA** reflection paper on extrapolation (2018) — explicit framework for pediatric extrapolation.
- **ICH E9(R1)** — estimand framework applies equally to Bayesian.
- **ICH E17** — multi-regional Bayesian borrowing acceptable with pre-specification.

## R / software packages

- **`rstan` / `cmdstanr`** — Stan-based posterior computation.
- **`brms`** — Stan frontend for mixed-model Bayesian.
- **`RBesT`** — MAP / robust MAP priors (Novartis).
- **`bayesDP`** — Bayesian borrowing from historical controls.
- **`FACTS`** — commercial Bayesian adaptive trial design (Berry Consultants).
- **`pbatR`**, **`BayesCT`** — Bayesian adaptive design simulation.

## Cases in this corpus

| Case | Year | Setting | Bayesian element |
|---|---|---|---|
| BATTLE — lung cancer biomarker trial | 2011 | Refractory NSCLC | Bayesian adaptive randomization by biomarker |
| I-SPY2 — neoadjuvant breast cancer | 2010 | Breast cancer neoadjuvant | Bayesian predictive probability + graduation |
| Neuenschwander MAP prior methodology | 2010 | Any with historical data | Meta-analytic-predictive prior |
| Gamalo-Siebers pediatric extrapolation | 2017 | Pediatric rare disease | Power prior / MAP borrowing from adult |
| Berry Bayesian adaptive designs | 2010 | General adaptive | Textbook reference |
