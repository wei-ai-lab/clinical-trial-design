# NAS (2010) / Little et al. (2012) — Missing Data in Clinical Trials

**Family:** non-standard · **Kind:** regulatory-guidance · **Scope:** cross-cutting missing data methodology

## Why this case is in the corpus

- **Canonical cross-cutting reference** for missing data methodology — shaped FDA Missing Data Guidance, ICH E9(R1), and industry best practices since 2010.
- Distinguishes MCAR / MAR / MNAR mechanisms and recommends prevention-first design.
- Rejects LOCF as primary analysis and endorses MMRM / MI for most settings.
- Co-foundational document with ICH E9(R1) for modern trial design.

## Citation

- National Research Council. *The Prevention and Treatment of Missing Data in Clinical Trials.* Washington DC: The National Academies Press; 2010.
- Little RJ, D'Agostino R, Cohen ML, et al. *The prevention and treatment of missing data in clinical trials.* N Engl J Med. 2012 Oct 4;367(14):1355-60.

## Key recommendations

1. **Prevent missing data** by design: run-in periods, active retention, adherence protocols, clear informed consent about the importance of full follow-up.
2. **Pre-specify** the missing data mechanism (MCAR/MAR/MNAR) and handling method in the protocol and SAP.
3. Use **principled methods**: MMRM, multiple imputation, inverse probability weighting, likelihood-based methods.
4. **Avoid LOCF** as primary analysis — it biases and does not quantify uncertainty.
5. **Sensitivity analyses** for MNAR: tipping-point, pattern-mixture, reference-based imputation.

## Mechanisms classification

| Mechanism | Definition | Typical method |
|---|---|---|
| MCAR | Missingness independent of observed and unobserved data | Complete-case valid |
| MAR | Missingness independent of unobserved values, conditional on observed | MMRM, MI |
| MNAR | Missingness depends on unobserved values | Pattern-mixture, sensitivity |

## Algorithm recommendations

```r
# MMRM — canonical for continuous longitudinal endpoints under MAR
library(mmrm)
fit <- mmrm(
  FEV1 ~ trt * visit + baseline + (us(visit | subject)),
  data = df
)

# Multiple Imputation under MAR (predictive mean matching)
library(mice)
imp <- mice(df, method = "pmm", m = 50, seed = 42)
fit_pool <- with(imp, lm(FEV1 ~ trt + baseline + covs))
pool(fit_pool)

# Reference-based MI for hypothetical estimand (jump-to-reference)
library(rbmi)
imputations <- impute(
  data = df,
  vars = list(outcome = "FEV1", group = "trt", visit = "visit"),
  method = method_condmean(type = "jomo"),
  references = c(active = "control", control = "control")
)
# Pool and analyze
pool_and_analyze(imputations)

# Delta-adjusted tipping point (MNAR sensitivity)
library(rbmi)
tipping_point <- sens_delta_adjusted(
  imputations,
  delta_values = seq(-10, 10, 1),
  threshold = 0.05  # p-value threshold
)
```

## Real-world implications

- **Sample-size inflation**: variance inflation factor ~ 1.1-1.3 for 20-40% missing data with MI/MMRM.
- **Run-in designs** favored in chronic-disease pharma trials.
- **MMRM** standard for continuous longitudinal endpoints since ~ 2012.
- **Reference-based MI** (J2R, copy-reference) canonical for hypothetical estimands with rescue.

## Relationship to ICH E9(R1)

The NAS 2010 report laid groundwork for the ICH E9(R1) Estimand Framework (2019):
- NAS: "pre-specify primary analysis and sensitivity analyses".
- E9(R1): "pre-specify estimand and sensitivity analyses".
- NAS: "MAR is the standard working assumption".
- E9(R1): "intercurrent event strategy must be pre-specified".

The two documents are complementary: E9(R1) gives the scientific question; NAS provides the analytical methods.

## Evolution (2010 → 2024)

- **2010**: NAS report published; LOCF phase-out begins.
- **2012**: Little et al. NEJM summary.
- **2014**: FDA Guidance on Missing Data in Clinical Trials (draft).
- **2019**: ICH E9(R1) Estimand Addendum.
- **2021**: rbmi (Roche) R package for FDA-endorsed reference-based MI.
- **2022**: FDA Missing Data Guidance finalized with estimand alignment.

## How this case validates designr

- Adds the **canonical missing data methodology** to the corpus as a cross-cutting reference complementing ICH E9(R1).
- `designr` should expose MMRM, multiple imputation (via mice/rbmi), and tipping-point sensitivity as standard elements of the analysis plan.
- Sample-size calculation should account for expected missing-data rate and variance inflation under the chosen imputation method.
- Teaches: missing data is a design problem, not just an analysis problem.
