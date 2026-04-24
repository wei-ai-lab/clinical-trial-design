# RTS,S/AS01 (2015) — First Malaria Vaccine Phase 3

**Family:** count-rate · **Kind:** landmark Phase 3 vaccine · **Scope:** negative binomial recurrent-episode design

## Why this case is in the corpus

- **First malaria vaccine** to complete Phase 3 and receive WHO broad recommendation (2021).
- **Negative binomial** recurrent-episode primary — canonical for high-incidence endemic disease.
- Dual-cohort design (6-12 week infants, 5-17 month children) across 7 African countries.
- **Waning immunity + booster** design captured in 48-month follow-up.
- Modest VE (~ 35%) but large public health impact given malaria burden.

## Citation

- RTS,S Clinical Trials Partnership. *Efficacy and safety of RTS,S/AS01 malaria vaccine with or without a booster dose.* Lancet. 2015 Jul 4;386(9988):31-45.
- RTS,S Clinical Trials Partnership. *A phase 3 trial of RTS,S/AS01 malaria vaccine in African infants.* N Engl J Med. 2012 Dec 13;367(24):2284-2295.

## Design summary

| Parameter | Value |
|---|---|
| Indication | Clinical malaria prevention in African children/infants |
| Arms | RTS,S + booster : RTS,S no booster : comparator (1:1:1) |
| Primary endpoint | Clinical malaria episodes (NB recurrent-event) |
| α / power | 0.025 one-sided / 80% |
| Target VE | 50% |
| Assumed control incidence | ~ 0.5 / person-year |
| Follow-up | 32 months (no booster) / 48 months (with booster) |
| Randomized N | 15,459 (6,537 infants + 8,922 children) |
| Sites | 11 across 7 African countries |

## Case definition

Clinical malaria episode:
- Axillary temperature ≥ 37.5°C.
- AND P. falciparum parasite density > 5,000/μL (primary).
- Secondary definitions: ≥ 500/μL; severe malaria; hospitalization; death.

## Primary analysis model

```r
library(glmmTMB)

# Negative binomial with log PYR offset, site as random effect
fit <- glmmTMB(
  n_episodes ~ arm + age_cohort + (1 | site) + offset(log(pyr)),
  data = df,
  family = nbinom2
)
summary(fit)

# Vaccine efficacy
irr <- exp(coef(summary(fit))[["cond"]]["armRTSS", "Estimate"])
ve <- 1 - irr
```

**Why NB over Poisson**:
- Over-dispersion k ~ 0.5-1.0 — children experience correlated recurrent episodes.
- Heterogeneity in transmission across sites.
- Poisson underestimates SE.

**Alternative models considered**:
- **Andersen-Gill** recurrent event TTE.
- **LWYY** (Lin-Wei-Yang-Ying 2000, in corpus).
- **Frailty** (shared gamma frailty by child).

## Sample-size reasoning

Normal approximation on log IRR for NB:

$$n_{\text{events}} \approx \frac{(z_\alpha + z_\beta)^2 \cdot [1 + 1/(1-VE)^2]}{[\ln(1-VE)]^2}$$

Inflated for:
- NB over-dispersion factor (1 + k · mean).
- Site clustering (design effect).
- Multiplicity across cohorts.

Results in ~ 15,000 total randomized to accumulate sufficient events with VE detectable at 30%+ lower bound.

## Key results (final, 48-month follow-up)

| Cohort / outcome | VE (95% CI) |
|---|---|
| 5-17 mo, with booster, clinical malaria | **36.3% (31.8-40.5)** |
| 6-12 wk, with booster, clinical malaria | 25.9% (19.9-31.5) |
| 5-17 mo, with booster, severe malaria | 32.2% (13.7-46.9) |
| 5-17 mo, without booster, clinical malaria | 28.3% |
| 6-12 wk, without booster, clinical malaria | 18.3% |

**Cases prevented**: ~ 1,774 per 1,000 vaccinated children over 4 years (older cohort with booster).

## Waning immunity + booster

- Primary series efficacy: ~ 50% in first year.
- Drops to ~ 20% by year 4 without booster.
- Booster (month 20) restores efficacy partially.
- Motivation for R21/Matrix-M (2023) reformulation.

## Regulatory & policy milestones

- 2015: EMA positive opinion under Art 58.
- 2016: WHO Malaria Vaccine Implementation Program (MVIP) pilots.
- 2019: MVIP launches in Ghana, Kenya, Malawi.
- **Oct 2021**: WHO broad recommendation for use in moderate-high transmission areas.
- 2023: R21/Matrix-M complementary recommendation (77% VE over 12 months in seasonal).

## Related vaccine count-rate trials

| Trial | Vaccine | VE |
|---|---|---|
| RotaTeq (in corpus) | Rotavirus | 74% severe |
| ZOE-50 (in corpus) | Shingrix zoster | 97% |
| BNT162b2 (in corpus) | COVID-19 | 95% |
| RTS,S/AS01 (this case) | Malaria | 36% over 48 mo |
| R21/Matrix-M | Malaria (new formulation) | 77% over 12 mo |

## How this case validates designr

- Adds a **recurrent-episode NB vaccine trial** to count-rate corpus.
- `designr` should expose NB sample-size calculation with log-PYR offset and over-dispersion; site clustering design effect.
- Teaches: recurrent episodes warrant NB (not time-to-first), waning immunity requires booster analysis, modest VE can still be high public-health value.
- Contrasts with Shingrix (97% VE in adults) and BNT162b2 (95% VE COVID) by showing the design challenge when VE is modest but burden high.
