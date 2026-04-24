# Uno et al. (2014) — RMST for Non-Proportional Hazards

**Family:** group-sequential-nph · **Kind:** methodology-paper · **Scope:** Restricted Mean Survival Time as a model-free alternative to hazard ratio

## Why this case is in the corpus

- **Canonical advocacy paper** for Restricted Mean Survival Time (RMST) as a primary / co-primary endpoint in TTE trials with non-proportional hazards.
- Catalyzed industry and regulatory adoption of RMST alongside or instead of HR in IO oncology and HF trials.
- Model-free, clinically interpretable ('extra months over τ years'), and robust to PH violations.
- Complements the six real IO/NPH trials in the corpus with the canonical methodology reference.

## Citation

Uno H, Claggett B, Tian L, Inoue E, Gallo P, Miyata T, Schrag D, Takeuchi M, Uyama Y, Zhao L, Skali H, Solomon S, Jacobus S, Hughes M, Packer M, Wei LJ. *Moving beyond the hazard ratio in quantifying the between-group difference in survival analysis.* J Clin Oncol. 2014 Aug 1;32(22):2380-5.

## Core framework

| Element | Value |
|---|---|
| Statistic | RMST Δ(τ) = RMST_exp(τ) - RMST_ctrl(τ) |
| Interpretation | Additional mean event-free time over interval [0, τ] |
| Assumptions | None on hazard shape — model-free |
| Variance | Robust via martingale residuals (Greenwood-like) |
| Truncation τ | Pre-specified; typically min observed follow-up |

## Algorithm

```r
# RMST analysis (Uno et al. 2014)
library(survRM2)
rmst2(
  time = df$time,
  status = df$event,
  arm = df$arm,          # 1 = experimental, 0 = control
  tau = 24               # truncation at 24 months
)
# Returns: RMST in each arm, Δ(τ), CI, p-value

# Sample-size design (RMST-based)
library(npsurvSS)
arm_exp <- create_arm(size = 1,
                      accr_time = 12,
                      follow_time = 24,
                      surv_shape = 1,
                      surv_scale = 0.05)
arm_ctl <- create_arm(size = 1,
                      accr_time = 12,
                      follow_time = 24,
                      surv_shape = 1,
                      surv_scale = 0.08)
size_two_arm(
  arm0 = arm_ctl, arm1 = arm_exp,
  power = 0.80, alpha = 0.025, sides = 1,
  test = list(test = "rmst difference", milestone = 24)
)
```

## Sample-size rules of thumb

- Under PH, RMST design typically needs ~5-10% more events than logrank for same power.
- Under delayed-effect NPH, RMST design needs ~20-40% fewer events vs logrank.
- Under crossing curves, RMST preserves power while logrank can fail.
- MaxCombo test (Lin-Magirr-Burman, in NPH corpus) offers robust fallback.

## Power vs logrank

| NPH type | Logrank power | RMST power |
|---|---|---|
| PH | High | Medium-High |
| Delayed effect | Medium | High |
| Crossing curves | Low | Medium-High |
| Cure fraction | Medium | Medium-High |

## Regulatory / industry adoption

- **FDA 2021 Non-Proportional Hazards Workshop** endorsed RMST as complementary summary.
- **EMA 2020 draft guidance on oncology endpoints** discusses RMST.
- **CheckMate-067, EMPEROR-Preserved, ATTRACTION-3**: RMST reported alongside HR.
- Pembrolizumab and nivolumab programs increasingly feature RMST in secondary analyses.

## How this case validates designr

- Adds the **foundational RMST methodology** to the GS-NPH corpus — the six real trials show RMST applied; this paper is the methodological bedrock.
- `designr` should expose `npsurvSS::size_two_arm(test = 'rmst difference')` as a first-class NPH design option alongside logrank.
- Teaches when RMST is preferred over HR: pre-specified NPH expectation, delayed-effect immunotherapies, crossing-curve cardiology.
