# PATENT-1 (2013) — riociguat for PAH

**Family:** fixed-superiority · **Endpoint:** continuous (change in 6MWD) · **N:** 443 (2:1:1)

## Why this case is in the corpus

- Canonical **fixed-sample, continuous-endpoint** Phase 3 in a rare disease.
- Uses **ANCOVA with baseline as covariate** — the most common analytical refinement in change-from-baseline designs, and a frequent source of discrepancy between textbook power calculations and real protocols.
- Directly relevant to pulmonary vascular disease design work (sibling to the PH-ILD indication family).

## Citation

Ghofrani HA, Galiè N, Grimminger F, et al. *Riociguat for the treatment of pulmonary arterial hypertension.* N Engl J Med. 2013;369(4):330-340. doi:10.1056/NEJMoa1209655. NCT00810693.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Randomized, double-blind, placebo-controlled, parallel-group |
| Indication | Symptomatic PAH (WHO FC II-III), treatment-naive or on ERA/prostanoid |
| Arms | Riociguat titrated to ≤2.5 mg tid · Placebo · Riociguat capped at 1.5 mg tid |
| Allocation | 2 : 1 : 1 |
| Primary endpoint | Change from baseline in 6-minute walk distance at 12 weeks |
| Primary comparison | High-dose riociguat vs placebo |
| Analysis | ANCOVA with baseline 6MWD as covariate; missing data: LOCF with death/transplant ranked lowest |
| α / power | 0.05 (two-sided) / 0.9 |
| Assumed Δ | 30 m |
| Assumed SD | 70 m |

## Reported sample size

**Total N = 443** across three arms (254 high-dose riociguat, 126 placebo, 63 low-dose-capped riociguat). The primary analysis was high-dose vs placebo.

## Reproducing the calculation

A pure two-sample t-test with Δ = 30, SD = 70, α = 0.05 two-sided, power = 0.90:

```r
power.t.test(delta = 30, sd = 70, sig.level = 0.05, power = 0.90)
# n per arm ≈ 115
```

That gives 115 per arm → 230 for a pure 1:1 comparison. The trial used a 2:1 allocation (high-dose:placebo), which preserves effective information if the per-placebo N is set so that the limiting arm still has ≥ 115 — i.e. placebo = 126 ≈ 115 rounded up. The 254 high-dose is ~2× placebo (maintaining 2:1 allocation).

The low-dose-capped arm (63 subjects) was not part of the primary efficacy comparison; it supported the dose-response characterization.

## What the trial found

Observed least-squares mean treatment effect for high-dose riociguat vs placebo: **+36 m** (95% CI 20–52), p<0.001 — slightly larger than the 30 m powered-for assumption, consistent with modest over-powering in practice.

## Caveats & teaching points

- **ANCOVA adjustment.** The powered-for effective SD is lower than the raw-measurement SD because ANCOVA removes baseline variance. A benchmark check that compares the designed sample size against a raw two-sample power calc will match only approximately; a check that respects the ANCOVA adjustment (using SD × √(1−ρ²) where ρ ≈ 0.5) will match tighter.
- **Unequal allocation.** If your power calculation assumes 1:1, you'll get the per-arm number; the actual total N depends on the allocation ratio.
- **Rare-disease context.** The trial deliberately enrolled more than the minimum to support dose-response characterization. The "powered-for" minimum is ~230; the enrolled 443 reflects program-level objectives beyond the primary hypothesis.

## How this case validates designr

- Tests `designr`'s continuous-endpoint fixed-sample calculation with **unequal allocation** and **ANCOVA correction**.
- Tests the agent's ability to explain *why* the real N exceeds the bare-minimum calculation.
