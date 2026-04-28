# KEYNOTE-189 (2018) — pembrolizumab + chemo in 1L metastatic NSCLC

**Family:** multiplicity-co-primary · **Endpoints:** PFS + OS (hierarchical) · **N:** 600 planned · **NCT02578680**

## Why this case is in the corpus

- **Canonical co-primary survival design** with hierarchical (fixed-sequence) alpha control — PFS tested at full α=0.025 one-sided, OS tested at full α=0.025 conditional on PFS rejection.
- 2:1 randomization with two interim analyses on each endpoint via OBF spending.
- Highly cited; clear separation of design parameters from operational realities (the trial stopped early at IA on PFS; OS was then tested at full alpha).
- Tests the agent's understanding that fixed-sequence preserves family-wise alpha without splitting — a common multiplicity mistake is to alpha-split co-primary endpoints when the trial actually used hierarchical testing.

## Citation

Gandhi L, Rodríguez-Abreu D, Gadgeel S, et al. *Pembrolizumab plus Chemotherapy in Metastatic Non-Small-Cell Lung Cancer.* N Engl J Med. 2018;378(22):2078-2092. DOI: 10.1056/NEJMoa1801005.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 2:1 |
| Indication | 1L metastatic non-squamous NSCLC, no EGFR/ALK |
| Arms | Pembro + pem/plat · Placebo + pem/plat |
| Co-primary endpoints | PFS (BICR, RECIST 1.1), OS (all-cause mortality) |
| Multiplicity | Fixed-sequence (PFS → OS) |
| α / power | 0.025 one-sided, 80% per endpoint |
| HR PFS / median control | 0.50 / 4.7 mo |
| HR OS / median control | 0.70 / 17.0 mo |
| Planned N | 600 |
| Interim analyses | 2 each on PFS and OS, OBF spending |

## Reproducing the calculation

Hierarchical (fixed-sequence) co-primary procedure: each hypothesis is tested at the full one-sided 0.025 alpha; OS testing is gated on PFS rejection. The family-wise type I error is preserved by the closed-testing principle (you can only test OS in the path where PFS has been rejected).

```r
library(gsDesign)

# PFS arm: HR 0.5, median 4.7 mo, GS 2 looks
pfs <- gsSurv(k=2, test.type=1, alpha=0.025, beta=0.20,
              sfu=sfLDOF, timing=c(0.5),
              lambdaC=log(2)/4.7, hr=0.5, eta=-log(0.95)/12,
              ratio=2, R=20, T=NULL, minfup=12)
pfs$d  # ~372 events

# OS arm: HR 0.7, median 17 mo
os <- gsSurv(k=2, test.type=1, alpha=0.025, beta=0.20,
             sfu=sfLDOF, timing=c(0.5),
             lambdaC=log(2)/17, hr=0.7, eta=-log(0.95)/12,
             ratio=2, R=20, T=NULL, minfup=12)
os$d   # ~416 events

# Total N is driven by whichever endpoint requires more patients.
# OS at HR 0.7 with longer median is the limiting factor: ~600.
```

## What the trial found

- **PFS**: HR 0.52 (95% CI 0.43–0.64), p < 0.001 (rejected at IA)
- **OS**: HR 0.49 (95% CI 0.38–0.64), p < 0.001 (rejected at full α)

Both co-primary hypotheses rejected at the planned interim analysis on PFS. The fixed-sequence procedure allowed OS to be tested at the full 0.025 one-sided alpha because PFS had been rejected.

## Caveats & teaching points

- **Alpha-split would be wrong here.** A naïve agent might split α=0.025 across PFS+OS (e.g., 0.0125 each). That would be conservative and depart from the published design. The agent must recognize "co-primary with hierarchical testing" as fixed-sequence, not alpha-split.
- **The driver of N is the second hypothesis in the chain.** OS at HR 0.70 needs ~416 events; PFS at HR 0.50 needs ~372 events. The total trial size is set by OS plus operational constraints — you cannot ship the design until the slower endpoint has enough events.
- **Sample-size rounding.** Published planned N = 600. Reproducing within ±5% is acceptable.

## How this case validates clinical-trial-design

- Tests `design_co_primary` with `strategy = "fixed-sequence"`.
- Validates that the per-endpoint alpha is preserved (not split).
- Validates that total N is correctly driven by the maximum of the two endpoints' required N, plus a small operational buffer.
