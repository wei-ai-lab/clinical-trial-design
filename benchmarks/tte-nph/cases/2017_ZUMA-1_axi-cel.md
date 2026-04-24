# ZUMA-1 (2017) — axicabtagene ciloleucel in refractory DLBCL

**Family:** tte-nph · **Endpoint:** ORR primary, DOR/OS with cure fraction · **N:** 101 treated · **Design feature:** CAR-T with long-tail survival plateau

## Why this case is in the corpus

- **Cure-fraction NPH** — responders show a durable plateau; mixture-cure models apply.
- **Single-arm pivotal** using binomial ORR vs historical control for primary; DOR/OS landmark-based rather than HR-based.
- First commercial CAR-T approval (axi-cel / Yescarta).

## Citation

Neelapu SS, Locke FL, Bartlett NL, et al. *Axicabtagene ciloleucel CAR T-cell therapy in refractory large B-cell lymphoma.* N Engl J Med. 2017;377(26):2531-2544. doi:10.1056/NEJMoa1707447. NCT02348216.

## Design summary

| | |
|---|---|
| Design | Single-arm pivotal (Phase 2) |
| Population | Refractory aggressive B-NHL ≥ 2 prior lines |
| Intervention | Axi-cel 2×10^6 CAR+ T cells/kg |
| Primary endpoint | Objective response rate (ORR) |
| Secondary endpoint | DOR, OS, safety |
| Historical control | ORR 26% (SCHOLAR-1 pooled refractory DLBCL) |
| Target ORR | 50% |
| α (one-sided) / power | 0.025 / ~0.975 at ORR 0.50 vs 0.26 |
| Planned N | ~112 (for adequate ORR precision) |

## Reproducing the design

```r
library(gsDesign)
# Single-arm binomial: ORR 0.50 vs 0.26 historical
d <- nBinomial(p1 = 0.50, p2 = 0.26, alpha = 0.025, beta = 0.025,
               sided = 1, ratio = 0)
# Approximate cure-fraction DOR with flexsurvcure or simulation
```

## Trial outcome

- 111 enrolled, 101 treated (10 did not receive infusion).
- ORR **82%** (CR 54%, PR 28%), 95% CI 73-89% — far exceeded historical.
- Median DOR not reached at 15 months; 42% maintained response at cutoff.
- FDA approval October 2017 → Yescarta.
- 5-year OS ~43% — cure-fraction validated.

## How this case validates designr

- Cure-fraction TTE estimand — landmark and RMST rather than HR.
- Single-arm pivotal with historical control framing.
- Cellular-therapy (CAR-T) archetype for confirmatory design.
