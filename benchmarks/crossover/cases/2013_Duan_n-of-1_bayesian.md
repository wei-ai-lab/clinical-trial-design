# Duan-Kravitz-Schmid (2013) — N-of-1 Bayesian Hierarchical Framework

**Family:** crossover · **Kind:** methodology-paper · **Scope:** single-patient multi-period crossover with Bayesian hierarchical pooling

## Why this case is in the corpus

- **Canonical modern framework** for N-of-1 trials — the most extreme form of within-subject crossover.
- Introduces Bayesian hierarchical pooling that enables borrowing strength across N-of-1 patients while preserving individual inference.
- PCORI and comparative-effectiveness research template — increasingly used for patient-centered care decisions.
- Complements Jones-Kenward's N-of-1 chapter (in corpus) with explicit Bayesian methodology.

## Citation

- Duan N, Kravitz RL, Schmid CH. *Single-patient (n-of-1) trials: a pragmatic clinical decision methodology for patient-centered comparative effectiveness research.* J Clin Epidemiol. 2013 Aug;66(8 Suppl):S21-8.
- Schork NJ. *Personalized medicine: time for one-person trials.* Nature. 2015 Apr 30;520(7549):609-11.

## Core design

| Element | Value |
|---|---|
| Patients | Individual; sometimes pooled across a registry |
| Periods per patient | ≥ 3 AB pairs (typical 3-6) |
| Sequence | Randomized crossover (AB BA AB...) with washout |
| Analysis | Individual paired + (optional) Bayesian hierarchical pooling |
| Target estimand | Patient-specific δ_i; population μ if pooled |

## Algorithm

```r
# Single-patient N-of-1 with paired analysis
library(stats)
# Patient data: treatment periods A, B within same subject
paired_result <- t.test(x = outcomes_B, y = outcomes_A, paired = TRUE)
# Individual-level inference

# Bayesian hierarchical pooling across multiple N-of-1 patients
library(brms)
fit <- brm(
  outcome ~ treatment + (1 + treatment | patient_id),
  data = n_of_1_registry_df,
  family = gaussian(),
  prior = c(
    prior(normal(0, 1), class = "b"),     # fixed effect on treatment
    prior(student_t(3, 0, 2.5), class = "sd")  # random-effect heterogeneity
  ),
  chains = 4, iter = 2000, seed = 42
)
# Posterior of δ_i (each patient) and μ (population average)

# Per-patient sample-size heuristic
library(pwr)
# Given within-subject SD sigma_W and detectable effect delta:
pwr.t.test(d = 0.8, power = 0.80, type = "paired", alternative = "two.sided")
# n = number of AB pairs per patient
```

## Typical design parameters

- 3-4 AB pairs per patient for 80% power when effect = within-subject σ_W.
- Larger pair counts for smaller effects or more heterogeneous patients.
- Pooled hierarchical N-of-1 registries: ~20-100 patients total with 3-4 pairs each.
- Bayesian hierarchical priors calibrated from sceptical, enthusiastic, or reference positions.

## When N-of-1 works

- **Chronic, stable condition** — disease state doesn't drift over trial period.
- **Rapid-response treatment** — days to weeks to reach effect (not months).
- **Individualized outcome** — PRO, symptom score, or biomarker.
- **Reversible effect** — patient returns to baseline during washout.

## Real applications

- **Migraine**: triptan comparison for individual patient.
- **Attention disorders**: stimulant dose optimization.
- **Fibromyalgia / chronic pain**: individualized pharmacotherapy choice.
- **Rare disease registries**: pooled N-of-1 for orphan drug CER.
- **PCORI networks**: N-of-1 for patient-centered CER.

## How this case validates designr

- Adds the **Bayesian hierarchical N-of-1 framework** as a distinct crossover subtype in the corpus.
- `designr` should expose N-of-1 sizing via simulation + Bayesian framework (brms / rstan) alongside traditional crossover.
- Teaching case: when individual patient response variability is high and treatments are reversible, N-of-1 is statistically principled and clinically compelling.
