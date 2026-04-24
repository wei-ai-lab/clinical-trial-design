# KEYNOTE-024 (2016) — Pembrolizumab vs Chemo in PD-L1 High NSCLC

**Family:** tte-nph · **Kind:** landmark Phase 3 · **Scope:** biomarker-enriched IO frontline, crossing hazards with long-term plateau

## Why this case is in the corpus

- **Paradigm-shifting IO trial** — first Phase 3 to establish immunotherapy monotherapy frontline in NSCLC.
- Classic **non-proportional hazards** pattern: early/sustained separation with long-term plateau in pembro arm.
- **Biomarker-enriched** (PD-L1 TPS ≥ 50%) design — focused study in responder population.
- Designed under PH assumption; PH violations at long follow-up motivated modern NPH methodology (MaxCombo, RMST).
- **Crossover** 66% chemo → pembro at progression complicates OS interpretation.

## Citation

- Reck M, Rodríguez-Abreu D, Robinson AG, et al. *Pembrolizumab versus chemotherapy for PD-L1-positive NSCLC.* N Engl J Med. 2016 Nov 10;375(19):1823-1833.
- Reck M, et al. *5-year outcomes with pembrolizumab vs chemo.* J Clin Oncol. 2021;39(21):2339-2349.

## Design summary

| Parameter | Value |
|---|---|
| Indication | PD-L1 TPS ≥ 50%, EGFR/ALK wild-type, frontline advanced NSCLC |
| Arms | Pembrolizumab 200 mg Q3W vs platinum-doublet chemo (1:1) |
| Primary endpoint | PFS (BICR RECIST v1.1) |
| Key secondary | OS, hierarchically tested |
| α / power | 0.05 two-sided / 89% |
| Assumed HR (PFS) | 0.55 |
| Control median PFS | 6.0 months |
| Target events (PFS) | 175 |
| Randomized N | 305 |
| Accrual | 14 months |

## The NPH pattern

**PFS**: roughly proportional hazards — classical Cox/log-rank valid.

**OS**: clear non-proportional pattern visible by 2-year follow-up:
- Early parallel hazards (0-6 months).
- Sustained separation after 6 months.
- Pembrolizumab plateau ~ 30% at 5 years (vs ~ 16% chemo, inflated by crossover).

Schoenfeld residual test rejects PH for OS at long follow-up.

## Why PH was used at design

- 2015 IO methodology literature did not yet establish MaxCombo / RMST as primary.
- PD-L1 ≥ 50% expected large effect size → classical design sufficient.
- Hierarchical PFS → OS testing.
- Sponsors bore the risk of designing under PH with potential NPH realization.

## Modern NPH post-hoc analyses

```r
library(survRM2)
library(nphRCT)
library(nph)

# RMST at 24 months
rmst_24 <- rmst2(time, status, arm, tau = 24)
print(rmst_24$unadjusted.result)

# Max-combo weighted log-rank
wlr <- wlr_combo(
  formula = Surv(time, status) ~ arm,
  data = df,
  rho_gamma = rbind(c(0, 0), c(0, 1), c(1, 0), c(1, 1))
)
wlr

# Visual check: Grambsch-Therneau
library(survival)
cox <- coxph(Surv(time, status) ~ arm, data = df)
zph <- cox.zph(cox)
plot(zph)
```

## Results

**Initial (2016)**:
| Outcome | Pembro | Chemo | HR (95% CI) |
|---|---|---|---|
| PFS | 10.3 mo | 6.0 mo | 0.50 (0.37-0.68) |
| OS | NR | 14.2 mo | 0.60 (0.41-0.89) |
| ORR | 44.8% | 27.8% | — |

**5-year update (2021)**:
| Outcome | Pembro | Chemo | HR (95% CI) |
|---|---|---|---|
| 5-yr OS | 31.9% | 16.3%* | 0.62 (0.48-0.81) |
| PFS plateau | — | — | — |

*Chemo arm OS inflated by 66% crossover to pembrolizumab.

## Crossover handling

Pre-specified sensitivity analyses:
- **Rank-preserving structural failure time (RPSFT)**: estimates counterfactual HR.
- **Inverse probability of censoring weights (IPCW)**: re-weights censored at crossover.
- **Observed**: HR 0.60 (ITT).
- **RPSFT-adjusted**: HR 0.45 (removing crossover dilution).

## Regulatory & clinical impact

- FDA approval Oct 2016 — pembrolizumab frontline NSCLC PD-L1 ≥ 50%.
- Changed NSCLC frontline standard within 6 months.
- Established biomarker testing (PD-L1 IHC) as standard of care.

## Related trials

| Trial | Setting | Key point |
|---|---|---|
| KEYNOTE-024 (this case) | PD-L1 ≥ 50% | Biomarker-enriched positive |
| KEYNOTE-042 | PD-L1 ≥ 1% | Positive but driven by ≥ 50% subgroup |
| KEYNOTE-189 | Regardless of PD-L1 | Pembro + chemo broader label |
| CheckMate-026 | PD-L1 ≥ 5% | Negative (threshold too low + PH misspecification) |

## How this case validates designr

- Adds the **paradigm-shifting biomarker-enriched IO trial** to tte-nph.
- `designr` should reproduce classical PFS event-driven sizing via `gsDesign::gsSurv` but also flag NPH risk via simulation.
- Teaches: when NPH realization expected (long-term plateau), pre-specify RMST / MaxCombo as sensitivity or primary.
- Companion to CheckMate-9LA (in corpus) showing IO trial design maturation.
