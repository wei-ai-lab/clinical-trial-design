# ACTT-1 (2020) — NIAID Adaptive COVID Treatment Trial: Remdesivir

**Family:** platform · **Kind:** landmark Phase 3 adaptive platform · **Scope:** ordinal-endpoint time-to-recovery, NIAID pandemic framework

## Why this case is in the corpus

- **First major adaptive platform trial** of the COVID-19 pandemic — established the NIAID ACTT framework.
- First FDA-approved COVID-19 therapeutic (remdesivir, October 2020).
- **Ordinal 8-category recovery scale** as primary endpoint — canonical for pandemic respiratory-disease trials.
- Platform structure enabled rapid launch of ACTT-2/3/4 sub-studies using same infrastructure.
- Demonstrates adaptive-platform rapid-response capability during health emergencies.

## Citation

- Beigel JH, Tomashek KM, Dodd LE, et al. *Remdesivir for the treatment of Covid-19 — final report.* N Engl J Med. 2020 Nov 5;383(19):1813-1826.
- Preliminary report: N Engl J Med. 2020 May 22. (ACTT-1 Protocol v10, NIAID.)

## Design summary

| Parameter | Value |
|---|---|
| Indication | Hospitalized COVID-19 with lower respiratory tract involvement |
| Arms | Remdesivir IV 10 days vs placebo (1:1) |
| Primary endpoint | Time to recovery (ordinal scale category 1-3) |
| α / power | 0.05 two-sided / 90% |
| Assumed recovery RR | 1.35 |
| Control median recovery | 15 days |
| Randomized N | 1,062 |
| Sites | 60 sites, 10 countries |
| Stratification | Site + baseline severity (ordinal category 4-5 vs 6-7) |

## 8-category ordinal scale

| Cat | Status |
|---|---|
| 1 | Not hospitalized, no activity limits |
| 2 | Not hospitalized, with activity limits |
| 3 | Hospitalized, not requiring ongoing care |
| 4 | Hospitalized, requiring ongoing care |
| 5 | Hospitalized, supplemental O2 |
| 6 | Hospitalized, high-flow O2 or NIV |
| 7 | Hospitalized, mechanical ventilation / ECMO |
| 8 | Death |

**Recovery** = reaching category 1-3.

## Primary analysis model

```r
library(survival)

# Cox model for time-to-recovery, stratified by baseline severity
fit <- coxph(
  Surv(time_to_recovery, recovered) ~ trt + strata(baseline_cat),
  data = df
)
summary(fit)
# Hazard ratio interpreted as "recovery rate ratio"
```

## Adaptive platform structure

ACTT-1 established infrastructure for rapid expansion:
- Same DSMB.
- Shared protocol scaffold.
- Common data capture, laboratory standards.
- Central coordinating center (NIAID).

| Sub-study | Comparison | Year |
|---|---|---|
| ACTT-1 (this case) | Remdesivir vs placebo | 2020 |
| ACTT-2 | + Baricitinib vs remdesivir | 2021 |
| ACTT-3 | + Interferon β-1a | 2021 |
| ACTT-4 | Baricitinib vs dexamethasone | 2022 |

4 comparative trials within 2 years — pandemic-scale efficiency.

## Results

| Outcome | Remdesivir | Placebo | Effect |
|---|---|---|---|
| Median time to recovery | 10 days | 15 days | **RR 1.29 (1.12-1.49)**, P < 0.001 |
| Day-29 mortality | 11.4% | 15.2% | HR 0.73 (0.52-1.03) |
| Cat 5 (O2 only) subgroup | — | — | RR 1.45 — largest benefit |
| Cat 7 (ventilation) subgroup | — | — | RR 1.06 — minimal benefit |

## Heterogeneous effect by severity

Pre-specified subgroup analysis revealed:
- **Supplemental O2 only** (cat 5): largest benefit (RR 1.45).
- **High-flow / NIV** (cat 6): modest benefit.
- **Mechanical ventilation / ECMO** (cat 7): minimal benefit.

Informed subsequent ACTT-4 design targeting specific severity strata.

## Interim analysis cadence

- DSMB review every 2 weeks during rapid enrollment.
- Efficacy/futility boundaries: O'Brien-Fleming-style.
- Preliminary analysis at ~ 50% enrollment showed efficacy crossing boundary.
- DSMB recommended continuation to full accrual + crossover option.

## Regulatory & clinical impact

- FDA EUA May 1, 2020 — within days of preliminary report.
- FDA approval October 22, 2020 — first COVID-19 therapeutic.
- Paralleled Solidarity (WHO 2020, in corpus) which showed no remdesivir mortality benefit — illustrating endpoint selection controversy (recovery vs mortality).

## Related platform trials

| Trial | Design | Key endpoint |
|---|---|---|
| ACTT-1 (this case) | Adaptive platform | Time to recovery |
| Solidarity (in corpus) | Pragmatic open-label | All-cause mortality |
| RECOVERY (in corpus) | MAMS platform | Mortality |
| REMAP-CAP (in corpus) | Domain-based Bayesian | Multiple outcomes |
| DIAN-TU (in corpus) | Alzheimer adaptive platform | Cognitive decline |

## How this case validates designr

- Adds the **canonical pandemic adaptive platform trial** to the platform corpus.
- `designr` should support ordinal-endpoint time-to-recovery TTE analysis with stratified Cox.
- Teaches: platform infrastructure enabling sub-study launch; ordinal recovery scales; interim cadence during rapid enrollment.
- Companion to Solidarity, RECOVERY, REMAP-CAP illustrating different platform operational philosophies.
