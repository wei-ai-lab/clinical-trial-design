# PACIFIC (2017) — durvalumab consolidation after chemoradiation in stage III NSCLC

**Family:** group-sequential-nph · **Endpoint:** TTE PFS + OS (dual primary) · **N:** 713 · **Design feature:** consolidation therapy with clear delayed PFS effect

## Why this case is in the corpus

- **Delayed PFS separation** — curves begin to separate at ~3 months as consolidation durvalumab suppresses micro-residual disease.
- **Dual-primary endpoint** (PFS + OS) with α-splitting and hierarchical sequence.
- Teaching case for **consolidation-therapy** design where control arm is placebo post-CRT.

## Citation

Antonia SJ, Villegas A, Daniel D, et al. *Durvalumab after chemoradiotherapy in stage III non-small-cell lung cancer.* N Engl J Med. 2017;377(20):1919-1929. doi:10.1056/NEJMoa1709937. NCT02125461.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 2:1 durvalumab:placebo, GS |
| Population | Unresectable stage III NSCLC, no progression after ≥ 2 cycles platinum-based CRT |
| Arms | Durvalumab 10 mg/kg q2w up to 12 mo · Placebo |
| Primary endpoints | PFS (BICR) and OS (dual primary, hierarchical) |
| α / power | 0.025 PFS + 0.025 OS (one-sided) / 0.90 each |
| Assumed HR | PFS 0.67 · OS 0.73 |
| Spending | Lan-DeMets OBF α per endpoint |
| Planned looks | 1 interim PFS + final PFS + 2 interim OS + final OS |
| Planned N | 702 (final enrolled 713) |
| Target events | PFS 458 · OS 491 |

## Reproducing the design

```r
library(gsDesign)
d_pfs <- gsSurv(
  k = 2, test.type = 2,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF,
  hr = 0.67, hr0 = 1,
  lambdaC = -log(0.5)/10,   # control median PFS 10 months post-CRT
  R = 24, minfup = 12, ratio = 2
)
# N ≈ 702, events ≈ 458 PFS

d_os <- gsSurv(
  k = 3, test.type = 2,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF,
  hr = 0.73, hr0 = 1,
  lambdaC = -log(0.5)/24,   # control median OS 24 months post-CRT
  R = 24, minfup = 36, ratio = 2
)
```

## What the trial found

- PFS HR **0.52** (95% CI 0.42–0.65), median 16.8 vs 5.6 mo — met at first pre-planned interim.
- OS HR **0.68** (95% CI 0.53–0.87), median NR vs 28.7 mo.
- KM curves for PFS overlap for ~2 months then separate widely — the classic delayed-effect NPH shape.
- Became standard-of-care and defined the "consolidation IO" paradigm post-CRT.

## Caveats & teaching points

- **Allocation ratio 2:1** increases active-arm precision but reduces power per-subject vs 1:1. Chosen to accumulate nivolumab safety/PK data in consolidation setting.
- **Hierarchical gatekeeping** — PFS must succeed before OS tested. PACIFIC's PFS was strongly positive, enabling OS α to cascade down.
- **Post-CRT baseline heterogeneity.** Patients varied in tumor burden after CRT; stratification was by PD-L1 ≥/< 25% (EU) — not a universal stratifier.

## How this case validates designr

- Delayed-effect PFS design — benchmarks gsDesign2 NPH workflow.
- Dual-primary endpoint (PFS + OS) with hierarchical α-recycling.
- 2:1 allocation in an IO consolidation setting.
