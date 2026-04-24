# factorial — Factorial Phase 3 designs

## Family overview

**Factorial trials** evaluate **two or more interventions simultaneously** by randomizing each participant independently to each intervention. A 2×2 factorial (most common) randomizes to (A, B), (A, placebo_B), (placebo_A, B), (placebo_A, placebo_B). Each intervention is evaluated vs its control using the full trial N (assuming no interaction).

Canonical use cases:
- **CVOT factorial** — test two independent preventive interventions simultaneously (aspirin + vitamin E, statin + ARB, etc.).
- **AMI management** — test adjuvant interventions vs concurrent SOC (COMMIT: metoprolol + clopidogrel).
- **Rare-event prevention** — leverage large N for two hypotheses efficiently.

## Design structure

1. **2×2**: two factors, two levels each (4 cells).
2. **2×2×2**: three factors, 8 cells (e.g., HOPE-3).
3. **Partial factorial**: drop some cells (e.g., eliminate "both treatments" cell for safety or drug-interaction concerns).
4. **Fractional factorial**: sample subset of cells when full factorial infeasible.

## Statistical advantages

- **N efficiency**: testing 2 factors in one trial uses ~50-60% of the combined N for two separate trials (if no interaction).
- **Shared infrastructure**: single operational setup for multiple hypotheses.
- **Interaction estimation**: if interaction exists, factorial is the only efficient way to detect it.

## Common pitfalls

- **Interaction assumption**: factorial analysis of main effects assumes no interaction. If strong interaction exists, the average treatment effect is a mis-specified summary.
- **Drug interaction**: two active drugs may have PK/PD interaction — can inflate adverse events.
- **Power for interaction**: detecting interaction typically requires 4× N vs detecting main effects — interactions rarely powered adequately.
- **Multi-factor sample size**: each factor has own power calculation; when both factors expect modest effects, N driven by the larger-N factor.
- **ITT analysis**: each factor analyzed across both levels of the other factor.

## R packages

- **`stats::aov` / `stats::lm`** — factorial analysis.
- **`nlme` / `lme4`** — random effects when factors crossed with subjects.
- **`gsDesign` / `rpact`** — per-factor sample size.
- **`DoE.base`** — factorial and fractional-factorial design.

## Cases in this corpus

| Case | Year | Factorial structure | Setting |
|---|---|---|---|
| HOPE-3 — 2×2 rosuvastatin + cand/HCTZ | 2016 | 2×2 | Intermediate-risk primary CV prevention |
| COMMIT — 2×2 metoprolol + clopidogrel | 2005 | 2×2 | Acute MI management |
| Byar factorial methodology | 2001 | Any | Methodology caveats |
