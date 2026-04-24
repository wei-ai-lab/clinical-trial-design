# Mehta-Pocock (2011) — promising-zone SSR operational framework

**Family:** adaptive-ssr · **Endpoint:** TTE or continuous · **Design feature:** modern canonical SSR for under-powered Phase 3 rescue

## Why this case is in the corpus

- **Current modern default** for unblinded SSR in Phase 3. Cited as preferred approach in FDA Adaptive Designs Guidance (2019).
- Generalizes Chen-DeMets-Lan with **practical operational guidance** on choosing the promising-zone boundary, N cap, and target conditional power.
- Published with a fully worked Phase 3 cardiology illustration (adjudicated MACE endpoint).

## Citation

Mehta CR, Pocock SJ. *Adaptive increase in sample size when interim results are promising: a practical guide with examples.* Statistics in Medicine. 2011;30(28):3267-3284. doi:10.1002/sim.4102.

## The framework

Define three zones based on conditional power CP(ẑ₁) at interim:

| Zone | CP range | Action |
|---|---|---|
| **Unfavorable** | CP < 0.30 | Stop for futility (or continue unchanged) |
| **Promising** | 0.30 ≤ CP < 0.80 | **Increase N** — target CP* = 0.80, subject to cap |
| **Favorable** | CP ≥ 0.80 | Continue at planned N |

Use CHW weighted statistic at final to preserve α exactly. Alternatively, if staying within the promising-zone bounds that CDL identified, use conventional z (same α control).

## Worked Phase 3 example (from paper)

| | |
|---|---|
| Setting | Phase 3 CV, endpoint = MACE |
| α / power | 0.025 (one-sided) / 0.90 |
| Assumed HR | 0.75 |
| Control MACE rate | 10% at 2 years |
| Planned events | 442 |
| Planned N | 2,400 |
| Interim | IF = 0.50 (221 events) |
| Promising zone | CP ∈ [0.365, 0.80) |
| N cap | 3,500 (1.46× increase) |
| Target CP* | 0.80 |

## Reproducing the design

```r
library(rpact)
d <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.10,
  typeOfDesign = "OF"
)
ss <- getSampleSizeSurvival(
  design = d,
  hazardRatio = 0.75,
  lambda2 = -log(0.9)/24,   # MACE 10% at 24 mo under control
  accrualTime = 18, followUpTime = 24
)
# Events ≈ 442, N ≈ 2400

# At interim, use getAnalysisResults with observed data to compute
# conditional power and determine new event target if in promising zone
```

## Why this is the modern standard

- **Operational clarity:** pre-specifiable zone thresholds, cap, and target CP — easy to embed in a SAP.
- **Interpretable rescue:** increasing N *only when* it's likely to help (promising zone) and not when the effect looks weak (futility) or already strong (success assured).
- **Regulator acceptance:** Type-I error is preserved via CHW weights; no contested adjustments.
- **Economic efficiency:** avoids overpowering when effect is as-assumed, avoids wasting money when effect is weak.

## Caveats & teaching points

- **Promising-zone boundaries are sponsor choices** — different CP_L and CP_U values yield different operating characteristics. Simulate before committing in SAP.
- **N cap is strategic** — too low and SSR cannot rescue the trial; too high and cost escalates. Typical 1.5–2×.
- **Early-phase similar trials** should inform the zone — if Phase 2 was strong, narrow PZ; if Phase 2 was weak but mechanism plausible, wide PZ.

## How this case validates designr

- Benchmark for the modern canonical SSR workflow.
- Reference for `rpact::getDesignInverseNormal` + CHW SSR pipeline.
- Teaching case for zone-based SSR reasoning the agent must recommend.
