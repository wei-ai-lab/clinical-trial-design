# Murphy (2005) — SMART Designs for Dynamic Treatment Regimes

**Family:** non-standard · **Kind:** methodology-paper · **Scope:** sequential multiple-assignment randomized trials for developing DTRs

## Why this case is in the corpus

- **Foundational SMART methodology paper** — established the design framework for developing dynamic treatment regimes in chronic relapsing conditions.
- Introduced the concept of 'embedded DTRs' and two-stage randomization for sequential decision-making.
- Basis for subsequent work on Q-learning, policy learning, and adaptive interventions in behavioral and mental health.
- Canonical non-standard design that does not fit group-sequential, adaptive-enrichment, or platform categories.

## Citation

Murphy SA. *An experimental design for the development of adaptive treatment strategies.* Stat Med. 2005 May 30;24(10):1455-81.

## Core design

| Element | Value |
|---|---|
| Stages | 2 (sometimes more) |
| Stage 1 randomization | All patients to initial treatment options |
| Response assessment | At pre-specified interim point (weeks-months) |
| Stage 2 randomization | Non-responders re-randomized to salvage strategies; sometimes responders also re-randomized |
| Target estimand | Mean outcome under each embedded DTR |
| Analysis | Weighted or g-computation accounting for staged randomization |

## Algorithm

```r
# SMART schematic: initial treatments A, B; 2nd-stage options
#   responders (R) → maintain
#   non-responders (NR) → switch or augment

# Stage 1: randomize all N patients 1:1 to A or B
# Wait until week 8 (example): assess response
# Stage 2 for non-responders: re-randomize 1:1 to switch or augment
# Stage 2 for responders: maintain same treatment (or sub-randomize)

library(DynTxRegime)
# Fit Q-learning to estimate optimal DTR from SMART data
fit <- qLearn(
  moPropen = buildModelObj(
    model = ~ 1, solver.method = "glm",
    solver.args = list(family = "binomial")
  ),
  moMain = list(...),   # main outcome models for each stage
  moCont = list(...),   # contrast functions
  data = smart_df,
  response = smart_df$Y,
  txName = c("A1", "A2")
)

# Key SMART sample-size formula (Oetting et al. 2011) for
# comparing two embedded DTRs:
#   n = 4 * (z_{α/2} + z_β)^2 * σ^2 / Δ^2 * (1 + p_nr)
# where p_nr = proportion of non-responders (who get re-randomized)
```

## Typical design parameters

- Total N: 200-500 (behavioral trials often 100-300).
- Non-responder fraction: 30-50%.
- Effective DTR comparison N: ~60% of total.
- Stage-1 and stage-2 outcomes analyzed jointly (Q-learning) or end-of-stage-2 as primary.

## Real SMART-flavored trials

- **CATIE schizophrenia** (2005) — NIMH staged antipsychotic trial.
- **STAR*D depression** (2006) — 4-stage MDD algorithm.
- **ExTENd alcoholism** (Almirall 2012) — pure SMART design.
- **ASTRA-2 pediatric ADHD** (2014).

## How this case validates designr

- Adds the **foundational SMART methodology** to the non-standard corpus, complementing Bauer-Kieser seamless (methodology), INHANCE (real seamless trial), and Pocock win ratio.
- Sample-size via Oetting formula or simulation is a distinct computation not in gsDesign/rpact — `designr` would expose via DynTxRegime/simulation.
- Teaches the notion of dynamic treatment regime estimand — distinct from intention-to-treat comparison of fixed regimens.
