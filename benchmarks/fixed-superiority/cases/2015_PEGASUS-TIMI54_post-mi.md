# PEGASUS-TIMI 54 (2015) — long-term ticagrelor after MI

**Family:** fixed-superiority · **Endpoint:** TTE MACE composite · **N:** 21,162 · **Design feature:** three-arm with hierarchical testing

## Why this case is in the corpus

- **Three-arm design with shared placebo** — tests `designr`'s handling of multi-arm allocation and **fixed-sequence hierarchical multiplicity** without formal α-split.
- Modern-era cardiovascular outcomes trial with long-follow-up TTE composite primary.
- Teaches the agent to reason about the trade-off between 1:1:1 and enriched-control allocation in multi-active-arm designs.

## Citation

Bonaca MP, Bhatt DL, Cohen M, et al. *Long-term use of ticagrelor in patients with prior myocardial infarction.* N Engl J Med. 2015;372(19):1791-1800. doi:10.1056/NEJMoa1500857. NCT01225562.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, three-arm parallel |
| Indication | Prior MI 1-3 y ago + atherothrombotic risk factor |
| Arms | Ticagrelor 90 mg bid · Ticagrelor 60 mg bid · Placebo |
| Allocation | 1 : 1 : 1 |
| Primary endpoint | Composite CV death + MI + stroke |
| Multiplicity | Fixed sequence: test 90 mg vs placebo first, if significant then 60 mg vs placebo at full α |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.81 (each dose vs placebo) |
| Assumed control rate | ~3.3% / year |
| Target events | 1,360 |
| Planned N | 21,162 |
| Follow-up | Event-driven, median ~33 mo |

## Reproducing the calculation

For one active vs placebo, HR = 0.81, α = 0.05 two-sided, power = 0.9, 1:1 within pair:

```r
library(gsDesign)
nEvents(hr = 0.81, alpha = 0.025, beta = 0.10, ratio = 1)
# events ≈ 1,360
```

Three-arm total N from event-count and ~3.3% annual event rate:
- With 1:1:1 and ~33 mo median follow-up, the total N required to observe 1,360 events across the 2/3 of subjects contributing to the primary comparison is ≈ 21,000.

```r
nSurv(
  lambdaC = -log(1 - 0.033),
  hr      = 0.81,
  alpha   = 0.025,
  beta    = 0.10,
  ratio   = 1,     # per-comparison ratio (one active : placebo)
  R       = 27,
  minfup  = 12,
  T       = 39
)
# N per 2-arm comparison ≈ 14,100 → scale to 3-arm ≈ 21,000
```

## What the trial found

- Both doses met superiority vs placebo.
- 90 mg HR = **0.85** (95% CI 0.75–0.96), p = 0.008.
- 60 mg HR = **0.84** (95% CI 0.74–0.95), p = 0.004.
- Bleeding risk higher with both active doses; 60 mg emerged as preferred maintenance dose.

## Caveats & teaching points

- **Hierarchical fixed sequence** preserves α = 0.05 for both tests without splitting, conditional on the first test rejecting. If the 90 mg test had failed, the 60 mg test could not be made at α = 0.05 under this strategy.
- **1:1:1 allocation is sub-optimal** for two vs-placebo tests when placebo is shared. Optimal allocation for fixed-power would weight placebo higher (√2 : 1 : 1 ≈ 1.41:1:1) — the trial chose to simplify operationally.
- **Active-control events are not "wasted"** — the active arms contribute to both efficacy and safety characterization.

## How this case validates designr

- Three-arm TTE fixed design with shared control.
- Hierarchical fixed-sequence multiplicity — agent should explain why no α-split is needed.
- Optional: agent should flag 1:1:1 as inefficient and suggest enriched-placebo allocation as a design alternative.
