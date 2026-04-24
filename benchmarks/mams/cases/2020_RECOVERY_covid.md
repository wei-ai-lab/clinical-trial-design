# RECOVERY (2020-) — adaptive platform MAMS in hospitalized COVID-19

**Family:** mams · **Endpoint:** binary/TTE mortality at day 28 · **N:** 47,000+ · **Design feature:** pandemic-era open-label platform MAMS with radical operational simplicity

## Why this case is in the corpus

- **Largest COVID-19 Phase 3** — enrolled 47,000+ patients across UK NHS hospitals starting March 2020.
- **Radical operational simplicity** — minimal eCRF, centralized randomization, 28-day mortality from routine records; enabled rapid accrual.
- **Landmark results** — dexamethasone (mortality HR 0.83 in oxygen, 0.65 in ventilated), tocilizumab, baricitinib all identified as effective; hydroxychloroquine, lopinavir-ritonavir identified as ineffective.

## Citation

RECOVERY Collaborative Group (Horby P, Landray MJ, et al.). *Randomised Evaluation of COVID-19 Therapy (RECOVERY) protocol.* 2020. Primary dexamethasone paper: NEJM 2021;384:693-704. doi:10.1056/NEJMoa2021436. ISRCTN50189673.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Open-label, MAMS platform |
| Population | Hospitalized COVID-19 adults (+ children, pregnant) |
| Arms (rotating) | Usual care (control) + various experimental: dexamethasone, hydroxychloroquine, lopinavir-ritonavir, azithromycin, tocilizumab, convalescent plasma, colchicine, aspirin, baricitinib, etc. |
| Primary endpoint | 28-day all-cause mortality |
| α / power | 0.05 (two-sided) / ~0.90 per arm |
| Assumed mortality | ~20% control |
| Spending | MAMS boundaries with lack-of-benefit drops |
| Planned looks | Event-driven interim per arm |

## Reproducing the design

```r
library(MAMS)
d <- mams(
  K = 4, J = 3,
  r = c(1, 2, 3), r0 = c(1, 2, 3),
  alpha = 0.025, power = 0.90,
  p = 0.165,    # experimental mortality under HR 0.8
  p0 = 0.20,    # control mortality
  ushape = "obf", lshape = "obf",
  nstart = 500
)
```

Actual RECOVERY implementation used bespoke UK MRC CTU code; MAMS R package is an accurate approximation.

## What the trial found (highlights)

- **Dexamethasone**: mortality HR 0.83 overall, 0.65 ventilated patients. Became SOC within weeks. (June 2020)
- **Hydroxychloroquine**: no benefit, slight harm signal. Terminated. (June 2020)
- **Tocilizumab**: mortality HR 0.85 in hypoxic patients. (Feb 2021)
- **Baricitinib**: mortality HR 0.87. (Mar 2022)
- **Aspirin, colchicine, convalescent plasma**: no benefit.

## Caveats & teaching points

- **Pandemic-era operational excellence.** Minimal CRF, free-text eligibility, routine NHS data linkage for mortality — enabled rapid recruitment and results.
- **Open-label is acceptable** for mortality endpoint (objective), but secondary endpoints (symptom-based) carry bias risk — trial de-emphasized these.
- **FWER control across arms.** RECOVERY used strong FWER via Bonferroni-like adjustment; some argued for relaxed multiplicity given urgency, but sponsor chose conservative.
- **Ethics of concurrent randomization** in a pandemic: arms added/removed without cross-contamination; each patient randomized to one experimental + control at any given time.

## How this case validates designr

- Emergency-use MAMS platform benchmark.
- Mortality-endpoint MAMS with large pragmatic N.
- Operational-lessons case for rapid-deployment trial design.
