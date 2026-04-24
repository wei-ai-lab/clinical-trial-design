# PACIFIC (2017) — Durvalumab Consolidation in Stage III NSCLC

**Family:** tte-nph · **Kind:** landmark Phase 3 · **Scope:** delayed-effect NPH with plateau / cure fraction

## Why this case is in the corpus

- **Landmark consolidation IO trial** — first Phase 3 to establish maintenance immunotherapy after chemoradiation.
- Classic **delayed-separation NPH** pattern — curves separate at ~ 6 months (immune response lag).
- **Plateau effect** visible by 3 years — substantial cure fraction.
- **Co-primary PFS + OS** with pre-specified **alpha splitting** (0.01 + 0.04).
- **2:1 allocation** — concentrates patients on experimental arm.
- Changed stage III NSCLC standard of care within 12 months of publication.

## Citation

- Antonia SJ, Villegas A, Daniel D, et al. *Durvalumab after chemoradiotherapy in stage III NSCLC.* N Engl J Med. 2017 Nov 16;377(20):1919-1929.
- Antonia SJ, et al. *Overall survival with durvalumab after CRT.* N Engl J Med. 2018 Dec 13;379(24):2342-2350.
- Spigel DR, et al. *5-year survival outcomes PACIFIC.* J Clin Oncol. 2022;40(12):1301-1311.

## Design summary

| Parameter | Value |
|---|---|
| Indication | Unresectable stage III NSCLC post-definitive CRT |
| Arms | Durvalumab 10 mg/kg Q2W × 12 mo vs placebo (2:1) |
| Co-primary | PFS (α = 0.01) + OS (α = 0.04) |
| Power | 85% (each co-primary) |
| Assumed HR (PFS) | 0.67 |
| Assumed HR (OS) | 0.73 |
| Control median PFS | 5.6 months |
| Target events | 458 PFS + 491 OS |
| Randomized N | 713 (476 + 237) |

## Alpha splitting for co-primary

Pre-specified Hochberg-like closed test:
- PFS tested at α = 0.01 (one-sided equivalent).
- OS tested at α = 0.04.
- Family-wise α = 0.05.
- If PFS significant, full α available for OS.

## The NPH pattern

**PFS**: reasonably proportional; classical Cox valid.

**OS**: clear delayed separation:
- **0-6 months**: minimal separation (immune response lag).
- **6-18 months**: gradual widening.
- **18+ months**: sustained separation.
- **36+ months**: plateau in both arms — cure fraction.

```r
library(survival)
library(nphRCT)
library(survRM2)

# Schoenfeld test for PH
cox <- coxph(Surv(time, status) ~ arm, data = df)
cox.zph(cox)   # expect rejection for OS

# RMST at 36 months (capture cure fraction benefit)
rmst2(time, status, arm, tau = 36)

# Magirr-Burman modestly-weighted log-rank (emphasizes later times)
wlr_test(
  formula = Surv(time, status) ~ arm,
  data = df,
  method = "mw",
  t_star = 6    # delay threshold
)
```

## Results

**Initial (2017/2018)**:
| Outcome | Durvalumab | Placebo | HR (95% CI) |
|---|---|---|---|
| PFS | 16.8 mo | 5.6 mo | 0.52 (0.42-0.65) |
| OS median | NR | 28.7 mo | 0.68 (0.53-0.87) |
| Time to distant mets / death | 28.3 mo | 16.2 mo | 0.53 (0.41-0.68) |

**5-year follow-up (2022)**:
| Outcome | Durvalumab | Placebo |
|---|---|---|
| 5-yr OS | 42.9% | 33.4% |
| 5-yr PFS | 33.1% | 19.0% |

Substantial cure fraction — plateau evident.

## Why NPH was not catastrophic for log-rank

- Effect sustained throughout (no curve crossing).
- Delayed start but consistent direction.
- Large HR (0.52 PFS, 0.68 OS) absorbs log-rank weighting inefficiency.
- Trial still "passed" classical log-rank — but modern design would flag underestimation of long-term benefit.

## Design choices that mattered

**2:1 allocation**:
- More patients on active arm (ethically appealing for stage III).
- Maintains near-optimal power for HR ~ 0.7.
- Standard for consolidation / maintenance settings.

**PFS α = 0.01**:
- Strict threshold for PFS because PFS more sensitive to assessment bias.
- Preserved α for OS secondary.

**PD-L1 post-hoc refinement**:
- Benefit larger at PD-L1 ≥ 1%.
- EMA initially restricted label to PD-L1 ≥ 1%; later liberalized.
- FDA approved regardless of PD-L1.

## Regulatory & clinical impact

- FDA approval Feb 2018 (Imfinzi) for unresectable stage III NSCLC post-CRT.
- Changed stage III NSCLC standard of care.
- Spawned PACIFIC-2 (concurrent with CRT, failed), PACIFIC-R (RWE), LAURA (EGFR+).

## Related trials

| Trial | Setting | Design relevance |
|---|---|---|
| PACIFIC (this case) | Consolidation after CRT | Delayed-NPH + plateau |
| PACIFIC-2 | Concurrent with CRT | Failed — different biology |
| LAURA | Osimertinib (EGFR+) consolidation | PH-dominant |
| KEYNOTE-024 (in corpus) | Frontline IO monotherapy | Crossing hazards + plateau |
| CheckMate-9LA (in corpus) | Dual IO + chemo | NPH |

## How this case validates designr

- Adds the **canonical consolidation / delayed-effect NPH trial** to tte-nph.
- `designr` should reproduce classical PH-based sizing (`gsDesign::gsSurv`) but also provide simulation tools to quantify power loss under delayed effect.
- Teaches: alpha splitting across co-primary TTE, 2:1 allocation, cure-fraction plateau.
- Motivates MaxCombo / Magirr-Burman (2019, in corpus) and RMST (Uno 2014, in corpus) as sensitivity analyses.
