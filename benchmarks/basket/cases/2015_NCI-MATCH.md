# NCI-MATCH (2015) — centralized NGS-driven master protocol basket

**Family:** basket · **Endpoint:** per-sub-study ORR and 6-month PFS · **N:** ~6,000 screened across 30+ arms · **Design feature:** central NGS + 30+ biomarker-matched sub-studies

## Why this case is in the corpus

- **NCI-led public master protocol basket** with centralized NGS screening.
- 30+ biomarker-matched treatment sub-studies under one umbrella.
- Foundational reference for genomic master protocols.

## Citation

Flaherty KT, Gray RJ, Chen AP, et al. *The Molecular Analysis for Therapy Choice (NCI-MATCH) Trial: lessons for genomic trial design.* J Natl Cancer Inst. 2020;112(10):1021-1029. doi:10.1093/jnci/djz245. NCT02465060.

## Design summary

| | |
|---|---|
| Design | Master protocol, 30+ single-arm sub-studies |
| Screening | Centralized NGS (Oncomine Comprehensive Panel) |
| Enrollment target | ~6000 screened, ~1000 matched to therapy |
| Per-sub-study primary | ORR (RECIST) |
| Per-sub-study secondary | 6-month PFS |
| Null vs alternative ORR | 5% vs 16% |
| α / power per sub-study | 0.10 (1-sided) / 0.90 |
| Per-arm N | ~35 (Simon two-stage) |

## Reproducing the per-arm design

```r
library(clinfun)
s <- ph2simon(pu = 0.05, pa = 0.16, ep1 = 0.10, ep2 = 0.10)
# Optimal / minimax: ~35 per arm
```

## Trial outcome (selected)

- **Arm H (BRAF V600 non-melanoma) dabrafenib+trametinib**: positive; supported BRAF combination non-melanoma expansion.
- **Arm Q (HER2 amp) T-DM1**: active in multiple histologies.
- **Arm A (EGFR mut) afatinib**: active, rare-histology NSCLC.
- **Arm W (FGFR) AZD4547**: negative (illustrates biomarker-target mismatch complexity).
- Screening yield ~38% matched to arm (biomarker prevalence lower than planning).
- Template for TAPUR, Lung-MAP, industry master protocols.

## How this case validates designr

- Master protocol basket architecture.
- Centralized NGS screening operational pattern.
- Per-arm Simon two-stage with shared infrastructure reference.
- Public-sector exemplar (NCI + ECOG-ACRIN partnership).
