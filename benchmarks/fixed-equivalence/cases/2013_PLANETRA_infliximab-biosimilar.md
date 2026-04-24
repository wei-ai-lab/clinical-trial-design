# PLANETRA (2013) — CT-P13 infliximab biosimilar equivalence

**Family:** fixed-equivalence · **Endpoint:** binary ACR20 at 30 wk · **N:** 606 · **Design feature:** EMA biosimilar guidance, ±15% TOST

## Why this case is in the corpus

- **First large-scale biosimilar Phase 3** for a monoclonal antibody — established the template for subsequent biosimilar equivalence trials (adalimumab, trastuzumab, rituximab biosimilars followed).
- **±15% TOST margin** on binary rate difference — EMA/FDA-accepted standard for RA biosimilars.
- Tests `designr`'s handling of **two-sided equivalence** vs one-sided NI.

## Citation

Yoo DH, Hrycaj P, Miranda P, et al. *A randomised, double-blind, parallel-group study to demonstrate equivalence in efficacy and safety of CT-P13 compared with innovator infliximab when coadministered with methotrexate in patients with active rheumatoid arthritis: the PLANETRA study.* Ann Rheum Dis. 2013;72(10):1613-1620. NCT01217086.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1 |
| Arms | CT-P13 · Innovator infliximab |
| Primary endpoint | ACR20 response at week 30 |
| Comparison | Two-sided equivalence, symmetric margin Δ = ±15% |
| α / power | 0.05 (two-sided, split 2 × 0.025 one-sided) / 0.80 |
| Assumed rate (both arms) | ~60% |
| Planned N | 606 (303 per arm) |

## Reproducing the calculation

For two-sided equivalence with binary endpoint, symmetric margin ±0.15:

```r
library(gsDesign)
# Equivalent to NI test at each bound: sizing driven by the tighter bound
nBinomial(p1 = 0.60, p2 = 0.60, delta0 = 0.15,
          alpha = 0.025, beta = 0.20, sided = 1)
# n per arm ≈ 290 → total ~580; planned 606 adds ~4% margin
```

Note: under true δ = 0, power for TOST ≈ power for one-sided NI at the tighter bound. Under true δ > 0, TOST power drops faster than NI.

## What the trial found

- ACR20 at week 30: CT-P13 60.9%, innovator 58.6%.
- Difference: +2.3% (95% CI −6.0 to +10.6).
- Both bounds within ±15% → equivalence demonstrated.
- CT-P13 became the first mAb biosimilar approved by EMA (2013) and FDA (2016).

## Caveats & teaching points

- **Per-protocol as primary.** Biosimilar equivalence typically uses PP set as primary (to avoid dilution by non-adherers), with ITT supportive. Both should meet equivalence for a robust conclusion.
- **Wide CIs common near margin.** At N = 606 and true δ ≈ 0, 95% CI half-width ≈ ±8%. Sponsors often inflate N 10-20% above minimum for confidence.
- **±15% is margin not truth.** The margin is regulatorily-agreed tolerance; it doesn't mean real-world differences up to 15% are clinically unimportant. Downstream biosimilar interchangeability studies test more narrowly.

## How this case validates designr

- Two-sided equivalence sample-size calc (TOST logic).
- Agent reasoning about biosimilar regulatory margins (EMA vs FDA conventions).
- PP vs ITT handling in biosimilar context.
