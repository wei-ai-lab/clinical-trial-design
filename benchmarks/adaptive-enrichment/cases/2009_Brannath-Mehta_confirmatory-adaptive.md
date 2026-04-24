# Brannath-Mehta (2009) — confirmatory adaptive with Bayesian decision tools

**Family:** adaptive-enrichment · **Endpoint:** any · **Design feature:** Bayesian posterior drives population selection; frequentist α control at final

## Why this case is in the corpus

- **Combines Bayesian decision-making** (for selection) with **frequentist Type-I control** (at final) — a hybrid commonly acceptable to regulators.
- Worked example in oncology (gastrointestinal stromal tumor) with KIT/PDGFRA mutational subgroups.
- Teaches how a pre-specified prior constrains the selection rule and preserves α.

## Citation

Brannath W, Zuber E, Branson M, Bretz F, Gsponer T, Racine-Poon A, König F. *Confirmatory adaptive designs with Bayesian decision tools for a targeted therapy in oncology.* Statistics in Medicine. 2009;28(10):1445-1463. doi:10.1002/sim.3559.

## The method

1. **Stage 1** — recruit all-comers, stratified by biomarker. Collect PFS events.
2. **Interim decision** — compute Bayesian posterior for HR in (a) full population, (b) biomarker+ subgroup. Use a pre-specified Bayesian decision rule:
   - If P(HR_F < HR_threshold | data) > τ_F, continue full.
   - If P(HR_+ < HR_threshold | data) > τ_+, restrict to biomarker+.
   - Otherwise stop.
3. **Stage 2** — enroll per selection. Collect additional events.
4. **Final** — frequentist inverse-normal combination test with pre-specified weights, corrected for multiple hypotheses via closed testing.

## Illustrative design (from paper's GIST example)

| | |
|---|---|
| Indication | Advanced GIST |
| Biomarker | KIT exon 11 mutation (~60% prevalence) |
| Arms | Experimental vs imatinib |
| Primary endpoint | PFS |
| α / power | 0.025 / 0.80 |
| Assumed HR (KIT+) | 0.60 |
| Assumed HR (KIT−) | 0.85 |
| Planned N | 360 stage 1 → up to 720 total |
| Bayesian prior (HR_+) | log-normal, center 0.70, modest variance |
| Selection | At IF = 0.5 |

## Reproducing the design

```r
library(rpact)
d <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.20,
  typeOfDesign = "OF"
)
# Stage 1 design
ss <- getSampleSizeSurvival(
  design = d, hazardRatio = 0.70, lambda2 = -log(0.5)/12
)

# Bayesian posterior computation: R packages like BRugs, rjags, or Stan
# Combined with inverse-normal test at final via rpact::getAnalysisResults
```

## What this approach offers

- **Principled decision under uncertainty** — Bayesian posterior naturally handles the "promising but not certain" case where frequentist CP thresholds feel arbitrary.
- **α preserved** because the final inference uses the pre-specified combination test; Bayesian decisions affect recruitment but not the test statistic weights.
- **Flexible prior**: can incorporate Phase 2 data, real-world evidence, or other trials.

## Caveats & teaching points

- **Prior must be pre-specified** — regulators will scrutinize whether the prior is aligned with external evidence or sponsor-favorable.
- **Power sensitivity to prior.** An optimistic prior can trigger selection too readily; conservative prior may miss genuine enrichment opportunities.
- **Two-layer sensitivity** — posterior thresholds τ_F, τ_+ are separate from frequentist critical values. Simulation-based calibration is standard.

## How this case validates designr

- Agent reasoning about Bayesian-informed adaptive Phase 3.
- Handling of biomarker subgroup selection with pre-specified prior.
- Combination test implementation benchmark.
