# Benchmark glossary

Terms and conventions used throughout the benchmark corpus. Referenced by cases so prose stays short.

## General

- **Phase 3 / pivotal trial** — confirmatory trial intended to support a regulatory submission.
- **α / Type I error** — probability of rejecting H₀ when true. Unless stated, the reported α is the **family-wise error rate** controlled for the primary analysis.
- **Sidedness** — `sidedness: 2` means α is split; `sidedness: 1` means all α is on the hypothesized direction. Pharma default for superiority: two-sided α = 0.05. NI is usually one-sided at α = 0.025.
- **Power (1−β)** — probability of rejecting H₀ under the assumed effect.

## Endpoints

- **Binary** — cured/not, responder/not. Effect specified as risk ratio, odds ratio, or risk difference.
- **Continuous** — change from baseline. Effect specified as mean difference + pooled SD.
- **Time-to-event (TTE)** — sample size driven by *events*, not subjects. Effect specified as hazard ratio (PH) or survival functions (NPH).
- **Recurrent event** — counts of events per subject. Analyzed via negative binomial, Andersen-Gill, LWYY, or joint frailty.
- **Count / rate** — seizure count, exacerbation count. Often Poisson or NB with offset for exposure.
- **Ordinal** — e.g. modified Rankin Scale. Analyzed via proportional odds or shift analysis.

## Comparison types

- **Superiority** — H₀: treatment ≤ control; H₁: treatment > control (or two-sided).
- **Non-inferiority (NI)** — H₀: treatment worse than control by more than margin Δ; H₁: treatment worse by at most Δ. The margin must be pre-specified and justified.
- **Equivalence** — H₀: difference outside (−Δ, +Δ); H₁: difference inside. Requires two one-sided tests (TOST).

## Group-sequential

- **Spending function** — function α(t) or β(t) on information fraction t ∈ [0, 1] that allocates type I / II error across analyses.
- **O'Brien-Fleming (OBF)** — conservative early, reaches full α at t=1. Canonical choice for efficacy.
- **Pocock** — constant boundary on z-scale; equal α at each look. Rarely used alone in confirmatory trials.
- **Lan-DeMets** — family of *continuous* spending functions approximating OBF or Pocock, robust to unequal information fractions. De-facto standard.
- **Hwang-Shih-DeCani (HSD)** — parametric family indexed by γ; `γ=-4` ≈ OBF, `γ=1` ≈ Pocock.
- **Non-binding futility** — futility boundary treated as non-binding in α calculation (DSMB can override). Standard for efficacy-preserving futility.
- **Binding futility** — futility is mandatory; lowers type I error but removes flexibility. Used when sponsor commits to stopping.
- **Information fraction (IF)** — for TTE designs, `events_at_analysis / total_events`; for others, `N_at_analysis / total_N`.

## Non-proportional hazards

- **Delayed effect** — treatment effect emerges after a delay (immuno-oncology typical: 3–6 months). Log-rank underpowered.
- **Crossing curves** — short-term harm, long-term benefit (some surgical interventions).
- **Cure fraction** — a proportion of patients are event-free asymptotically.
- **Weighted log-rank (Fleming-Harrington, G^ρ,γ)** — up-weights late events; `ρ=0, γ=1` emphasizes late separation.
- **MaxCombo** — takes max of standard + weighted log-rank; robust across NPH patterns. Implemented in `simtrial`, `gsDesign2`.
- **RMST (restricted mean survival time)** — area under survival curve up to τ; interpretable without PH.

## Adaptive designs

- **SSR (sample-size re-estimation)** — update N mid-trial.
  - *Blinded* — use pooled variance / overall event rate; low type-I risk.
  - *Unblinded* — uses interim treatment effect; requires preservation method (Cui-Hung-Wang, conditional power, promising-zone).
- **Promising zone** — Mehta-Pocock 2011: increase N if conditional power is in a "promising" band.
- **Enrichment** — narrow eligibility at interim based on biomarker subgroup performance.
- **Treatment selection / pick-the-winner** — MAMS-like: drop arms at interim, continue with best.
- **Combination-function approach** — Bauer-Köhne, inverse-normal: combines stage-wise p-values with pre-specified weights.
- **Conditional error rate (CER)** — Proschan-Hunsberger: preserve type I by constraining how the second-stage test is constructed.

## Master protocols

- **Platform trial** — ongoing trial with arms added/removed over time, usually shared control. Ex: RECOVERY, REMAP-CAP, I-SPY2, STAMPEDE.
- **Basket** — one treatment, many indications (usually biomarker-defined).
- **Umbrella** — one indication, many treatments (often biomarker-matched).

## Effect-size conventions used in YAML

### Binary
```yaml
effect:
  control_rate: 0.10
  treatment_rate: 0.075        # OR rr: 0.75   OR rd: -0.025
```

### Continuous
```yaml
effect:
  mean_diff: 35                 # treatment - control
  sd: 70
```

### Time-to-event, PH
```yaml
effect:
  hr: 0.75
  control_median: 12           # months — used to derive event time
```

### Time-to-event, NPH
```yaml
effect:
  model: "delayed"              # or "crossing", "cure", "piecewise"
  params:
    delay_months: 3
    hr_early: 1.0
    hr_late: 0.6
```

### Recurrent event (NB)
```yaml
effect:
  control_rate: 1.2              # events/year
  rate_ratio: 0.75
  dispersion: 0.6                # NB dispersion k
```

### Count / rate
```yaml
effect:
  control_rate: 8.0              # seizures / 4 weeks
  rate_ratio: 0.70
  exposure_time: 28              # days
```
