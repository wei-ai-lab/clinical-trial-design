# Rosenberger-Lachin (2015) — Response-Adaptive Randomization

**Family:** non-standard · **Kind:** methodology-textbook · **Scope:** canonical reference on response-adaptive randomization

## Why this case is in the corpus

- **Most-cited modern textbook on randomization methodology** — comprehensive reference for response-adaptive randomization (RAR) design, analysis, and regulatory considerations.
- Covers play-the-winner (Wei-Durham), DBCD (Hu-Rosenberger), Bayesian adaptive randomization, and Neyman-optimal allocation.
- Authoritative source on chronological-bias and type-I-error concerns that shape regulatory skepticism toward RAR in confirmatory trials.
- Canonical non-standard design entry complementing SMART (Murphy 2005), seamless (Bauer-Kieser), win-ratio (Pocock).

## Citation

Rosenberger WF, Lachin JM. *Randomization in Clinical Trials: Theory and Practice.* 2nd edition. Wiley Series in Probability and Statistics; 2015.

## RAR schemes catalog

| Scheme | Allocation rule | Best for |
|---|---|---|
| Play-the-winner (Wei-Durham 1978) | Urn with balls of winning arm added on each success | Pedagogical |
| Randomized play-the-winner (RPW) | Probabilistic version of urn | Early Phase 2 |
| DBCD (Hu-Rosenberger 2003) | Target allocation ρ*, converges asymptotically | Phase 2 with efficiency goals |
| Bayesian adaptive (BAR) | Allocation ~ posterior prob of best | I-SPY2, BATTLE |
| Neyman-optimal | Minimize variance of Δ̂ | Theoretical benchmark |

## Algorithm

```r
# DBCD (Hu-Rosenberger) pseudocode
# Target allocation ρ* derived from optimality criterion (Neyman,
# ethical, or hybrid).
# At each patient i, compute P(treatment_A) = g(current allocation,
# target, accumulated data).
# Allocate via biased coin using this probability.

library(adaptr)
# Simulate a Bayesian adaptive-randomization trial
spec <- setup_trial_binom(
  arms = c("control", "active1", "active2"),
  true_ys = c(0.3, 0.4, 0.5),
  fixed_ys = c(0.3, 0.3, 0.3),   # null allocation
  start_probs = rep(1/3, 3),
  randomised_at_looks = c(100, 200, 300, 400, 500),
  control = "control",
  allocation_ratios = "BAR"       # Bayesian adaptive randomization
)
sim <- run_trial(spec, seed = 42)
# Evaluate: type I, power, expected allocation, chronological drift
```

## Key cautions from the textbook

1. **Chronological bias** — allocation probability evolves with time; patient mix can drift (seasonality, SoC changes). Stratification and time-adjustment essential.
2. **Type I error** — can inflate beyond nominal α under certain nuisance-parameter scenarios. Requires simulation verification.
3. **Analysis** — standard t-test and logistic regression are only asymptotically valid; randomization-based inference preferred.
4. **Sample-size planning** — expected-N savings depend heavily on true effect; can be smaller than with fixed allocation if effect is null.

## Real applications

- **ECMO neonatal trial (Bartlett 1985)** — first notable RPW; highly controversial.
- **I-SPY2** — BAR within Bayesian adaptive platform.
- **BATTLE / BATTLE-2 (umbrella, in corpus)** — BAR by biomarker subgroup.
- **REMAP-CAP, RECOVERY (platform, in corpus)** — hybrid stratified adaptive randomization.
- **Several Phase 2 oncology trials** — cisplatin-etoposide variant doses.

## Regulatory context

- **FDA 2019 Adaptive Designs guidance**: supportive with strong cautions — requires pre-specification of rule, simulation of operating characteristics, and evaluation of chronological bias risk.
- **EMA Reflection Paper on Adaptive Designs (2007)**: cautious; prefers fixed allocation for confirmatory Phase 3.
- **ICH E9(R1) estimands (2019)**: compatible with RAR if estimand and DTR are clearly articulated.

## How this case validates designr

- Adds the **RAR methodology perspective** to the non-standard corpus — a distinct adaptive-allocation design not covered by adaptive-ssr, adaptive-enrichment, or adaptive-selection families.
- `designr` should expose RAR simulation (adaptr or custom) as a design class alongside fixed-allocation designs.
- Teaching case for when RAR is ethically compelling vs when fixed allocation is preferable (regulatory, operational simplicity, chronological-bias protection).
