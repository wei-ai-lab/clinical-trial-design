# VE-BASKET (2015) — vemurafenib in BRAF V600-mutated non-melanoma cancers

**Family:** basket · **Endpoint:** RECIST RR at 8 weeks · **N:** 122 across 6+ cohorts · **Design feature:** first published basket trial (no cross-basket borrowing)

## Why this case is in the corpus

- **Seminal first-published basket trial** — vemurafenib across multiple non-melanoma BRAF V600-mutated tumors.
- Per-basket Simon two-stage with no hierarchical borrowing (conservative choice).
- Demonstrated basket heterogeneity: strong response in some (NSCLC, ECD, LCH), no response in colorectal.

## Citation

Hyman DM, Puzanov I, Subbiah V, et al. *Vemurafenib in multiple nonmelanoma cancers with BRAF V600 mutations.* N Engl J Med. 2015;373(8):726-736. doi:10.1056/NEJMoa1502309. NCT01524978.

## Design summary

| | |
|---|---|
| Design | Open-label basket, per-cohort Simon two-stage |
| Biomarker | BRAF V600 mutation |
| Baskets | NSCLC · Ovarian · CRC · Anaplastic thyroid · Cholangiocarcinoma · ECD/LCH (other) |
| Primary | Response rate week 8 (RECIST) |
| Null vs alternative | 15% vs 35% |
| α / power (per basket) | 0.10 (one-sided) / 0.90 |
| Total N | 122 |

## Reproducing the design

```r
library(clinfun)
# Simon two-stage per basket:
s <- ph2simon(pu = 0.15, pa = 0.35, ep1 = 0.10, ep2 = 0.10)
# Optimal and minimax designs; typical N ~ 15-25 per basket
```

## Trial outcome

- **NSCLC**: RR 42% (95% CI 20-67%) → positive.
- **Erdheim-Chester / LCH**: RR 43% → accelerated approval (Nov 2017).
- **Colorectal**: RR 0/10 → negative, showing basket heterogeneity.
- **Anaplastic thyroid**: RR 29% (2/7) → signal but small N.
- **Ovarian**: 1/5 → non-definitive.
- Demonstrated BRAF V600 effect depends on histology context.

## How this case validates designr

- Per-basket Simon two-stage reference.
- Basket trial as historical archetype.
- Heterogeneous basket demonstration (CRC resistance vs melanoma/LCH sensitivity).
