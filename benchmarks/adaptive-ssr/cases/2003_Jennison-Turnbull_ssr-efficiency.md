# Jennison-Turnbull (2003/2006) — SSR Efficiency Critique

**Family:** adaptive-ssr · **Kind:** methodology-paper · **Scope:** canonical critique showing non-adaptive GS often dominates SSR in efficiency

## Why this case is in the corpus

- **Canonical methodological critique** of unblinded effect-based SSR — two of the most-cited papers in the adaptive-design literature, authored by the writers of the definitive GS textbook.
- Argues optimally-designed non-adaptive GS match or exceed CHW-weighted SSR in expected-N across the plausible effect range.
- Motivated the shift toward blinded SSR (Friede-Kieser 2002, in corpus) and promising-zone SSR (Mehta-Pocock 2011, in corpus).
- Required methodological counterpoint to the other five adaptive-ssr cases.

## Citation

- Jennison C, Turnbull BW. *Mid-course sample size modification in clinical trials based on the observed treatment effect.* Stat Med. 2003 Mar 30;22(6):971-93.
- Jennison C, Turnbull BW. *Adaptive and nonadaptive group sequential tests.* Biometrika. 2006;93(1):1-21.

## Core argument

| Approach | Expected N | Max N | Type I | Complexity |
|---|---|---|---|---|
| Optimal non-adaptive GS (Pampallona-Tsiatis, ρ-family, power-family) | Low | Fixed | α | Low |
| CHW-weighted SSR | Medium-Low | Flexible | α (pre-set weights) | Medium |
| Proschan-Hunsberger CP-SSR | Low | Flexible | α (adj. boundary) | High |
| Blinded SSR | Low-Medium | Flexible (modest) | α | Low |

## Efficiency argument

```r
# Benchmark: optimal non-adaptive GS vs CHW-SSR
library(gsDesign)
library(rpact)

# (1) Optimal non-adaptive 4-look GS with power-family boundaries
gs_opt <- gsDesign(
  k = 4, test.type = 1, alpha = 0.025, beta = 0.1,
  sfu = sfPower, sfupar = 3
)
# expected N under delta = 0.3: ~ 120 * info-weighted
cat("Expected N non-adaptive GS:", sum(gs_opt$en)/gs_opt$n.I[4], "\n")

# (2) CHW-SSR with pre-specified weights
design_chw <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.1, sided = 1,
  typeOfDesign = "WT"     # Wang-Tsiatis-style
)
sim_chw <- getSampleSizeMeans(
  design_chw, alternative = 0.3, stDev = 1,
  allocationRatioPlanned = 1
)
# Typically CHW-SSR has 5-10% higher expected N vs optimal non-adaptive GS
```

## Empirical findings from the papers

- Under ρ-family boundaries, a 4-look GS has expected N within 2-4% of the theoretically optimal test.
- CHW-SSR with the same max N has expected N 5-10% higher than this optimal, due to weighted-statistic power loss.
- Proschan-Hunsberger CP-SSR reaches optimal expected N but requires the boundary adjustment (less familiar to reviewers).
- Blinded SSR has nearly the same efficiency as non-adaptive GS plus flexibility for nuisance-parameter uncertainty — best of both worlds.

## Impact

- FDA 2019 Adaptive Designs guidance reflects these findings — blinded SSR widely acceptable, unblinded SSR acceptable with good pre-specification but not preferred for efficiency.
- Industry norm shifted: blinded SSR on event rate or variance is default; unblinded effect-based SSR reserved for promising-zone (Mehta-Pocock) or CP-based designs.
- Motivated information-based designs that stop at fixed information rather than fixed N.

## How this case validates designr

- Adds the **methodological counterpoint** to the corpus — users exploring SSR should know the critique and understand when non-adaptive GS is preferable.
- `designr` should be able to side-by-side compare expected-N across GS, CHW-SSR, CP-SSR, and blinded SSR for the same design problem (the Jennison-Turnbull comparison table).
- Key teaching case: sample-size *re-estimation* is not a free lunch; use it only when the specific decision context justifies its complexity.
