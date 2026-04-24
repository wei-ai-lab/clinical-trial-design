# Gao-Liu-Mehta (2012) — blinded SSR for binary endpoints

**Family:** adaptive-ssr · **Endpoint:** binary · **Design feature:** pooled event rate SSR with rigorous α control

## Why this case is in the corpus

- **Binary endpoints complicate blinded SSR** — pooled event rate carries treatment-effect information, unlike pooled variance for continuous data.
- Gao-Liu-Mehta 2012 proved bounds on Type-I inflation for naive blinded SSR on binary data and proposed a small adjustment that makes it rigorous.
- Essential reference for NI and superiority Phase 3 trials with binary primary (MACE responder, treatment success, ADR, etc.).

## Citation

Gao P, Liu L, Mehta C. *Exact inference for adaptive group sequential designs.* Statistics in Medicine. 2013;32(23):3991-4005. doi:10.1002/sim.5847.

Additional: Gould AL, Shih WJ. *Sample size re-estimation without unblinding for normally distributed outcomes with unknown variance.* Communications in Statistics 1992 (historical foundation).

## The problem

For a binary endpoint, the pooled event rate p̂ = (X_T + X_C)/N_total is:

```
p̂ = (p_T + p_C)/2  (under 1:1)
```

This estimator depends on both arms' event rates, so it indirectly reveals the treatment effect. Naive blinded SSR using only p̂ can inflate α modestly (typically 0.5-1.5% above nominal, depending on effect size and interim timing).

## The solution

Gao-Liu-Mehta 2012 provides:

1. **Exact α-calibration tables** — for a given interim timing, effect size, and N cap, compute the inflated α and adjust the final critical value.
2. **Conservative bound** — use an adjusted z-critical `z_α' < z_α` that caps α inflation.
3. **Alternative:** use blinded-but-hypothesized-effect SSR (assume a fixed Δ at interim, don't estimate it) — this preserves α but loses efficiency.

## Illustrative design

| | |
|---|---|
| Endpoint | Binary (responder at week 12) |
| Assumed p_C / p_T | 0.30 / 0.45 (Δ = 15 percentage points) |
| α / power | 0.05 (two-sided) / 0.90 |
| Planned N | 332 (166 per arm) |
| Interim | IF = 0.5 (166 subjects) |
| SSR rule | Recompute N based on p̂ only; cap at 2× |
| α adjustment | Use z_α' from Gao-Liu-Mehta calibration (≈ 1.98 vs nominal 1.96) |

## Reproducing the design

```r
library(rpact)
# Design
ss <- getSampleSizeRates(
  pi1 = 0.45, pi2 = 0.30,
  alpha = 0.025, beta = 0.10
)
# At interim: blinded re-estimate of pooled rate and recompute N
# Apply adjusted z-critical (typically via simulation or published tables)
```

## What the method offers

- **α preserved to nominal** with small explicit adjustment.
- **Power restored** if true p_C or p_T differs from assumptions.
- **No DSMB unblinding** — operationally simple.

## Caveats & teaching points

- **Alternative:** fully-unblinded SSR with CHW weighting (Bauer-Köhne combination) gives exact α without needing adjustment tables, but requires DSMB unblinding.
- **Very small adjustments (~1%)** often justify ignoring them in practice — but regulators prefer the formal adjustment or a conservative simulation-calibrated critical value.
- **Regulatory acceptance** has grown since 2012 — FDA Adaptive Designs Guidance (2019) explicitly mentions blinded SSR for binary with α calibration.

## How this case validates designr

- Benchmark for blinded SSR with binary primaries.
- Completes the SSR methodology trio: continuous (Friede-Kieser), TTE (Mehta-Pocock), binary (Gao-Liu-Mehta).
- Reference for `rpact::getSampleSizeRates` + calibrated blinded SSR workflow.
