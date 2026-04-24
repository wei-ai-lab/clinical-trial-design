# Angus et al. (2019) — adaptive platform trial methodology review

**Family:** platform · **Endpoint:** any · **Design feature:** field-standard consensus framework

## Why this case is in the corpus

- **Adaptive Platform Trials Coalition consensus review** — cross-industry methodology framework.
- Underpins FDA 2018 master protocol guidance and EMA 2022 reflection paper.
- Defines platform trial terminology, governance, and reporting standards.

## Citation

Angus DC, Alexander BM, Berry S, et al. *Adaptive platform trials: definition, design, conduct and reporting considerations.* Nat Rev Drug Discov. 2019;18(10):797-807. doi:10.1038/s41573-019-0034-3.

## Design summary

| Element | Framework |
|---|---|
| Definition | Single master protocol, multiple arms, open-ended, adaptive |
| Design | Bayesian or frequentist; RAR optional |
| Control | Shared (concurrent preferred; non-concurrent with time-trend adjustment) |
| α control | Per-comparison (independent questions) OR family-wise (related arms) |
| Biomarker stratification | Common in umbrella-style platforms |
| Governance | SAC · DSMB · Arm-entry committee |
| Reporting | ICMJE-aligned, per-arm + platform-level |

## Reproducing design elements

Design decisions cluster into five domains:

1. **Arm entry/exit rules**:
   - Scientific bar: mechanism, pre-clinical, Phase 1 data.
   - Operational: drug supply, randomization capacity.
   - Ethical: IRB approval.

2. **α control**:
   - Per-comparison (default for platforms with independent questions).
   - Family-wise (e.g., if same drug tested at multiple doses).
   - FDA pragmatic acceptance: per-comparison with pre-specified plan.

3. **Control arm**:
   - Concurrent only (gold standard, cleanest internal validity).
   - Historical + concurrent (time-trend risk).
   - Pure historical (high risk; acceptable only with MAP prior + calibration).

4. **Response-adaptive randomization (RAR)**:
   - Gains: faster arm-dropping, ethical allocation.
   - Losses: time-trend confounding, reduced statistical efficiency for final comparison.

5. **Reporting**:
   - Per-arm paper (conventional).
   - Platform-level summary (new standard per Angus 2019).
   - Pre-registered, open-ended.

## Reproducing simulations

```r
library(FACTS)  # commercial

# Per-arm and platform-level OC simulation:
#  - Type I error (per-arm, FWER)
#  - Power (per-arm)
#  - Expected enrollment (per-arm, platform)
#  - Expected study duration
#  - Control arm ESS per calendar window
```

## How this case validates designr

- Cross-industry reference framework for platform trials.
- Governance and reporting specifications.
- Anchor for platform-specific design choices in the corpus.
