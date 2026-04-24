# INHANCE (2010) — Seamless Phase 2/3 indacaterol in COPD

**Family:** non-standard · **Endpoint:** 26-week trough FEV1 · **N:** 1,683 · **Design feature:** real-world inferential-seamless P2/3, 4→2 dose selection

## Why this case is in the corpus

- **Most cited real-world inferential-seamless Phase 2/3 trial** — saved ~1 year of development.
- Demonstrates Bauer-Kieser / Cui-Hung-Wang combination-test machinery in a regulatory-approved trial.
- Registration basis for indacaterol (Onbrez / Arcapta) at EMA and FDA.
- Benchmark for any sponsor considering a seamless P2/3 respiratory program.

## Citation

Barnes PJ, Pocock SJ, Magnussen H, et al. *Integrating indacaterol dose selection in a clinical study in COPD using an adaptive seamless design.* Pulm Pharmacol Ther. 2010;23(3):165-171. doi:10.1016/j.pupt.2010.01.003. NCT00393458.

## Design summary

| | |
|---|---|
| Design | Two-stage seamless Phase 2/3, inverse-normal combination test |
| Population | Moderate-to-severe COPD, ≥ 40 y, ≥ 20 pack-years |
| Stage 1 (dose selection) | 4 indacaterol doses (75, 150, 300, 600 µg QD) vs placebo + active comparators; primary: 14-day FEV1 AUC |
| Selection rule | Retain **2** of 4 indacaterol doses for Stage 2 based on Stage-1 efficacy + safety |
| Stage 2 (confirmation) | Selected doses (150 + 300 µg) vs placebo + active comparators; primary: 26-week trough FEV1 |
| α | 0.05 (two-sided), FWER protected by closed testing |
| Power | 0.90 |
| Planned N | 1,683 |

## Reproducing the design

```r
library(rpact)

design <- getDesignInverseNormal(
  kMax = 2,
  alpha = 0.025,
  beta = 0.10,
  informationRates = c(0.25, 1.0),
  typeOfDesign = "asOF"
)

ss <- getSampleSizeMeans(
  design = design,
  alternative = 0.12,   # L difference vs placebo in trough FEV1
  stDev = 0.30,
  allocationRatioPlanned = 1
)
```

## Trial outcome

- **Stage 1**: All 4 indacaterol doses beat placebo on 14-day FEV1 AUC; dose-response plateau between 150-600 µg. Doses **150 µg** and **300 µg QD** selected to carry forward (75 µg under-performed; 600 µg no marginal benefit + mild tolerability signal).
- **Stage 2**: Selected doses beat placebo on 26-week trough FEV1 by ~120 mL (p < 0.001); comparable to formoterol BID and tiotropium QD.
- FDA / EMA approval: 150 µg QD (most indications), 300 µg QD (severe COPD).

## How this case validates designr

- Real-world benchmark for seamless Phase 2/3 sample sizing.
- Two doses selected, not one — stresses closed-testing implementation.
- Inverse-normal combination test with asymmetric information fractions (Stage 1 ≈ 20% of final info).
- Enables `designr` to reproduce the combination-function + closed-testing pipeline on an approved trial.
