# Rosenblum-van der Laan (2011) — Adaptive Enrichment with Prospective α Control

**Family:** adaptive-enrichment · **Kind:** foundational methodology · **Scope:** general framework for arbitrary pre-specified decision rules

## Why this case is in the corpus

- Unified the adaptive-enrichment literature into a general framework accepting **arbitrary pre-specified** decision rules.
- Three MTP families (barely / exactly / approximately valid) formalized by Rosenblum et al. 2016 — foundation for modern enrichment MTPs.
- Generalizes Wang-O'Neill-Hung, Brannath-Mehta, Jenkins-Stone-Jennison by removing rule-specific constraints.
- Prospective α control via pre-specified rules — regulatory-acceptable.
- Referenced by FDA 2019 Adaptive Designs Guidance.

## Citation

- Rosenblum M, van der Laan MJ. *Optimizing randomized trial designs to distinguish which subpopulations benefit from treatment.* Biometrika. 2011;98(4):845-860.
- Tutorial extension: Rosenblum M, Qian T, Du Y, Qiu H, Fisher A. *Multiple testing procedures for adaptive enrichment designs: barely valid, exactly valid, and approximately valid.* Biostatistics. 2016;17(4):732-746.

## Two-stage adaptive enrichment structure

**Stage 1** — enroll all comers:
- Randomize both marker+ and marker- patients.
- Estimate Δ̂+ and Δ̂- at interim.

**Interim decision** — pre-specified function F(Δ̂+, Δ̂-):
- **Continue all-comer**: both subgroups show benefit.
- **Enrich to marker+ only**: Δ̂+ large, Δ̂- small.
- **Stop for futility**: Δ̂+ and Δ̂- both small.

**Stage 2** — enroll per decision:
- Continue to planned total sample size.

**Final testing** — two hypotheses, FWER-controlled:
- **H₀⁺**: Δ+ ≤ 0
- **H₀ᵒ**: Δ_overall ≤ 0 (only if all-comer continued)

## Three MTP families (Rosenblum et al. 2016)

| MTP Family | FWER | Power | Complexity |
|---|---|---|---|
| **Barely valid** (Bonferroni-like) | ≤ α | Lowest | Trivial |
| **Exactly valid** (numerical) | = α | Highest | Numerical integration |
| **Approximately valid** (asymptotic) | ≈ α | Near-exact | Simulation |

## Weighted combination of stage p-values

Pre-specified weights w₁, w₂ combine stage-1 and stage-2 z-scores:

```
z_combined = w₁ · z₁ + w₂ · z₂     (with w₁² + w₂² = 1)
```

Common weight choices:
- Equal: w = 1/√2
- Information-based: w_k ∝ √n_k
- Decision-dependent: different if enriched vs all-comer

Cui-Hung-Wang principle: weighted inverse-normal preserves α under any pre-specified adaptation.

## Why arbitrary decision rules work

Traditional group-sequential requires fixed timing + pre-specified spending. Rosenblum-vdL showed that **any** pre-specified function F(Δ̂+, Δ̂-) is valid, because:

1. Selection based on stage-1 data creates known distribution.
2. Stage-2 critical values computed via multivariate normal accounting for selection.
3. FWER controlled by appropriate MTP choice.

The rule need only be:
- Pre-specified (locked in protocol before unblinding).
- Deterministic (or known-probability if randomized).

## Comparison to other adaptive enrichment methods

| Method | Decision Rule | α Control | In Corpus |
|---|---|---|---|
| Wang-O'Neill-Hung 2007 | Specific rules 1-3 | Yes | ✓ |
| Brannath-Mehta 2009 | Fisher combination | Yes | ✓ |
| Jenkins-Stone-Jennison 2011 | GS boundaries + combo | Yes | ✓ |
| **Rosenblum-vdL 2011 (this case)** | **ARBITRARY F(·)** | **Any MTP** | **✓** |
| Magnusson-Turnbull 2013 | OPTIMAL F(·) | Yes | ✓ |

