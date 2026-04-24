# DAPA-HF (2019) — dapagliflozin in HFrEF

**Family:** group-sequential · **Endpoint:** TTE composite · **N:** 4,744 · **Design feature:** two-look GS (IF 0.60, 1.0)

## Why this case is in the corpus

- **Minimalist modern GS design** — only 1 interim + 1 final. Contrast with 3-4 look classics.
- Demonstrates that **fewer looks = lower penalty** on final-boundary strictness (2.00 vs 2.04 with 3 looks).
- Modern SGLT2-inhibitor HF trial that established a new treatment class.

## Citation

McMurray JJV, Solomon SD, Inzucchi SE, et al. *Dapagliflozin in patients with heart failure and reduced ejection fraction.* N Engl J Med. 2019;381(21):1995-2008. doi:10.1056/NEJMoa1911303. NCT03036124.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, group-sequential |
| Arms | Dapagliflozin 10 mg · Placebo |
| Primary endpoint | Worsening HF event + CV death composite |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.80 |
| Assumed control rate | ~11% per year |
| Spending | Lan-DeMets OBF |
| Planned looks | 1 interim (IF 0.60) + final (IF 1.0) |
| Target events | 844 |
| Planned N | 4,744 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k         = 2,
  test.type = 1,
  alpha     = 0.025,
  beta      = 0.10,
  sfu       = sfLDOF,
  timing    = c(0.60, 1.0),
  hr        = 0.80, hr0 = 1,
  lambdaC   = -log(1 - 0.11),
  R         = 18, minfup = 18, ratio = 1
)
summary(d)
# events ≈ 840, N ≈ 4,700, z-bounds ~2.39 / 2.00
```

## What the trial found

- Ran to final analysis.
- HR for primary = **0.74** (95% CI 0.65–0.85), p < 0.001.
- Benefit consistent across T2D and non-T2D subgroups — broadened SGLT2i indication beyond diabetes.

## Caveats & teaching points

- **Two-look GS trade-off.** Fewer looks → less alpha spent early → less conservative final boundary. Good for trials expecting the final readout to be informative.
- **Not stopped early.** Contrasts with RALES/PARADIGM-HF (stopped early). Illustrates that GS designs often run to final when effects are closer to plan.
- **IF 0.60 interim is well-timed.** Early enough to inform program planning; late enough that the GS penalty is modest.

## How this case validates designr

- Efficient 2-look GS design.
- Agent reasoning about look-count vs final-boundary strictness trade-off.
- Cross-family comparison: SPRINT (fixed) vs DAPA-HF (GS) for similar HR assumption illustrates the ~3% inflation cost of GS.
