# PANORAMIC (2022) — UK Community COVID Antiviral Platform

**Family:** platform · **Kind:** landmark Phase 3 platform · **Scope:** open-label pragmatic community-based platform with Bayesian primary

## Why this case is in the corpus

- **First large-scale community pragmatic platform** for COVID-19 antivirals (UK NHS).
- Open-label, remote/decentralized, mail-delivered study drug.
- **Bayesian primary**: posterior probability of superiority > 0.98.
- Platform designed to add/drop arms as new antivirals become available.
- Complementary to ACTT-1 (hospitalized) — illustrates community vs hospital platform philosophies.
- Demonstrates challenges of trials in vaccinated, low-event-rate populations.

## Citation

- Butler CC, Hobbs FDR, Gbinigie OA, et al. *Molnupiravir plus usual care versus usual care alone as early treatment for adults with COVID-19 at increased risk of adverse outcomes (PANORAMIC): an open-label, platform-adaptive randomised controlled trial.* Lancet. 2023 Jan 28;401(10373):281-293.
- Yu LM, Hobbs FDR, Butler CC, et al. *PANORAMIC Platform trial protocol.* BMJ Open. 2022;12:e060464.

## Design summary

| Parameter | Value |
|---|---|
| Indication | Community COVID-19 at increased risk of severe outcome |
| Arms (initial) | Usual care vs usual care + molnupiravir 800 mg BID × 5 d |
| Primary endpoint | All-cause hospitalization or death within 28 days |
| Analysis | Bayesian risk-difference with posterior P > 0.98 for success |
| Power (frequentist equivalent) | 90% |
| Assumed risk difference | -1.5% |
| Control event rate | ~ 3% (initial design) → ~ 1% (Omicron reality) |
| Randomized N (molnupiravir) | 25,783 |
| Accrual | 14 months |

## Pragmatic community operations

1. Patient self-registers online or via GP referral.
2. Symptom screening → eligibility check.
3. Randomization central via RCT-hub.
4. Study drug mailed next-day.
5. Online daily symptom diary.
6. Day-28 follow-up via phone or online.

Key enablers:
- Open-label (no placebo manufacturing/distribution logistics).
- Shared usual-care control across sub-studies.
- NHS data linkage for hospitalization/death endpoints.

## Bayesian primary analysis

```r
library(rstanarm)

# Risk-difference Bayesian logistic regression
fit <- stan_glm(
  hosp_death ~ trt + age_cat + comorbidity_score,
  data = df,
  family = binomial(link = "identity"),
  prior = normal(0, 0.05),
  prior_intercept = normal(0.03, 0.02)
)

# Posterior probability of superiority
post <- as.matrix(fit)
prob_sup <- mean(post[, "trt"] < 0)
# Success threshold: prob_sup > 0.98
```

**Threshold calibration**:
- 0.98 posterior probability of superiority ≈ one-sided frequentist P < 0.025.
- Marginally more stringent to protect against prior-data conflict.

## Results (molnupiravir sub-study)

| Outcome | Molnupiravir | Usual care | Effect |
|---|---|---|---|
| Hospitalization or death (28 d) | 105 (1.0%) | 98 (1.0%) | RD -0.2% (-0.4 to 0.1) |
| Posterior P(superiority) | — | — | 0.57 (< 0.98 threshold) |
| Faster recovery (self-report) | -4 days | — | Bayesian-significant |
| Symptom duration | 9 days | 15 days | — |

**Conclusion**: molnupiravir NOT effective for hospitalization/death in vaccinated UK community population. NICE restricted use guidance.

## Context & challenges

- **Omicron era** (late 2021-2022): lower severity than Delta.
- **Highly vaccinated UK**: baseline hospitalization/death rate ~ 1% (vs 3-5% expected).
- **Low event rate** → very large N required; 25K+ randomized still gives wide CI.
- Sample size originally powered for higher baseline rate; re-analysis with smaller effect sizes.

## Platform operating model

- **Open-enrollment platform**: new arms can be added dynamically.
- **Nirmatrelvir-ritonavir (Paxlovid)** arm planned but didn't launch due to changing landscape.
- **Shared central infrastructure**: reduces per-arm cost.
- **DMC reviews**: per sub-study + overall safety.

## Related platform trials

| Trial | Setting | Design |
|---|---|---|
| ACTT-1 (in corpus) | Hospitalized severe | Placebo-controlled blinded |
| RECOVERY (in corpus) | Hospitalized | MAMS open-label |
| REMAP-CAP (in corpus) | Hospitalized ICU | Bayesian domain-based |
| Solidarity (in corpus) | Hospitalized | Global pragmatic |
| PANORAMIC (this case) | Community early | Pragmatic open-label Bayesian |

## How this case validates designr

- Adds a **community pragmatic platform** to the platform corpus — distinct from hospital-focused trials.
- `designr` should support Bayesian risk-difference primary with posterior probability threshold.
- Teaches: pragmatic remote trials, low-event-rate sizing, open-label trade-offs, Bayesian decision thresholds.
- Illustrates platform flexibility: designed to add Paxlovid arm but adapted to changing therapeutic landscape.
