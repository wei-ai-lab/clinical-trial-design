# Rogers-Pocock (2014) — joint frailty for recurrent HF hospitalization

**Family:** recurrent-events · **Endpoint:** recurrent HF hosp + CV death (joint frailty) · **Design feature:** terminal-event informative censoring handled

## Why this case is in the corpus

- **Field-standard methodology reference** for HF hospitalization recurrent-event analyses.
- Joint frailty handles informative censoring by CV death.
- CHARM-Preserved re-analysis demonstrates TTE information loss vs recurrent model.

## Citation

Rogers JK, Pocock SJ, McMurray JJV, et al. *Analysing recurrent hospitalizations in heart failure: a review of statistical methodology, with application to CHARM-Preserved.* Eur J Heart Fail. 2014;16(1):33-40. doi:10.1002/ejhf.29.

## Design summary

| | |
|---|---|
| Framework | Methodology — joint frailty model |
| Rate function | λ₁(t) = λ₁₀(t) · u · exp(β₁Z) |
| Terminal event | λ₂(t) = λ₂₀(t) · u^α · exp(β₂Z) (u = shared gamma frailty) |
| Rate ratio | exp(β₁) for recurrent; hazard ratio for terminal |
| α / power | 0.05 (two-sided) / 0.90 example |
| Example rate RR | 0.80 (HF hospitalization) |
| Example HR | 0.90 (CV death) |
| Example N | ~3,000 |

## Reproducing the test

```r
library(frailtypack)
# Joint frailty for recurrent HF hosp + CV death
fit <- frailtyPenal(
  Surv(t_start, t_stop, hf_hosp) ~ arm + cluster(id) + terminal(cv_death),
  data = df, n.knots = 10, kappa = c(1000, 1000),
  recurrentAG = TRUE
)
```

## Key methodology points

- **Shared gamma frailty** u captures unobserved subject-level risk.
- **α parameter** relates recurrent-event frailty to terminal-event risk.
- **CHARM-Preserved illustration**:
  - TTE-to-first HF hosp: HR 0.85 (candesartan)
  - LWYY rate ratio: RR 0.77
  - Joint frailty rate ratio: RR 0.75
  - Information gain from using all events is substantial
- **Regulatory adoption**: DAPA-HF, EMPEROR, PARADIGM-HF, FINEARTS-HF all use recurrent-event methodology.
- **Alternative**: win ratio (Pocock 2012) combines recurrent + terminal hierarchically.

## How this case validates designr

- Joint frailty reference for HF recurrent hospitalization + terminal death.
- Backbone of `frailtypack` design specification.
- Illustrates information gain from recurrent-event methods over TTE-to-first.
