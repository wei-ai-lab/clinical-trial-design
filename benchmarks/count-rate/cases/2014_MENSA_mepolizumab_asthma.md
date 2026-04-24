# MENSA (2014) — mepolizumab in severe eosinophilic asthma

**Family:** count-rate · **Endpoint:** annualized exacerbation rate (NB) · **N:** 576 · **Design feature:** three-arm biologic trial, NB primary

## Why this case is in the corpus

- **Canonical severe asthma biologic design** — NB annualized exacerbation rate primary.
- Three-arm (IV + SC + placebo) with hierarchical testing.
- Stratified by eosinophil count (the biomarker).

## Citation

Ortega HG, Liu MC, Pavord ID, et al. *Mepolizumab treatment in patients with severe eosinophilic asthma (MENSA).* N Engl J Med. 2014;371(13):1198-1207. doi:10.1056/NEJMoa1403290. NCT01691521.

## Design summary

| | |
|---|---|
| Design | RDBPC, 3-arm (IV+SC+placebo) |
| Population | Severe eosinophilic asthma, ≥ 2 exacerbations prior yr |
| Arms | Mepolizumab 75 mg IV · 100 mg SC · placebo |
| Primary | Annualized rate of clinically significant exacerbations (NB) |
| Multiple testing | Hierarchical: SC → IV |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed rate ratio | 0.55 (vs placebo) |
| Assumed dispersion k | 2.0 |
| Planned N | ~576 |

## Reproducing the design

```r
library(rpact)
d <- getSampleSizeCounts(
  alpha = 0.025, beta = 0.10,
  lambda1 = 1.32, lambda2 = 2.40,  # rate per year
  overdispersion = 2.0,
  accrualTime = 12, followUpTime = 8
)
```

Analysis:

```r
library(MASS)
fit <- glm.nb(n_exac ~ arm + strata_eos + offset(log(fup_days/365)),
              data = df)
```

## Trial outcome

- Annualized exacerbation rate: **0.83 (SC) vs 0.93 (IV) vs 1.74 (placebo)**.
- Rate ratio SC vs placebo: **0.47** (95% CI 0.35-0.64), p < 0.001.
- Rate ratio IV vs placebo: **0.53** (95% CI 0.40-0.71), p < 0.001.
- ACQ-5, AQLQ, FEV1 all improved significantly.
- FDA approval (Nucala) November 2015; EMA approval December 2015.

## How this case validates designr

- Severe asthma biologic NB design reference.
- Three-arm pivotal with hierarchical multiple testing.
- Stratified randomization by biomarker.
