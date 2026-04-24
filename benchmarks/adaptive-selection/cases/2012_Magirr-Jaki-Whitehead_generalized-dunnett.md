# Magirr-Jaki-Whitehead (2012) — generalized Dunnett for MAMS with treatment selection

**Family:** adaptive-selection · **Endpoint:** any · **Design feature:** exact critical values accounting for correlation in shared-control multi-arm GS + selection

## Why this case is in the corpus

- **Efficient α control** via Dunnett-style exact critical values that exploit the correlation induced by shared control arm — more powerful than Bonferroni or naive combination test.
- Implemented in the widely-used `MAMS` R package (Magirr et al.), which is a standard tool for multi-arm multi-stage trial design.
- Connects adaptive-selection to the MAMS family: same math, different emphasis on which arms continue.

## Citation

Magirr D, Jaki T, Whitehead J. *A generalized Dunnett test for multi-arm multi-stage clinical studies with treatment selection.* Biometrika. 2012;99(2):494-501. doi:10.1093/biomet/ass002.

## The method

Consider K experimental arms vs shared control with J-stage GS:

1. **At stage j**, compute z-statistics Z₁^(j), ..., Z_K^(j) for each arm vs control.
2. **Pre-specified critical values** u₁, ..., u_J are computed from a multivariate normal distribution accounting for:
   - Correlation between Z_k^(j) across arms k (shared control induces positive correlation).
   - Correlation between Z_k^(j) across stages j (accumulated data).
3. **Decisions**:
   - If any Z_k^(j) > u_j → reject H_k (efficacy).
   - If all Z_k^(j) < l_j → stop for futility.
   - Otherwise drop arms below a pre-specified "drop boundary" d_j (selection).
4. **Final analysis** — test retained arms at final boundary u_J with exact FWER ≤ α.

## Illustrative Phase 3 design

| | |
|---|---|
| Endpoint | TTE OS |
| K arms | 3 experimental + 1 control |
| Stages | J = 3 (2 interim + final) |
| α / power | 0.025 (one-sided) / 0.90 |
| Information fractions | 0.33, 0.67, 1.0 |
| Critical values | u₁ = 3.5, u₂ = 2.9, u₃ = 2.2 (from MAMS package) |
| Drop rule | Drop any arm with z < 0 at each stage |
| Target events (total) | 600 (across all arms) |

## Reproducing the design

```r
library(MAMS)
d <- mams(
  K = 3, J = 3, r = c(1, 2, 3), r0 = c(1, 2, 3),
  alpha = 0.025, power = 0.90,
  p = 0.65, p0 = 0.50,   # or HR parameterization
  ushape = "obf", lshape = "obf",
  nstart = 50
)
# $u gives upper critical values, $l gives lower (futility)
```

For TTE:

```r
library(MAMS)
# For time-to-event, parameterize via expected log-HR
d_tte <- mams.sim(
  K = 3, J = 3, ...
)
```

## What the method offers

- **Efficiency** — exact Dunnett-adjusted critical values are less conservative than Bonferroni-style bounds.
- **Selection integrated** — arms can be dropped without additional α adjustment, because critical values are designed for the worst-case retention pattern.
- **MAMS package implementation** — well-documented, maintained, and widely used for regulatory submissions.

## Caveats & teaching points

- **Correlation assumption.** Generalized Dunnett relies on the multivariate normal correlation structure of z-statistics. For log-HR with censored data, this is approximate; simulation should confirm operating characteristics.
- **"Drop" vs "stop"**. Magirr-Jaki-Whitehead distinguishes between dropping an individual arm (continue trial) vs stopping entire trial for futility. Both are pre-specified via boundaries l_j and d_j.
- **Not all selection rules are supported.** The design assumes "drop arms below threshold"; data-driven rules like "pick top-K" need custom simulation.

## How this case validates designr

- Modern, efficient benchmark for multi-arm selection Phase 3.
- Direct mapping to `MAMS` R package.
- Bridge case between adaptive-selection and mams families.