Rosenblum-vdL is the **most general**; Magnusson-Turnbull answers "which F is best?".

## Numerical example

HER2+ breast cancer with uncertain marker-negative benefit:

**Stage 1** — n = 200 (50 HER2+, 150 HER2-):
- Observe Δ̂+ and Δ̂-.

**Interim decision rule**:
```
IF Δ̂+ > 0.3 AND Δ̂- < 0.1 → ENRICH to HER2+ only
IF Δ̂+ > 0.3 AND Δ̂- ≥ 0.1 → continue ALL-COMER
IF Δ̂+ < 0.1                → futility stop
```

**Stage 2** — n = 400 per chosen cohort.

**Final analysis** — exactly-valid MTP preserves overall FWER at 0.025 despite adaptive enrichment.

## Regulatory acceptance

| Agency | Document | Position |
|---|---|---|
| FDA | 2019 Adaptive Designs Guidance | Enrichment with prospective α control accepted |
| EMA | 2007 CHMP Reflection Paper on Adaptive Designs | Pre-specified rules accepted |
| ICH | E9 (R1) | Adaptive designs within framework |

Exactly-valid MTPs require extensive simulation documentation for FDA review.

## Implementation outline

```r
# Conceptual workflow (custom code — no single R package)

# Stage 1 ----
n1 <- 200

# Enroll all comers, randomize 1:1, observe Δ̂+ and Δ̂-
fit_stage1 <- fit_model(data_stage1)
delta_plus  <- coef(fit_stage1, subgroup = "marker+")
delta_minus <- coef(fit_stage1, subgroup = "marker-")

# Pre-specified decision rule ----
enrichment_decision <- function(dp, dm) {
  if (dp > 0.3 && dm < 0.1)  return("enrich")
  if (dp > 0.3 && dm >= 0.1) return("all_comer")
  if (dp < 0.1)              return("futility")
  return("all_comer")
}
decision <- enrichment_decision(delta_plus, delta_minus)

# Stage 2 ----
if (decision != "futility") {
  # enroll per decision
  # ...
}

# Weighted combination at final ----
w1 <- sqrt(n1 / n_total)
w2 <- sqrt(1 - w1^2)
z_combined <- w1 * z_stage1 + w2 * z_stage2

# Compare to exactly-valid critical value (computed via MVN
# integration accounting for selection + MTP family)
```

## Relationship to Simon-Maitournam framework

| Aspect | Simon-Maitournam (2004) | Rosenblum-vdL (2011) |
|---|---|---|
| Enrichment timing | Fixed a priori | Adaptive interim |
| Hedging | None (must commit) | Enrolls all initially, hedges |
| α control | Trivial (single hypothesis) | MTP required (two hypotheses) |
| Complexity | Simple | Moderate (pre-specified F, MTP) |
| Use case | Strong biomarker confidence | Biomarker uncertainty |

Rosenblum-vdL is the natural adaptive extension when Δ- / Δ+ ratio is uncertain.

## Modern applications

- **DESTINY-Breast04** (trastuzumab deruxtecan, 2022): enrichment across HER2-low and HER2+.
- **PALOMA-2** (palbociclib + letrozole): stratified enrichment by ESR1/PIK3CA.
- **KEYNOTE-158** (pembrolizumab MSI-H): site-agnostic enrichment.
- **BERENICE** (IL-6 inhibition): pre-specified cytokine enrichment.
- **CheckMate-914** (nivolumab adjuvant): PD-L1 enrichment.

## How this case validates designr

- Adds the **unifying adaptive enrichment methodology paper** — general framework for prospective α control.
- `designr` should support adaptive enrichment with pre-specified arbitrary decision rules + MTP family selection.
- Teaches: prospective α control principle, three MTP families trade-off, weighted combination, decision-rule specification.
- Paired with 5 other adaptive enrichment methodology cases in corpus (Simon-Maitournam, Freidlin-Simon, Wang-O'Neill-Hung, Brannath-Mehta, Jenkins-Stone-Jennison, Magnusson-Turnbull) — covers full methodological landscape.
