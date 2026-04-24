# Pocock et al. (2012) — Win ratio for hierarchical composite endpoints

**Family:** non-standard · **Kind:** methodology-canonical · **N:** n/a (estimand framework) · **Design feature:** hierarchical composite primary

## Why this case is in the corpus

- **Defines the win-ratio estimand**, now a mainstream alternative to time-to-first-event composite in CV trials.
- Basis for the primary analyses of EMPEROR-Preserved (2021), EMPULSE (2022), ATTR-ACT (2018), and many others.
- Addresses the core flaw of time-to-first-event: death and hospitalization are treated as equivalent, and post-event data are discarded.
- Foundation for `WINS`, `wwr`, `WR` R packages.

## Citation

Pocock SJ, Ariti CA, Collier TJ, Wang D. *The win ratio: a new approach to the analysis of composite endpoints in clinical trials based on clinical priorities.* Eur Heart J. 2012;33(2):176-182. doi:10.1093/eurheartj/ehr352.

Related: Finkelstein DM, Schoenfeld DA. *Combining mortality and longitudinal measures in clinical trials.* Stat Med. 1999;18:1341-1354.

## Design summary

| | |
|---|---|
| Estimand | Win ratio = #wins / #losses across all experimental-vs-control pairs |
| Endpoint structure | **Hierarchical** — e.g. (1) CV death → (2) HF hospitalization → (3) KCCQ or 6MWD |
| Pair comparison | Use highest-priority component with informative data for the pair; if tied, move to next priority |
| Inference | Stratified logrank-type statistic (Finkelstein-Schoenfeld); CI via Bebu-Lachin or bootstrap |
| Typical target | WR ~ 1.25 (corresponds roughly to HR 0.80 on dominant component) |

## Reproducing the design

```r
library(WINS)
# Simulate a hierarchical composite trial: CV death > HF hosp > KCCQ
sim <- win.stat(
  data = trial_df,
  ep_type = c("tte", "tte", "continuous"),
  Delta = c(0, 0, 5),   # minimum clinically important difference for continuous comp
  arm.name = c("experimental", "control"),
  priority = c(1, 2, 3),
  alpha = 0.05,
  stratum.name = "region"
)
# sim$Win_statistic, sim$p_value, sim$Win_Ratio + CI
```

Sample-size sizing typically requires simulation — no clean closed form because the win ratio depends on the joint distribution of components, not just marginal hazards.

## Key conclusions

- Win ratio respects **clinical priority** among components — addresses the "death pulls hospitalization" concern.
- Uses **all follow-up data** on secondary components even after a primary event has occurred.
- Power advantage over time-to-first-event is largest when the primary (death) component is **rare** relative to secondaries.
- Pre-specification of component order + tie-breaking is critical.

## How this case validates designr

- Canonical reference for hierarchical composite endpoint design.
- Motivates simulation-based sample sizing as a first-class designr capability (vs closed-form only).
- Enables `designr` to size / analyze any modern CV trial whose primary is win-ratio-based.
- Completes the taxonomy: `designr` must handle estimands beyond HR / RR / mean difference.
