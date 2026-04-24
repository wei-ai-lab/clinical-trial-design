# ZOE-50 (2015) — Shingrix Zoster Vaccine

**Family:** count-rate · **Kind:** landmark Phase 3 vaccine · **Scope:** event-driven IRR / vaccine efficacy

## Why this case is in the corpus

- **Landmark zoster vaccine trial** — 97.2% VE, paradigm-shifting over 51% live Zostavax.
- Canonical **count-rate** primary analysis: vaccine efficacy VE = 1 − IRR.
- **Event-driven** design — pre-specified ≥ 84 confirmed cases.
- Exact conditional binomial test given total cases.
- Complemented by ZOE-70 (adults ≥ 70) pooled analyses.

## Citation

- Lal H, Cunningham AL, Godeaux O, et al. *Efficacy of an adjuvanted herpes zoster subunit vaccine in older adults.* N Engl J Med. 2015 May 28;372(22):2087-96.
- Cunningham AL, Lal H, Kovac M, et al. *Efficacy of the herpes zoster subunit vaccine in adults 70 years of age or older.* N Engl J Med. 2016 Sep 15;375(11):1019-32. (ZOE-70)

## Design summary

| Parameter | Value |
|---|---|
| Indication | Prevention of herpes zoster in adults ≥ 50 |
| Arms | HZ/su adjuvanted subunit vaccine (2 doses, 2 mo apart) vs placebo (1:1) |
| Primary endpoint | Confirmed herpes zoster cases |
| Analysis | IRR → VE = 1 − IRR; exact Poisson / conditional binomial |
| α / power | 0.025 one-sided / 95% |
| Target VE | 60% (lower CI > 25%) |
| Assumed control incidence | ~7 cases per 1,000 person-years |
| Target events | 84 confirmed cases |
| Randomized N | 15,411 |
| Mean follow-up | 3.2 years |

## VE calculation

```r
library(epiR)

# 6 cases in vaccine (pyr ~ 24,500), 210 in placebo (pyr ~ 24,500)
dat <- matrix(c(6, 24500, 210, 24500), nrow = 2, byrow = FALSE)
epi.2by2(dat, method = "cohort.time")
# Incidence rate ratio: 0.028 (0.012-0.063)
# Vaccine efficacy: 1 − IRR = 97.2%

library(exactci)
poisson.exact(c(6, 210), c(24500, 24500), tsmethod = "central")
```

## Sample-size calculation for VE

Under null H0: VE = 0 (IRR = 1), alternative H1: VE ≥ VE_target.

Approximate event count (using normal approximation on log IRR):

$$n_{\text{events}} \approx \frac{(z_\alpha + z_\beta)^2 \cdot [1 + 1/(1-VE)]}{[\ln(1-VE)]^2}$$

At VE 60%, α = 0.025, β = 0.05:
- z_α ≈ 1.96, z_β ≈ 1.645
- n ≈ (1.96 + 1.645)² × (1 + 2.5) / (ln 0.4)² ≈ 13 × 3.5 / 0.84 ≈ 54 — conservative sizing used 84.

Then total person-years = 84 / (incidence × (2−VE)) ≈ 84 / 0.0049 ≈ 17,000 PYR per arm.

## Stratification by age

Pre-specified strata:
- 50-59 years.
- 60-69 years.
- ≥ 70 years.

Age is dominant zoster risk factor. Stratification ensured valid overall VE and enabled VE estimation within age groups.

## Results

| Stratum | Vaccine cases | Placebo cases | VE (95% CI) |
|---|---|---|---|
| Overall (≥ 50) | 6 | 210 | **97.2% (93.7-99.0)** |
| 50-59 | 1 | 75 | 96.6% (89.6-99.4) |
| 60-69 | 2 | 68 | 97.4% (90.1-99.7) |
| ≥ 70 | 3 | 67 | 97.9% (87.9-100) |
| PHN (ZOE-50+70 pooled) | 4 | 36 | 88.8% (68.7-97.1) |

## Exact conditional test

Given total confirmed cases n = 216:
- Under H0: X_vac ~ Binom(216, 0.5).
- Observed: X_vac = 6.
- P(X_vac ≤ 6 | n = 216) ≈ extreme.
- Inverts to exact 95% CI on VE.

Exact conditional test avoids Poisson normal-approximation issues at low event counts.

## Regulatory & clinical impact

- FDA approval October 2017 (Shingrix, GSK).
- ACIP 2018: preferred recommendation over Zostavax.
- 2021 label expansion: immunocompromised ≥ 18 years.
- Shingrix replaced Zostavax as standard of care.

## Related vaccine trials

| Trial | Vaccine | VE (primary) |
|---|---|---|
| ZOE-50 (this case) | Shingrix zoster | 97.2% |
| ZOE-70 | Shingrix ≥ 70 | 89.8% |
| RotaTeq (in corpus) | Rotavirus | 74% |
| BNT162b2 (in corpus) | COVID-19 | 95% |
| RTS,S/AS01 (in corpus) | Malaria | 36% over 4 yr |

## How this case validates designr

- Adds the **highest-efficacy vaccine count-rate case** to count-rate corpus.
- `designr` should expose VE / IRR sample-size calculation via event-count approach (exact conditional binomial and Poisson).
- Teaches: age-stratified vaccine efficacy; event-driven design with high over-accrual; exact tests at low event counts.
- Contrasts with lower-efficacy malaria (RTS,S) and broad-spectrum COVID vaccine (BNT162b2) trials already in corpus.
