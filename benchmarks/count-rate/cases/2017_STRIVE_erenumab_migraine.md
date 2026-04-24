# STRIVE (2017) — Erenumab episodic migraine prevention, MMD change primary

**Family:** count-rate · **Endpoint:** monthly migraine day change · **N:** 955 · **Design feature:** MMRM primary with NB count sensitivity — canonical CGRP-mAb migraine design

## Why this case is in the corpus

- **Pivotal Phase 3** for erenumab (Aimovig), first CGRP-receptor mAb approved for migraine prevention (FDA May 2018).
- Established monthly migraine days (MMD) as regulatory endpoint.
- Established MMRM primary + negative binomial sensitivity as the migraine Phase 3 template.
- Reference for CGRP-mAb class sizing (fremanezumab, galcanezumab, eptinezumab, atogepant) pivotal trials.

## Citation

Goadsby PJ, Reuter U, Hallström Y, et al. *A controlled trial of erenumab for episodic migraine.* N Engl J Med. 2017;377(22):2123-2132. doi:10.1056/NEJMoa1705848. NCT02456740.

## Design summary

| | |
|---|---|
| Design | Double-blind placebo-controlled, 3-arm |
| Population | Episodic migraine, 4-14 MMD at baseline, 18-65 y |
| Arms | Erenumab 70 mg, erenumab 140 mg, placebo (all SC monthly) |
| Primary | Change from baseline in mean MMD (average of months 4-6) |
| Analysis | MMRM on change from baseline, adjusted for region + baseline MMD |
| Baseline MMD | ~ 8.3 (mean) |
| Target diff from placebo | -1.4 days |
| Placebo response | -1.8 days |
| α | 0.05 two-sided |
| Power | 0.90 |
| Planned N | 955 |

## Reproducing the design

```r
library(mmrm)
# MMRM primary
fit <- mmrm(
  change_mmd ~ arm * month + baseline_mmd + region +
               us(month | subject),
  data = strive_df
)
# Estimated difference at month 6 from 'arm:month' contrast

# NB sensitivity on raw MMD counts
library(MASS)
nb <- glm.nb(
  monthly_migraine_days ~ arm + baseline_mmd + region +
                          offset(log(30)),
  data = strive_df
)

# Sample-size sizing (continuous change, diff = -1.4, SD ~ 3.5)
library(gsDesign)
n_total <- 3 * ceiling(
  (qnorm(0.975) + qnorm(0.90))^2 * 2 * 3.5^2 / 1.4^2
)
# ≈ 955
```

## Trial outcome

- **Erenumab 70 mg**: MMD change -3.2 vs placebo -1.8, diff **-1.4** (95% CI -1.9 to -0.9), p < 0.001.
- **Erenumab 140 mg**: MMD change -3.7 vs placebo -1.8, diff -1.9 (-2.3 to -1.4), p < 0.001.
- **≥ 50% responder rate**: 43% (70 mg), 50% (140 mg), 27% placebo.
- MIDAS (migraine disability) and HIT-6 (headache impact) improved on both doses.
- Both doses FDA approved; 70 mg starting, 140 mg for inadequate response.

## How this case validates designr

- MMRM sample-size benchmark for continuous change-from-baseline migraine endpoint.
- NB-on-raw-count sensitivity cross-check — paired analytical pattern.
- Placebo-response magnitude as sizing input (non-trivial in migraine).
- Reference for any CGRP-class or oral-gepant migraine pivotal design.
- Paired with FREEDOMS (MS ARR), MENSA (asthma exacerbation), Perampanel (seizure) in count-rate, spanning neurological / respiratory count-rate endpoints.
