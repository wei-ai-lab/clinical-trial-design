# Wang-O'Neill-Hung (2007) — FDA framework for biomarker-based enrichment

**Family:** adaptive-enrichment · **Endpoint:** any · **Design feature:** FDA-perspective framework with α-control via pre-specified hypothesis sequence

## Why this case is in the corpus

- **FDA-authored methodology paper** establishing the regulatory perspective on adaptive enrichment.
- Defines the three-scenario taxonomy (targeted, broad, adaptive) used as the mental model in subsequent methodology and guidance.
- Precursor to FDA Enrichment Strategies Guidance (2019).

## Citation

Wang S-J, O'Neill RT, Hung HMJ. *Approaches to evaluation of treatment effect in randomized clinical trials with genomic subset.* Pharmaceutical Statistics. 2007;6(3):227-244. doi:10.1002/pst.300.

## The framework

Three approaches to trial design under biomarker uncertainty:

| Strategy | When used | α-control |
|---|---|---|
| **Targeted** | Strong Phase 2 evidence biomarker+ drives effect; enroll only biomarker+ | Conventional — single population |
| **Broad + biomarker subgroup** | Effect uncertain; enroll all, pre-specify biomarker subgroup test | Hierarchical (closed testing) or Bonferroni-adjusted |
| **Adaptive** | Effect uncertain *and* biomarker prevalence uncertain; use interim to select | Inverse-normal / CHW combination at final |

## Illustrative Phase 3 design (adaptive)

| | |
|---|---|
| Indication | Solid tumor with candidate biomarker (say EGFR mutation) |
| Biomarker prevalence | ~40% in target population (assumed) |
| Endpoint | OS |
| α / power | 0.025 (one-sided), 0.85 in biomarker+ or 0.80 full |
| Assumed HR (biomarker+) | 0.70 |
| Assumed HR (biomarker−) | 0.85 |
| Planned N (stage 1) | 300 (all-comers) |
| Interim | IF = 0.4 (events in all-comers) |
| Decision | (a) continue all-comers, (b) restrict to biomarker+, (c) stop |
| Planned N (stage 2) | Up to 600 additional, depends on (a/b/c) |

## Reproducing the design

```r
library(rpact)
d <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.15,
  typeOfDesign = "OF"
)
# Stage 1: all-comers design
ss1 <- getSampleSizeSurvival(design = d, hazardRatio = 0.78, lambda2 = -log(0.5)/24)

# At interim: separate event counts for biomarker+ and overall, compute CP
# Apply selection rule; continue with combined combination test at final
```

## α-control mechanics

Because stage 2 population depends on stage-1 data, combination test (inverse-normal or Fisher) at final analysis is essential:

```
Z_combined = w₁ · Z_stage1 + w₂ · Z_stage2
```

with w₁, w₂ pre-specified, regardless of the selection decision. This preserves α exactly across the three selection paths.

## Caveats & teaching points

- **Selection rule must be pre-specified** — "select biomarker+ if observed HR_+ < 0.75 and HR_− > 0.85" (not post-hoc thresholds).
- **Biomarker must be measurable in stage 1** — the decision cannot depend on stage-2 biomarker data.
- **Regulators prefer pre-specified thresholds over optimization-based** selection rules (e.g., don't let DSMB "pick the biomarker cutoff at interim").

## How this case validates designr

- Foundational reference for FDA regulatory perspective.
- Taxonomy (targeted / broad / adaptive) maps directly to designr family recommendations.
- Benchmark for inverse-normal combination test with adaptive subgroup selection.
