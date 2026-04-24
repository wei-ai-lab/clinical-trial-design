# PARADIGM-HF (2014) — sacubitril/valsartan vs enalapril in HFrEF

**Family:** group-sequential · **Endpoint:** TTE composite · **N:** 8,442 · **Design feature:** active-control superiority, OBF efficacy + non-binding futility

## Why this case is in the corpus

- **Active-control superiority with GS** — tests `designr`'s handling of superiority tests vs an established active control (not placebo).
- **Combined efficacy + non-binding futility** boundaries.
- Landmark trial — sacubitril/valsartan became first-line HFrEF therapy post-PARADIGM.
- Design paper (Solomon et al. 2013) is a benchmark reference for GS HF trials.

## Citation

McMurray JJ, Packer M, Desai AS, et al. *Angiotensin-neprilysin inhibition versus enalapril in heart failure.* N Engl J Med. 2014;371(11):993-1004. doi:10.1056/NEJMoa1409077. NCT01035255.

Design paper: Solomon SD, McMurray JJV, PARADIGM-HF Investigators. *Baseline characteristics of patients in the Prospective Comparison of ARNI with ACEI to Determine Impact on Global Mortality and Morbidity in Heart Failure trial (PARADIGM-HF).* Eur J Heart Fail. 2014;16(7):817-25.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, group-sequential, active control |
| Arms | Sacubitril/valsartan 200 mg bid · Enalapril 10 mg bid |
| Primary endpoint | Composite: CV death + HF hospitalization |
| α / power | 0.05 (two-sided) / 0.80 |
| Assumed HR | 0.85 |
| Assumed control event rate | ~14.5% per year |
| Spending (efficacy) | Lan-DeMets OBF at 3 looks (IF 0.33, 0.67, 1.0) |
| Futility | Non-binding, favoring enalapril at first two looks |
| Target events | 2,410 |
| Planned N | 8,442 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k         = 3,
  test.type = 4,                       # asymmetric: efficacy OBF, futility
  alpha     = 0.025,
  beta      = 0.20,
  sfu       = sfLDOF,                  # Lan-DeMets OBF efficacy
  sfl       = sfHSD, sflpar = -2,      # Hwang-Shih-DeCani for futility
  timing    = c(0.33, 0.67, 1.0),
  hr        = 0.85, hr0 = 1,
  lambdaC   = -log(1 - 0.145),
  R         = 27, minfup = 27, ratio = 1
)
summary(d)
# events ≈ 2,400, N ≈ 8,400, efficacy bounds ~z = 3.71 / 2.77 / 2.05
```

## What the trial found

- Stopped at IF ~0.78 on DSMB recommendation.
- HR for primary composite = **0.80** (95% CI 0.73–0.87), p < 0.001.
- HR for CV death alone = 0.80; HF hospitalization = 0.79.
- Effect consistent with design assumption (HR 0.85) but slightly better.

## Caveats & teaching points

- **Active-control trials require tighter effect assumptions.** Against enalapril (already effective), the margin for superiority is small; HR 0.85 was the design assumption reflecting modest expected improvement. A weaker improvement would have been undetectable.
- **Non-binding futility is protective, not binding.** DSMB can override; α unchanged. Compare with binding futility which lowers α slightly in exchange for requiring stopping.
- **Run-in phase.** PARADIGM-HF used an active run-in (both drugs tolerability check) before randomization. This is a conduct detail; does not affect sample-size calculation but does affect interpretation (enriched for tolerators).

## How this case validates designr

- Active-control superiority GS.
- Combined efficacy (OBF) + non-binding futility (HSD) boundaries.
- Handling of enriched-for-tolerance population via run-in.
