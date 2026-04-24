# LOXO-TRK (2018) — Larotrectinib NTRK-fusion tissue-agnostic basket

**Family:** basket · **Endpoint:** ORR (RECIST 1.1, IRC) · **N:** 55 evaluable · **Design feature:** first tissue-agnostic FDA approval

## Why this case is in the corpus

- **First tumor-agnostic FDA approval** (vitrakvi, November 2018).
- Demonstrates regulatory acceptance of pooled evidence across many small per-histology baskets.
- Defining modern precedent for "molecularly-defined target trumps tissue-of-origin".
- Enabled subsequent tissue-agnostic approvals (pembrolizumab TMB-H, selpercatinib RET, entrectinib ROS1/NTRK, etc.).

## Citation

Drilon A, Laetsch TW, Kummar S, et al. *Efficacy of larotrectinib in TRK fusion-positive cancers in adults and children.* N Engl J Med. 2018;378(8):731-739. doi:10.1056/NEJMoa1714448. NCT02122913 (adult Phase 1), NCT02576431 (pediatric SCOUT Phase 1/2), NCT02637687 (adult NAVIGATE Phase 2).

## Design summary

| | |
|---|---|
| Design | Pooled single-arm basket across 3 studies (Phase 1 + SCOUT + NAVIGATE) |
| Population | NTRK1/2/3 fusion-positive solid tumors, any histology, adults + children |
| Dose | 100 mg BID (adults); 100 mg/m² BID (pediatric, max 100 mg) |
| Primary | ORR per RECIST 1.1 by independent central review |
| Comparator | Historical benchmark (single-agent ORR ~5-15% in refractory solid tumors) |
| α | 0.025 one-sided (conventional for single-arm oncology) |
| Power | 0.90 for ORR 0.50 vs null 0.30 |
| Planned / observed N | 55 evaluable, ≥ 17 histologies |

## Reproducing the design

```r
library(gsDesign)
# Single-arm exact binomial for pooled ORR
nBinomial(p0 = 0.30, p1 = 0.50,
          alpha = 0.025, beta = 0.10, sided = 1)
# ≈ 52–55 subjects

# Bayesian hierarchical pooling with histology clusters
library(basket)
basket_design(
  responses = observed_responses_by_histology,
  size = n_by_histology,
  p0 = 0.30,
  alpha = 0.10,
  beta = 0.90,
  pars_distr = "normal",
  mu_0 = 0, tau_0 = 1
)
```

## Trial outcome

- **Pooled ORR: 75% (41/55)** (95% CI 61-85%) across ≥ 17 histologies.
- **Pediatric subgroup** (infantile fibrosarcoma, TPM3-NTRK1 fusion): ORR 93% (14/15).
- Salivary MASC: ORR 83%. GIST: 100% (3/3). Melanoma: 50%. Lung: 71%. Thyroid: 75%.
- Duration: 79% of responses ongoing at 1 year; median DOR not reached at data cutoff.
- **Regulatory outcome**: FDA tissue-agnostic approval 26 Nov 2018.

## How this case validates designr

- Benchmark for tissue-agnostic single-arm basket sizing.
- Bayesian hierarchical / EXNEX borrowing across histologies for sensitivity.
- Rare-target pooled-basket sample-size logic with historical control benchmarking.
- Exercises the `basket` package's BHM + EXNEX reference implementation.
