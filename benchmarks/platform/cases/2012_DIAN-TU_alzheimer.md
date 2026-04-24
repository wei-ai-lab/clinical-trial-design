# DIAN-TU (2012-) — Autosomal dominant AD prevention platform

**Family:** platform · **Endpoint:** DIAN multivariate cognitive composite · **N:** 194 · **Design feature:** ultra-rare-disease prevention platform with shared placebo

## Why this case is in the corpus

- **Template rare-disease prevention platform** — autosomal dominant AD mutation carriers (~500 families worldwide).
- **Pre-symptomatic enrollment**: 10-15 years before expected symptom onset, derived from parent's age.
- Shared placebo across drug arms (2:1 ratio) — essential efficiency for precious cohort.
- Template for any mutation-defined neurodegeneration prevention program.

## Citation

Salloway S, Farlow M, McDade E, et al. *A trial of gantenerumab or solanezumab in dominantly inherited Alzheimer's disease.* Nat Med. 2021;27(7):1187-1196. doi:10.1038/s41591-021-01369-8. NCT01760005. Design paper: Mills SM et al. *Preclinical trials in autosomal dominant AD: implementation of the DIAN-TU trial.* Rev Neurol (Paris). 2013;169(10):737-743.

## Design summary

| | |
|---|---|
| Design | Open-label platform, shared placebo, adaptive biomarker-guided |
| Population | PSEN1 / PSEN2 / APP mutation carriers, ±15 y from expected onset |
| Arms | Gantenerumab (anti-aggregate Aβ), solanezumab (anti-soluble Aβ), shared placebo |
| Allocation | Gantenerumab 1 : solanezumab 1 : placebo 2 (shared placebo) |
| Primary | DIAN multivariate cognitive composite (DIAN-MCC) — 4-year slope |
| Secondary | CSF Aβ42/tau, PET amyloid, PET tau |
| α | 0.05 (two-sided) |
| Power | 0.80 on 0.50 SD cognitive slope difference over 4 y |
| Planned N | 194 (65 per drug arm + 64 pooled placebo) |

## Reproducing the design

```r
library(nlme)
# Mixed-effects slope analysis on DIAN-MCC
m <- lme(
  DIAN_MCC ~ arm * years_from_baseline + age_at_baseline + EYO,
  random = ~ years_from_baseline | id,
  data = dian_df,
  correlation = corCAR1(form = ~ years_from_baseline | id)
)

# Sample-size calculation for longitudinal slope comparison
library(longpower)
lmmpower(
  beta = 0.5,      # SD units over 4 years (target slope difference)
  pct.change = NULL,
  t = seq(0, 4, by = 1),
  sig2.i = 1.0,    # between-subject intercept variance
  sig2.s = 0.25,   # between-subject slope variance
  sig2.e = 0.3,    # residual variance
  power = 0.80
)
```

## Trial outcome (DIAN-TU-001 primary, 2021)

- **Gantenerumab**: no benefit on 4-year DIAN-MCC slope (p = 0.55); reduced amyloid PET SUVR (biomarker effect present).
- **Solanezumab**: no benefit on cognition or amyloid.
- Both drugs discontinued in platform; open-label extension offered for all.
- **Platform continued**: next-generation arms (lecanemab extension, anti-tau, combination) under DIAN-TU-002.

## How this case validates designr

- Rare-disease small-N longitudinal slope sample-size benchmark.
- Shared-placebo platform efficiency quantification.
- Mixed-effects modeling for longitudinal cognitive composite.
- Adaptive platform in a setting where per-drug RCTs are simply infeasible.
- Complementary to pandemic platforms (REMAP-CAP, PRINCIPLE) and master-protocol oncology (Lung-MAP, GBM-AGILE).
