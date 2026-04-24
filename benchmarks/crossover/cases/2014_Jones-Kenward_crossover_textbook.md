# Jones-Kenward (2014) — Design and Analysis of Cross-Over Trials, 3rd ed.

**Family:** crossover · **Kind:** methodology-textbook · **Scope:** comprehensive crossover design and analysis reference

## Why this case is in the corpus

- **Most-cited modern crossover textbook** — authoritative reference for design construction and analysis.
- Comprehensive coverage of AB/BA, Williams squares, replicate designs (RSABE), incomplete blocks, N-of-1.
- Complements Senn (2002, in corpus) with encyclopedic design catalog vs Senn's polemical style.
- Basis for the R `Crossover` package (Jaki et al.) and `PowerTOST` crossover sizing.

## Citation

Jones B, Kenward MG. *Design and Analysis of Cross-Over Trials.* 3rd edition. Chapman & Hall/CRC Biostatistics Series; 2014. ISBN 978-1-4398-6142-4.

## Design catalog

| Design | Sequences | When used |
|---|---|---|
| **AB/BA** | 2 | 2 treatments, short-term outcomes, washout feasible |
| **Williams square** | 4+ | ≥ 3 treatments, balanced for first-order carryover |
| **Replicate (TRR, RTR)** | 4 | Highly variable drugs (CV_W > 30%), RSABE |
| **Incomplete block** | per design | ≥ 5 treatments, limited periods feasible |
| **N-of-1** | as many as subject tolerates | Individual patient inference |

## Analysis methods by design

```r
# AB/BA (2-period) paired analysis
library(emmeans)
fit <- lme(outcome ~ treatment + period + sequence,
           random = ~ 1 | subject,
           data = crossover_df)
emmeans(fit, "treatment") |> pairs()

# Williams square (≥ 3 treatments)
fit_ws <- lme(outcome ~ treatment + period,
              random = ~ 1 | subject,
              correlation = corCompSymm(form = ~ 1 | subject),
              data = williams_df)

# Binary crossover (Mainland-Gart)
library(survival)
clogit(response ~ treatment + strata(subject), data = bin_df)

# Replicate RSABE for highly variable drugs
library(PowerTOST)
sampleN.scABEL(
  alpha = 0.05, targetpower = 0.80,
  theta0 = 0.95,
  CV = 0.40,               # high within-subject CV
  design = "2x3x3"         # partial replicate
)
```

## Sample-size formulas

| Design | Formula |
|---|---|
| AB/BA | n per seq ≈ (z_{α/2} + z_β)^2 σ_W^2 / δ^2 / 2 |
| Williams 3x3 | n per seq ≈ (z_{α/2} + z_β)^2 × VIF × σ_W^2 / δ^2 |
| Replicate RSABE | Varies — scaled BE limits, PowerTOST::sampleN.scABEL |
| Equivalence (TOST) | n per seq ≈ (z_α + z_β)^2 σ_W^2 / (margin - \|δ\|)^2 |

## Special topics

- **Carryover**: Jones-Kenward discuss both the pro-test (historical) and Senn position (no formal test, adequate washout); modern practice follows Senn.
- **Missing data**: more problematic than parallel designs due to pairing; recommended multiple imputation or MMRM.
- **Equivalence / BE**: Two One-Sided Tests (TOST) on within-subject difference.
- **N-of-1**: Bayesian hierarchical pooling extension (Duan 2022) builds on J+K's N-of-1 chapter.

## How this case validates designr

- Canonical textbook reference for the crossover family.
- Design-catalog breadth enables `designr` to expose AB/BA through replicate RSABE via a unified crossover API.
- Sample-size formulas directly implementable via `PowerTOST` and `Crossover` backends.
- Complements Senn (2002) and FDA ABE (2001) entries in the corpus with the comprehensive methodological reference.
