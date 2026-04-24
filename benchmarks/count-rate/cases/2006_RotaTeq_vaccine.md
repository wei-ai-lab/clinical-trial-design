# RotaTeq (2006) — pentavalent rotavirus vaccine

**Family:** count-rate · **Endpoint:** RVGE incidence (primary) + intussusception safety · **N:** 68,038 · **Design feature:** mega-trial sized on safety rule-out

## Why this case is in the corpus

- **Vaccine efficacy as Poisson rate ratio** — VE = 1 - RR with person-time offset.
- **Safety-driven sample size** post-Rotashield withdrawal for intussusception concern.
- Mega-trial archetype with dual efficacy/safety framing.

## Citation

Vesikari T, Matson DO, Dennehy P, et al. *Safety and efficacy of a pentavalent human-bovine (WC3) reassortant rotavirus vaccine (RotaTeq).* N Engl J Med. 2006;354(1):23-33. doi:10.1056/NEJMoa052664. NCT00090233.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1, infants 6-12 wk |
| Intervention | RotaTeq × 3 oral doses |
| Control | Placebo × 3 oral doses |
| Co-primary efficacy | Severe RVGE + any RVGE |
| Co-primary safety | Intussusception rule-out |
| α / power | 0.05 (two-sided) / 0.90 |
| VE assumed | 80% severe, 60% any |
| Planned N | ~70,000 |

## Reproducing the design

```r
library(rpact)
# VE = 1 - RR; sample size on rate ratio
d_eff <- getSampleSizeRates(
  alpha = 0.025, beta = 0.10,
  pi1 = 0.02, pi2 = 0.10,   # 80% VE against severe
  sided = 1
)

# Safety: rule out >2x intussusception rate
# Background ~1/2000 events
# Large N required to rule out small RR increase
```

## Trial outcome

- VE against severe G1-G4 RVGE: **98.0%** (95% CI 88.3-100.0).
- VE against any G1-G4 RVGE: **74.0%**.
- Intussusception: 12 vaccine / 15 placebo (within 42 d post-dose) — safety met.
- FDA approval February 2006.

## How this case validates designr

- Vaccine efficacy design with count-rate primary.
- Dual efficacy + safety rule-out design.
- Mega-trial sample size driven by rare safety event.
