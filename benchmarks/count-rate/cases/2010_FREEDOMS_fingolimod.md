# FREEDOMS (2010) — Fingolimod in RRMS, annualized relapse rate primary

**Family:** count-rate · **Endpoint:** annualized relapse rate (24 mo) · **N:** 1,272 · **Design feature:** canonical negative binomial count-rate Phase 3 in MS

## Why this case is in the corpus

- **First oral disease-modifying therapy approved for MS** (Gilenya, Sep 2010).
- Canonical reference for annualized relapse rate (ARR) primary analyzed by negative binomial.
- Template for subsequent oral MS DMT approvals (TEMSO, DEFINE, SUNBEAM).
- Benchmark for Keene-Jones 2007 NB sample-size methodology in a real trial.

## Citation

Kappos L, Radue EW, O'Connor P, et al. *A placebo-controlled trial of oral fingolimod in relapsing multiple sclerosis.* N Engl J Med. 2010;362(5):387-401. doi:10.1056/NEJMoa0909494. NCT00289978.

## Design summary

| | |
|---|---|
| Design | Double-blind placebo-controlled, 3-arm |
| Population | RRMS, EDSS ≤ 5.5, ≥ 1 relapse/year or ≥ 2/2 years, 18-55 y |
| Arms | Fingolimod 1.25 mg QD, fingolimod 0.5 mg QD, placebo |
| Primary | Annualized relapse rate over 24 mo |
| Analysis | Negative binomial with log-exposure-time offset, region/prior-relapse/baseline-EDSS adjustment |
| Assumed ARR placebo | 0.40 |
| Target RR | 0.50 |
| Over-dispersion k | ~0.5 (assumed) |
| α | 0.05 two-sided |
| Power | 0.95 |
| Planned N | 1,272 (425 × 3 arms) |

## Reproducing the design

```r
library(MASS)
# Primary NB analysis
fit <- glm.nb(
  relapses ~ arm + region + prior_relapses + baseline_EDSS +
             offset(log(exposure_years)),
  data = freedoms_df
)

# Rate ratio with CI
library(emmeans)
emmeans(fit, "arm", type = "response") |>
  pairs(reverse = TRUE) |>
  confint()

# Sample-size sizing (Keene-Jones 2007)
# N per arm ≈ (z_{α/2} + z_β)^2 * (1/μ_1 + 1/μ_2 + k_1 + k_2)
# / (log(RR))^2
n_per_arm <- ceiling(
  (qnorm(0.975) + qnorm(0.95))^2 *
  (1/0.40 + 1/0.20 + 0.5 + 0.5) /
  (log(0.50))^2
)
# ≈ 425 per arm; 1,272 total
```

## Trial outcome

- **Fingolimod 0.5 mg**: ARR 0.18 vs placebo 0.40, RR **0.46** (95% CI 0.40-0.52), p < 0.001 — primary met.
- **Fingolimod 1.25 mg**: ARR 0.16 vs placebo 0.40, RR 0.40 (0.34-0.47).
- 3-month confirmed disability progression: HR 0.70 (0.52-0.96), p = 0.02.
- MRI lesion activity reduced >50% (secondary).
- **1.25 mg dose dropped** for cardiac (bradycardia) + infection safety; 0.5 mg marketed.

## How this case validates designr

- Canonical Keene-Jones NB sample-size worked example.
- Real-trial over-dispersion parameter as sensitivity input.
- ARR primary endpoint benchmark — de facto regulatory standard for RRMS.
- Reference for subsequent corpus entries in MS DMT lineage (teriflunomide, dimethyl fumarate, ozanimod, ocrelizumab).
