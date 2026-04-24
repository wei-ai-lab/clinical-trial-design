# PARAGON-HF (2019) — Sacubitril/valsartan in HFpEF, recurrent-event primary

**Family:** recurrent-events · **Endpoint:** total HFH + CV death · **N:** 4,822 · **Design feature:** first Phase 3 HF trial with total-event primary composite

## Why this case is in the corpus

- **First confirmatory Phase 3 HF trial with a total-event (recurrent) primary composite**.
- Narrow-miss primary (p = 0.059) led to the first **partial-benefit HF labeling** (FDA 2021, LVEF ≤ ~57%).
- Analytical template (semiparametric joint frailty per Rogers-Pocock 2014) is now the HF-trial standard.
- Benchmark for sample sizing under LWYY / joint frailty in HF.

## Citation

Solomon SD, McMurray JJV, Anand IS, et al. *Angiotensin-neprilysin inhibition in heart failure with preserved ejection fraction.* N Engl J Med. 2019;381(17):1609-1620. doi:10.1056/NEJMoa1908655. NCT01920711.

## Design summary

| | |
|---|---|
| Design | Double-blind RDB, total-event primary |
| Population | HFpEF, LVEF ≥ 45%, NYHA II-IV, elevated BNP/NT-proBNP, structural heart disease |
| Arms | Sacubitril/valsartan 97/103 mg BID vs valsartan 160 mg BID |
| Primary | Total (first + recurrent) HF hospitalizations + CV death |
| Analysis | Semiparametric joint frailty model (LWYY for recurrent HFH + Cox for CV death) |
| Rate-ratio target | 0.80 |
| Control total-HFH rate | 0.13 per patient-year |
| Control CV-death rate | 0.036 per patient-year |
| α | 0.05 two-sided |
| Power | 0.80 |
| Planned N | 4,822 |
| Expected events | 1,571 |

## Reproducing the design

```r
library(frailtypack)
# Semiparametric joint frailty for total HFH + CV death
fit <- frailtyPenal(
  Surv(start, stop, hosp_event) ~ arm + terminal(cv_death),
  formula.terminalEvent = ~ arm,
  data = paragon_df,
  n.knots = 8, kappa = c(1e5, 1e5), recurrentAG = TRUE
)

# Sample-size sizing (rate-ratio approach)
library(gsDesign)
# Simplified: approximate via LWYY effective sample size
events_primary <- ceiling(log(1/0.80)^2 /
                          ((qnorm(1 - 0.025) + qnorm(0.80))^2 * 0.25))^(-1)
```

## Trial outcome

- **Primary**: rate ratio 0.87 (95% CI 0.75-1.01), **p = 0.059** — narrowly missed.
- **LVEF 45-57% subgroup** (n = 2,495): RR 0.78 (0.64-0.95), p = 0.017 → FDA approval Feb 2021 for "below-normal EF" labeling.
- **Win ratio sensitivity**: WR 1.13 (1.03-1.23) — consistent with primary direction.
- **Total HFH component** alone: RR 0.85 (0.72-1.00), p = 0.056.
- **CV death component**: HR 0.95 (0.79-1.16), NS.

## How this case validates designr

- Joint-frailty sample-size benchmark for HF total-event primary.
- Rogers-Pocock 2014 analytical framework worked example.
- LWYY + Cox combined-analysis reference implementation.
- Historical precedent for partial-benefit / subgroup labeling — relevant to adaptive enrichment sizing.
- Narrow-miss with positive subgroup — teaching case for over-powered subgroup analyses.
