# fixed-non-inferiority

Fixed-sample-size non-inferiority (NI) designs. The goal is to demonstrate that the experimental treatment is **not worse** than an active control by more than a pre-specified margin Δ.

## When this family is the right choice

- A well-established active control already demonstrates superiority over placebo, and placebo-controlled testing is unethical.
- The experimental treatment has plausible non-efficacy advantages (safety, convenience, cost).
- Regulatory precedent exists for NI in the therapeutic area (anticoagulation, antibiotics, antivirals, some oncology).

## Margin justification

The NI margin Δ is the single most consequential design choice. Pharma-standard frameworks:

| Method | Reference | Use |
|---|---|---|
| **Fixed-margin (95/95)** | FDA NI Guidance 2016 | Most common. Margin = point estimate of control vs placebo × factor (e.g. 50%), capped by lower 95% CI bound. |
| **Synthesis** | Tsong et al.; FDA (secondary) | Combine historical active-vs-placebo with current active-vs-experimental in a single analysis. More efficient but less transparent. |
| **Two-confidence-interval** | ICH E10 | Margin = lower 95% CI of historical meta-analysis of active vs placebo, discounted (often 50%). |

## Common pitfalls

- **Assay sensitivity.** If the trial cannot distinguish active from placebo, NI is uninterpretable. Design should ensure active control could demonstrate superiority vs historical placebo.
- **Constancy assumption.** Historical active-vs-placebo effect must be assumed constant in the current trial. Violated by changes in standard of care, population, endpoint definition.
- **Bio-creep.** Successive NI trials drift the bar for efficacy downward.
- **NI → superiority conversion.** If NI is achieved and the point estimate favors experimental, superiority can be tested at α without α-penalty (hierarchical).

## R packages

| Endpoint | Preferred packages |
|---|---|
| Continuous | `gsDesign::nNormal`, `rpact::getSampleSizeMeans` |
| Binary | `gsDesign::nBinomial`, `rpact::getSampleSizeRates`, `Hmisc::bpower` |
| TTE (PH) | `gsDesign::nSurv`, `rpact::getSampleSizeSurvival` (set `hr0` to NI margin) |

## Cases

See `cases/` — each is `<id>.md` + `<id>.yaml` pair.
