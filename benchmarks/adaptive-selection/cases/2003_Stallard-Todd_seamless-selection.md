# Stallard-Todd (2003) — seamless Phase II/III with treatment selection in GS framework

**Family:** adaptive-selection · **Endpoint:** any · **Design feature:** group-sequential framework with interim selection + futility + efficacy stopping

## Why this case is in the corpus

- **Seamless Phase II/III** — same trial learns the best arm (Phase 2) and confirms it (Phase 3), with Phase 2 data contributing to the final test.
- **GS boundaries** extended to multi-arm: efficacy, futility, and selection decisions all happen at pre-specified information fractions.
- Widely cited as the practical template for modern multi-arm Phase 3.

## Citation

Stallard N, Todd S. *Sequential designs for phase III clinical trials incorporating treatment selection.* Statistics in Medicine. 2003;22(5):689-703. doi:10.1002/sim.1362.

## The design

1. **Stage 1** — all K experimental arms vs control, randomized equally, observed over information fraction up to pre-specified interim.
2. **Interim analysis** at IF = t₁:
   - Compute pairwise z-statistics Z_k vs control for each arm.
   - **Efficacy stopping**: if max Z_k > upper boundary u₁ AND the selected arm is clearly separated from others, stop with that arm.
   - **Futility stopping**: if max Z_k < lower boundary l₁, stop all arms.
   - **Selection**: drop all but the best-performing arm; continue to stage 2.
3. **Stage 2** — continue selected arm vs control; possibly with SSR.
4. **Final analysis** — combine stage-1 + stage-2 data for the selected arm via weighted z statistic; compare to final boundary u_∞.

## Illustrative Phase 3 design

| | |
|---|---|
| Endpoint | TTE OS |
| K arms | 3 experimental + 1 control |
| Assumed HR (each exp arm) | 0.70 |
| α / power | 0.025 (one-sided) / 0.85 |
| Planned total events | 420 |
| Interim | IF = 0.4 (168 events) |
| Efficacy boundary (stage 1) | u₁ = 2.5 |
| Futility boundary (stage 1) | l₁ = 0.5 |
| Selection rule | drop 2 losers at IF = 0.4 |

## Reproducing the design

```r
library(asd)
# Stallard-Todd combined design
# asd supports multi-arm + selection + GS
ts <- treatsel.sim(
  n1 = 100, n2 = 200, K = 3,
  theta = c(0.3, 0.3, 0.3),   # effect size per arm
  theta0 = 0, alpha = 0.025,
  select = "best"
)
```

Or via rpact:

```r
library(rpact)
d <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.15,
  typeOfDesign = "OF"
)
# Multi-arm stage 1 with arm selection; combine via inverse-normal
```

## What the method offers

- **GS structure** — familiar boundaries for efficacy and futility, pre-specified and reproducible.
- **Selection** — drops weaker arms, reduces stage-2 cost.
- **α control** — inverse-normal combination preserves α strong-FWER across K arms.

## Caveats & teaching points

- **Pre-specified boundaries + selection rule** are both required. Post-hoc "pick the best at interim, apply conventional z" inflates α.
- **Selection rule flexibility.** Stallard-Todd covers "pick best one" but generalizations (pick top-two, pick any with z > threshold) need additional FWER accounting.
- **Correlated arm outcomes** (e.g., arms share mechanism) weaken selection power — observed differences are noisier than i.i.d. assumption.

## How this case validates designr

- Seamless Phase II/III methodology benchmark.
- GS + selection integration.
- Template for MAMS-style designs (see adjacent mams family).
