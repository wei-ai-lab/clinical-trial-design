# Schmidli et al. (2014) — Robust Meta-Analytic-Predictive Priors

**Family:** bayesian · **Kind:** methodology-paper · **Scope:** canonical framework for historical-control borrowing via mixture priors

## Why this case is in the corpus

- **Canonical methodology** for incorporating historical control information via robust MAP priors.
- Extends Neuenschwander et al. (2010) MAP with a **mixture-robustification** component that hedges against prior-data conflict.
- Basis for **EXNEX** (Neuenschwander-Wandel-Roychoudhury-Schmidli 2016) for non-exchangeable basket cohorts.
- Implemented in **RBesT** (Novartis), the canonical R package for historical borrowing.
- Referenced in FDA CID pilot acceptances, pediatric extrapolation (Gamalo-Siebers 2017, in corpus), and rare-disease submissions.

## Citation

- Schmidli H, Gsteiger S, Roychoudhury S, O'Hagan A, Spiegelhalter D, Neuenschwander B. *Robust meta-analytic-predictive priors in clinical trials with historical control information.* Biometrics. 2014 Dec;70(4):1023-32.
- Neuenschwander B, Wandel S, Roychoudhury S, Schmidli H. *Robust exchangeability designs for early phase clinical trials with multiple strata.* Pharm Stat. 2016 Mar-Apr;15(2):123-34. (EXNEX)

## Core framework

| Element | Value |
|---|---|
| Setting | Phase 2/3 or confirmatory with historical controls |
| Prior construction | Random-effects meta-analysis of K historical control trials |
| MAP prior | Predictive distribution for new-trial control parameter |
| Robustification | Mixture with weak uninformative component at weight w |
| Typical w | 0.10 – 0.30 |
| Effective sample size | MAP ESS in 'prior patients' — reduces concurrent control N |

## The robust MAP construction

**Step 1 — MAP prior from historical**:
- K historical trials provide summaries on control parameter θ_k (log-odds, log-hazard, or mean).
- Fit random-effects meta-analysis (normal-normal hierarchical):
  - θ_k | μ, τ² ~ N(μ, τ²)
  - Prior on (μ, τ²).
- Predictive distribution for new trial:
  - p_MAP(θ*) = ∫ N(θ* | μ, τ²) π(μ, τ² | θ_1,...,θ_K) dμ dτ²

**Step 2 — Robustification**:
- Mix MAP with a weakly informative ('vague') component:
  - p_robust(θ) = (1 − w) · p_MAP(θ) + w · p_vague(θ)
- Interpretation: with probability w, the current trial's control parameter is not well-represented by history.

**Step 3 — Sample-size impact**:
- Reduce concurrent control N by ~ MAP ESS (effective sample size).
- Calibrate w to achieve acceptable operating characteristics under prior-data conflict scenarios.

## Algorithm (RBesT)

```r
library(RBesT)

# 1. Historical control data (K trials)
hist_data <- data.frame(
  trial = paste0("T", 1:5),
  r = c(14, 22, 31, 18, 25),   # responders
  n = c(100, 150, 200, 120, 170)  # sample size
)

# 2. Fit MAP prior (random-effects meta-analysis)
set.seed(42)
map_mcmc <- gMAP(
  cbind(r, n - r) ~ 1 | trial,
  family = binomial,
  data = hist_data,
  tau.dist = "HalfNormal",
  tau.prior = 1,
  beta.prior = 2
)

# 3. Parametric approximation (Beta mixture)
map_prior <- automixfit(map_mcmc)
print(map_prior)
# e.g., Beta(20, 80) + Beta(5, 45) mixture; ESS ~ 50

# 4. Robustify — add 20% weight on weak Beta(1, 1)
robust_prior <- robustify(map_prior, weight = 0.2, mean = 0.2)

# 5. Effective sample size
ess(map_prior)         # ~ 50 prior-patient equivalents
ess(robust_prior)      # ~ 40 after robustification

# 6. Sample-size calculation for new trial
# With robust prior ESS = 40, reduce concurrent control N by ~ 40
design <- oc2S(
  prior1 = robust_prior,     # control arm
  prior2 = mixbeta(c(1, 1, 1)),  # treatment arm (vague)
  n1 = 60,                   # reduced concurrent control
  n2 = 100,                  # experimental
  decision = decision2S(0.975, 0, lower.tail = FALSE)
)
print(design(c(0.2, 0.4)))  # power at control=0.2, trt=0.4
```

## Operating characteristics

| Scenario | Behavior |
|---|---|
| Prior-data agreement (current control ≈ historical) | ESS ≈ MAP ESS; Type I preserved; power boost |
| Moderate conflict | Mixture weight w on vague pulls posterior toward data |
| Severe conflict | Effective ESS → 0; behavior → purely frequentist |

## EXNEX extension (2016)

For basket trials with K cohorts, each cohort's parameter θ_k is either:
- **Exchangeable**: θ_k ~ N(μ, τ²) — borrows from pool (pool weight π_k)
- **Non-exchangeable**: θ_k ~ N(μ_k, σ_k²) — standalone (1 − π_k)

Prior on π_k = P(exchangeable) estimated from data. Downweights shrinkage when biologically unreasonable.

## Regulatory acceptance

- **Pediatric extrapolation** (Gamalo-Siebers 2017, in corpus): robust MAP standard for leveraging adult data.
- **Rare disease trials**: MAP for historical control when concurrent RCT infeasible.
- **FDA 2018 Complex Innovative Designs (CID) pilot**: several accepted submissions used MAP / EXNEX.
- **EMA**: pragmatic acceptance for rare disease, pediatric.
- **Dalbavancin** (bacterial skin), **pertuzumab** (pediatric breast) — MAP from adult data.
- **RECOVERY / REMAP-CAP**: platform-style ongoing MAP updates.

## Relationship to other historical borrowing

| Method | Reference | Use |
|---|---|---|
| **Power prior** | Ibrahim-Chen 2000 | Raises historical likelihood to power α ∈ [0,1]; simpler |
| **Commensurate prior** | Hobbs-Carlin 2011 | Smooth transition via commensurability parameter |
| **Bayesian model averaging** | Various | Average across priors with different weights |
| **MAP** | Neuenschwander 2010 (in corpus) | Predictive distribution from meta-analysis |
| **Robust MAP** | Schmidli 2014 (this case) | MAP + mixture for prior-data conflict |
| **EXNEX** | Neuenschwander 2016 | Robust MAP for non-exchangeable strata |
| **psborrow** | MSKCC / Regeneron | Commensurate prior variants |

## How this case validates designr

- Adds the **canonical robust historical-borrowing methodology** to the bayesian corpus, complementing:
  - Neuenschwander MAP (2010) — the predecessor MAP construction (in corpus).
  - Thall-Simon (1994) — continuous Bayesian monitoring (in corpus).
  - Spiegelhalter / Berry textbooks (in corpus).
  - FDA Bayesian Devices Guidance (in corpus).
- `designr` should expose MAP prior construction (`gMAP`), robustification (`robustify`), and ESS-based sample-size calculation via **RBesT** as first-class design elements.
- Teaching case: historical borrowing requires pre-specified mixture weight and simulation under prior-data conflict — not a free lunch.
- Sample-size calculation should integrate MAP ESS directly into the concurrent control N reduction.
