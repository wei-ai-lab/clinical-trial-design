# OASIS-5 (2006) — fondaparinux vs enoxaparin in NSTE-ACS

**Family:** fixed-non-inferiority · **Endpoint:** binary 9-day composite · **N:** 20,000 · **Design feature:** relative margin on binary endpoint, short follow-up

## Why this case is in the corpus

- **Binary NI with relative (multiplicative) margin** — less common than additive-margin binary NI; a closer analog to HR-margin TTE.
- **Short-term endpoint** (9 days) — contrast with long-follow-up TTE NI.
- Pure fixed-design NI without GS structure.

## Citation

The Fifth Organization to Assess Strategies in Acute Ischemic Syndromes Investigators. *Comparison of fondaparinux and enoxaparin in acute coronary syndromes.* N Engl J Med. 2006;354(14):1464-1476. doi:10.1056/NEJMoa055443. NCT00139815.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1 |
| Arms | Fondaparinux · Enoxaparin |
| Primary endpoint | 9-day composite: death + MI + refractory ischemia |
| Comparison | Non-inferiority, relative margin 1.185 (upper bound on rate ratio) |
| α / power | 0.025 (one-sided) / 0.90 |
| Assumed event rate (both arms) | 4.5% |
| Planned N | 20,000 |

## Reproducing the calculation

For binary NI with relative margin on rate ratio:

```r
# Approximation: log rate ratio with variance 2/(np) under HR≈1, p≈0.045
#   N per arm ≈ (z_{α} + z_β)² × 2/(p × (log 1.185)²)
z_alpha <- qnorm(0.975)
z_beta  <- qnorm(0.90)
p       <- 0.045
log_m   <- log(1.185)
n_arm   <- (z_alpha + z_beta)^2 * 2 / (p * log_m^2)
round(n_arm)
# n per arm ≈ 9,500 → total 19,000

# gsDesign binary NI (additive equivalent):
library(gsDesign)
nBinomial(p1 = 0.045, p2 = 0.045, delta0 = 0.045 * 0.185,
          alpha = 0.025, beta = 0.10, sided = 1)
```

## What the trial found

- 9-day composite: fondaparinux 5.8%, enoxaparin 5.7%.
- Rate ratio = 1.01 (95% CI 0.90–1.13); NI met comfortably.
- Major bleeding at 9 days: fondaparinux 2.2%, enoxaparin 4.1% — dramatic superiority on bleeding.
- Net clinical benefit favored fondaparinux.

## Caveats & teaching points

- **Relative vs absolute NI margins.** Relative (multiplicative) margins preserve interpretability as event rates change. Absolute margins are tighter when rates are low, looser when rates are high — the opposite of what you'd usually want.
- **Binary endpoint sample-size formulas are approximations.** Normal approximation to log rate ratio is decent for moderate event rates; better approaches (Farrington-Manning, Miettinen-Nurminen) are in `gsDesign::nBinomial`.
- **Short-term endpoints accumulate fast.** 9-day endpoints make enrollment rate the binding constraint, not follow-up time.

## How this case validates designr

- Binary NI with relative margin — an option the agent should distinguish from absolute margin.
- Large N driven by low event rate.
- Exercises the agent's awareness of Farrington-Manning-style corrections in `nBinomial`.
