# CT-P10 (2018) — Rituximab biosimilar Phase 3 equivalence in RA

**Family:** fixed-equivalence · **Endpoint:** DAS28-ESR change at week 24 · **N:** 372 · **Design feature:** first rituximab biosimilar approved; sensitive-indication Phase 3

## Why this case is in the corpus

- **First rituximab biosimilar** approved by EMA (2017) and FDA (2018) — Truxima (Celltrion).
- Template for subsequent rituximab biosimilars (Rixathon, Riabni, Ruxience).
- Exemplar of EMA-guided sensitive-indication Phase 3 for mAb biosimilars (RA primary, then extrapolation).
- Reference for DAS28-based equivalence margin (±0.6 = ~50% MCID).

## Citation

Park W, Yoo DH, Miranda P, et al. *Efficacy and safety of CT-P10 (rituximab biosimilar) versus innovator rituximab in patients with rheumatoid arthritis: results of a 54-week randomised controlled trial.* Arthritis Res Ther. 2018;20:245. doi:10.1186/s13075-018-1758-x. NCT01693151.

## Design summary

| | |
|---|---|
| Design | Double-blind equivalence trial |
| Population | RA, DAS28 ≥ 5.1, SJC ≥ 6, TJC ≥ 6, prior inadequate TNFi response |
| Arms | CT-P10 1000 mg × 2 vs reference rituximab 1000 mg × 2 |
| Primary | Change in DAS28-ESR at week 24 |
| Equivalence margin | ±0.6 DAS28 units (symmetric) |
| Assumed true difference | 0 |
| SD change DAS28 | ~1.4 |
| α | 0.05 two-sided |
| Power | 0.90 |
| Planned N | 372 (186 per arm) |

## Reproducing the design

```r
library(PowerTOST)
sampleN.TOST(
  alpha = 0.05,
  targetpower = 0.90,
  theta0 = 0,              # assumed true diff
  theta1 = -0.6, theta2 = 0.6,   # ± 0.6 DAS28 margin
  CV = 1.4 / 2.3,          # ~0.6 coefficient of variation
  design = "parallel"
)
# ~ 186 per arm with 90% power

# Equivalence CI at analysis
library(emmeans)
fit <- lm(das28_change_w24 ~ arm + baseline_das28 + region, data = trial_df)
emm <- emmeans(fit, "arm")
contrast(emm, method = "pairwise") |> confint(level = 0.95)
# If 95% CI is within ± 0.6, equivalence declared
```

## Trial outcome

- **Week 24 DAS28 change**: CT-P10 -2.3 (SD 1.4), reference -2.4 (SD 1.5).
- **Difference**: -0.01 (95% CI -0.31 to 0.29) — fully within ±0.6 margin → **equivalence**.
- **Immunogenicity**: anti-drug antibodies 17% vs 14% (comparable).
- **Safety**: superimposable adverse-event profiles.
- **Extrapolation**: label extended to CLL, NHL, GPA/MPA indications without additional clinical trials.

## How this case validates designr

- Biosimilar equivalence sample-size benchmark for continuous endpoint.
- TOST / parallel equivalence design reference implementation.
- DAS28 as sensitive-indication endpoint for RA biosimilar Phase 3.
- Margin derivation (50% of MCID) as parameterization template.
- Complements existing equivalence corpus (PLANETRA infliximab, MYL-1401O trastuzumab, SB5 adalimumab, V114 lot consistency) — spans major mAb biosimilar classes.
