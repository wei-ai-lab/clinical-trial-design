# Thall-Simon-Ellenberg (1988) — two-stage drop-the-loser design

**Family:** adaptive-selection · **Endpoint:** binary or continuous · **Design feature:** foundational two-stage selection of one-from-K experimental arms

## Why this case is in the corpus

- **Foundational methodology** — the first widely-cited design for choosing among multiple experimental arms and a control in a single trial.
- Core idea: stage 1 selects the "best" experimental arm by observed response; stage 2 tests that arm against control with pre-specified α.
- Precursor to Stallard-Todd (2003) and modern combination-test frameworks.

## Citation

Thall PF, Simon R, Ellenberg SS. *A two-stage design for choosing among several experimental treatments and a control in clinical trials.* Biometrics. 1988;44(2):537-547.

## The design

1. **Stage 1** — randomize equal n₁ subjects to each of K experimental arms + 1 control.
2. **Selection** — at end of stage 1, identify the experimental arm with the largest observed response (or smallest event rate, etc.).
3. **Stage 2** — randomize additional subjects to the selected arm vs control (typically in 1:1 ratio).
4. **Final test** — compute z-statistic from combined stage-1 + stage-2 data for selected arm vs control; compare to pre-specified critical value z_c adjusted for the K-arm selection process.

**α control**: the critical value z_c is inflated above the naive value to account for the selection bias. Published tables (Thall-Simon-Ellenberg 1988) give z_c for K = 2, 3, 4, 5 and various stage ratios.

## Illustrative Phase 3 design

| | |
|---|---|
| Endpoint | Binary responder |
| Assumed p_control | 0.30 |
| Assumed p_best | 0.45 |
| K (experimental arms) | 3 |
| α / power | 0.05 (two-sided) / 0.85 |
| Stage 1 n | 50 per arm (200 total) |
| Stage 2 n | 100 per selected arm + control (200 total) |
| Total N | 400 |
| Critical value z_c | 2.14 (vs naive 1.96) |

## Reproducing the design

```r
library(asd)
# Thall-Simon-Ellenberg style implementation
# asd::treatsel.sim supports selection of best experimental arm vs control
```

Or via first principles using rpact:

```r
library(rpact)
d <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.15,
  typeOfDesign = "OF"
)
# Multi-arm stage 1; use combination test at final
```

## What the method guarantees

- **α control** at pre-specified level via Bonferroni-style adjusted critical value.
- **Power** against the alternative that the best arm has effect p_best — not against the alternative that any arm has effect (which is a different question).

## Caveats & teaching points

- **Conservative α adjustment.** Bonferroni-style correction overspends α when arms are correlated (share control). Modern approaches (Dunnett, combination test) are more efficient.
- **Selection rule rigidity.** The design assumes naive "pick the best observed" — but at low n₁, observed-best is a noisy estimate. Methodology extensions include confidence-based selection (if difference < threshold, select multiple arms).
- **Does not adapt to effect size.** If stage 1 shows all arms weak, the design still carries a selected arm to stage 2; futility stopping is a separate extension (see Stallard-Todd).

## How this case validates designr

- Foundational reference for multi-arm Phase 3 selection.
- Benchmark for Bonferroni-style α control vs more efficient combination tests.
- Teaching case for the design trade-off: simple rule vs efficient rule.
