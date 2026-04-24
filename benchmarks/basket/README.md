# basket — Basket / tissue-agnostic Phase 2/3 designs

## Family overview

**Basket trials** enroll patients across multiple cancer types (or disease types) who share a common biomarker-defined feature, and evaluate a **single intervention** against this shared target. Distinct from umbrella (same disease, multiple biomarkers) and platform (multiple diseases/interventions under master protocol).

Key design elements:
- **Shared drug, single mechanism, single biomarker, multiple histologies.**
- **Per-histology substudy** ("basket" or "cohort") with binary / TTE efficacy endpoint.
- **Hierarchical borrowing** across baskets — all-or-nothing is inefficient; no-borrowing misses signal in small baskets.

## Design options

1. **Simon two-stage per basket** — each cohort independent; no cross-basket borrowing. Simple, conservative.
2. **Bayesian hierarchical model (BHM) — Berry et al. 2013** — exchangeable random effects across baskets; borrows strength under exchangeability assumption.
3. **EXNEX (Exchangeability-Non-exchangeability) — Neuenschwander 2016** — robust mixture prior allowing each basket to opt out of the exchangeable group.
4. **CBHM (Calibrated Bayesian Hierarchical Model) — Chu & Yuan 2018** — data-driven calibration of shrinkage amount.
5. **MUCE (Multi-arm Cohort Evaluation) — Chen et al. 2016** — multi-arm frequentist basket with cross-basket adjustment.

## Regulatory milestones

- **Pembrolizumab in MSI-H/dMMR** (Le et al., FDA 2017) — first tissue-agnostic approval, based on KEYNOTE-012, -016, -028, -158, -164.
- **Larotrectinib in NTRK-fusion** (Drilon et al., FDA 2018) — second tissue-agnostic approval.
- **Pembrolizumab in TMB-H** (KEYNOTE-158, FDA 2020) — third.
- **Entrectinib in NTRK / ROS1** (FDA 2019).
- FDA guidance: *Master Protocols: Efficient Clinical Trial Design Strategies* (2022).

## Common design pitfalls

- **Basket heterogeneity** — disease biology may not be shared despite biomarker; shrinkage to grand mean can mislead.
- **Small baskets under-power** — rare histologies (e.g., cholangiocarcinoma in dMMR basket) may have ≤ 5 patients.
- **Histology-as-covariate risk** — adjusting for histology shifts interpretation to biomarker-conditional effect.
- **Tumor-agnostic claim**: requires evidence of effect across sufficient histologies — no formal threshold, but ≥ 3-5 baskets with consistent signal is typical FDA bar.

## R packages

- **`basket`** — (Broglio, Muth, Berry) BHM, EXNEX, CBHM implementations.
- **`bhmbasket`** — Bayesian hierarchical basket model.
- **`RBesT`** — MAP priors adaptable to basket setting.
- **`rstan` / `brms`** — custom hierarchical models.

## Cases in this corpus

| Case | Year | Setting | Design |
|---|---|---|---|
| VE-BASKET — vemurafenib in BRAF V600 | 2015 | 6 cancer types | Simon two-stage, no borrowing |
| KEYNOTE-158 — pembrolizumab MSI-H / TMB-H | 2017 | Multiple tumor types | Tissue-agnostic single-arm |
| NCI-MATCH — biomarker-matched therapy | 2015 | 30+ biomarker arms | Master screening + per-arm Phase 2 |
| Berry-Broglio-Groshen-Berry BHM | 2013 | Any basket | Bayesian hierarchical borrowing methodology |
