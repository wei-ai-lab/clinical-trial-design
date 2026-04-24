# EMA (2014) — Biosimilar similarity regulatory guideline

**Family:** fixed-equivalence · **Kind:** regulatory-guidance · **Scope:** confirmatory biosimilar Phase 3 equivalence trial design

## Why this case is in the corpus

- **Gold-standard regulatory framework** for biosimilar development worldwide.
- Codifies the **totality of evidence** principle — Phase 3 is confirmatory, not foundational.
- Establishes sensitive-indication selection rules for Phase 3 similarity studies.
- Basis for subsequent FDA 2015 biosimilar guidance and ICH Q5E extensions.

## Citation

European Medicines Agency. *Guideline on similar biological medicinal products containing biotechnology-derived proteins as active substance: non-clinical and clinical issues.* EMEA/CHMP/BMWP/42832/2005 Rev.1; 2014.

Companion: *Guideline on similar biological medicinal products.* CHMP/437/04 Rev.1; 2014.

## Core principles

| Principle | Description |
|---|---|
| **Totality of evidence** | Biosimilarity demonstrated by full dossier (analytical + PK + PD + clinical); Phase 3 confirmatory only |
| **Sensitive indication** | Phase 3 in indication where PK/PD differences most likely to translate to clinical effect |
| **Equivalence margin** | Pre-specified, symmetric ±; typically derived from 50% preservation of reference effect |
| **Extrapolation** | Once similar in one indication, label extends to all reference indications with same MoA |
| **Interchangeability** | FDA-only; additional switching study required (not EMA) |

## Design pattern: confirmatory biosimilar Phase 3

```r
library(PowerTOST)
# TOST equivalence sample size for continuous endpoint (means)
sampleN.TOST(
  alpha = 0.05,
  targetpower = 0.90,
  theta0 = 1.00,              # assumed true ratio (similar)
  theta1 = 0.85, theta2 = 1.176,   # ±15% bounds (log-scale symmetric)
  CV = 0.25,                  # coefficient of variation
  design = "parallel"
)

# For binary endpoint (ratio of response rates), e.g., ACR20 at week 24
library(rpact)
ss <- getSampleSizeRates(
  alpha = 0.025, beta = 0.10,
  riskRatio = TRUE,
  thetaH0 = 1.00,
  pi1 = 0.65, pi2 = 0.65,
  margin = 0.15,
  groups = 2
)
```

## Sensitive indication selection for common biosimilars

| Reference | Sensitive indication | Rationale |
|---|---|---|
| Rituximab | Rheumatoid arthritis (ACR20 at wk 24) | Low placebo response; well-characterized endpoint |
| Infliximab | Rheumatoid arthritis or AS | Established DAS28 / BASDAI endpoints |
| Adalimumab | Psoriasis (PASI 75 at wk 16) | Fast endpoint, steep dose-response |
| Trastuzumab | Neoadjuvant HER2+ breast cancer (pCR) | Short endpoint, steep dose-response |
| Bevacizumab | First-line metastatic NSCLC (ORR) | Established endpoint |
| Etanercept | Psoriasis or RA | Fast response |

## How this case validates designr

- Primary regulatory reference for the equivalence family.
- Equivalence-margin derivation framework for `designr` parameter guidance.
- Totality-of-evidence principle informs Phase 3 sample-size expectations (often smaller than first-in-class trials).
- Indication-selection rules enable `designr` to suggest appropriate sensitive-indication defaults for biosimilar Phase 3 designs.
- Complements existing real-trial entries (PLANETRA infliximab, MYL-1401O trastuzumab, SB5 adalimumab) with common methodology underpinning.
