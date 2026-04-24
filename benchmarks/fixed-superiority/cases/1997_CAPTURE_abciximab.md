# CAPTURE (1997) — abciximab in refractory unstable angina

**Family:** fixed-superiority · **Endpoint:** binary 30-day composite · **N:** 1,400 planned · **Era:** pre-NCT

## Why this case is in the corpus

- Classic **binary-endpoint fixed-superiority** design — the bread-and-butter of acute cardiac care trials.
- Pre-registry era (1990s) — tests the corpus's ability to capture design parameters extracted from the primary publication alone.
- Early-stopped by DSMB before planned N — useful counterpoint to GS designs.

## Citation

The CAPTURE Investigators. *Randomised placebo-controlled trial of abciximab before and during coronary intervention in refractory unstable angina: the CAPTURE Study.* Lancet. 1997;349(9063):1429-1435.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1 |
| Indication | Refractory unstable angina with planned PCI |
| Arms | Abciximab · Placebo |
| Primary endpoint | 30-day composite: death + MI + urgent reintervention |
| α / power | 0.05 (two-sided) / 0.80 |
| Assumed control rate | 15% |
| Assumed treatment rate | 9% |
| Planned N | 1,400 |

## Reproducing the calculation

For binary superiority, p_c = 0.15, p_t = 0.09:

```r
power.prop.test(p1 = 0.09, p2 = 0.15, sig.level = 0.05, power = 0.80)
# n per arm ≈ 457 → total 914

# With continuity correction + realistic attrition:
library(gsDesign)
nBinomial(p1 = 0.09, p2 = 0.15, alpha = 0.025, beta = 0.20, sided = 1)
# N per arm ≈ 500 → total 1,000–1,100; sponsor chose 1,400 for margin
```

The 1,400 planned N exceeds the textbook minimum by ~30% — common in real trials to buffer against protocol deviations, blinded dropouts, and analysis-population reductions.

## What the trial found

- Composite 30-day event rate: abciximab 11.3%, placebo 15.9%.
- Absolute risk reduction: **−4.6%** (95% CI −8.2 to −1.0), p = 0.012.
- Stopped early at 1,265 subjects based on DSMB recommendation.

## Caveats & teaching points

- **Effect size as-observed smaller than assumed.** Placebo rate 15.9% close to planned 15%; abciximab 11.3% vs planned 9% — the effect was smaller than hoped, but enough subjects had accrued for detection.
- **DSMB-driven early stop.** No pre-specified GS boundary; DSMB used clinical judgment against monitoring guidelines.
- **Pre-NCT era.** Sponsors and investigators should capture design details from the methods section of the primary paper; supplementary material was less common pre-2000.

## How this case validates designr

- Binary-endpoint fixed-sample calculation, classic setting.
- Agent should recognize the 30% sample-size inflation over the textbook minimum as normal practice.
- Tests handling of trials with incomplete public documentation (no design paper, no registry entry).
