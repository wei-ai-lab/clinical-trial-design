# SPRINT (2015) — intensive vs standard blood-pressure control

**Family:** fixed-superiority · **Endpoint:** TTE composite · **N:** 9,250 planned (9,361 enrolled)

## Why this case is in the corpus

- Large **cardiovascular outcomes trial (CVOT)** — prototypical Phase 3 for chronic disease.
- **Fixed-sample TTE design** powered by events, not subjects.
- Teaching case for **DSMB early stopping without formal GS boundaries** — a pattern seen in many outcome trials.
- Reproducing the planned sample size exercises `gsDesign::nSurv` / `rpact::getSampleSizeSurvival` in their simplest mode.

## Citation

SPRINT Research Group. *A randomized trial of intensive versus standard blood-pressure control.* N Engl J Med. 2015;373(22):2103-2116. doi:10.1056/NEJMoa1511939. NCT01206062.

Design paper: Ambrosius WT, Sink KM, Foy CG, et al. *The design and rationale of a multicenter clinical trial comparing two strategies for control of systolic blood pressure.* Clin Trials. 2014;11(5):532-46.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Randomized, open-label, blinded-endpoint, two-arm parallel |
| Indication | Hypertension with increased CV risk (no diabetes, no prior stroke) |
| Arms | Intensive (SBP target < 120) · Standard (SBP target < 140), 1:1 |
| Primary endpoint | Composite CV: MI, non-MI ACS, stroke, acute decompensated HF, CV death |
| α / power | 0.05 (two-sided) / 0.887 |
| Assumed HR | 0.80 (intensive vs standard) |
| Assumed control event rate | ~2.2% / year |
| Accrual | 24 months |
| Follow-up | ≥ 4 years after last enrollment |
| Target events | 2,028 |
| Planned N | 9,250 |
| Actual N | 9,361 |

## Reproducing the calculation

Under HR = 0.80, α = 0.05 two-sided, power = 0.887, with equal allocation:

- Total events needed: `4 × (z_{α/2} + z_β)² / (log(0.80))² ≈ 2028`

```r
# gsDesign
library(gsDesign)
nSurv(
  lambdaC = -log(1 - 0.022),   # from 2.2%/year exponential
  hr      = 0.80,
  alpha   = 0.025,             # one-sided equiv of 0.05 two-sided
  beta    = 0.113,
  ratio   = 1,
  T       = 72,                # total trial months
  minfup  = 48,
  R       = 24                 # enrollment duration
)
```

This returns target events ≈ 2,028 and total N ≈ 9,250 under the assumed event rate.

## What the trial found

- Stopped early after median 3.26 years follow-up.
- Primary outcome HR = **0.75** (95% CI 0.64–0.89), driven largely by HF and CV-death components.
- **405 total primary events** at early stop — well below the 2,028 target — but the observed effect size was stronger than assumed (HR 0.75 vs planned 0.80), giving adequate power even at lower event count.

## Caveats & teaching points

- **No formal GS boundaries.** Protocol did not pre-specify α-spending. DSMB used monitoring guidelines (Haybittle-Peto-like in spirit, but not binding).
- **Open-label with blinded adjudication.** Design classification is still "fixed-superiority"; the open-label aspect affects conduct risk but not the sample-size calculation.
- **Why stopping matters for benchmarks.** A strict benchmark replay of the design gives 2,028 events / 9,250 N. Replaying the *analysis* requires modeling the stopping decision — out of scope for a design benchmark.

## How this case validates designr

- Basic TTE fixed-design calc under exponential survival.
- Agent interpretation: should identify this as fixed-superiority despite the early stopping, and explain the distinction between design and conduct.
