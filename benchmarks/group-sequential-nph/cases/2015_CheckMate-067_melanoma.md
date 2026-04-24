# CheckMate-067 (2015) — nivolumab ± ipilimumab in advanced melanoma

**Family:** group-sequential-nph · **Endpoint:** TTE PFS + OS (co-primary) · **N:** 945 · **Design feature:** delayed-effect with hierarchical multiplicity across 3 arms

## Why this case is in the corpus

- **Three-arm IO trial** — nivolumab + ipilimumab combo vs each monotherapy, each pairwise comparison against ipilimumab requires α-splitting.
- **Classic delayed + sustained effect** — KM curves overlap for ~3 months then separate durably.
- Teaching case for **group-sequential with hierarchical endpoint testing** under NPH.

## Citation

Larkin J, Chiarion-Sileni V, Gonzalez R, et al. *Combined nivolumab and ipilimumab or monotherapy in untreated melanoma.* N Engl J Med. 2015;373(1):23-34. doi:10.1056/NEJMoa1504030. NCT01844505.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1:1, GS |
| Population | Untreated advanced melanoma, BRAF WT or mutant |
| Arms | Nivolumab + ipilimumab · Nivolumab · Ipilimumab |
| Primary endpoints | PFS + OS (co-primary, hierarchical) |
| α / power | 0.05 (two-sided, split across comparisons) / 0.90 |
| Assumed HR | 0.65 (combo vs ipi), 0.75 (nivo vs ipi) |
| Spending | Lan-DeMets OBF (α-spending only) |
| Planned looks | 1 interim (PFS) + final PFS + interim OS + final OS |
| Planned N | 945 |
| Target events | PFS ≥ 550 · OS ≥ 555 |

## Reproducing the design

```r
library(gsDesign2)
# Piecewise HR to capture delayed effect
d_pfs <- gs_design_ahr(
  enrollRates  = tibble::tibble(stratum = "All", duration = 24, rate = 945/24),
  failRates    = tibble::tibble(
    stratum   = "All",
    duration  = c(3, Inf),
    fail_rate = c(-log(0.5)/8, -log(0.5)/10),   # median 8 → 10 mo under treatment transition
    hr        = c(1.0, 0.65),                    # no effect month 0-3, then HR 0.65
    dropout_rate = 0.001
  ),
  alpha = 0.025, beta = 0.10,
  analysis_time = c(12, 24),
  upper = gs_spending_bound,
  upar  = list(sf = gsDesign::sfLDOF, total_spend = 0.025)
)
# events ≈ 550, N ≈ 945
```

## What the trial found

- PFS (combo vs ipi): HR **0.42** (95% CI 0.34–0.51), median 11.5 vs 2.9 mo.
- PFS (nivo vs ipi): HR **0.57** (95% CI 0.47–0.69), median 6.9 vs 2.9 mo.
- OS at 5 y (combo): **52%** vs 44% (nivo) vs 26% (ipi).
- KM curves overlap for ~2-3 months then separate durably — classic delayed + sustained IO response.

## Caveats & teaching points

- **Delayed-effect log-rank underpowered.** Had log-rank been used under exact PH assumption with observed early-overlap, power would have been lower than observed. Trial survived because HR was very large (0.42) once separation occurred.
- **Alpha split across 3 comparisons.** Two co-primary comparisons (combo vs ipi, nivo vs ipi) + co-primary endpoints (PFS + OS) means 4 hierarchical tests. Graphical α-propagation (Bretz-Maurer) was used.
- **Nivo+ipi vs nivo comparison underpowered.** Trial not designed to prove superiority of combo over nivo monotherapy — distinction that affects labeling and payer decisions.

## How this case validates designr

- Multi-arm GS with α-splitting.
- Delayed-effect NPH design using gsDesign2 piecewise-HR workflow.
- Co-primary endpoint multiplicity handling (PFS + OS).
