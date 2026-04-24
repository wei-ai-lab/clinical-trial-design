# AIM-HIGH (2011) — niacin + statin in CVD with low HDL

**Family:** group-sequential-futility · **Endpoint:** TTE MACE · **N:** 3,414 · **Design feature:** stopped at 2nd interim for futility

## Why this case is in the corpus

- **Futility-stopped** at second planned interim despite dramatic surrogate-marker improvements (HDL up, LDL down, TG down). Teaching case for the disconnect between surrogates and hard endpoints.
- Uses **HSD β-spending** paired with **Lan-DeMets OBF α-spending** — standard asymmetric GS construction.
- Non-binding futility — DSMB could override; in practice they recommended stop.

## Citation

AIM-HIGH Investigators. *Niacin in patients with low HDL cholesterol levels receiving intensive statin therapy.* N Engl J Med. 2011;365(24):2255-2267. doi:10.1056/NEJMoa1107579. NCT00120289.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, GS with asymmetric futility |
| Arms | Niacin ER 1.5-2 g + simvastatin · Placebo + simvastatin |
| Primary endpoint | 5-component MACE |
| α / power | 0.05 (two-sided) / 0.85 |
| Assumed HR | 0.75 |
| Assumed control rate | ~2.7%/y |
| Spending α | Lan-DeMets OBF |
| Spending β | HSD γ = −2 |
| Analyses | IF 0.33, 0.67, 1.0 |
| Target events | ~800 |
| Planned N | 3,414 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 3, test.type = 4,             # asymmetric, non-binding futility
  alpha = 0.025, beta = 0.15,
  sfu = sfLDOF,
  sfl = sfHSD, sflpar = -2,
  timing = c(1/3, 2/3, 1),
  hr = 0.75, hr0 = 1,
  lambdaC = -log(1 - 0.027),
  R = 48, minfup = 36, ratio = 1
)
summary(d)
# events ≈ 800, N ≈ 3,400
# efficacy bounds ~ 3.71/2.62/2.03, futility bounds ~ -0.76/0.92
```

## What the trial found

- Stopped at IF ≈ 0.67 on DSMB recommendation.
- HR for primary at stop = **1.02** (95% CI 0.87–1.21).
- HDL rose 25%, TG fell 28%, LDL fell 13% vs placebo — yet no MACE benefit.
- Post-trial: niacin withdrawn as add-on therapy for residual CV risk despite favorable surrogates.

## Caveats & teaching points

- **Surrogate endpoint skepticism.** AIM-HIGH is a textbook example of surrogate-to-outcome translation failure. HDL modification no longer a recommended therapeutic target.
- **Futility z ≈ 0 at stop.** Observed test statistic between 0 and +1 at second interim — clearly not progressing toward efficacy boundary. HSD γ = −2 β-spending boundary around +0.92 at IF=0.67; observed statistic below it triggered futility.
- **Cost savings.** Stopping at IF 0.67 saved ~1/3 of total trial cost. For a 3,414-N CVOT, likely $30-50M savings.

## How this case validates designr

- Asymmetric GS with futility (gsDesign test.type=4).
- Agent interpretation of futility-stop results.
- Design vs surrogate-endpoint reasoning.
