# I-SPY 2 (2016) — adaptive platform in neoadjuvant breast cancer

**Family:** bayesian · **Endpoint:** pCR at surgery · **Design feature:** Bayesian predictive probability of Phase 3 success

## Why this case is in the corpus

- **Canonical Bayesian adaptive platform** feeding Phase 2 → Phase 3 transitions.
- Predictive probability of Phase 3 success as graduation rule (≥ 85%).
- Multi-drug platform: pembrolizumab, olaparib, T-DM1, durvalumab, neratinib all graduated.

## Citation

Park JW, Liu MC, Yee D, et al. *Adaptive randomization of neratinib in early breast cancer (I-SPY 2 TRIAL).* N Engl J Med. 2016;375(1):11-22. doi:10.1056/NEJMoa1513750. NCT01042379.

## Design summary

| | |
|---|---|
| Design | Adaptive platform Phase 2 |
| Population | High-risk early breast cancer, neoadjuvant |
| Biomarker signatures | 10 (HR/HER2/MammaPrint combinations) |
| Primary | pCR at surgery |
| Adaptation | Bayesian allocation ∝ Pr(best in signature) |
| Graduation | Pr(Phase 3 success, N = 300) ≥ 85% |
| Futility | Pr(Phase 3 success) ≤ 10% |
| Arm-specific N | ~50-150 |
| Shared control | Anthracycline + taxane (± trastuzumab) |

## Reproducing the design

```r
# Bayesian logistic model for pCR
# Posterior updated after each ~20-patient block
# Predictive probability computed by:
#  1) simulate future Phase 3 data from posterior
#  2) estimate Pr(Phase 3 p < 0.05) marginalized over posterior

library(rstan)
# Hierarchical Beta-binomial per biomarker signature
```

## Trial outcome (neratinib arm)

- Neratinib graduated in HR-/HER2+ signature: pCR 56% vs 33% control.
- Bayesian posterior Pr(Phase 3 success) reached 79% (below 85% graduation but clinically promising).
- Final evaluation confirmed HR-/HER2+ as target signature.
- Phase 3 ExteNET → FDA approval July 2017.

## How this case validates designr

- Bayesian adaptive platform reference.
- Predictive-probability graduation rule specification.
- Arm-specific N in shared-control platform trial.
