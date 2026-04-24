# Jenkins-Stone-Jennison (2011) — adaptive seamless Ph II/III with subpopulation selection

**Family:** adaptive-enrichment · **Endpoint:** TTE · **Design feature:** Phase 2 + Phase 3 integrated with mid-trial subpopulation choice

## Why this case is in the corpus

- **Seamless II/III design** — Phase 2 data used for selection and contributes to the Phase 3 combination test.
- **Formal framework for subpopulation selection** with closed testing across H_F (full), H_B+ (biomarker+), and H_B− (biomarker−).
- Widely cited as a template for modern adaptive enrichment in oncology.

## Citation

Jenkins M, Stone A, Jennison C. *An adaptive seamless phase II/III design for oncology trials with subpopulation selection using correlated survival endpoints.* Pharmaceutical Statistics. 2011;10(4):347-356. doi:10.1002/pst.472.

## The design

1. **Stage 1 (Phase 2-like)** — all-comers randomized to test vs control; interim endpoint (say PFS at 6 months or a surrogate TTE).
2. **Selection decision** — based on interim PFS:
   - If full population looks strong (conditional power ≥ some threshold) → continue all-comers in stage 2.
   - If biomarker+ subgroup looks strong and full does not → restrict stage 2 to biomarker+.
   - Otherwise stop.
3. **Stage 2 (Phase 3)** — continue per selection on the confirmatory endpoint (OS, or PFS with additional patients and events).
4. **Final analysis** — inverse-normal combination of stage 1 + stage 2 z-statistics, with closed testing over H_F, H_B+, H_B−.

## Illustrative design

| | |
|---|---|
| Endpoint (Ph2) | PFS at 6 months |
| Endpoint (Ph3) | OS |
| Biomarker prevalence | 50% |
| α / power | 0.025 / 0.85 |
| Assumed HR (full) | 0.80 |
| Assumed HR (B+) | 0.65 |
| Planned N stage 1 | 300 (150 per arm, 150 B+ overall) |
| Planned N stage 2 | 600 (if full) or 400 (if B+ only) |
| Interim | After all stage-1 PFS events or end of stage 1 accrual |

## Reproducing the design

```r
library(asd)   # or rpact
# Phase II/III adaptive seamless
# asd::treatsel.sim supports treatment and subgroup selection
```

## α-control mechanics

Closed testing across three hypotheses:

- **H_F** (full): treatment effective in full population.
- **H_B+**: treatment effective in biomarker+ subgroup.
- **H_B−**: treatment effective in biomarker− subgroup.

Each hypothesis tested at α = 0.025 with inverse-normal weights pre-specified. Closure principle: reject H_F only if all intersections containing H_F are rejected, similarly for others.

## What the design offers

- **Efficient** — Phase 2 data is not wasted; it contributes to the final test via the combination statistic.
- **Robust α control** across all selection decisions.
- **Regulator-friendly** — Jenkins-Stone-Jennison has been explicitly cited as acceptable by FDA/EMA in several published Phase 3s.

## Caveats & teaching points

- **Surrogate endpoint risk.** If PFS-at-6-months does not correlate with final OS, the selection rule can misfire. Trial must pre-specify sensitivity analysis.
- **Strong FWER control is expensive.** Closed testing across 3 hypotheses can inflate required N by 15-30% vs a single-hypothesis test.
- **Small subgroup sample.** If biomarker+ prevalence is low, stage 1 power for the B+ hypothesis is low; may need external Phase 1/2 data to inform prior.

## How this case validates designr

- Seamless Phase II/III methodology benchmark.
- Closed-testing multiplicity handling reference.
- Template for real trials like TAPPAS (see companion case).
