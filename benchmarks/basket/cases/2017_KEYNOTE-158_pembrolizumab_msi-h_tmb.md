# KEYNOTE-158 (2017) — pembrolizumab in MSI-H / TMB-H solid tumors

**Family:** basket · **Endpoint:** ORR (RECIST) · **N:** 233+ across ≥ 8 baskets · **Design feature:** tissue-agnostic basket with per-cohort ORR

## Why this case is in the corpus

- **Pivotal basket trial for two tissue-agnostic FDA approvals**:
  - MSI-H / dMMR solid tumors (2017, first-ever tissue-agnostic approval).
  - TMB-H ≥ 10 mut/Mb solid tumors (2020).
- Per-basket single-arm ORR aggregated to pan-tumor claim.
- Established TMB cutoff via FoundationOne CDx companion diagnostic.

## Citation

Marabelle A, Le DT, Ascierto PA, et al. *Efficacy of pembrolizumab in patients with noncolorectal high microsatellite instability/mismatch repair-deficient cancer: results from the phase II KEYNOTE-158 study.* J Clin Oncol. 2020;38(1):1-10. doi:10.1200/JCO.19.02105. NCT02628067.

## Design summary

| | |
|---|---|
| Design | Open-label single-arm basket |
| Biomarker | MSI-H / dMMR (Cohort K); TMB-H (exploratory) |
| Intervention | Pembrolizumab 200 mg IV q3w |
| Primary | Objective response rate (RECIST v1.1) |
| Target ORR | 30% |
| α / power (per basket) | 0.05 (1-sided) / 0.80 |
| Total N (MSI-H non-CRC) | 233 |
| Total N (TMB-H) | 102 |

## Reproducing the design

```r
library(clinfun)
# Per-basket Simon two-stage:
# Null ORR 10-15%, target 30%
s <- ph2simon(pu = 0.10, pa = 0.30, ep1 = 0.05, ep2 = 0.20)
# Each basket ~25-50 patients
```

## Trial outcome

- **MSI-H non-CRC cohort**: ORR **34.3%** (95% CI 28.3-40.8%).
- **TMB-H cohort (n=102)**: ORR **29%**; TMB < 10 cohort ORR 6%.
- Median DOR not reached at 13 months.
- **FDA approval**:
  - MSI-H / dMMR pan-tumor: May 2017 (accelerated).
  - TMB-H ≥ 10 mut/Mb pan-tumor: June 2020.

## How this case validates designr

- Tissue-agnostic basket archetype.
- Per-basket single-arm ORR aggregation.
- Companion-diagnostic-defined biomarker (MSI IHC/PCR, TMB by NGS).
- Regulatory precedent for pan-tumor approval based on basket evidence.
