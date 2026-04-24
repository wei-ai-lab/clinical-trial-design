# FOCUS4 (2014-) — biomarker-stratified MAMS platform in metastatic colorectal cancer

**Family:** mams · **Endpoint:** TTE PFS · **N:** ~1,200+ (platform, multi-cohort) · **Design feature:** molecular biomarker stratification with cohort-specific MAMS sub-trials

## Why this case is in the corpus

- **Biomarker-stratified platform** — patients are triaged to one of 5 molecular cohorts (BRAF, PIK3CA/PTEN, RAS, EGFR/HER2, all-wild-type), each with its own MAMS trial.
- Combines adaptive-enrichment (molecular cohort assignment) with MAMS (multi-arm within cohort).
- Published design paper is a canonical reference for molecular-stratified confirmatory trials.

## Citation

Kaplan R, Maughan T, Crook A, et al. *Evaluating many treatments and biomarkers in oncology: a new design.* J Clin Oncol. 2013;31(36):4562-4568. doi:10.1200/JCO.2013.50.7905.

FOCUS4 Trialists (Adams R, et al.). *Intermittent versus continuous oxaliplatin-fluoropyrimidine chemotherapy for first-line treatment of advanced colorectal cancer (COIN): a phase 3 randomised controlled trial.* (Related FOCUS series). ISRCTN90061143.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Biomarker-stratified MAMS platform |
| Population | Metastatic colorectal cancer post first-line |
| Biomarker cohorts | BRAF mut · PIK3CA/PTEN · RAS mut · EGFR/HER2 · all-WT (FOCUS4-N) |
| Arms (within cohort) | Cohort-specific targeted + placebo |
| Primary endpoint | PFS |
| α / power | 0.05 (two-sided) per cohort / 0.80 |
| Assumed HR | 0.60 per cohort |
| Spending | MAMS boundaries with lack-of-benefit drops at IF 0.33, 0.67 |
| Planned N per cohort | ~120-180 |
| Total platform N | ~1,200 |

## Reproducing the design

```r
library(MAMS)
# Within-cohort MAMS
d <- mams(
  K = 2, J = 3,
  r = c(1, 2, 3), r0 = c(1, 2, 3),
  alpha = 0.025, power = 0.80,
  p = 0.40, p0 = 0.25,      # PFS-related rates
  ushape = "obf", lshape = "obf",
  nstart = 40
)
```

## What the trial found

Multi-cohort reports from 2017 onwards:

- **FOCUS4-D (BRAF mut)**: AZD8931 arm closed early for futility at IF 0.33.
- **FOCUS4-C (PIK3CA/PTEN)**: trametinib arm showed signal; continued.
- **FOCUS4-N (all-WT)**: capecitabine maintenance vs observation — positive PFS signal.
- Several arms dropped at planned lack-of-benefit stages.

## Caveats & teaching points

- **Molecular triage** requires rapid assay turnaround (< 4 weeks) — not always feasible outside major centers. FOCUS4 centralized testing via NHS pathology network.
- **Cohort-specific α** — each cohort's MAMS is analyzed independently with its own FWER; no cross-cohort alpha borrowing.
- **Biomarker prevalence** shapes recruitment — all-WT cohort recruits fastest; BRAF mut slowest. Trial design must anticipate variable cohort accrual.
- **Platform governance** — new arms added via protocol amendments; DMC reviews per cohort.

## How this case validates designr

- Biomarker-stratified MAMS platform template.
- Cohort-specific MAMS with pre-specified drop boundaries.
- Rare / uncommon biomarker cohort design (BRAF ~5-10% of mCRC).
