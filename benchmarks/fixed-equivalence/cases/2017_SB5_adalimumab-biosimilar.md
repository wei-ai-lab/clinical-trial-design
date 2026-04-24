# SB5 (2017) — adalimumab biosimilar equivalence

**Family:** fixed-equivalence · **Endpoint:** continuous DAS28-CRP change · **N:** 542 · **Design feature:** continuous-endpoint biosimilar equivalence

## Why this case is in the corpus

- **Continuous-endpoint biosimilar equivalence** — contrast with binary-endpoint biosimilars (PLANETRA).
- Uses **DAS28-CRP** (composite disease activity score) with ±0.6 margin reflecting minimum clinically important difference.
- Tests `designr`'s continuous-endpoint TOST calculation.

## Citation

Weinblatt ME, Baranauskaite A, Niebrzydowski J, et al. *Phase III randomized study of SB5, an adalimumab biosimilar, versus reference adalimumab in patients with moderate-to-severe rheumatoid arthritis.* Arthritis Rheumatol. 2018;70(1):40-48. doi:10.1002/art.40336. NCT02167139.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1 |
| Arms | SB5 · Reference adalimumab |
| Primary endpoint | Change in DAS28-CRP from baseline to week 24 |
| Comparison | Two-sided equivalence, margin ±0.6 DAS28 points |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed SD | 1.3 (DAS28-CRP change) |
| Assumed true difference | 0 |
| Planned N | 542 |

## Reproducing the calculation

For continuous equivalence, TOST at margin ±0.6, SD = 1.3:

```r
library(gsDesign)
# NI-style sizing at tighter bound:
nNormal(delta1 = 0, delta0 = -0.6, sd = 1.3,
        alpha = 0.025, beta = 0.10, sided = 1)
# n per arm ≈ 250 → total 500; planned 542 adds ~8% margin for dropout
```

Alternatively with `PowerTOST`:

```r
library(PowerTOST)
sampleN.TOST(alpha = 0.05, targetpower = 0.90,
             theta0 = 0, theta1 = -0.6, theta2 = 0.6, CV = 1.3)
```

## What the trial found

- Week-24 DAS28-CRP change: SB5 −2.22, reference −2.26.
- Difference: +0.04 (95% CI −0.17 to +0.24).
- Both 95% CI bounds well within ±0.6 → equivalence demonstrated on both PP and ITT.
- Approved by EMA (2017) and FDA (2017).

## Caveats & teaching points

- **MCID-based margins.** For continuous endpoints where a MCID is established, using MCID as the margin ties the regulatory test to clinical meaningfulness. DAS28 MCID ≈ 0.6 is well-established.
- **Efficiency of continuous endpoints.** 542 subjects suffice for DAS28 equivalence at ±0.6; a binary ACR20 equivalence at ±15% needs ~600. Continuous endpoints often cheaper when available.
- **ANCOVA recommended.** Analysis should adjust for baseline DAS28 via ANCOVA, reducing effective SD by ~15-20% vs change-score-only analysis. Design assumed this adjustment.

## How this case validates designr

- Continuous-endpoint TOST sizing.
- Agent reasoning about MCID-anchored margins.
- Translation between N and margin for fixed power.
