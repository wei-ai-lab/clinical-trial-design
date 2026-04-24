# JUPITER (2008) — rosuvastatin primary prevention with elevated hsCRP

**Family:** group-sequential · **Endpoint:** TTE composite CV · **N:** 17,802 · **Design feature:** Lan-DeMets OBF, 3 analyses, stopped early

## Why this case is in the corpus

- **Large primary-prevention GS trial** — low baseline event rate, high N, pre-specified 3-look GS.
- **Stopped early at second interim** (actual IF ~0.44) for efficacy; observed HR 0.56 at stop vs assumed 0.75.
- Teaching case for OBF spending in very-low-event-rate primary prevention.

## Citation

Ridker PM, Danielson E, Fonseca FA, et al. *Rosuvastatin to prevent vascular events in men and women with elevated C-reactive protein.* N Engl J Med. 2008;359(21):2195-2207. doi:10.1056/NEJMoa0807646. NCT00239681.

Design paper: Ridker PM, Danielson E, Fonseca FA, et al. *Rationale, design, and methodology of the Justification for the Use of Statins in Primary Prevention: An Intervention Trial Evaluating Rosuvastatin (JUPITER).* Am J Cardiol. 2003 Jul 1;92(1B):12B-15B.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, group-sequential |
| Population | Primary prevention, hsCRP ≥ 2, LDL < 130 |
| Arms | Rosuvastatin 20 mg · Placebo |
| Primary endpoint | Composite CV: MI, stroke, revascularization, UA hospitalization, CV death |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.75 |
| Assumed control event rate | ~0.9% per year |
| Spending | Lan-DeMets OBF |
| Planned looks | 2 interim (IF 0.50, 0.75) + final (IF 1.0) |
| Target events | 520 |
| Planned N | 17,802 |
| Max follow-up | Up to ~5 years |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k         = 3,
  test.type = 1,
  alpha     = 0.025,
  beta      = 0.10,
  sfu       = sfLDOF,
  timing    = c(0.50, 0.75, 1.0),
  hr        = 0.75, hr0 = 1,
  lambdaC   = -log(1 - 0.009),
  R         = 24, minfup = 48, ratio = 1
)
summary(d)
# N ≈ 17,800, events ≈ 520, z-bounds ≈ 2.80 / 2.34 / 2.04
```

## What the trial found

- Stopped at median 1.9 years follow-up (before second planned interim, IF ~0.44).
- Observed HR = **0.56** (95% CI 0.46–0.69), p < 0.001.
- Primary endpoint rate: rosuvastatin 0.77 per 100 person-years, placebo 1.36.
- Led to expanded statin guidelines for hsCRP-elevated primary prevention.

## Caveats & teaching points

- **Large effect eclipsed design assumptions.** HR 0.56 vs planned 0.75; z-boundary crossed at lower-than-planned information. Under OBF, even an off-schedule early analysis maintains α because spending is tied to information fraction via Lan-DeMets.
- **Commercial and ethical dimensions.** Several post-trial commentaries noted that early stop + sponsor-driven design has complex ethical and interpretive consequences. Not a design defect; a feature of GS that should be acknowledged.
- **Primary prevention sample sizes are huge.** 0.9%/y control rate × 520 events / HR 0.75 = ~17,800 subjects with 5-year follow-up. A move to secondary prevention would cut N 5-10×.

## How this case validates designr

- GS design with non-equal IF spacing (0.50, 0.75, 1.0 vs even 0.33/0.67/1.0 in RALES).
- Very low event rate (~1%/y) driving large N.
- Agent reasoning about Lan-DeMets handling of off-schedule interims.
