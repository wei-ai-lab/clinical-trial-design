# Friede-Kieser (2002) — blinded internal-pilot SSR for continuous endpoint

**Family:** adaptive-ssr · **Endpoint:** continuous · **Design feature:** blinded variance re-estimation preserves α without adaptation burden

## Why this case is in the corpus

- **Blinded SSR is the regulatory-friendly default** — EMA and FDA accept blinded SSR with no α adjustment, provided the trial remains blinded and only nuisance parameters are used.
- The Friede-Kieser approach re-estimates the pooled variance at interim and solves for new N to restore power.
- Foundation for `rpact::getSampleSizeMeans(stDev = "recalculate")` workflows.

## Citation

Friede T, Kieser M. *On the inappropriateness of an EM algorithm based procedure for blinded sample size re-estimation.* Statistics in Medicine. 2002;21(2):165-176. doi:10.1002/sim.977.

Additional: Friede & Kieser. *Sample size recalculation in internal pilot designs: a review.* Biometrical Journal. 2006;48(4):537-555.

## The method

1. At design, assume σ = σ₀, compute N₀ for target power under effect Δ.
2. At internal pilot (typically IF = 0.3–0.5), use **blinded** pooled data to estimate σ̂.
3. Recompute required N:
   ```
   N_new = N₀ · (σ̂ / σ₀)²
   ```
   subject to a pre-specified cap (typically 2× N₀).
4. Continue enrollment to N_new.
5. Analyze with conventional z-test — no α adjustment needed because the treatment assignment was never unblinded.

## Illustrative design

| | |
|---|---|
| Endpoint | Continuous, assumed σ₀ = 10 |
| Assumed Δ | 3 units |
| α / power | 0.05 (two-sided) / 0.80 |
| Planned N | 176 (88 per arm) |
| Internal pilot | IF = 0.5 (88 subjects) |
| SSR rule | Recompute N_new = 176 · (σ̂/10)², cap at 352 |
| Test | Standard two-sample t-test at end |

## Reproducing the design

```r
library(rpact)
# Design
ss <- getSampleSizeMeans(
  alternative = 3,
  stDev       = 10,
  alpha       = 0.025,
  beta        = 0.20,
  groups      = 2
)
# Blinded SSR: at interim, compute pooled variance and scale N
# (rpact::getDataSet + getStageResults with blinded SSR workflow)
```

## What the method guarantees

- **α ≤ 0.05 (no inflation)** — blinded variance estimation does not introduce bias in the z-statistic.
- **Power restoration** — if true σ > assumed σ₀, trial is still powered; if σ < σ₀, N_new reduces (cost saving).

## Caveats & teaching points

- **Blinded ≠ unbiased under NPH or treatment-group heterogeneity.** If arms have different variances (e.g., control stable, treatment variable), pooled σ̂ is a mixture that biases the SSR toward overestimating required N. This edge case is rare but documented.
- **Binary endpoint blinded SSR** (Gao-Liu-Mehta 2008) has subtler α control — pooled event rate carries treatment-effect information. See 2012_Gao-Liu-Mehta case.
- **Regulators prefer blinded SSR** over unblinded when feasible — less governance burden, no DSMB unblinding, no α adjustment.

## How this case validates designr

- Reference for when blinded SSR is the preferred recommendation (continuous, σ uncertain).
- Benchmark for correct implementation in rpact.
- Contrast point with the Gao-Liu-Mehta binary-endpoint case.
