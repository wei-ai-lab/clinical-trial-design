# ICH E9(R1) (2019) — Estimands and Sensitivity Analysis

**Family:** non-standard · **Kind:** regulatory-guidance · **Scope:** cross-cutting estimand framework affecting every design family

## Why this case is in the corpus

- **Single most influential cross-cutting methodology framework** for modern trial design — ICH-wide, adopted FDA (2021), EMA (2020), PMDA.
- Separates scientific question (estimand) from statistical method (estimator) — reshapes protocol writing, SAP specification, and regulatory review.
- Informs analysis of intercurrent events across every design family in the corpus.
- Cross-cutting reference that every trial designed after 2020 must engage with.

## Citation

International Council for Harmonisation. *ICH E9(R1): Addendum on Estimands and Sensitivity Analysis in Clinical Trials to the Guideline on Statistical Principles for Clinical Trials.* Step 4, 20 November 2019.

## The estimand framework

An **estimand** is defined by five attributes:

| # | Attribute | Example |
|---|---|---|
| 1 | Population | ITT population, aged 18-75, with specific diagnosis |
| 2 | Variable | Change from baseline in HbA1c at week 24 |
| 3 | Intercurrent events | Rescue medication handling, discontinuation |
| 4 | Summary measure | Mean difference between arms |
| 5 | Population-level summary | Average treatment effect in target population |

## Intercurrent event strategies

| # | Strategy | Description | Example |
|---|---|---|---|
| 1 | Treatment-policy | Ignore occurrence, measure outcome regardless | Canonical ITT |
| 2 | Composite | Combine event with unfavorable outcome | 'HbA1c unchanged or rescue received' |
| 3 | Hypothetical | Counterfactual — what outcome without event | MI imputing what would have been without rescue |
| 4 | Principal-stratum | Restrict to subset defined by potential event | 'Always-compliers' per Angrist/Rubin |
| 5 | While-on-treatment | Outcome only while still on therapy | Efficacy signal of continuous treatment |

## Example: HbA1c estimands

```
Estimand 1 (treatment-policy):
  Difference in mean HbA1c at week 24 between arms in all randomized
  patients regardless of rescue medication or discontinuation.

Estimand 2 (hypothetical):
  Difference in mean HbA1c at week 24 between arms assuming no
  patient had received rescue medication.

Estimand 3 (while-on-treatment):
  Difference in mean HbA1c at week 24 between arms restricted to
  patients still on assigned study medication at week 24.
```

## Implementation across design families

| Family | Common intercurrent events | Typical strategy |
|---|---|---|
| Fixed-superiority | Discontinuation, rescue | Treatment-policy + hypothetical sensitivity |
| TTE | Treatment switching, non-cancer death | Treatment-policy (usual); IPCW, RPSFTM, RMST for hypothetical |
| Recurrent events | Terminal event (death) | Composite or principal-stratum |
| Adaptive | Early termination | Pre-specified per arm |
| Platform | Inter-arm switching | Composite or treatment-policy |

## R packages aligned with ICH E9(R1)

```r
# Example: treatment-policy estimand with multiple imputation for missing
library(mice)
# Impute missing outcomes under MNAR for sensitivity
imp <- mice(df, method = "pmm", m = 50, seed = 42)
fit <- with(imp, lm(y ~ trt + baseline))
pool(fit)

# mmrm: canonical continuous-endpoint MMRM for treatment-policy
library(mmrm)
fit_mmrm <- mmrm(y ~ trt * visit + baseline + covs + us(visit | subject),
                 data = df)

# Hypothetical estimand via jump-to-reference (J2R) imputation
library(mice)
# Custom imputation method implementing J2R

# Principal-stratum compliance
library(ivreg)   # Angrist-Imbens-Rubin
fit_iv <- ivreg(outcome ~ trt | instrument, data = df)
```

## Regulatory adoption

- **FDA**: endorsed May 2021; increasingly cited in guidance documents and advisory reviews.
- **EMA**: adopted February 2020; mandatory in clinical trial applications.
- **PMDA**: aligned adoption per ICH.
- **NEJM / Lancet / JAMA**: high-tier journals now expect estimand pre-specification in reports of pivotal trials.

## Relationship to other frameworks

- **ICH E9 (1998)**: original statistical principles; E9(R1) is its addendum.
- **FDA Missing Data Guidance (2022 update)**: aligned with E9(R1) estimand language.
- **FDA Demonstrating Substantial Evidence (2019)**: references estimand specification.
- **ICH E20 (adaptive designs, draft)**: will harmonize with E9(R1).

## How this case validates designr

- Adds the **foundational estimand framework** to the corpus — applies to every design family.
- `designr` should expose estimand specification as a first-class design input: population, intercurrent event strategy per event type, summary measure.
- Teaching case: trial planning now begins with 'what estimand do we want?' before 'what sample size do we need?'. Estimand drives analytical plan which drives sample size.
