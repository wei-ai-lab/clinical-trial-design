# EMPHASIS-HF (2011) — eplerenone in mild HFrEF

**Family:** group-sequential · **Endpoint:** TTE composite · **N:** 3,100 · **Design feature:** stopped at first planned interim

## Why this case is in the corpus

- **Stopped at first interim (IF=0.50)** — rare; first-look stops require very strong effect (z > 2.80 under OBF).
- Complementary to RALES — RALES used NYHA III-IV; EMPHASIS-HF extended MRA benefit to NYHA II.
- Teaching case for the cost/benefit of first-look efficacy stopping.

## Citation

Zannad F, McMurray JJV, Krum H, et al. *Eplerenone in patients with systolic heart failure and mild symptoms.* N Engl J Med. 2011;364(1):11-21. doi:10.1056/NEJMoa1009492. NCT00232180.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, GS |
| Population | NYHA II HFrEF, LVEF ≤ 30% |
| Arms | Eplerenone 50 mg · Placebo |
| Primary endpoint | CV death + HF hospitalization |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.80 |
| Assumed control rate | ~18% per year |
| Spending | Lan-DeMets OBF, 3 looks |
| Target events | 813 |
| Planned N | 3,100 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 3, test.type = 1,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF,
  hr = 0.80, hr0 = 1,
  lambdaC = -log(1 - 0.18),
  R = 36, minfup = 21, ratio = 1
)
# events ≈ 810; N ≈ 3,100; boundaries ~ z = 2.80 / 2.34 / 2.04
```

## What the trial found

- Stopped at first planned interim (median follow-up 21 months, IF ≈ 0.50).
- HR primary = **0.63** (95% CI 0.54–0.74), p < 0.001.
- 37% relative risk reduction.
- Established eplerenone in milder HF population (previously indicated for post-MI HF only).

## Caveats & teaching points

- **First-interim stops are extreme signals.** OBF z-bound at IF=0.50 is ~2.80. Observed z ≈ 7 (based on HR 0.63). Such a result at first look means the true effect is either far stronger than planned or chance is extreme.
- **Sampling distribution after first-look stop is extremely biased.** Point estimate HR 0.63 almost certainly overstates true effect; bias-corrected estimators (median-unbiased or repeated-CI) should be used for honest reporting.
- **Comparison to RALES.** RALES observed HR 0.70 in severe HF; EMPHASIS observed HR 0.63 in mild HF. Effect is plausibly *larger* in milder disease (more reserve for improvement), which contradicts naive hypothesis of larger effect in sicker patients.

## How this case validates designr

- First-look stop scenario.
- Agent teaching: bias in point estimates post-early-stop.
- Cross-trial comparison against RALES in the same drug class.
