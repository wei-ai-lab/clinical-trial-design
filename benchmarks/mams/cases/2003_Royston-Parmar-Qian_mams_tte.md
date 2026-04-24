# Royston-Parmar-Qian (2003) — MAMS methodology for time-to-event endpoints

**Family:** mams · **Kind:** methodology-canonical · **Scope:** TTE MAMS framework; STAMPEDE backbone

## Why this case is in the corpus

- **Foundation paper for TTE MAMS** — direct basis for STAMPEDE (2011-, in corpus).
- Establishes intermediate-endpoint-guided futility dropping as core MAMS feature.
- Codifies per-arm type-I control + shared-control efficiency argument.
- Reference for subsequent methodology (Wason-Jaki 2012, Bratton-Phillips-Parmar 2013, Magirr-Jaki-Whitehead 2012).

## Citation

Royston P, Parmar MK, Qian W. *Novel designs for multi-arm clinical trials with survival outcomes with an application in ovarian cancer.* Stat Med. 2003;22(14):2239-2256. doi:10.1002/sim.1430.

## Framework summary

| Element | Mechanism |
|---|---|
| **Shared control** | All experimental arms compared to one common control; ~25-40% N savings vs separate bilateral trials |
| **Intermediate endpoint** | E.g., PFS, used to drop arms at interim stage |
| **Final endpoint** | E.g., OS, tested only on arms surviving intermediate |
| **Per-arm α** | 0.025 (not FWER-adjusted; each arm = separate confirmatory question) |
| **Futility threshold** | Observed HR on intermediate > 1.0 (or similar) → drop |
| **Stages** | Typically 2-3; could be more |

## Reproducing the framework

```r
library(gsDesign)
# Per-arm event-driven sizing (for final endpoint test)
ss <- nSurv(
  lambdaC = -log(1 - 0.50) / 5,    # 50% 5-year OS in control
  hr = 0.75,
  alpha = 0.025, beta = 0.20,
  R = 60, minfup = 36, sided = 1
)

# Intermediate-stage futility: conditional power / predictive power
library(rpact)
# Drop arm at intermediate stage if:
#   observed intermediate HR > 1.0, OR
#   predictive probability of eventual OS benefit < 0.20

# MAMS with shared control (R package)
library(MAMS)
m <- mams(
  K = 3,             # 3 experimental arms
  J = 2,             # 2 stages
  alpha = 0.025,
  power = 0.80,
  r = c(1, 1, 1, 1),     # allocation weights
  r0 = c(1, 1),          # control allocation per stage
  u = 2.7, l = 0.0,      # efficacy / futility boundaries
  ushape = "obf", lshape = "obf",
  p0 = 0.5, p = 0.65,
  delta = log(1/0.75)
)
```

## Efficiency argument — shared control

For 3 experimental arms vs common control (vs 3 separate 2-arm trials):
- **Separate trials**: 6 × n/2 = 3n total.
- **MAMS with shared control**: 3 × n experimental + 1 × n control (amortized) ≈ 4n/3 × n total.
- **Savings**: ~25-40% depending on allocation ratio and # arms.

## How this case validates designr

- Canonical reference for MAMS sample sizing.
- Intermediate-endpoint-guided futility dropping.
- Shared-control efficiency benchmark.
- Theoretical foundation for STAMPEDE (real trial), FOCUS4, ROMA, RECOVERY in the corpus.
- Enables `designr` to expose MAMS via gsDesign / rpact / MAMS backends with shared-control and intermediate-endpoint features.
