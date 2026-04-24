# Solidarity (2020) — WHO global pragmatic platform in COVID-19

**Family:** platform · **Endpoint:** in-hospital mortality · **N:** 11,266 · **Design feature:** open-label pragmatic multi-national platform

## Why this case is in the corpus

- **WHO-led global pragmatic platform** — 405 hospitals across 30 countries.
- Open-label to maximize global deployability.
- Arm dropping based on interim: HCQ, lopinavir/ritonavir, interferon β-1a all dropped.

## Citation

WHO Solidarity Trial Consortium. *Repurposed antiviral drugs for Covid-19 — interim WHO Solidarity Trial results.* N Engl J Med. 2021;384(6):497-511. doi:10.1056/NEJMoa2023184. NCT04315948.

## Design summary

| | |
|---|---|
| Design | Open-label pragmatic platform |
| Population | Hospitalized COVID-19 adults |
| Arms | Remdesivir · HCQ · Lop/rit · IFN β-1a · SOC |
| Primary | In-hospital mortality (TTE) |
| Secondary | Ventilation initiation, hospitalization duration |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed rate ratio | 0.80 |
| Planned N | ~11,000 |
| Arm drops | HCQ (June 2020), lop/rit (July 2020), IFN (Oct 2020) |

## Reproducing the design

```r
library(gsDesign)
# Per-arm Cox TTE
d <- nSurv(
  lambdaC = -log(1-0.12), hr = 0.80,
  alpha = 0.0125,  # Bonferroni 4 arms
  beta = 0.10,
  R = 6, minfup = 0
)
```

## Trial outcome

- **Remdesivir**: RR 0.95 (95% CI 0.81-1.11) — no effect on OS.
- **HCQ**: RR 1.19 (95% CI 0.89-1.59) — dropped for futility.
- **Lopinavir/ritonavir**: RR 1.00 (0.79-1.25) — dropped.
- **IFN β-1a**: RR 1.16 (0.96-1.39) — dropped.
- Reshaped global COVID-19 treatment guidelines.

## How this case validates designr

- Pragmatic global platform reference.
- Open-label design choice tradeoff (external validity vs bias).
- Futility-driven arm drop pattern.
- Multi-country shared-control architecture.
