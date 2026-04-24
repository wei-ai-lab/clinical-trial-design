# umbrella — Umbrella Phase 2/3 designs

## Family overview

**Umbrella trials** study a **single disease** across **multiple biomarker-defined sub-groups**, each matched to a different targeted therapy. One master protocol, one tumor type, several biomarker-therapy branches. Distinguished from:

- **Basket** (one drug, multiple diseases/tumor types with shared biomarker).
- **Platform** (often disease-focused master protocol with open-ended arm addition; umbrella is a platform when arms can be added/dropped over time).

## Canonical structure

1. **Shared disease eligibility** — e.g., "refractory NSCLC" or "stage III colorectal cancer".
2. **Centralized biomarker screening** — typically a multi-analyte NGS panel.
3. **Biomarker-matched sub-studies** — each sub-study = a Phase 2/3 mini-trial for a biomarker × drug pair.
4. **Non-match cohort** — patients without an actionable biomarker typically flow to immunotherapy or default therapy.
5. **Shared infrastructure** — single IRB package, single informed consent, unified data collection.

## Design choices

- **Sub-study primary endpoint**: often PFS or ORR (Phase 2) or OS (Phase 3).
- **Randomization per sub-study**: RCT against SOC or single-arm against historical.
- **Cross-sub-study α control**: usually per-sub-study (each biomarker-drug pair is a distinct scientific question). Family-wise α occasionally chosen when arms are related (e.g., multiple doses of same target).
- **Adaptive element**: some umbrellas (Lung-MAP, BATTLE-2, FOCUS4) add Bayesian or frequentist adaptation.

## Common pitfalls

- **Biomarker prevalence uncertainty**: planning often over-estimates prevalence; screen-to-enroll ratio frequently 3-5:1.
- **Operational complexity**: dozens of biomarker-drug combinations × company partnerships.
- **Biomarker ambiguity**: overlapping alterations (e.g., co-occurring mutations) force prioritization rules.
- **Sub-study heterogeneity**: different sub-studies may use different designs (single-arm vs RCT, different controls).
- **Regulatory harmonization**: FDA/EMA align on master protocol concept but individual sub-studies need independent submission-readiness.

## R packages

- **`gsDesign` / `rpact`** — per-sub-study frequentist design.
- **`FACTS`** — Bayesian adaptive umbrella designs.
- **`rstan` / `brms`** — hierarchical umbrella with cross-sub-study borrowing.
- **`MAMS` / `nstage`** — umbrella with MAMS-style interim rules per sub-study.

## Cases in this corpus

| Case | Year | Disease | Sub-studies |
|---|---|---|---|
| BATTLE-2 — refractory NSCLC adaptive umbrella | 2016 | NSCLC | 4 arms adaptively allocated |
| ALCHEMIST — adjuvant NSCLC biomarker umbrella | 2014 | Resected early NSCLC | 3 sub-studies (EGFR, ALK, wild-type) |
| NCI-MPACT — NCI molecular profiling umbrella | 2017 | Advanced solid tumors (pan) | 4 biomarker-pathway pairs |
| Renfro-Mandrekar umbrella methodology | 2018 | Any | Design/conduct review |
