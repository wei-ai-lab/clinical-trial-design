# recurrent-events — Recurrent event Phase 3 designs

## Family overview

Phase 3 designs where each participant can experience the primary event **more than once**. Examples: heart failure hospitalizations, COPD/asthma exacerbations, seizures, falls, stroke/TIA recurrences, bone fractures. The key design choice is the **event model**:

1. **Marginal means/rates** — Lin-Wei-Yang-Ying (LWYY) 2000 model — treats each person's counting process and regresses cumulative mean function. Robust to within-subject correlation.
2. **Negative binomial** (NB) — models per-person event count with offset = follow-up time; extra-Poisson variability via over-dispersion parameter.
3. **Joint frailty models** — Rogers-Pocock 2016 and Ghosh-Lin — jointly model recurrent event + terminating event (death), accounting for informative censoring.
4. **Andersen-Gill** — Cox-type recurrent-event model; assumes PH of intensity. Valid when gap times are approximately independent.
5. **WLW / PWP marginal/conditional** — Wei-Lin-Weissfeld or Prentice-Williams-Peterson; different treatments of event-number strata.

## Common design pitfalls

- **Informative censoring by death**: ignoring terminal event (death) biases rate estimates when treatment affects both. Use LWYY with CV-death as competing event or joint frailty.
- **Over-dispersion**: NB sample size formulas require realistic φ (dispersion); often under-estimated, causing under-power.
- **Mean cumulative function interpretation**: LWYY rate ratio is a marginal mean ratio, not a hazard ratio — regulatory interpretation must be clear.
- **Baseline rate stratification**: COPD and asthma trials stratify by prior exacerbation rate; imbalance → biased NB estimate.
- **First-event-only dilution**: TTE-to-first-event designs waste information from subsequent events, and interpret as smaller effect than true rate ratio.

## R packages that implement this family

- **`WR`** — win ratio for recurrent + terminal composites.
- **`survival::coxph`** with `cluster()` — Andersen-Gill, LWYY via robust variance.
- **`frailtypack`** — joint frailty models for recurrent + terminal.
- **`reReg`** — recurrent event regression with full spectrum of models.
- **`MASS::glm.nb`** — negative binomial rate regression.
- **`rpact`** — approximates via Poisson/NB rate sample size.
- **`gsDesign2`** — rate-based recurrent-event sizing.

## Cases in this corpus

| Case | Year | Model | Setting |
|---|---|---|---|
| Lin-Wei-Yang-Ying methodology | 2000 | Marginal means/rates | Foundational recurrent-event methodology |
| UPLIFT — tiotropium COPD | 2008 | Negative binomial | Exacerbation rate over 4 years |
| TORCH — salmeterol/fluticasone COPD | 2007 | Poisson rate | Exacerbation rate + OS |
| Rogers-Pocock joint frailty methodology | 2014 | Joint frailty (recurrent HF hosp + CV death) | HF composite design |
