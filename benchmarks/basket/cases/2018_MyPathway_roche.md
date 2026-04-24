# MyPathway (2018) — Industry Multi-Drug Pan-Tumor Basket

**Family:** basket · **Kind:** primary-results · **N:** 251 (interim) · **Endpoint:** ORR per RECIST · **Design:** 5 drug-pathway arms × tumor histology cohorts

## Why this case is in the corpus

- **Canonical industry-sponsored multi-drug basket** — 5 targeted therapies across 5 molecular pathways, with tumor-histology sub-cohorts per drug.
- Complements the academic (NCI-MATCH), academic-single-drug (VE-BASKET, KEYNOTE-158, LOXO-TRK, ROAR), and national-reimbursement (DRUP) baskets in the corpus.
- Generated registration-grade evidence for multiple accelerated approvals (HER2-amplified mCRC).
- Template for subsequent Roche / industry baskets (CUPISCO) and ASCO-TAPUR.

## Citation

Hainsworth JD, Meric-Bernstam F, Swanton C, et al. *Targeted therapy for advanced solid tumors on the basis of molecular profiles: results from MyPathway, an open-label, phase IIa multiple basket study.* J Clin Oncol. 2018 Feb 20;36(6):536-542. (NCT02091141.)

## Design summary

| Drug | Pathway | Main tumor cohorts |
|---|---|---|
| Trastuzumab + pertuzumab | HER2-amplified | CRC, biliary, salivary, bladder, endometrial, lung, ovarian, prostate |
| Vemurafenib | BRAF V600-mutated non-melanoma | CRC, biliary, lung, thyroid |
| Vismodegib | Hedgehog-activated | pancreatic, ameloblastoma, other |
| Erlotinib | EGFR-mutated non-NSCLC | biliary, head/neck, other |
| Alectinib | ALK/ROS1-rearranged non-NSCLC | thyroid, biliary, colorectal |

## Per-cohort design

```r
# MyPathway: Simon 2-stage optimal per drug-pathway-tumor cohort
library(clinfun)
# Example: HER2 CRC cohort with p0 = 0.05, p1 = 0.25
ph2simon(
  pu = 0.05, pa = 0.25,
  ep1 = 0.10, ep2 = 0.20,
  nmax = 40
)
# Optimal: n1 = 7 (stop if ≤ 0); n = 22 (success if ≥ 3)
# Expected N under H0 ≈ 10.5; Probability of early termination ≈ 0.70
```

## Interim findings (2018)

| Drug-pathway | Cohort | N | ORR | Interpretation |
|---|---|---|---|---|
| Trastuzumab+pertuzumab | HER2+ CRC | 37 | 38% | Strong signal → tucatinib/trastuzumab approval 2023 |
| Trastuzumab+pertuzumab | HER2+ biliary | 11 | 42% | Positive, expanded |
| Vemurafenib | BRAF CRC | 10 | 0% | Null — CRC needs EGFR blockade |
| Vemurafenib | BRAF biliary | 8 | 25% | Positive |
| Vismodegib | Hedgehog (various) | 11 | 0-17% | Disappointing |

## Regulatory impact

- Accelerated approval for **tucatinib + trastuzumab** in HER2-amplified mCRC (2023) derived partly from MyPathway-class evidence.
- **Vemurafenib** in BRAF V600 non-melanoma: NCCN guideline inclusion for thyroid, biliary.
- Informed FDA tissue-agnostic approval pathway alongside pembrolizumab MSI-H (2017), larotrectinib (2018), entrectinib (2019).

## Distinguishing features from other baskets

- **Industry-sponsored** (Roche) vs academic (NCI-MATCH) or national (DRUP).
- **Multi-drug** — 5 drug classes in one trial infrastructure.
- **Pre-specified pathway-drug mapping** — not agnostic target-drug assignment.
- **Tissue-histology sub-cohorts** within each drug arm — granular response estimation.

## How this case validates designr

- Complements the basket corpus with an **industry multi-drug basket** archetype.
- Per-cohort Simon 2-stage with differential p0/p1 by tumor baseline — `designr` should expose `ph2simon` with per-cohort parameterization.
- Teaching case: when biology suggests the same molecular alteration may respond differently across tumor types (BRAF V600 in CRC vs biliary vs thyroid), cohort-level reporting is essential — BHM borrowing can obscure clinically meaningful cohort-specific effects.
