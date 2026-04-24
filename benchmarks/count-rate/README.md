# count-rate — Count / rate endpoint Phase 3 designs

## Family overview

Phase 3 designs where the primary endpoint is an **event count per unit exposure time**. Distinct from recurrent-events in that the time ordering of events within a subject is typically secondary or ignored — the primary inference is on a **rate ratio** (λ_E / λ_C) via Poisson or negative binomial regression with a log offset for exposure time.

Canonical settings:
- **Epilepsy** — seizures per 28 days (primary for almost all AED adjunctive trials).
- **Asthma** — annual exacerbations (primary for mepolizumab, omalizumab, reslizumab, etc.).
- **Vaccine trials** — per-person-year incidence of target disease, sometimes binary VE but often rate-ratio.
- **Migraine** — monthly migraine days.
- **COPD** — annual exacerbations (overlaps with recurrent-events family).

## Common design pitfalls

- **Over-dispersion** — in almost every real count endpoint, variance exceeds mean. Poisson assumes variance = mean; NB adds dispersion parameter φ. Under-powering results when Poisson is assumed but NB dispersion is present.
- **Zero-inflation** — some subjects have intrinsically zero events (e.g., well-controlled asthma); ZINB or hurdle models may be appropriate.
- **Baseline rate stratification** — epilepsy/asthma trials randomize within baseline-rate strata; sample size formulas should account for stratification.
- **Percent-change vs rate ratio** — epilepsy industry convention reports median %Δ seizure frequency (Wilcoxon); but regulatory primary often now NB rate ratio. Both analyses matter.
- **Follow-up duration variance** — with variable exposure, use per-subject offset = log(follow-up time).

## R packages that implement this family

- **`MASS::glm.nb`** — negative binomial regression.
- **`stats::glm(family = poisson)`** — Poisson + quasi-Poisson for over-dispersion.
- **`pscl::zeroinfl`** — zero-inflated Poisson/NB.
- **`rpact::getSampleSizeCounts`** — NB rate-ratio sample size.
- **`gsDesign2::counts_`** — rate-ratio design.
- **`longpower`** — rate-based longitudinal sample size.

## Cases in this corpus

| Case | Year | Setting | Model |
|---|---|---|---|
| RotaTeq — rotavirus vaccine | 2006 | Rotavirus gastroenteritis episodes | Vaccine efficacy (Poisson rate) |
| MENSA — mepolizumab severe asthma | 2014 | Annual exacerbations | Negative binomial |
| Perampanel epilepsy study 304 | 2012 | Seizures per 28 days | Negative binomial + %Δ |
| Keene-Jones NB methodology | 2007 | Asthma/COPD design | NB sample size methodology |
