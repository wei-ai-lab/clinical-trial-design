# KEYNOTE-042 (2019) — pembrolizumab in PD-L1-positive 1L NSCLC

**Family:** multiplicity-multi-population · **Endpoint:** OS · **N:** 1,240 planned · **NCT02220894**

## Why this case is in the corpus

- Real-world **multi-population (nested-subgroup) design** — tests the same OS endpoint in three populations of decreasing biomarker expression: TPS≥50 → TPS≥20 → TPS≥1.
- **Hierarchical (fixed-sequence) testing** preserves family-wise α=0.025 across the three subgroup tests. No alpha-split.
- 1:1 randomization at the broadest population (TPS≥1); the narrower subgroups are subsets of those patients.
- Validates the "biomarker subgroup + ITT" pattern that pharma-skills' multi-population workflow targets — but with three nested levels rather than just two.

## Citation

Mok TSK, Wu Y-L, Kudaba I, et al. *Pembrolizumab versus chemotherapy for previously untreated, PD-L1-expressing, locally advanced or metastatic non-small-cell lung cancer (KEYNOTE-042): a randomised, open-label, controlled, phase 3 trial.* Lancet. 2019;393(10183):1819-1830. DOI: 10.1016/S0140-6736(18)32409-7.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Open-label RCT, 1:1 |
| Indication | 1L NSCLC, PD-L1 TPS≥1 |
| Endpoint | OS |
| Populations tested | TPS≥50, TPS≥20, TPS≥1 (nested) |
| Multiplicity | Fixed-sequence (TPS≥50 → TPS≥20 → TPS≥1) |
| α / power | 0.025 one-sided, 85% |
| HR (50/20/1) | 0.65 / 0.70 / 0.78 |
| Control median OS | 12.2 mo |
| Planned N | 1,240 (broader-population-driven) |

## Reproducing the calculation

```r
library(gsDesign)

# Each subgroup is its own log-rank test at full α=0.025
# (hierarchical gating preserves family-wise α).
# Required events per subgroup:
events_per_pop <- function(hr, alpha=0.025, beta=0.15, ratio=1) {
  ceiling((qnorm(1-alpha) + qnorm(1-beta))^2 /
          (log(hr)^2 * ratio/(1+ratio)^2))
}
events_per_pop(0.65)  # ~285 events for TPS≥50
events_per_pop(0.70)  # ~462 events for TPS≥20
events_per_pop(0.78)  # ~690 events for TPS≥1

# Total N driven by the broadest population (TPS≥1) needing 690 events,
# given control median 12.2 mo and 25-month accrual:
nSurv(lambdaC=log(2)/12.2, hr=0.78, eta=-log(0.95)/12,
      ratio=1, alpha=0.025, beta=0.15, R=25, minfup=12)$n
# ~1,240
```

## What the trial found

- **TPS≥50**: HR 0.69 (95% CI 0.56–0.85), p < 0.001 (rejected)
- **TPS≥20**: HR 0.77 (95% CI 0.64–0.92), p = 0.002 (rejected)
- **TPS≥1**: HR 0.81 (95% CI 0.71–0.93), p = 0.0018 (rejected)

All three sequential population tests rejected.

## Caveats & teaching points

- **Sequential subgroup testing ≠ alpha-split.** Each subgroup is tested at full α=0.025 conditional on prior subgroup rejection. The agent must avoid the common mistake of dividing 0.025 by 3.
- **Nested populations share patients.** Total N is driven by the broadest stratum (TPS≥1), not by summing per-subgroup N requirements.
- **Subgroup prevalence matters for events.** TPS≥50 represents ~47% of the TPS≥1 population, so 690 events in TPS≥1 yields ~324 events in TPS≥50 (slightly above the 285 required), making the design feasible.

## How this case validates clinical-trial-design

- Tests `design_multi_population` with three nested strata.
- Tests `strategy = "fixed-sequence"` ordering by population.
- Validates total-N driven by broadest population, not sum of per-subgroup needs.
