# Renfro-Mandrekar (2018) — umbrella methodology reference

**Family:** umbrella · **Endpoint:** any · **Design feature:** methodology framework for umbrella statistical properties

## Why this case is in the corpus

- **Standard methodology reference** for umbrella SAP writers.
- Contrasts umbrella, basket, platform with crisp definitions.
- Lays out α-control, prevalence planning, and design choices.

## Citation

Renfro LA, Mandrekar SJ. *Definitions and statistical properties of master protocols for personalized medicine in oncology.* J Biopharm Stat. 2018;28(2):217-228. doi:10.1080/10543406.2017.1372778.

## Framework summary

| Question | Options |
|---|---|
| α control | Per-comparison · Family-wise (Bonferroni, Dunnett) · Hierarchical Bayesian |
| Biomarker approach | Enrichment · Stratified · Hybrid (biomarker primary, all secondary) |
| Sub-study design | RCT (within-umbrella matched vs control) · Single-arm (vs historical) |
| Shared control | Concurrent · Historical · Hybrid (MAP prior) |
| Adaptation | Fixed · Response-adaptive · Biomarker-adaptive |

## Reproducing design simulations

```r
library(FACTS)  # commercial
# Or custom simulation:

# Per-sub-study OC:
# - Type I error under H0
# - Power under pre-specified effect
# - Expected enrollment given biomarker prevalence distribution

# Platform-level OC:
# - Probability of at least one sub-study positive under H0_all
# - Expected total enrollment
# - Expected study duration
```

## Key design insights

1. **Biomarker prevalence planning**: retrospective comparison shows sponsors often over-estimate prevalence by 2-5×. Plan with conservative (lower) prevalence and sensitivity analyses.

2. **α control choice**:
   - Per-comparison: independent biomarker-drug questions, each its own claim.
   - Family-wise: related arms (e.g., multiple doses of one drug).
   - Hierarchical Bayesian: across biomarkers when biology suggests exchangeability.

3. **Enrichment vs stratified**:
   - Enrichment: biomarker-positive only — highest per-subject power, narrow claim.
   - Stratified: both positive and negative, biomarker as factor — broader claim, more N.

4. **Operational pitfalls**:
   - Central biomarker testing turnaround (< 14 days required for most protocols).
   - Sub-study launch/close asynchrony complicates shared data management.
   - Regulatory interactions per sub-study must be pre-planned.

## How this case validates designr

- Reference methodology framework for umbrella design specifications.
- Operationally-grounded design choice tree for SAP writers.
- Bridge between biomarker-driven umbrella architecture and FDA master protocol guidance (2022).
