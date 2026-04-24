# ROAR (2018-2023) — Dabrafenib + trametinib BRAF V600E basket

**Family:** basket · **Endpoint:** ORR (RECIST / RANO) · **N:** 206 across 9 histologies · **Design feature:** per-histology Simon 2-stage + BHM sensitivity; multiple sequential approvals

## Why this case is in the corpus

- **Multi-approval basket**: single trial design yielded **5+ separate FDA approvals** across rare BRAF V600E histologies (anaplastic thyroid 2018, biliary tract 2022, hairy cell leukemia 2022, tissue-agnostic 2022, pediatric low-grade glioma 2023).
- Benchmark for **histology-heterogeneous** responses to the same molecular target — motivates EXNEX-style shrinkage over full pooling.
- Single most-cited precedent for Bayesian hierarchical basket analyses in regulatory submissions.

## Citation

Subbiah V, Kreitman RJ, Wainberg ZA, et al. *Dabrafenib plus trametinib in patients with BRAF V600E-mutant rare cancers: Phase 2 ROAR basket study.* Nat Med. 2023;29(5):1103-1112. NCT02034110. Histology-specific readouts: anaplastic thyroid (Subbiah 2018, JCO); biliary tract (Subbiah 2020, Lancet Oncol); hairy cell leukemia (Tiacci 2021, NEJM); low-grade glioma (Bouffet 2023, NEJM).

## Design summary

| | |
|---|---|
| Design | Phase 2 open-label basket, per-histology Simon 2-stage + BHM sensitivity |
| Population | Adults with BRAF V600E-mutant rare cancers (9 pre-defined histologies) |
| Treatment | Dabrafenib 150 mg BID + trametinib 2 mg QD |
| Primary | ORR per RECIST 1.1 (solid tumors) or RANO (gliomas) |
| Null ORR per histology | 0.15 |
| Alt ORR per histology | 0.35 |
| α per histology | 0.025 one-sided |
| Power | 0.80 |
| Target per histology | ~ 25 (Simon 2-stage minimax) |
| Planned / observed total N | 206 across 9 histologies |

## Reproducing the design

```r
library(clinfun)
# Per-histology Simon 2-stage (minimax)
ph2simon(pu = 0.15, pa = 0.35, ep1 = 0.10, ep2 = 0.20,
         nmax = 30)

# Cross-histology Bayesian hierarchical pooling sensitivity
library(basket)
res <- mem_mcmc(
  responses = observed_responses,     # per-histology counts
  size = n_per_histology,
  name = histology_names,
  p0 = 0.15,
  mcmc_iter = 50000,
  shape1 = 0.5, shape2 = 0.5            # prior on marginal response
)
```

## Trial outcome (pooled across cohorts, 2018-2023 readouts)

| Histology | N evaluable | ORR | Regulatory outcome |
|---|---|---|---|
| Anaplastic thyroid | 25 | 56% | FDA approval May 2018 |
| Biliary tract | 36 | 47% | FDA approval May 2022 |
| Hairy cell leukemia | 27 | 89% | FDA approval June 2022 |
| Low-grade glioma (pediatric) | 52 | 54% | FDA approval June 2023 |
| High-grade glioma | 45 | 33% | EMA review |
| Small bowel adenoca | 7 | 43% | — |
| Multiple myeloma | 4 | 50% | — (too few) |
| Non-seminoma germ cell | 1 | 0% | — (too few) |
| Tissue-agnostic umbrella claim | ≥ 131 | — | **FDA tissue-agnostic label June 2022** |

## How this case validates designr

- Per-histology Simon 2-stage sizing benchmark.
- Cross-histology Bayesian hierarchical (BHM / EXNEX) benchmark on real heterogeneous data.
- Multi-indication basket strategy where individual baskets become separate labels sequentially.
- Tissue-agnostic extension pathway for molecularly-defined targets with histology-dependent response magnitudes.
