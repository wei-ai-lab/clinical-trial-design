# STAMPEDE (2011-) — MAMS platform in advanced/metastatic prostate cancer

**Family:** mams · **Endpoint:** TTE OS + FFS · **N:** 11,000+ (ongoing) · **Design feature:** flagship MAMS platform in oncology; multiple research arms vs standard of care

## Why this case is in the corpus

- **Flagship MAMS trial** — first large-scale Phase 3 oncology MAMS, designed by the UK MRC CTU (Parmar, Sydes, Royston).
- Multiple experimental arms tested against shared ADT-based standard-of-care control.
- Teaching case for **staged lack-of-benefit boundaries** on intermediate endpoint (failure-free survival) with final OS test.

## Citation

Sydes MR, Parmar MKB, James ND, et al. *Issues in applying multi-arm multi-stage methodology to a clinical trial in prostate cancer: the MRC STAMPEDE trial.* Trials. 2009;10:39. doi:10.1186/1745-6215-10-39.

James ND, Sydes MR, Clarke NW, et al. *Addition of docetaxel, zoledronic acid, or both to first-line long-term hormone therapy in prostate cancer (STAMPEDE): survival results from an adaptive, multiarm, multistage, platform randomised controlled trial.* Lancet. 2016;387(10024):1163-1177. doi:10.1016/S0140-6736(15)01037-5. ISRCTN78818544.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Open-label, MAMS platform, K arms + control |
| Population | Advanced/metastatic prostate cancer starting ADT |
| Arms (initial) | ADT alone (control) · ADT + zoledronic acid · ADT + docetaxel · ADT + celecoxib · ADT + zol+cel · ADT + zol+doc |
| Primary endpoints | Intermediate: Failure-free survival (FFS); Final: Overall survival (OS) |
| α / power | 0.05 (two-sided) per arm / 0.90 OS |
| Assumed HR | 0.75 (per arm) |
| Spending | MAMS Lan-DeMets-like boundaries computed per `nstage` software |
| Planned stages | 4 (3 intermediate + 1 final) |
| Information fractions (FFS) | 0.33 / 0.67 / 1.0 / final OS |
| Control HR equivalence | Control arm shared; new arms added over time |

## Reproducing the design

```r
library(MAMS)
d <- mams(
  K = 5, J = 4,
  r = c(1, 2, 3, 4),     # stage ratios for experimental
  r0 = c(1, 2, 3, 4),    # stage ratios for control
  alpha = 0.025, power = 0.90,
  p = 0.57, p0 = 0.50,   # approx FFS rates
  ushape = "obf", lshape = "obf",
  nstart = 400
)
# Print boundaries
d$u
d$l
```

## What the trial found

Multiple landmark findings across arms:

- **Docetaxel arm (2015)**: HR 0.78 for OS; 10-month median OS improvement in M1 patients.
- **Abiraterone arm (2017)**: HR 0.63 for OS in M1; 37% mortality reduction.
- **Radiotherapy arm to primary (2018)**: HR 0.68 for OS in low-burden M1.
- **Enzalutamide + abiraterone (2020)**: limited incremental benefit.
- Multiple arms stopped for lack of benefit at intermediate FFS stages.

## Caveats & teaching points

- **Platform evolution.** New arms added over 15+ years; control arm evolved as SOC improved. MAMS math handles this via time-varying control.
- **Intermediate endpoint (FFS).** Used at stages 1-3 for lack-of-benefit stops; OS reserved for final efficacy. Reduces trial duration but requires FFS-OS correlation assumption.
- **Open-label, but primary endpoints objective** (OS and PSA-based FFS) — low risk of outcome bias.
- **DSMB independence and pre-specified lack-of-benefit boundaries** — each arm evaluated against its enrollment cohort; no cross-arm α borrowing except via strong FWER at final OS stage.

## How this case validates designr

- MAMS platform flagship benchmark.
- Intermediate lack-of-benefit boundaries with final OS.
- Time-varying control arm handling.
- Reference implementation in `nstage` / `MAMS` packages.
