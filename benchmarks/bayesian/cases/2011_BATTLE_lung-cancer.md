# BATTLE (2011) — Bayesian adaptive biomarker trial in NSCLC

**Family:** bayesian · **Endpoint:** 8-wk disease control rate · **N:** 255 · **Design feature:** biomarker-stratified Bayesian adaptive randomization

## Why this case is in the corpus

- **Seminal Bayesian adaptive biomarker design** that inspired I-SPY2, Lung-MAP, FOCUS4.
- 4 treatments × 5 biomarker groups with Thompson-sampling-like allocation.
- Foundational reference for platform-biomarker adaptive design paradigm.

## Citation

Kim ES, Herbst RS, Wistuba II, et al. *The BATTLE trial: personalizing therapy for lung cancer.* Cancer Discov. 2011;1(1):44-53. doi:10.1158/2159-8290.CD-10-0010. NCT00409968.

## Design summary

| | |
|---|---|
| Design | Bayesian adaptive 4-arm × 5 biomarker group |
| Population | Refractory NSCLC |
| Arms | Erlotinib · Vandetanib · Erlotinib+bexarotene · Sorafenib |
| Biomarker groups | EGFR · KRAS/BRAF · VEGF/VEGFR · RXR/CycD1 · negative |
| Primary | 8-week DCR (binary) |
| Adaptation | Allocation ∝ Pr(arm is best in biomarker group) |
| Run-in | ~140 equal allocation, then ~115 adaptive |
| Planned N | ~255 |

## Reproducing the design

```r
# Thompson-sampling posterior:
# p_best[arm, bmk] = Pr(θ_arm is max among arms | biomarker group, data)
# Allocation prob ∝ p_best with floor and burn-in period

library(rstan)
# Beta-binomial posterior per arm × biomarker group
# Updated after each ~20 patient block
```

## Trial outcome

- N = 255 randomized, 244 evaluable.
- Overall 8-week DCR: 46%.
- EGFR mutants benefited from erlotinib; KRAS mutants from sorafenib.
- Results generated biomarker-treatment hypotheses for subsequent Phase 3 validation.
- FDA engagement informed successor designs (BATTLE-2, Lung-MAP).

## How this case validates designr

- Bayesian adaptive randomization reference.
- Biomarker-stratified multi-arm design.
- Historical reference for platform-Phase 2/3 designs that followed.
