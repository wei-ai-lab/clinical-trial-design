# ALCHEMIST (2014) — adjuvant NSCLC biomarker umbrella

**Family:** umbrella · **Endpoint:** per-sub-study DFS · **N:** ~2,100 matched (8,300 screened) · **Design feature:** adjuvant setting biomarker-matched umbrella

## Why this case is in the corpus

- **Adjuvant-setting umbrella** — distinctive focus on early-stage resected NSCLC vs metastatic focus of most umbrellas.
- Central NGS screening post-resection feeds three biomarker-matched sub-studies.
- NCI-sponsored (Alliance / ECOG-ACRIN) public-sector template.

## Citation

Govindan R, Mandrekar SJ, Gerber DE, et al. *ALCHEMIST Trials: a golden opportunity to transform outcomes in early-stage non-small cell lung cancer.* Clin Cancer Res. 2015;21(24):5439-5444. doi:10.1158/1078-0432.CCR-15-0354. NCT02194738.

## Design summary

| | |
|---|---|
| Design | NCI master protocol umbrella |
| Disease | Resected stage IB-IIIA non-squamous NSCLC |
| Biomarker | Central NGS for EGFR mut, ALK fusion |
| Sub-studies | EGFR-mut: erlotinib vs placebo · ALK: crizotinib vs observation · Wild-type: nivolumab vs observation |
| Primary | DFS per sub-study |
| Target HR | 0.67 |
| α / power | 0.05 (two-sided) / 0.90 |
| Screening target | ~8,300 patients |
| Matched N | ~2,100 |

## Reproducing the design (per sub-study)

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(0.60)/2, hr = 0.67,
  alpha = 0.025, beta = 0.10,
  R = 60, minfup = 60
)
# Events ~140 per sub-study; interim at 67%
```

## Trial outcome (as of 2023)

- **EGFR-mutant (A081105)**: erlotinib vs placebo superseded by ADAURA (osimertinib) → ADAURA showed DFS HR 0.17 and became SOC.
- **ALK-fusion (E4512)**: crizotinib vs observation, ongoing.
- **Wild-type (ANVIL)**: nivolumab vs observation; data matured with negative primary.
- Operational success: screened 8,000+ patients across US and established central NGS workflow.

## How this case validates designr

- Adjuvant umbrella design reference.
- Central biomarker screening operational pattern.
- Three-sub-study architecture with different controls.
- Public-sector NCI Alliance template.
