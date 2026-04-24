# BATTLE-2 (2016) — biomarker-integrated umbrella in refractory NSCLC

**Family:** umbrella · **Endpoint:** 8-week DCR · **N:** 334 · **Design feature:** two-stage learn-then-confirm Bayesian adaptive umbrella

## Why this case is in the corpus

- **Successor to BATTLE** with explicit learn (stage 1) + confirm (stage 2) architecture.
- 4-arm biomarker-informed Bayesian adaptive randomization.
- Cautionary tale on stage 1 → stage 2 validation in small umbrellas.

## Citation

Papadimitrakopoulou V, Lee JJ, Wistuba II, et al. *The BATTLE-2 study: a biomarker-integrated targeted therapy study in previously treated patients with advanced non-small-cell lung cancer.* J Clin Oncol. 2016;34(30):3638-3647. doi:10.1200/JCO.2015.66.0084. NCT01248247.

## Design summary

| | |
|---|---|
| Design | Two-stage umbrella: learn (n=200) + confirm (n=200) |
| Disease | Refractory advanced NSCLC post-platinum |
| Arms | Erlotinib · Erlotinib+MK2206 · MK2206+selumetinib · Sorafenib |
| Biomarkers | KRAS · PI3K/AKT/mTOR · EGFR · FGFR |
| Stage 1 adaptation | Bayesian RAR with biomarker × arm posterior |
| Primary | 8-week disease control rate |
| α / power | Bayesian posterior-based decision |
| Planned N | ~334 |

## Reproducing the design

```r
# Stage 1: Bayesian RAR by biomarker × arm
# Per-cell posterior: π(DCR | biomarker, arm) ~ Beta
# Allocation: prob ∝ Pr(arm is best | biomarker, data)

library(rstan)
# Hierarchical Beta-binomial with biomarker and arm effects
# Updated after each ~20 patient block

# Stage 2: confirmatory — fixed allocation to best arm per biomarker
```

## Trial outcome

- Stage 1 signal: sorafenib appeared best in KRAS-mutant; combo arms in PI3K-altered.
- Stage 2 validation: no arm clearly dominated in any biomarker subgroup.
- 8-week DCR ~51% across all patients.
- Published learnings emphasized the difficulty of stage 1 → stage 2 confirmation in small umbrellas.
- Operational template informed Lung-MAP.

## How this case validates designr

- Two-stage learn-then-confirm umbrella design reference.
- Bayesian adaptive randomization in umbrella context.
- Cautionary case for small-N umbrella validation.
