# FDA NTI Bioequivalence (2015) — Narrow therapeutic index crossover BE

**Family:** crossover · **Kind:** regulatory-guidance · **Scope:** replicate-design BE for NTI drugs (warfarin, tacrolimus, levothyroxine, etc.)

## Why this case is in the corpus

- **Specialized BE framework for Narrow Therapeutic Index drugs**.
- Requires **replicate crossover design** (4-period full or 3-period partial) — cannot use standard AB/BA.
- Defines tightened BE limits scaled by within-subject CV of reference.
- Reference for NTI drug PSGs (warfarin, tacrolimus, levothyroxine, lithium, digoxin, phenytoin).

## Citation

FDA. *Guidance for Industry: Bioequivalence Studies With Pharmacokinetic Endpoints for Drugs Submitted Under an ANDA.* Draft 2013, finalized 2021. Warfarin NTI-specific BE approach: FDA Product-Specific Guidance for Warfarin Sodium (2012, revised 2015). Extended framework: FDA Statistical Approaches to Establishing Bioequivalence (Jan 2001, updated 2022).

## Core framework

| Element | Standard ABE | NTI ABE |
|---|---|---|
| Design | 2-period AB/BA | **Replicate 4-period** (TRTR/RTRT) |
| BE limits | 80.00-125.00% | **Tightened, CV-scaled** (e.g., 90-111% when CV_WR = 10%) |
| Variance ratio | Not required | **σ²_WT / σ²_WR ≤ 2.5** (individual BE component) |
| Power | 0.80-0.90 | **0.90** standard |
| Typical N | 24-36 | 20-36 × replicate periods |

## Reference-Scaled NTI BE limits

```r
# NTI-BE limits scale with within-subject SD of reference:
#   upper = exp(1.053605 × σ_WR)
#   lower = 1 / upper

# Example: if CV_WR = 10% → σ_WR ≈ 0.10
upper <- exp(1.053605 * 0.10)     # ≈ 1.111 (111%)
lower <- 1 / upper                # ≈ 0.900 (90%)

# Sample-size sizing (PowerTOST)
library(PowerTOST)
sampleN.NTIDFDA(
  alpha = 0.05,
  targetpower = 0.90,
  theta0 = 0.95,
  CV = 0.10,
  design = "2x2x4"    # 4-period full replicate
)
# Typical result: 24-30 subjects for CV ≈ 10%
```

## FDA NTI drug list (partial)

| Drug | Indication | NTI reason |
|---|---|---|
| Warfarin | Anticoagulation | Bleed/clot balance |
| Tacrolimus | Transplant rejection | Graft failure / nephrotoxicity |
| Levothyroxine | Hypothyroidism | Cardiac arrhythmia / hypothyroid symptoms |
| Phenytoin | Epilepsy | Toxicity / breakthrough seizure |
| Digoxin | HF / AF | Toxicity cliff |
| Lithium | Bipolar | Narrow dosing window |
| Cyclosporine | Transplant | Similar to tacrolimus |
| Theophylline | Asthma / COPD | Toxicity cliff |
| Carbamazepine | Epilepsy | Similar to phenytoin |
| Valproic acid | Epilepsy | Hepatotoxicity cliff |

## Drug-specific PSG particulars

- **Warfarin**: replicate 4-period fasting; fed study also required.
- **Tacrolimus**: **patient-based** BE (not healthy volunteers); pre-dose trough + full PK profile.
- **Levothyroxine**: baseline-subtracted PK (endogenous T4 correction).
- **Carbamazepine**: steady-state multiple-dose design due to auto-induction.

## How this case validates designr

- Specialized crossover design (replicate) sizing for NTI regulatory submissions.
- Reference-scaled BE limits parameterization.
- Individual-BE variance-ratio constraint as additional design criterion.
- Complements FDA ABE (2001), Senn (2002), and Jones-Kenward (2014) in the crossover corpus.
- Enables `designr` to expose NTI BE design via `PowerTOST::sampleN.NTIDFDA`.
