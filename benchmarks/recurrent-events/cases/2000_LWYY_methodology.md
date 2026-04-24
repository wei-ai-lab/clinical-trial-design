# Lin-Wei-Yang-Ying (2000) — LWYY marginal mean/rate for recurrent events

**Family:** recurrent-events · **Endpoint:** mean cumulative function μ(t) · **Design feature:** marginal model with robust variance

## Why this case is in the corpus

- **Canonical methodology reference** for recurrent-event Phase 3 designs.
- Workhorse for HF hospitalization and COPD exacerbation endpoints.
- Robust sandwich variance — no frailty distribution required.

## Citation

Lin DY, Wei LJ, Yang I, Ying Z. *Semiparametric regression for the mean and rate functions of recurrent events.* J R Stat Soc B. 2000;62(4):711-730. doi:10.1111/1467-9868.00259.

## Design summary

| | |
|---|---|
| Framework | Methodology — marginal mean/rate model |
| Rate function | λ(t \| Z) = λ₀(t) · exp(βZ) |
| Estimator | Cox-style partial-likelihood score with robust variance |
| Rate ratio (RR) | exp(β) — interpretable as marginal mean ratio |
| α / power | 0.05 (two-sided) / 0.90 example |
| Example RR | 0.75 (25% rate reduction) |
| Example rate_C | 0.50 events/year |
| Example N | ~1,200 |

## Reproducing the test

```r
library(survival)
# LWYY: Cox with cluster(id) and Andersen-Gill counting-process data
coxph(Surv(start, stop, event) ~ arm + cluster(id), data = df)
# robust SE reported as "robust se"
```

For design sizing:

```r
# Rate ratio with over-dispersion correction:
# n per arm ≈ (z_{α/2} + z_β)^2 · (1/λ_C + 1/λ_E) · (1 + ρ(k-1)) / (log(RR))^2
# where k = mean events/subject, ρ = within-subject correlation
```

## Key methodology points

- **Marginal interpretation**: RR from LWYY is a ratio of mean cumulative counts, not a hazard ratio.
- **Robust variance**: sandwich estimator accounts for arbitrary within-subject dependence.
- **No frailty needed**: unlike parametric NB or joint frailty models.
- **Terminal events**: extension in Ghosh-Lin (2000, 2002) handles informative censoring by death.

## How this case validates designr

- Foundational reference for recurrent-event Phase 3 family.
- Backbone of LWYY-based design specifications in HF hospitalization trials.
- Connects to both `survival::coxph` (test) and rate-ratio sample-size formulas.
