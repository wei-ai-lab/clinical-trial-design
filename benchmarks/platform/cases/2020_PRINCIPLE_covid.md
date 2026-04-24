# PRINCIPLE (2020-2023) — UK primary-care COVID adaptive platform

**Family:** platform · **Endpoint:** co-primary (time to recovery + hospitalization/death) · **N:** ~10,000 · **Design feature:** primary-care Bayesian adaptive multi-arm platform

## Why this case is in the corpus

- **Largest community-based COVID-19 trial** — first platform to run in primary care, not inpatient.
- Bayesian continuous-monitoring decision framework with MHRA acceptance.
- Reshaped outpatient COVID management (inhaled budesonide, Sep 2021).
- Operational template for pandemic preparedness platforms.

## Citation

Butler CC, Dorward J, Yu LM, et al. *Doxycycline for community treatment of suspected COVID-19 in people at high risk of adverse outcomes in the UK (PRINCIPLE): a randomised, controlled, open-label, adaptive platform trial.* Lancet. 2021;397(10279):1063-1074. Inhaled budesonide readout: Yu LM et al. Lancet 2021;398(10303):843-855. ISRCTN86534580.

## Design summary

| | |
|---|---|
| Design | Open-label Bayesian adaptive multi-arm platform, primary care |
| Population | Adults ≥ 65 (or ≥ 50 with comorbidity) with COVID-19 symptoms ≤ 14 d |
| Shared control | Usual care |
| Arms (over time) | Azithromycin, doxycycline, inhaled budesonide, colchicine, favipiravir, ivermectin |
| Co-primary | (1) Time to self-reported recovery (HR target 1.20); (2) hospitalization or death within 28 d (OR target 0.60) |
| Decision threshold | P(superior) > 0.975 for efficacy; P(benefit) < 0.01 for futility |
| Planned total N | ~10,000 (4-6 arms × 1,500-2,500 each) |

## Reproducing the design

```r
library(brms)
# Bayesian proportional hazards on time to recovery with arm effect
fit <- brm(
  recovery | cens(censor) ~ arm + age + comorbidity,
  data = trial_df,
  family = weibull(),
  prior = set_prior("normal(0, 1)", class = "b"),
  iter = 4000, chains = 4
)

# Continuous monitoring: stop arm if P(HR > 1) > 0.975
posterior_prob_benefit <- mean(posterior_samples(fit)$b_armIntervention > 0)
if (posterior_prob_benefit > 0.975) declare_efficacy()
if (posterior_prob_benefit < 0.01)  drop_for_futility()
```

## Trial outcome

- **Inhaled budesonide**: median time to recovery 11.8 vs 14.7 d (diff ~3 d); posterior probability superior > 0.999 → NHS treatment guidance updated fall 2021.
- **Azithromycin, doxycycline, colchicine, favipiravir, ivermectin**: no benefit on either co-primary — dropped for futility.
- Established that **primary-care platforms are feasible** at pandemic pace.

## How this case validates designr

- Bayesian continuous-monitoring reference.
- Shared-control platform efficiency in real-world primary care operations.
- Co-primary Bayesian decision framework benchmark.
- Complementary to REMAP-CAP (ICU) and RECOVERY (inpatient) platforms — spans full care spectrum.
