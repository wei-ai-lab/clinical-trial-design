# EMPEROR-Reduced (2020) — Empagliflozin HFrEF, joint-frailty key secondary

**Family:** recurrent-events · **Endpoint:** CV death + HFH (time-to-first primary); total HFH (secondary) · **N:** 3,730 · **Design feature:** joint-frailty analysis of total HFH as pre-specified key secondary

## Why this case is in the corpus

- **Canonical modern HFrEF trial** demonstrating SGLT2 inhibitor benefit.
- **Joint frailty** as pre-specified key secondary for total HFH — handles informative censoring of recurrent events by death.
- Established SGLT2i as 4th pillar of HFrEF therapy (post-DAPA-HF).
- Reference implementation of negative-binomial + joint-frailty dual analysis for HF total events.

## Citation

Packer M, Anker SD, Butler J, et al. *Cardiovascular and renal outcomes with empagliflozin in heart failure.* N Engl J Med. 2020;383(15):1413-1424. doi:10.1056/NEJMoa2022190. NCT03057977.

## Design summary

| | |
|---|---|
| Design | Double-blind placebo-controlled, event-driven |
| Population | HFrEF (LVEF ≤ 40%), NYHA II-IV, elevated NT-proBNP, ± T2DM |
| Arms | Empagliflozin 10 mg QD vs placebo |
| Primary | Time to first of CV death or HF hospitalization |
| Primary HR target | 0.80 |
| Key secondary | Total (first + recurrent) HF hospitalizations |
| Secondary rate-ratio target | 0.70 |
| Analysis — primary | Cox PH stratified by region, diabetes, eGFR |
| Analysis — total HFH | Joint frailty (LWYY-style with death terminal) + negative binomial |
| α | 0.05 two-sided |
| Power | 0.90 for primary |
| Planned N | 3,730 |
| Expected primary events | 841 |

## Reproducing the design

```r
library(gsDesign)
# Primary time-to-first-event sizing
nSurv(
  lambdaC = -log(1 - 0.21) / 1,   # ~21% annual event rate in placebo
  hr = 0.80,
  alpha = 0.025, beta = 0.10,
  R = 24, minfup = 12, sided = 1
)

# Key secondary — total HFH joint frailty
library(frailtypack)
jf <- frailtyPenal(
  Surv(start, stop, hosp_event) ~ arm + terminal(cv_death),
  formula.terminalEvent = ~ arm,
  data = emperor_df,
  n.knots = 8, kappa = c(1e5, 1e5),
  recurrentAG = TRUE
)
```

## Trial outcome

- **Primary** (CV death or first HFH): HR **0.75** (95% CI 0.65-0.86), p < 0.001 — positive.
- **Total HFH (joint frailty)**: rate ratio **0.70** (95% CI 0.58-0.85), p < 0.001.
- **Total HFH (negative binomial)**: RR 0.67 (95% CI 0.55-0.82) — consistent with joint frailty.
- **CV death alone**: HR 0.92 (0.75-1.12), NS.
- Effect emerged at ~1 month post-randomization, sustained through follow-up.
- No signal of benefit heterogeneity by diabetes status — reshaped SGLT2i indication to HF proper.

## How this case validates designr

- Joint-frailty modeling of total HFH as key secondary — canonical implementation.
- Negative-binomial + joint-frailty dual-method sensitivity pattern.
- Time-to-first-event primary sized in parallel with recurrent-event secondary.
- Benchmark that `designr` must support CV-death-terminal / HFH-recurrent joint-frailty pipelines.
- Paired with PARAGON-HF (HFpEF, total-event primary) and DAPA-HF in the corpus, spanning the modern HF trial analytical template.
