# FDA (2010) — Bayesian Statistics in Medical Device Trials

**Family:** bayesian · **Kind:** regulatory-guidance · **Scope:** PMA / 510(k) device submissions using Bayesian methods

## Why this case is in the corpus

- **Landmark FDA regulatory document** codifying Bayesian methods for medical device trials.
- Explicit regulatory acceptance of MAP priors, power priors, and posterior-probability decision rules.
- Operating-characteristics simulation requirements define the practical constraints on Bayesian Phase 3 / pivotal device designs.
- Foundation for subsequent TAVR, endovascular, and neurostimulation Bayesian approvals.

## Citation

U.S. Food and Drug Administration, Center for Devices and Radiological Health. *Guidance for the Use of Bayesian Statistics in Medical Device Clinical Trials.* February 2010. Updated 2018.

## Core regulatory framework

| Element | Requirement |
|---|---|
| **Prior specification** | Pre-specified before unblinding; documented derivation from historical data |
| **Prior-data conflict** | Simulation across scenarios: prior centered correctly, biased positive, biased negative |
| **Posterior threshold** | Typically P(criterion met) > 0.95 or 0.975 for regulatory decision |
| **Type-I error** | ≤ pre-specified α under null across all simulated conflict scenarios |
| **Power** | ≥ target under realistic effect assumptions, simulated |
| **Sample size** | Fixed or Bayesian-adaptive (predictive probability re-estimation) |
| **Simulation report** | Submitted with application; covers all operating characteristics |

## Accepted Bayesian design patterns

1. **Single-arm with objective performance criterion (OPC)** + Bayesian synthesis of historical controls.
2. **Randomized superiority** with MAP prior on control arm from prior-generation device.
3. **Non-inferiority** with power prior on the NI margin derived from historical active-comparator trials.
4. **Adaptive SSR** using Bayesian predictive probability at interim.

## Reproducing the framework

```r
library(RBesT)
# MAP prior from prior-generation device data (6 historical studies)
set.seed(42)
map <- gMAP(
  cbind(responses, n) ~ 1 | study,
  family = binomial,
  data = historical_devices,
  tau.dist = "HalfNormal",
  tau.prior = 1,
  beta.prior = 2
)
map_mix <- automixfit(map)

# Robust mixture to guard against prior-data conflict
robust_prior <- robustify(map_mix, weight = 0.20, mean = 0.5)

# Decision rule
decision <- function(posterior, threshold = 0.975) {
  mean(posterior > 0.5) > threshold
}
```

## Operating-characteristics simulation requirements

```r
# Scenario 1: prior centered correctly
sim1 <- simulate_trial(true_rate = prior_center, prior = robust_prior,
                       n_trials = 10000)
stopifnot(mean(sim1$type_I_error) <= 0.025)

# Scenario 2: prior biased positive (prior thinks device better than truth)
sim2 <- simulate_trial(true_rate = prior_center - 0.10, prior = robust_prior,
                       n_trials = 10000)
stopifnot(mean(sim2$type_I_error) <= 0.025 * 1.5)  # Some inflation tolerable

# Scenario 3: prior biased negative
# ... etc.
```

## Key device approvals based on this framework

- **Coronary drug-eluting stents** (multiple, 2010-present): MAP prior from prior-gen stent.
- **TAVR** (PARTNER, CoreValve): Bayesian predictive monitoring.
- **Deep brain stimulation** (PD, essential tremor): power-prior borrowing across indications.
- **Left atrial appendage closure** (WATCHMAN): Bayesian NI with MAP control.

## How this case validates designr

- Regulatory-grounded Bayesian design framework benchmark.
- Operating-characteristics simulation paradigm.
- MAP / power / robust mixture prior workflows usable via RBesT / bayesDP backends.
- Complements drug-side Spiegelhalter textbook (2004) with device-side regulatory practice.
- Provides concrete prior-data-conflict sizing examples for any `designr`-designed Bayesian Phase 3 / pivotal trial.
