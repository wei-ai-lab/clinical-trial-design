# CANVAS Program (2017) — canagliflozin CVOT

**Family:** fixed-superiority (after NI gate) · **Endpoint:** TTE MACE composite · **N:** 10,142

## Why this case is in the corpus

- **FDA-mandated CVOT** design under the 2008 guidance: exemplifies the **NI-then-superiority hierarchical strategy** that dominated diabetes Phase 3 trials 2008–2020.
- **Pooled integrated-analysis design** — two parallel trials (CANVAS, CANVAS-R) with shared primary analysis. Teaches the agent to handle multi-trial pooled designs.
- **2:1 allocation** (treatment:placebo) — common in safety-driven CVOTs.

## Citation

Neal B, Perkovic V, Mahaffey KW, et al. *Canagliflozin and cardiovascular and renal events in type 2 diabetes.* N Engl J Med. 2017;377(7):644-657. doi:10.1056/NEJMoa1611925. NCT01032629 (CANVAS) + NCT01989754 (CANVAS-R).

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Pooled integrated-analysis of two RDBPC trials |
| Indication | T2D with established CVD or high CV risk |
| Arms | Canagliflozin 100/300 mg · Placebo, 2:1 |
| Primary endpoint | MACE: CV death + non-fatal MI + non-fatal stroke |
| Hypothesis testing | Hierarchical: (1) non-inferiority with HR margin 1.3 → (2) superiority |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR (superiority arm) | 0.80 |
| Assumed control MACE rate | ~2.2% / year |
| Target events | 688 |
| Planned N | 10,142 |

## Reproducing the calculation

For superiority under HR = 0.80:

```r
library(gsDesign)
nSurv(hr = 0.80, alpha = 0.025, beta = 0.10, ratio = 2)
# events ≈ 688 for superiority at HR = 0.80
```

For the NI test (margin 1.3), the required events are substantially fewer under a point-alternative of HR = 1.0:

```r
nSurv(hr = 1.0, hr0 = 1.3, alpha = 0.025, beta = 0.10, ratio = 2)
# events ≈ 122 for NI at margin 1.3 under null effect
```

The larger of the two (superiority, 688 events) drove sizing. Total N is scaled up for accrual, follow-up, and dropout.

## What the trial found

- MACE HR = **0.86** (95% CI 0.75–0.97), p<0.001 for NI, p=0.02 for superiority.
- Both hierarchical tests passed.
- Adverse-event surprise: increased lower-extremity amputation risk — a safety signal that substantially shaped labeling.

## Caveats & teaching points

- **Hierarchical testing** matters for event-count sizing — the binding constraint (superiority at HR 0.80) determines N.
- **Pooled integrated design** — CANVAS and CANVAS-R were stopped pre-specified together. The pooled analysis has the design's claimed α; analyzing either alone does not.
- **Post-2020 CVOT landscape.** FDA withdrew the 2008 CVOT guidance in 2020; new T2D trials no longer require this specific NI-then-superiority construct, but many legacy trials in the benchmark reflect it.

## How this case validates designr

- Exercises TTE fixed design with **2:1 allocation**.
- Exercises agent reasoning about **hierarchical hypothesis** structure — should explain why the superiority calc, not the NI calc, drives N.
- Stress-tests the agent's handling of **pooled multi-trial integrated analysis**.
