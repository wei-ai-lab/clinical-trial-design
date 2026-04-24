# RE-LY (2009) — dabigatran vs warfarin in atrial fibrillation

**Family:** fixed-non-inferiority · **Endpoint:** TTE stroke/SE · **N:** 18,113 · **Design feature:** three-arm NI with PROBE design

## Why this case is in the corpus

- **Canonical NOAC NI trial** — first of the four (RE-LY, ROCKET-AF, ARISTOTLE, ENGAGE AF-TIMI 48) that established the NOAC class.
- **Fixed-margin method** for margin derivation (HR 1.46 from warfarin-vs-placebo meta-analysis).
- **Three-arm design with shared active control** — tests the agent's reasoning about dose selection under NI.

## Citation

Connolly SJ, Ezekowitz MD, Yusuf S, et al. *Dabigatran versus warfarin in patients with atrial fibrillation.* N Engl J Med. 2009;361(12):1139-1151. doi:10.1056/NEJMoa0905561. NCT00262600.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Randomized, open-label (PROBE) with blinded endpoint adjudication |
| Arms | Dabigatran 110 mg · Dabigatran 150 mg · Warfarin (INR 2-3), 1:1:1 |
| Primary endpoint | Stroke or systemic embolism (TTE) |
| Comparison | Non-inferiority, margin HR = 1.46 |
| Margin method | Fixed-margin 95/95, retention of 50% of warfarin-vs-placebo effect |
| α / power | 0.025 (one-sided) / 0.84 |
| Target events | ~302 (≈ 450 per 2-arm comparison pooled) |
| Planned N | 18,113 |
| Follow-up | Median 24 months |

## Margin derivation

From Hart et al. meta-analysis of warfarin vs placebo/aspirin in AF: stroke HR ≈ 0.36 (95% CI 0.26–0.51).

- Point estimate favoring warfarin: HR = 0.36, i.e. log HR = −1.02.
- Lower 95% CI bound of log HR = log(0.51) = −0.67.
- 50% retention = allow experimental to lose half of warfarin benefit = margin HR = exp(−0.67 × 0.5)⁻¹ ≈ exp(0.335)⁻¹... more directly: the FDA convention sets Δ such that demonstrating treatment better than Δ × warfarin-lower-CI still rules out ≥ 50% effect loss. Net result: **margin HR = 1.46**.

## Reproducing the calculation

For NI under HR = 1.0, margin HR₀ = 1.46, α = 0.025 one-sided, power = 0.84, 1:1:

```r
library(gsDesign)
nEvents(hr = 1.0, hr0 = 1.46, alpha = 0.025, beta = 0.16, ratio = 1)
# events ≈ 250 per 2-arm comparison
```

With three arms and a shared warfarin arm, events accumulate across the trial; ~300 primary events drive the analysis. N = 18,113 reflects the low residual event rate (1.6%/y) under effective warfarin.

## What the trial found

| Comparison | HR | 95% CI | NI met? | Superiority? |
|---|---|---|---|---|
| Dabigatran 110 vs warfarin | 0.91 | 0.74–1.11 | ✅ | Not pre-specified |
| Dabigatran 150 vs warfarin | 0.66 | 0.53–0.82 | ✅ | ✅ (hierarchically tested) |

Both doses met NI. The 150 mg dose demonstrated superiority and became the approved dose in most jurisdictions.

## Caveats & teaching points

- **PROBE design** (Prospective Randomized Open Blinded Endpoint) is common for anticoagulation trials where blinding to warfarin is impractical due to required INR monitoring. Blinded adjudication preserves unbiased outcome assessment.
- **Event counts are low** in NI anticoagulation trials because the active control (warfarin) is itself highly effective. This drives massive N requirements despite the modest number of events.
- **NI-then-superiority hierarchy** is standard: if NI is met, superiority testing at full α is pre-specified.

## How this case validates designr

- TTE NI sizing under PH with `hr0` parameter.
- Three-arm design with shared active control.
- Agent reasoning about margin derivation via fixed-margin method.
- Open-label PROBE design handling.
