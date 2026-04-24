# Senn (2002) — Cross-over Trials in Clinical Research

**Family:** crossover · **Endpoint:** within-subject paired difference · **Design feature:** canonical methodology reference

## Why this case is in the corpus

- **Field-standard textbook** by Stephen Senn for crossover trial design.
- Covers 2×2, Williams, n-of-1, and bioequivalence crossover.
- Cited in FDA/EMA crossover guidance documents.

## Citation

Senn S. *Cross-over Trials in Clinical Research.* 2nd ed. Wiley, 2002. ISBN 978-0-471-49653-3.

## Design summary

| | |
|---|---|
| Framework | Textbook — crossover design family |
| Basic unit | 2×2 AB/BA |
| Multi-period extension | Williams design (latin square with carryover balance) |
| Analysis | Paired t-test, mixed-effects model with period+treatment+subject |
| Sample size formula | N = 2·(z_{α/2}+z_β)²·σ²_w / δ² per sequence |
| Key assumption | Within-subject variance σ²_w typically ≤ between-subject σ²_b |

## Reproducing the design

```r
library(PowerTOST)
# Within-subject 2x2 crossover sample size (continuous outcome)
# Approximate via paired t-test power
# N per sequence = 2*(z_{α/2}+z_β)² * σ²_w / δ²

# Or via mixed-model simulation:
library(nlme)
# fit <- lme(response ~ period + treatment,
#            random = ~ 1 | subject, data = df)
```

Example (σ_w = 1, δ = 1, α = 0.05, power = 0.90):
- N per sequence ≈ 22 → total N ≈ 44.
- Parallel design would need N ≈ 88 (under σ_total = √2·σ_w).
- Crossover 2× efficiency gain.

## Key methodology insights

- **Carryover test is uninformative in 2×2** (Grizzle 1965; Senn 1994). Use washout period ≥ 5 half-lives instead.
- **Period effect** adjustment is essential — systematic time trends common (e.g., regression to the mean).
- **Dropout handling**: ITT analysis with multiple imputation recommended; completers-only under-represents harm.
- **Williams design**: for ≥ 3 treatments, Williams squares provide balanced carryover — each treatment precedes every other treatment equally.
- **N-of-1 designs**: individual-level crossover; meta-analysis via Bayesian hierarchical or mixed-effect models.
- **Bioequivalence**: TOST on log-transformed AUC and Cmax; 90% CI must lie within (0.80, 1.25).

## How this case validates designr

- Canonical reference for crossover design family.
- Sample-size formula backbone for `PowerTOST` and `Crossover` R packages.
- Cross-references FDA 2001 bioequivalence guidance and EMA crossover literature.
