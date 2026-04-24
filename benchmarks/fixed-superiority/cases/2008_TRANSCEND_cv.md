# TRANSCEND (2008) — telmisartan in ACEI-intolerant patients

**Family:** fixed-superiority · **Endpoint:** TTE composite · **N:** 5,926

## Why this case is in the corpus

- Clean **fixed-sample TTE design** without GS boundaries — reference case for the simplest TTE superiority calculation.
- Companion to ONTARGET (a three-arm trial); TRANSCEND was the placebo-controlled subset for ACEI-intolerant patients.
- Well-documented event-count planning in publicly available methods section.

## Citation

TRANSCEND Investigators. *Effects of the angiotensin-receptor blocker telmisartan on cardiovascular events in high-risk patients intolerant to angiotensin-converting-enzyme inhibitors: a randomised controlled trial.* Lancet. 2008;372(9644):1174-1183. doi:10.1016/S0140-6736(08)61242-8. NCT00153101.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1 |
| Arms | Telmisartan 80 mg · Placebo |
| Primary endpoint | Composite CV: CV death + MI + stroke + HF hospitalization |
| α / power | 0.05 (two-sided) / 0.85 |
| Assumed HR | 0.82 |
| Target events | ~1,145 |
| Planned N | 5,926 |
| Follow-up | Median ~56 months |

## Reproducing the calculation

```r
library(gsDesign)
nEvents(hr = 0.82, alpha = 0.025, beta = 0.15, ratio = 1)
# events ≈ 1,150

nSurv(
  lambdaC = -log(1 - 0.04),
  hr      = 0.82,
  alpha   = 0.025,
  beta    = 0.15,
  T       = 80,
  minfup  = 56,
  R       = 24
)
# N ≈ 5,900
```

## What the trial found

- HR = **0.92** (95% CI 0.81–1.05), p = 0.22 — **did not achieve superiority**.
- The trial is instructive because the observed effect (HR 0.92) was materially smaller than the powered-for assumption (HR 0.82).
- Illustrates the cost of optimistic effect assumptions in event-driven designs.

## Caveats & teaching points

- **Assumption-to-truth gap.** Designed for HR 0.82; observed 0.92. A sensitivity analysis at design time (e.g. powering for HR 0.90) would have required ~3× the events.
- **Why fixed vs GS matters.** A GS design with efficacy stopping would not have helped here (trial was negative); a futility boundary might have stopped it earlier, saving resources.
- **Companion-trial context.** TRANSCEND is paired with ONTARGET; together they support the telmisartan regulatory package. Reproducing TRANSCEND in isolation misses the ONTARGET design interaction.

## How this case validates designr

- Simplest possible TTE fixed superiority calculation.
- Agent teaching point: the cost of optimistic HR assumptions.
- Sets up a contrast with GS designs (see `group-sequential/` family) for when early stopping would have been informative.
