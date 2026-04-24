# Chen-DeMets-Lan (2004) — conditional-power SSR in the promising zone

**Family:** adaptive-ssr · **Endpoint:** TTE or continuous · **Design feature:** CP-triggered SSR without α adjustment if restricted to promising zone

## Why this case is in the corpus

- **The "free lunch" result** — Chen-DeMets-Lan proved that if you only increase N when conditional power is in a specific range (the "promising zone"), you can use a conventional z-statistic without α adjustment.
- Precursor to Mehta-Pocock (2011) which generalized this with a cleaner operational framework.
- Widely cited in FDA Adaptive Designs Guidance as a Type-I-preserving shortcut.

## Citation

Chen YHJ, DeMets DL, Lan KKG. *Increasing the sample size when the unblinded interim result is promising.* Statistics in Medicine. 2004;23(7):1023-1038. doi:10.1002/sim.1688.

## The key result

Let CP(ẑ₁, π) be the conditional power given interim z-statistic ẑ₁ and assumed effect π. The "promising zone" is:

```
CP(ẑ₁, π) ∈ [CP_L, 1 − α)
```

where `CP_L` is chosen (often 0.5) such that SSR is only triggered in the promising zone — *not* in the unpromising zone (where trial should stop for futility or continue unchanged) and not in the very-promising zone (where trial will succeed at planned N anyway).

**Key theorem (CDL 2004):** If SSR is only allowed in the promising zone and the new N satisfies a specific bound based on ẑ₁, then the conventional z-test with the final data controls α exactly — no CHW weighting needed.

## Illustrative design

| | |
|---|---|
| Endpoint | TTE, assumed HR 0.75 |
| α / power | 0.025 (one-sided) / 0.90 |
| Planned events | 250 |
| Planned N | 400 |
| Interim trigger | IF = 0.5 (125 events) |
| Promising zone | CP ∈ [0.50, 0.80) assuming observed ẑ₁ |
| SSR rule | If promising, increase events to 350 (40% increase, cap) |
| Test | Conventional log-rank z at final — no CHW weighting |

## Reproducing the design

```r
library(rpact)
d <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.10,
  typeOfDesign = "OF"
)
ss <- getSampleSizeSurvival(
  design = d,
  hazardRatio = 0.75,
  lambda2 = -log(0.7)/12,
  accrualTime = 12, followUpTime = 24, dropoutRate1 = 0.05, dropoutRate2 = 0.05
)
# CDL-style SSR: check CP at interim, re-compute event target if promising
```

## What the method enables

- **No α adjustment in promising zone** — conventional test used; simpler to interpret and defend to regulators.
- **Natural triage:** unpromising → futility, promising → SSR, very-promising → already success.

## Caveats & teaching points

- **CP must be computed under assumed effect, not observed.** CP under observed effect (which the Mehta-Pocock paper notes) leads to aggressive SSR and is not what CDL proved.
- **Cap on N increase matters.** Unbounded increases can re-introduce α inflation in edge cases. Typical cap is 1.5–2× original N.
- **Promising-zone boundary choice** affects operating characteristics — narrower zone = more conservative (less SSR triggered but cleaner α).

## How this case validates designr

- Methodology benchmark for promising-zone SSR.
- Foundation for Mehta-Pocock (2011) which designr should recommend as the modern operational version.
- Supports rpact `getDesignInverseNormal` + conditional-power workflows.
