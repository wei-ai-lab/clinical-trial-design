# Non-standard designs

Catch-all family for Phase 3 designs that do not cleanly fit the 19 standard
families — most commonly **inferential-seamless Phase 2/3 designs** (dose
or treatment selected at an interim and carried into a confirmatory stage
with strict type-I-error control) and **non-standard primary-analysis
frameworks** such as hierarchical composite endpoints (win ratio) and
desirability-of-outcome ranking.

## What distinguishes this family

| Feature | Standard adaptive | Non-standard |
|---|---|---|
| Interim decision | SSR / stop / enrich one biomarker subgroup | **Select 1 of k doses/treatments** and carry into Stage 2 |
| Type-I control | α-spending | **Combination-function** (Bauer-Köhne, inverse-normal) + closed testing |
| Endpoint | Usual superiority / NI | Standard **or** hierarchical composite (win ratio) / DOOR |
| Sponsor motivation | Preserve α under adaptation | Compress 2+ trials into one; or escape the "time-to-first" composite trap |

## Canonical references

- **Bauer P, Kieser M.** Combining different phases in the development of medical treatments within a single trial. *Stat Med.* 1999;18:1833-1848.
- **Bauer P, Köhne K.** Evaluation of experiments with adaptive interim analyses. *Biometrics.* 1994;50:1029-1041.
- **Stallard N, Todd S.** Sequential designs for phase III clinical trials incorporating treatment selection. *Stat Med.* 2003;22:689-703.
- **Posch M, Maurer W, Bretz F.** Type I error rate control in adaptive designs for confirmatory clinical trials with treatment selection at interim. *Pharm Stat.* 2011;10:96-104.
- **Pocock SJ, Ariti CA, Collier TJ, Wang D.** The win ratio: a new approach to the analysis of composite endpoints in clinical trials based on clinical priorities. *Eur Heart J.* 2012;33:176-182.
- **Finkelstein DM, Schoenfeld DA.** Combining mortality and longitudinal measures in clinical trials. *Stat Med.* 1999;18:1341-1354.

## Operational principles

1. **Pre-specify the combination test** (inverse-normal, Fisher product) before unblinding Stage 1.
2. **Pre-specify the selection rule** — usually highest observed treatment effect, or highest predictive-probability treatment.
3. **Closed testing** to protect the family-wise error rate across selected and non-selected arms.
4. **Independent data** between Stage 1 and Stage 2 required by the combination-test theory — so new patients enrolled in Stage 2 only.
5. For **win ratio** and **hierarchical composite**, the analysis pre-specifies the order of priority among components and uses stratified Finkelstein-Schoenfeld or Buyse generalized pairwise comparisons.

## R packages

- `adaptTest` — Bauer-Köhne combination test for adaptive designs.
- `asd` — adaptive seamless designs with treatment selection (Stallard-Todd).
- `rpact` — combination-function and closed-testing adaptive designs (incl. treatment selection).
- `gMCP` — closed testing and graphical procedures for adaptive trials.
- `WINS` — win ratio, win odds, win probability, Finkelstein-Schoenfeld.
- `wwr` — weighted win ratio.

## Common pitfalls

- **Combination-function choice**: inverse-normal with pre-specified weights is the modern default; Fisher product is simpler but less tunable.
- **Selection rule bias**: if the selected arm is chosen on Stage-1 effect estimate, the unadjusted Stage-2 estimate is biased — report both and discuss.
- **Win ratio interpretability**: WR quantifies relative frequency of "winning" pairs, not a hazard or rate — communicate to clinicians accordingly.
- **Win ratio ties**: handling of ties materially affects power; pre-specify the tie-breaking (lexicographic vs proportional) rule.
