# KEYNOTE-024 (2016) — pembrolizumab vs chemo in PD-L1 ≥ 50% NSCLC

**Family:** group-sequential-nph · **Endpoint:** TTE PFS + OS · **N:** 305 · **Design feature:** biomarker-enriched population with early separation

## Why this case is in the corpus

- **Pre-specified biomarker enrichment** — PD-L1 ≥ 50% only — produced a population where the delayed-effect pattern was less pronounced than in unselected populations.
- Separation was visible within ~2 months; trial met primary endpoint early at interim.
- Teaching case for **biomarker enrichment reducing the NPH problem** in IO trials.

## Citation

Reck M, Rodríguez-Abreu D, Robinson AG, et al. *Pembrolizumab versus chemotherapy for PD-L1-positive non-small-cell lung cancer.* N Engl J Med. 2016;375(19):1823-1833. doi:10.1056/NEJMoa1606774. NCT02142738.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Open-label, 1:1, GS |
| Population | Untreated NSCLC, PD-L1 TPS ≥ 50%, EGFR/ALK WT |
| Arms | Pembrolizumab 200 mg q3w · Platinum-doublet chemo |
| Primary endpoint | PFS (BICR) |
| Secondary | OS (key secondary, α-controlled) |
| α / power | 0.025 (one-sided PFS) / 0.97 |
| Assumed HR (PFS) | 0.55 |
| Spending | Lan-DeMets OBF α |
| Planned looks | 1 interim PFS + OS looks on pre-specified calendar |
| Planned N | 305 |
| Target PFS events | 175 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 2, test.type = 2,
  alpha = 0.025, beta = 0.025,
  sfu = sfLDOF,
  hr = 0.55, hr0 = 1,
  lambdaC = -log(0.5)/6,    # control median PFS 6 months
  R = 9, minfup = 12, ratio = 1
)
# events ≈ 175, N ≈ 305
```

## What the trial found

- PFS HR **0.50** (95% CI 0.37–0.68), median 10.3 vs 6.0 mo — met at pre-specified interim.
- OS HR **0.60** at interim — crossover from chemo to pembro on progression ( > 40% crossover rate) did not erase OS benefit.
- Trial stopped for efficacy at first interim.

## Caveats & teaching points

- **Biomarker enrichment reduces NPH.** PD-L1 ≥ 50% population has higher response rates and shorter time-to-response than PD-L1 low/negative — KM curves separate quickly, PH approximation works better.
- **OS estimation with high crossover** is biased toward the null. IPCW or RPSFT adjustment is standard for post-hoc OS analysis. KEYNOTE-024 showed OS benefit despite 40%+ crossover — the effect is robust.
- **Early efficacy stop at a single interim** is aggressive. OBF boundary at IF ≈ 0.7 is tight; observed HR 0.50 was well past it.

## How this case validates designr

- Biomarker-enriched population design.
- Early-separation IO pattern (vs delayed).
- OS with crossover — interpretation and sensitivity analysis choice.
