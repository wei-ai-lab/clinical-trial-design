# KEYNOTE-189 (2018) — pembrolizumab + chemo vs chemo in first-line non-squamous NSCLC

**Family:** group-sequential-nph · **Endpoint:** TTE OS + PFS (dual primary) · **N:** 616 · **Design feature:** combo-IO masks early NPH via chemo component

## Why this case is in the corpus

- **Combo IO+chemo** — adding pembrolizumab to platinum-pemetrexed. The chemo component provides early cytoreduction, so the combined effect curve separates quickly despite IO's underlying delayed effect.
- **All-comer (not PD-L1 selected)** design — complements KEYNOTE-024's biomarker-enriched approach.
- Teaching case for **combo-IO designs** where PH approximately holds despite IO component.

## Citation

Gandhi L, Rodríguez-Abreu D, Gadgeel S, et al. *Pembrolizumab plus chemotherapy in metastatic non-small-cell lung cancer.* N Engl J Med. 2018;378(22):2078-2092. doi:10.1056/NEJMoa1801005. NCT02578680.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 2:1 pembro+chemo : chemo, GS |
| Population | Untreated stage IV non-squamous NSCLC, EGFR/ALK WT |
| Arms | Pembrolizumab + pemetrexed + platinum · Placebo + pemetrexed + platinum |
| Primary endpoints | OS + PFS (dual primary, hierarchical) |
| α / power | 0.025 each / 0.85 |
| Assumed HR | OS 0.70 · PFS 0.60 |
| Spending | Lan-DeMets OBF α per endpoint |
| Planned looks | 2 interim OS + final · 1 interim PFS + final |
| Planned N | 616 |
| Target events | OS 416 · PFS 410 |

## Reproducing the design

```r
library(gsDesign)
d_os <- gsSurv(
  k = 3, test.type = 2,
  alpha = 0.025, beta = 0.15,
  sfu = sfLDOF,
  hr = 0.70, hr0 = 1,
  lambdaC = -log(0.5)/13,
  R = 12, minfup = 24, ratio = 2
)
# N ≈ 616, events ≈ 416 OS
```

## What the trial found

- OS HR **0.49** (95% CI 0.38–0.64), 12-mo OS 69.2% vs 49.4% — met at first interim.
- PFS HR **0.52** (95% CI 0.43–0.64), median 8.8 vs 4.9 mo.
- Benefit consistent across PD-L1 subgroups (< 1%, 1–49%, ≥ 50%) — all-comers benefited.
- KM separation emerged within ~2 months, driven by chemo cytoreduction + IO sustained effect.

## Caveats & teaching points

- **Combo-IO masks NPH.** Chemo backbone provides immediate tumor kill, so early KM overlap (the hallmark of IO delayed effect) is not observed. Log-rank remains efficient.
- **2:1 allocation** again chosen for combo-arm safety/PK data accumulation.
- **All-comer first-line** design contrasted with KEYNOTE-024's PD-L1 ≥ 50% enrichment — regulatory labeling therefore covers all PD-L1 levels in non-squamous NSCLC for combo.

## How this case validates designr

- Combo-IO with near-PH behavior (reference for when PH is actually fine).
- Dual-primary OS + PFS hierarchical α-handling.
- Contrast with KEYNOTE-024 enrichment strategy.
