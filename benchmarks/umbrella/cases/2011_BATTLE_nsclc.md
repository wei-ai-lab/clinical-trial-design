# BATTLE (2011) — Original adaptive biomarker-driven umbrella in NSCLC

**Family:** umbrella · **Endpoint:** 8-week disease control rate · **N:** 255 · **Design feature:** first published adaptive biomarker-driven umbrella; 5 biomarker groups × 4 treatments

## Why this case is in the corpus

- **First published adaptive biomarker-driven umbrella trial**.
- Established the umbrella template: mandatory biopsy → central profiling → adaptive randomization within biomarker subgroup.
- Architectural precedent for BATTLE-2, Lung-MAP, NCI-MATCH, SAFIR02, and most modern master-protocol oncology trials.
- MD Anderson canonical reference.

## Citation

Kim ES, Herbst RS, Wistuba II, et al. *The BATTLE trial: personalizing therapy for lung cancer.* Cancer Discov. 2011;1(1):44-53. doi:10.1158/2159-8290.CD-10-0010. NCT00409968.

Design paper: Zhou X, Liu S, Kim ES, et al. *Bayesian adaptive design for targeted therapy development in lung cancer — a step toward personalized medicine.* Clin Trials. 2008;5(3):181-193.

## Design summary

| | |
|---|---|
| Design | Adaptive biomarker-driven umbrella, Bayesian adaptive randomization |
| Population | Advanced NSCLC after ≥ 1 prior chemotherapy |
| Biomarker groups | 5 — EGFR mutation/copy, KRAS/BRAF mutation, VEGF/VEGFR expression, RXR/CycD1, multiple/none |
| Treatment arms | 4 — erlotinib, sorafenib, vandetanib, erlotinib + bexarotene |
| Primary | 8-week disease control rate (DCR) per RECIST |
| Target DCR | 0.50 (vs 0.30 null) |
| α | 0.05 one-sided (cell-specific) |
| Power | 0.80 at cell level |
| Planned N | 255 (biopsied: 244) |

## Reproducing the design

```r
# Per-cell Bayesian posterior DCR with Beta(0.5, 0.5) prior
posterior_dcr <- function(responses, n) {
  alpha_post <- 0.5 + responses
  beta_post  <- 0.5 + (n - responses)
  list(
    mean = alpha_post / (alpha_post + beta_post),
    prob_superior = 1 - pbeta(0.30, alpha_post, beta_post)
  )
}

# Adaptive randomization probability (with floor of 0.10 per cell)
adaptive_prob <- function(post_means) {
  raw <- post_means / sum(post_means)
  pmax(raw, 0.10) / sum(pmax(raw, 0.10))
}

# First 20 subjects per biomarker group: fixed 1:1:1:1, then adaptive
```

## Trial outcome

- **Overall 8-week DCR: 46%** vs historical ~30% — primary met.
- **EGFR mutant** → erlotinib 52% DCR (biomarker hypothesis supported).
- **VEGF/VEGFR-high** → sorafenib 64% DCR.
- **KRAS/BRAF mutant** → sorafenib 61% DCR (unexpected — was thought to be resistant to TKIs).
- 244 of 255 successfully biopsied and profiled.

## How this case validates designr

- Original reference for umbrella design sample sizing.
- Bayesian adaptive randomization benchmark with biomarker-stratified posterior updates.
- Demonstrates feasibility of mandatory-biopsy + central-profiling operational model.
- Complements BATTLE-2 (2016) in the corpus, showing the evolution of the template.
- Exercises `basket` / `bhmbasket` cross-cell hierarchical analysis capabilities.
