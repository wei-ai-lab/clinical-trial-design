# Wason-Jaki (2012) — Optimal MAMS designs with tabulated boundaries

**Family:** mams · **Kind:** methodology-canonical · **Scope:** optimal boundary parameters, FWER control, ESS minimization

## Why this case is in the corpus

- **Canonical paper on optimal MAMS design parameters** for K × J configurations.
- Basis for the R `MAMS` package — Jaki's reference implementation.
- Establishes strong FWER control for multi-dose regulatory settings.
- Defines ESS minimization criteria (ESS under H0, H1, LFC).

## Citation

Wason JMS, Jaki T. *Optimal design of multi-arm multi-stage trials.* Stat Med. 2012;31(30):4269-4279. doi:10.1002/sim.5513.

## Framework summary

| | |
|---|---|
| K × J range | 2-6 experimental arms × 2-4 stages |
| Boundary families | OBF, Pocock, triangular |
| Control policy | Per-arm OR strong FWER — sponsor choice |
| Optimality | ESS_H0, ESS_H1, minimax |
| Operating chars | Power per pair, ESS, FWER, prob. drop active arm |

## Reproducing the framework

```r
library(MAMS)

# Design a 3-arm, 2-stage MAMS with shared control, continuous endpoint
design <- mams(
  K = 3,                         # 3 experimental arms
  J = 2,                         # 2 stages
  alpha = 0.025,
  power = 0.80,
  r = c(1, 2),                   # allocation weights (stage 1, stage 2)
  r0 = c(1, 2),                  # control allocation (stage 1, stage 2)
  p = 0.65, p0 = 0.50,           # effect size as response rate (binary)
  delta = NULL, delta0 = NULL,
  ushape = "obf", lshape = "obf",
  sample.size = TRUE
)
print(design)      # Expected sample sizes + boundaries

# Simulation-based operating characteristics
sim <- mams.sim(
  design = design,
  nsim = 10000,
  nMat = rbind(c(25, 25, 25, 25), c(50, 50, 50, 50)),
  u = design$u, l = design$l
)
```

## Key results tabulated

- **Pre-computed optimal boundaries** indexed by K, J, α, power.
- **ESS savings vs fixed design**: 20-35% under alternative.
- **Probability of dropping the best arm**: < 5% for well-designed MAMS.
- **FWER** ≤ nominal under strong control across all LFC configurations.

## Operating characteristics table (abridged example)

| K | J | Boundary | α | Power | N_max | ESS_H0 | ESS_H1 |
|---|---|---|---|---|---|---|---|
| 3 | 2 | OBF | 0.025 | 0.80 | 400 | 280 | 320 |
| 3 | 3 | OBF | 0.025 | 0.80 | 400 | 240 | 300 |
| 4 | 2 | Pocock | 0.025 | 0.80 | 500 | 340 | 380 |

## How this case validates designr

- Tabulated optimal boundaries for direct implementation.
- R package `MAMS` enables `designr` to expose ESS-optimal MAMS designs.
- Theoretical FWER vs per-arm policy comparison.
- Bridges Royston-Parmar-Qian 2003 (TTE MAMS basis) to modern `MAMS` package (reference implementation).
- Enables cross-check of MAMS operating characteristics against pre-computed standards.
