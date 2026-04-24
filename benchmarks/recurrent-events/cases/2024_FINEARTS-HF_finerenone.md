# FINEARTS-HF (2024) — Finerenone in HFmrEF/HFpEF

**Family:** recurrent-events · **Kind:** landmark Phase 3 · **Scope:** first major HF trial with LWYY recurrent-event + CV death as primary

## Why this case is in the corpus

- **Paradigm case** for modern recurrent-event primary analysis in HF trials.
- **LWYY (Lin-Wei-Yang-Ying) 2000** semiparametric model applied to total worsening HF + CV death.
- First non-steroidal MRA for HFmrEF / HFpEF — positive outcome trial (2024).
- Demonstrates regulatory acceptance of rate-ratio primary over first-event HR.
- Complements PARAGON-HF (2019), EMPEROR-Preserved, DELIVER in HFpEF quadruple-therapy era.

## Citation

- Solomon SD, McMurray JJV, Vaduganathan M, et al. *Finerenone in heart failure with mildly reduced or preserved ejection fraction.* N Engl J Med. 2024 Oct 17;391(16):1475-1485.
- Vaduganathan M, Filippatos G, Claggett BL, et al. *FINEARTS-HF trial design.* Eur Heart J. 2024 Mar 21;45(12):1048-1058.

## Design summary

| Parameter | Value |
|---|---|
| Indication | HFmrEF/HFpEF (LVEF ≥ 40%), NYHA II-IV, elevated NT-proBNP |
| Arms | Finerenone 10-40 mg OD vs placebo (1:1) |
| Primary endpoint | Total worsening HF events + CV death (recurrent composite) |
| Analysis | LWYY semiparametric model, robust sandwich variance |
| α / power | 0.05 (2-sided) / 90% |
| Assumed rate ratio | 0.80 |
| Control annual composite rate | ~0.23 |
| Target total events | ~1,450 |
| Randomized N | 6,001 |

## LWYY primary analysis

```r
library(survival)

# LWYY via Andersen-Gill format with robust sandwich SE
# One row per event, cluster = subject ID
fit <- coxph(
  Surv(start, stop, event) ~ trt + strata(region) + cluster(id),
  data = recurrent_df,
  method = "breslow"
)
summary(fit)
# Rate ratio + robust 95% CI
```

**Key properties**:
- Semiparametric proportional rates (not proportional hazards).
- Marginal model — no assumption about within-subject dependence.
- Robust sandwich SE accounts for clustering.
- Terminal CV death contributes as an event, then censors.

## Sample-size calculation (sketch)

For LWYY with assumed rate ratio RR and control rate λ_C:
- Total events required ≈ (z_{1-α/2} + z_{1-β})² / (log RR)² × (1 + var_inflation).
- At RR 0.80, 90% power, α 0.05 two-sided: ~ 840 events for basic.
- Inflated for over-dispersion, CV death, and recurrent-event correlation → ~ 1,450 total events.
- At control rate 0.23/year over 32 months → ~ 6,000 randomized.

## Terminal event handling

Three modeling philosophies for recurrent + terminal:
1. **LWYY (primary)**: treat death as final event + censoring.
2. **Joint frailty (Rogers-Pocock 2014, in corpus)**: shared frailty links recurrent and terminal hazards.
3. **Win ratio (Pocock 2012)**: hierarchical pairwise comparison.

FINEARTS-HF used LWYY as primary with joint frailty and win ratio as sensitivity.

## Results

| Outcome | Finerenone | Placebo | Effect (95% CI) | P |
|---|---|---|---|---|
| Primary (LWYY rate ratio) | 842 events | 1,024 events | **RR 0.84 (0.74-0.95)** | 0.007 |
| First HF event (sensitivity) | — | — | HR 0.82 (0.71-0.94) | — |
| CV death alone | — | — | HR 0.93 (NS) | — |
| KCCQ-TSS 12 mo | +1.6 pts | — | (P < 0.001) | — |
| All-cause death | — | — | HR 0.93 | — |

## Hierarchical testing

1. Primary composite rate ratio (LWYY).
2. KCCQ-TSS improvement at 6/9/12 months.
3. NYHA class change.
4. Composite renal endpoint.
5. All-cause death.

Each tested sequentially only if prior significant at α = 0.05 two-sided.

## Regulatory & clinical impact

- FDA sNDA accepted (2025); EMA review in 2026.
- First non-steroidal MRA for HFmrEF / HFpEF.
- Expected guideline update: finerenone alongside SGLT2i as HFpEF pillars.

## Related methodology

| Reference | Role |
|---|---|
| LWYY 2000 (in corpus) | LWYY methodology foundation |
| Rogers-Pocock 2014 (in corpus) | Joint frailty HF methodology |
| PARAGON-HF 2019 (in corpus) | Recurrent-event secondary in HFpEF ARNI |
| EMPEROR-Reduced 2020 (in corpus) | LWYY secondary in HFrEF SGLT2i |
| FINEARTS-HF (this case) | LWYY primary — first major HF trial |

## How this case validates designr

- Adds the **first LWYY-primary HF trial** to recurrent-events corpus.
- `designr` should expose LWYY power / sample-size calculation (via simulation or Schoenfeld-style extension) alongside negative binomial (IMPACT, TORCH, UPLIFT).
- Teaches: recurrent + terminal composite with semiparametric proportional rates; rate ratio vs first-event HR.
- Companion to PARAGON-HF and EMPEROR-Reduced showing recurrent-event endpoint evolution 2019 → 2024.
