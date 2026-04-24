# crossover — Crossover Phase 3 designs

## Family overview

**Crossover trials** assign each participant to receive **both treatments in sequence**, in randomized order, with each serving as their own control. Distinguished from parallel designs in that the within-subject variance σ²_w (not between-subject σ²_b) drives sample size — often 2-10× more efficient.

Typical settings:
- **Chronic stable disease** where short-term symptom change is the endpoint (hypertension, asthma, migraine).
- **Bioequivalence / bioavailability** — pharmacokinetic PK crossover for ANDA / reference generics.
- **Rare disease** — n is small, so within-subject efficiency is essential.
- **Symptomatic pharmacology** — antiepileptics, analgesics for chronic pain.

## Canonical structures

1. **2×2 AB/BA** — two periods, two sequences; basic crossover.
2. **Williams designs** — balanced for carryover (4×4, 6×6 latin squares).
3. **N-of-1** — within-single-subject crossover for individual-level treatment decisions.
4. **Multi-period crossover** — three or more periods for dose-response or sequential comparisons.

## Design considerations

- **Carryover effect**: residual effect of first period into second. Washout period between treatments mitigates; cannot be tested in 2×2 without unbiased way to distinguish from period-by-treatment interaction (Grizzle 1965 critique).
- **Period effect**: systematic change across periods independent of treatment — accounted for by including period as factor.
- **Sequence effect**: if sequence (AB vs BA) affects outcome, interaction present; investigate carryover or differential dropout.
- **Dropout between periods**: common concern; analysis sets defined carefully (completers only vs ITT with imputation).
- **Bioequivalence specific**: ratio 80-125% for AUC and Cmax on log-scale via two one-sided tests (TOST); α = 0.05 each side.

## Common pitfalls

- **Carryover with short washout**: particularly for drugs with long half-life or effect accumulation.
- **Differential period effects** in placebo-active sequence vs active-placebo sequence — may indicate unblinding.
- **N-of-1 aggregation**: proper meta-analysis across n-of-1 trials requires Bayesian hierarchical or mixed-effect models.
- **Bioequivalence confidence interval misinterpretation**: 90% CI must lie entirely within (0.80, 1.25) — not just contain 1.00.

## R packages

- **`nlme`** / **`lme4`** — mixed-effects models for crossover.
- **`Crossover`** — CRAN package for crossover analysis.
- **`PowerTOST`** — bioequivalence power / sample size via TOST.
- **`replicateBE`** — replicate bioequivalence design.

## Cases in this corpus

| Case | Year | Setting | Design |
|---|---|---|---|
| Senn — Cross-over Trials textbook | 2002 | Methodology | 2nd ed. canonical reference |
| FDA Average Bioequivalence guidance | 2001 | Bioequivalence / generics | 2-period 2-sequence PK crossover + TOST |
| Sansone — dichlorphenamide in periodic paralysis | 2016 | Rare disease | 2-period AB/BA with open-label extension |
