# IMPACT (2018) — Triple Therapy in COPD

**Family:** recurrent-events · **Kind:** landmark Phase 3 · **Scope:** negative-binomial exacerbation rate with 2:2:1 allocation

## Why this case is in the corpus

- Largest **single-inhaler triple-therapy** Phase 3 in COPD (N = 10,355).
- **Negative binomial regression** primary analysis for recurrent exacerbations — canonical modern COPD design.
- **Three-arm 2:2:1** allocation with Hochberg closed testing across two primary dual comparisons.
- FDA-approved label expansion (2020) for **mortality reduction** in COPD.

## Citation

- Lipson DA, Barnhart F, Brealey N, et al. *Once-daily single-inhaler triple versus dual therapy in patients with COPD.* N Engl J Med. 2018 May 3;378(18):1671-1680.
- Pascoe SJ, Lipson DA, Locantore N, et al. *A phase III randomised controlled trial of single-dose triple therapy in COPD: the IMPACT protocol.* Eur Respir J. 2016 Aug;48(2):320-30.

## Design summary

| Parameter | Value |
|---|---|
| Indication | Moderate-severe COPD with exacerbation history |
| Arms | FF/UMEC/VI (triple) : FF/VI (ICS/LABA) : UMEC/VI (LAMA/LABA) = 2:2:1 |
| Primary endpoint | Annual rate of moderate-severe exacerbations |
| Analysis | Negative binomial with log(on-treatment time) offset |
| α / power | 0.05 (2-sided) / 90% |
| Assumed control rate | ~1.10/year |
| Target RR vs each dual | 0.83-0.85 |
| Duration | 52 weeks double-blind |
| Randomized N | 10,355 |

## Primary analysis model

```r
library(MASS)

# Negative binomial regression, rate ratio
fit <- glm.nb(
  exac_count ~ trt + region + smoke_status + prior_exac_cat +
               offset(log(on_trt_years)),
  data = df
)
summary(fit)

# Rate ratio and 95% CI
rr <- exp(coef(fit)["trtTriple"])
ci <- exp(confint(fit)["trtTriple", ])
```

## Sample size approach

- Annual rate on dual therapy: 1.10 events/patient-year.
- Target 15-17% relative reduction.
- Over-dispersion k ~ 0.5 estimated from TORCH (in corpus) and UPLIFT (in corpus).
- ~ 10,000 total subjects at 2:2:1 yields 90% power for both primary dual comparisons at α = 0.05 two-sided.

## Multiplicity: Hochberg

Two primary comparisons (triple vs each dual):
1. FF/UMEC/VI vs FF/VI.
2. FF/UMEC/VI vs UMEC/VI.

Hochberg procedure:
- Sort P-values P(1) ≤ P(2).
- If P(2) ≤ 0.05, both rejected.
- Else if P(1) ≤ 0.025, reject only P(1).

## Results

| Comparison | Rate (/yr) | RR (95% CI) | P |
|---|---|---|---|
| Triple vs FF/VI | 0.91 vs 1.07 | 0.85 (0.80-0.90) | < 0.001 |
| Triple vs UMEC/VI | 0.91 vs 1.21 | 0.75 (0.70-0.81) | < 0.001 |
| Severe exac hosp (Triple vs UMEC/VI) | — | HR 0.66 (0.56-0.78) | — |
| All-cause mortality (Triple vs UMEC/VI) | — | HR 0.72 (0.53-0.99) | secondary |

## Regulatory & clinical impact

- FDA approval 2017 for COPD maintenance (Trelegy Ellipta, GSK).
- 2020 label expansion: reduced all-cause mortality in COPD — first inhaled therapy with this label.
- 2023 GOLD report: triple therapy recommended for exacerbating eos ≥ 100-300.

## Related COPD trials

| Trial | Year | Design role |
|---|---|---|
| TORCH (in corpus) | 2007 | First major ICS/LABA mortality Phase 3 |
| UPLIFT (in corpus) | 2008 | Tiotropium monotherapy 4-yr |
| FLAME | 2016 | LAMA/LABA vs ICS/LABA |
| IMPACT (this case) | 2018 | Single-inhaler triple Phase 3 |
| ETHOS | 2020 | Replicated IMPACT with budesonide triple |

## How this case validates designr

- Adds the **canonical triple-therapy COPD design** to recurrent-events complementing TORCH/UPLIFT.
- `designr` should expose negative binomial sample-size calc (e.g., `MESS::power_t_test` for NB, or custom simulation) with over-dispersion, rate, exposure-time offset.
- Teaches: three-arm design with 2:2:1 allocation and Hochberg closed testing.
- On-treatment follow-up vs. ITT: pre-ICH E9(R1) estimand considerations.
