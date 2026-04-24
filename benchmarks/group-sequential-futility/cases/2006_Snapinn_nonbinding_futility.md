# Snapinn et al. (2006) — Non-binding futility in Phase 3 trials

**Family:** group-sequential-futility · **Kind:** methodology-canonical · **Scope:** pragmatic framework for DSMB-discretionary futility stopping

## Why this case is in the corpus

- **Pragmatic methodology reference** for the de facto standard non-binding futility framework.
- Articulates the operational rationale: DSMB discretion must be preserved.
- Defines conditional power and predictive power as the decision-support metrics.
- FDA 2019 Adaptive Design Guidance endorses non-binding as preferred for regulatory submissions.

## Citation

Snapinn S, Chen MG, Jiang Q, Koutsoukos T. *Assessment of futility in clinical trials.* Pharm Stat. 2006;5(4):273-281. doi:10.1002/pst.216.

## Framework summary

| Rule type | Computation | Typical threshold |
|---|---|---|
| **Conditional power (CP)** | P(reject H0 at final \| current data, alternative true) | CP < 0.15-0.30 |
| **Predictive power (PP)** | Bayesian posterior-weighted CP | PP < 0.10 |
| **β-spending** | Analog of α-spending on the null side | Lan-DeMets OBF/Pocock |
| **Hybrid** | CP threshold AND observed trend unfavorable | DSMB-interpreted |

## Non-binding mechanics

- **α-spending**: computed as if futility boundary does NOT force stopping — preserves type-I error under DSMB override.
- **Power**: computed assuming DSMB WILL follow the futility rule — provides sample size to sponsor.
- **Type-I error preservation**: automatic under any override behavior.
- **Power loss vs binding**: typically 1-3% for realistic designs — small cost for operational flexibility.

## Reproducing the framework

```r
library(gsDesign)
# Non-binding futility: test.type = 4
d <- gsDesign(
  k = 3,
  test.type = 4,                      # non-binding futility
  alpha = 0.025,
  beta = 0.20,
  sfu = sfLDOF, sfupar = 0,           # OBF efficacy
  sfl = sfLDOF, sflpar = 0,           # OBF β-spending futility
  timing = c(0.33, 0.67, 1.0)
)

# Conditional power at interim
gsCP(d, i = 1, zi = observed_z_at_interim1, theta = d$theta[1])
# returns CP under design alternative; DSMB stops if < 0.20
```

```r
library(rpact)
# Non-binding futility in rpact
design <- getDesignGroupSequential(
  kMax = 3,
  alpha = 0.025,
  beta = 0.20,
  typeOfDesign = "asOF",
  typeBetaSpending = "bsOF",
  bindingFutility = FALSE,
  informationRates = c(0.33, 0.67, 1.0)
)
```

## Common futility rules in Phase 3

| Trial | Rule | Outcome |
|---|---|---|
| ILLUMINATE (2006) | Harm review (not pure futility) | Stopped for harm |
| AIM-HIGH (2011) | CP < 0.15 | DSMB stopped for futility |
| STRENGTH (2020) | CP-based + safety signal | Stopped for futility |
| TOPCAT (2014) | No pre-specified futility | Neutral result |

## How this case validates designr

- Primary reference for non-binding futility implementation in `designr`.
- Conditional / predictive power API specification.
- Pairs with Pampallona-Tsiatis (1994) binding framework to complete the futility family.
- Supports real-trial corpus entries (ILLUMINATE, ACCORD, AIM-HIGH, TOPCAT, STRENGTH) with common methodology underpinning.
