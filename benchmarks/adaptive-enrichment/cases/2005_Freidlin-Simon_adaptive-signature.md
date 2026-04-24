# Freidlin-Simon (2005) — Adaptive Signature Design

**Family:** adaptive-enrichment · **Kind:** methodology-paper · **Scope:** single trial that develops + tests a biomarker signature

## Why this case is in the corpus

- **Foundational paper** for biomarker-adaptive enrichment methodology — first to formally combine signature development and testing in one confirmatory trial.
- Introduces the alpha-splitting decision rule (overall population at α1, signature-positive at α2) with closed-testing FWER control.
- Predecessor to Brannath-Mehta (2009), Jenkins-Stone-Jennison (2011), and the adaptive-enrichment section of FDA 2019 guidance.
- Canonical methodological entry for the adaptive-enrichment family.

## Citation

Freidlin B, Simon R. *Adaptive signature design: an adaptive clinical trial design for generating and prospectively testing a gene expression signature for sensitive patients.* Clin Cancer Res. 2005 Nov 1;11(21):7872-8.

## Core design

| Element | Value |
|---|---|
| Population split | Training subset (~50%) — classifier fit |
| | Test subset (~50%) — classifier-defined subgroup tested |
| α allocation | α1 (overall, e.g., 0.04) + α2 (subgroup, e.g., 0.01) = 0.05 one-sided |
| Decision rule | If overall rejects at α1: claim all-comers; else if subgroup rejects at α2: claim biomarker+ |
| FWER | Strong control via closed testing |

## Algorithm

```r
# Freidlin-Simon 2005 adaptive signature procedure
# Step 1: randomize all N patients
# Step 2: after all outcomes observed, randomly split into training (T)
#         and test (V) subsets, typically 50/50
# Step 3: on T, fit classifier f: biomarker -> sensitive / not
#         (original paper: compound covariate predictor on gene exp)
# Step 4: test overall treatment effect on full N at alpha1
#         (typical 0.04 of 0.05 total)
# Step 5: if overall fails, test treatment effect on V-subjects
#         classified "sensitive" by f at alpha2 (typical 0.01)
# Step 6: closed testing -> FWER <= 0.05 one-sided

# R sketch
library(adaptTest)
# no single canonical implementation — done from first principles
# with logistic/survival classifier on training half and conditional
# inference on held-out half.
```

## Sample-size heuristics

- Power the all-comers test to typical 0.80-0.90 at α1.
- Power the signature-positive test at α2 assuming the enriched subgroup has a larger effect size than the all-comers (often 1.5-2×).
- Training/test split halves the effective N for the subgroup test — signature needs to be strong to matter.

## Historical / scientific role

- Originated the term 'adaptive signature design' in oncology.
- Extended by same authors to **biomarker-adaptive threshold design** (Jiang-Freidlin-Simon 2007, JNCI) for continuous biomarkers.
- Conceptual basis for Brannath-Mehta (2009) and Jenkins-Stone-Jennison (2011) frameworks that added combination tests and adaptive sample size.
- Rarely used in exact original form today, but the principles underpin most modern biomarker-enrichment Phase 3 trials.

## How this case validates designr

- Adds the **foundational adaptive-signature methodology** to the enrichment corpus, complementing the four later cases (Wang-O'Neill, Brannath-Mehta, Jenkins-Stone, TAPPAS).
- Alpha-splitting + closed-testing structure is a common pattern that `designr` should expose as a building block.
- Sample-size calculation under the two-part test requires combining `gsDesign` (overall) with subgroup effective-N logic — canonical use case for a composite design API.
