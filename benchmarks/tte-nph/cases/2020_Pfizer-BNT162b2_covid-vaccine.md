# Pfizer/BioNTech BNT162b2 (2020) — mRNA COVID-19 vaccine

**Family:** tte-nph · **Endpoint:** time to first symptomatic COVID-19 · **N:** 43,448 · **Design feature:** case-driven Bayesian VE with waning efficacy

## Why this case is in the corpus

- **Canonical vaccine trial** — case-driven event count (not calendar time), VE posterior as primary success metric.
- **Waning efficacy** as NPH pattern — protection concentrated in early post-vaccination window.
- **Bayesian decision framework** with weakly informative prior β(0.700005, 1).

## Citation

Polack FP, Thomas SJ, Kitchin N, et al. *Safety and efficacy of the BNT162b2 mRNA Covid-19 vaccine.* N Engl J Med. 2020;383(27):2603-2615. doi:10.1056/NEJMoa2034577. NCT04368728.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1, case-driven |
| Population | ≥ 16 y, no prior SARS-CoV-2 |
| Intervention | BNT162b2 30 μg × 2 vs placebo |
| Primary endpoint | First confirmed COVID-19 ≥ 7 d post-dose 2 |
| Success rule | PP(VE > 30% \| data) > 99.5% via β(0.700005, 1) prior |
| Target VE | 60% (H1); 30% floor (H0) |
| α (one-sided) / power | 0.025 / 0.90 |
| Planned interims | 32, 62, 92, 120, 164 cases |
| Planned N | ~44,000 (to accumulate events) |

## Reproducing the design

```r
library(gsDesign)
# Approximate with binomial GS design
d <- gsDesign(
  k = 4, test.type = 1,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF,
  n.fix = 164, timing = c(32, 62, 120, 164)/164
)
```

## Trial outcome

- Case accumulation faster than expected — 170 cases in ~3 months.
- VE **95.0%** (95% CI 90.3-97.6%) — vastly exceeded design threshold.
- Cases: 8 vaccine / 162 placebo.
- Success declared at first scheduled interim.

## How this case validates designr

- Case-driven event count design (person-time basis).
- Bayesian posterior decision rule.
- Vaccine trial with NPH waning-efficacy estimand challenge.
- Public protocol/SAP available — excellent reference case.
