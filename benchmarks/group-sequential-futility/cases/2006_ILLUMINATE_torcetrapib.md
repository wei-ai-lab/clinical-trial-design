# ILLUMINATE (2006) — torcetrapib + atorvastatin in high-risk CAD

**Family:** group-sequential-futility (harm-stopped very early) · **Endpoint:** TTE MACE · **N:** 15,067 · **Design feature:** DSMB early harm-stop at IF ~0.30

## Why this case is in the corpus

- **Very early harm-stop** (IF ~0.30) — the earliest typical DSMB intervention.
- Established **CETP inhibition failure** for CV benefit; subsequent trials (anacetrapib, evacetrapib) corroborated. Teaching case for drug-class failure recognition.
- Non-binding DSMB authority in action.

## Citation

Barter PJ, Caulfield M, Eriksson M, et al. *Effects of torcetrapib in patients at high risk for coronary events.* N Engl J Med. 2007;357(21):2109-2122. doi:10.1056/NEJMoa0706628. NCT00134264.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, GS with DSMB oversight |
| Arms | Torcetrapib 60 mg + atorvastatin · Atorvastatin |
| Primary endpoint | 4-component CHD MACE |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.75 |
| Spending | Lan-DeMets OBF (planned) |
| Planned looks | 2 interim + final (IF 0.33, 0.67, 1.0) |
| Planned N | 15,067 |
| Target events | ~900 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 3, test.type = 4,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF, sfl = sfHSD, sflpar = -2,
  hr = 0.75, hr0 = 1,
  lambdaC = -log(1 - 0.03),
  R = 24, minfup = 30, ratio = 1
)
# N ≈ 15,000, events ≈ 900
```

## What the trial found

- Stopped at IF ~0.30 (18 months follow-up) on DSMB emergency recommendation.
- Torcetrapib raised BP ~4-5 mmHg (off-target aldosterone effect).
- HR all-cause mortality = **1.58** (95% CI 1.14–2.19).
- HR CV events = **1.25** (95% CI 1.09–1.44).
- Pfizer withdrew torcetrapib from development; cost estimated at $800M to $1B.

## Caveats & teaching points

- **Pre-trial pharmacology review matters.** Torcetrapib's BP signal was detectable in Phase 2 but not formally required to halt Phase 3 development. Post-incident regulatory expectations increased pre-Phase-3 pharmacodynamic scrutiny.
- **DSMB harm stops are judgment-driven.** No formal z-boundary triggered. DSMB weighed mortality + event-rate signals + known off-target effect and recommended stop.
- **Class-effect lesson.** CETP inhibition for HDL elevation repeatedly failed (anacetrapib, evacetrapib, dalcetrapib). Mechanism ≠ therapeutic benefit. Teaches caution about HDL-modification strategies.

## How this case validates designr

- Very-early harm-stop scenario.
- Agent reasoning about DSMB authority vs formal boundaries.
- Cross-trial class-effect recognition (CETP family failures).
