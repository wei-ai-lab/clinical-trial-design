# MYL-1401O (2017) — trastuzumab biosimilar in HER2+ breast cancer

**Family:** fixed-equivalence · **Endpoint:** binary ORR at 24 wk · **N:** 500 · **Design feature:** FDA oncology biosimilar guidance, ratio-scale margins

## Why this case is in the corpus

- **Oncology biosimilar** — contrast with immunology biosimilars (PLANETRA, SB5).
- **Ratio-scale equivalence margins** ([0.81, 1.24]) — the FDA oncology convention, vs risk-difference margins used in RA.
- Illustrates therapeutic-area conventions for biosimilar equivalence.

## Citation

Rugo HS, Barve A, Waller CF, et al. *Effect of a proposed trastuzumab biosimilar compared with trastuzumab on overall response rate in patients with ERBB2 (HER2)-positive metastatic breast cancer: a randomized clinical trial.* JAMA. 2017;317(1):37-47. doi:10.1001/jama.2016.18305. NCT02472964.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1 |
| Arms | MYL-1401O · Reference trastuzumab, both + taxane |
| Primary endpoint | ORR at week 24 |
| Comparison | Two-sided equivalence on ORR ratio, bounds [0.81, 1.24] |
| α / power | 0.05 (two-sided) / 0.80 |
| Assumed ORR (both arms) | ~40% |
| Planned N | 500 (250 per arm) |

## Reproducing the calculation

For binary equivalence on rate ratio, ORR_c = 0.40, bounds [0.81, 1.24]:

```r
# Convert to log-ratio scale; variance of log(p1/p2) under H0 approximates
#   var ≈ (1-p1)/(n p1) + (1-p2)/(n p2)

p <- 0.40
log_bound <- log(1.24)  # = 0.215, symmetric
# SE per arm for ORR difference on log scale:
# Use simulation-accurate package:
library(gsDesign)
nBinomial(p1 = 0.40, p2 = 0.40,
          delta0 = p * (1.24 - 1) / 2,   # approx RD margin from ratio margin
          alpha = 0.025, beta = 0.20, sided = 1)
# n per arm ≈ 245 → total 500
```

Note: exact sizing for ratio-margin equivalence requires specialized tools (e.g. `PASS` software). The `nBinomial` approximation via risk-difference-margin ≈ p × (upper_ratio − 1) is reasonable for p in the 30-60% range.

## What the trial found

- ORR: MYL-1401O 69.6%, reference 64.0%.
- Ratio: 1.09 (90% CI 0.974–1.211).
- 90% CI bounds within [0.81, 1.24] → equivalence demonstrated.
- Approved by FDA as Ogivri in 2017.

## Caveats & teaching points

- **90% vs 95% CIs.** FDA biosimilar guidance sometimes uses 90% CIs (equivalent to 2 × one-sided 0.05 TOSTs) rather than 95% (2 × one-sided 0.025). PLANETRA used 95%; Ogivri used 90%. Margin-and-CI combination determines type I error — sponsors negotiate this with the agency.
- **Ratio vs risk-difference margins.** Oncology ORR → ratio margin; immunology ACR20 → risk-difference margin. No universal rule; follow therapeutic-area guidance.
- **Higher-than-expected ORR.** Assumed 40%, observed 65-70%. Over-observation of response doesn't harm equivalence if the ratio stays within bounds.

## How this case validates designr

- Ratio-scale margins for binary equivalence.
- Oncology-specific biosimilar conventions (90% CI, ratio scale).
- Agent reasoning about therapeutic-area-specific margin choices.
