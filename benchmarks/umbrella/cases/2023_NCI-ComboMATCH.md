# NCI-ComboMATCH (2023-) — Combination-regimen umbrella successor to NCI-MATCH

**Family:** umbrella · **Endpoint:** per-arm PFS (randomized vs monotherapy comparator) · **N:** ~1,000 across 10+ arms · **Design feature:** modern combination-centric randomized umbrella with preclinical gatekeeping

## Why this case is in the corpus

- **State-of-the-art umbrella design** (2023-) addressing NCI-MATCH lessons.
- **Combination-only** arms (not single agents) with **randomized-within-arm** design.
- **Preclinical synergy gatekeeping** via PDX models — novel formal integration of translational evidence.
- Template for future post-MATCH master protocols.

## Citation

O'Dwyer PJ, Gray RJ, Flaherty KT, et al. *The NCI-MATCH trial: lessons learned and the path forward.* Nat Med. 2023;29:1349-1357. doi:10.1038/s41591-023-02379-4. ComboMATCH registry: NCT05564377 (EAY191), 2023 protocol.

## Design summary

| | |
|---|---|
| Design | Randomized combination-arm umbrella |
| Population | Advanced solid tumors progressing on ≥ 1 prior therapy; central NGS screen |
| Arm structure | Each arm: combination vs monotherapy comparator, randomized 1:1 |
| Arm inclusion criteria | Preclinical PDX synergy evidence + biomarker-defined eligibility |
| Primary (per arm) | Progression-free survival (PFS) |
| α | 0.025 one-sided per arm |
| Power | 0.80 on HR 0.65 per arm |
| Per-arm N | 70-160 (sized to ~80 PFS events) |
| Planned arms | 10+ at launch |
| Total N | ~1,000 across planned arms |

## Reproducing the design

```r
library(gsDesign)
# Per-arm PFS sample size — typical combo arm
nSurv(
  lambdaC = -log(1 - 0.50) / 6,   # median monotherapy PFS ~ 6 mo
  hr = 0.65,
  alpha = 0.025, beta = 0.20,
  R = 24, minfup = 12, sided = 1
)
# ~ 85 events; ~ 120 subjects depending on accrual

# Cross-arm sensitivity via hierarchical model
library(bhmbasket)
posteriorData <- bhmAnalysis(
  responses = arm_events,
  trialsize = arm_n,
  p0 = 0.65,       # HR null threshold
  shape1 = 0.5, shape2 = 0.5,
  mcmc = 20000
)
```

## Expected trial activity

- 10+ combination arms covering RAS/RAF, PI3K/AKT, DDR (PARP/WEE1/ATR), IO combinations, etc.
- **Central screening pipeline**: shared with NCI-MATCH (EAY131); genomic yield ~20% of screened patients find an eligible arm match.
- **Adaptive enrollment**: arms added as preclinical pipeline matures, dropped for futility at ~50% information.
- First readouts expected 2026-2027.

## How this case validates designr

- Modern umbrella sizing: per-arm PFS randomized vs monotherapy.
- Preclinical-gatekeeping + biomarker screening yield parameters.
- Cross-arm hierarchical sensitivity for rare combination-biomarker cells.
- Architectural contrast with BATTLE (2011) single-agent, NCI-MATCH (2015) single-agent pan-tumor — shows the evolution toward combination-centric randomized umbrellas.
