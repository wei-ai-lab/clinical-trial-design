# Bauer-Kieser (1999) — Seamless Phase 2/3 combination-test methodology

**Family:** non-standard · **Kind:** methodology-canonical · **N:** n/a (framework) · **Design feature:** combining Stage-1 dose selection + Stage-2 confirmation with FWER control

## Why this case is in the corpus

- **Canonical framework** for inferential-seamless Phase 2/3 designs.
- Establishes the combination-test + closed-testing machinery that underlies all modern seamless designs.
- Foundation for `adaptTest`, `asd`, and `rpact`'s seamless / treatment-selection modules.
- Cited by FDA 2019 Adaptive Design Guidance and EMA 2007 Reflection Paper.

## Citation

Bauer P, Kieser M. *Combining different phases in the development of medical treatments within a single trial.* Stat Med. 1999;18(14):1833-1848. doi:10.1002/(SICI)1097-0258(19990730)18:14<1833::AID-SIM221>3.0.CO;2-3.

Foundational: Bauer P, Köhne K. *Evaluation of experiments with adaptive interim analyses.* Biometrics. 1994;50:1029-1041.

## Design summary

| | |
|---|---|
| Design | Two-stage seamless Phase 2/3 with treatment selection |
| Stage 1 | Multi-arm (e.g. 3 doses + control), small N, select best dose |
| Stage 2 | Selected dose vs control, enroll **new** patients (independence required) |
| Primary inference | Combination of Stage-1 + Stage-2 p-values under pre-specified combination function |
| Type-I control | Combination function (inverse-normal or Fisher) + closed testing |
| α | 0.025 one-sided (canonical) |
| Power | 0.80 (target on selected vs control) |

## Reproducing the framework

```r
library(rpact)

# Inverse-normal combination, 2-stage seamless with 3 treatment arms selected to 1
design <- getDesignInverseNormal(
  kMax = 2,
  alpha = 0.025,
  beta = 0.20,
  typeOfDesign = "OF",
  informationRates = c(0.25, 1.0)
)

# Sample size for selected-dose vs control using inverse-normal combination
ss <- getSampleSizeMeans(
  design = design,
  alternative = 0.30,
  stDev = 1.0,
  allocationRatioPlanned = 1
)
```

## Core results

- **Combination function** (Fisher product or inverse-normal of stage-wise p-values) preserves type-I error *regardless* of the interim selection rule, provided Stage 1 and Stage 2 data are independent.
- **Closed testing** extends the single-comparison control to the full multi-arm family: intersection hypotheses are tested at the adjusted α via Bauer-Köhne, and rejection of all supersets is required to reject any elementary hypothesis.
- **Selection bias**: Stage-1 estimate of the selected arm is upwardly biased; pre-specify reporting of both naive and shrinkage/conditional estimates.

## How this case validates designr

- Canonical framework for the "seamless Phase 2/3" leg of non-standard designs.
- Establishes the inverse-normal default that modern designs (e.g. INHANCE) use.
- Provides the combination-function + closed-testing primitives that `designr` can expose through rpact / adaptTest / asd backends.
