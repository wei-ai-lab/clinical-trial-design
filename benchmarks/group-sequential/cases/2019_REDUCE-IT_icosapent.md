# REDUCE-IT (2019) — icosapent ethyl in hypertriglyceridemia

**Family:** group-sequential · **Endpoint:** TTE MACE composite · **N:** 8,179 · **Design feature:** 3-look OBF, unexpectedly strong effect

## Why this case is in the corpus

- GS design where **observed effect far exceeded planned** (HR 0.75 vs planned 0.85) — ran to final anyway because the trial was already mature.
- **Placebo controversy** (mineral oil, possibly bioactive) is a design-choice caution — illustrates that the placebo is not always neutral.
- Moderate-size CVOT with unusual omega-3 mechanism.

## Citation

Bhatt DL, Steg PG, Miller M, et al. *Cardiovascular risk reduction with icosapent ethyl for hypertriglyceridemia.* N Engl J Med. 2019;380(1):11-22. doi:10.1056/NEJMoa1812792. NCT01492361.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, GS |
| Arms | Icosapent ethyl 2 g bid · Placebo (mineral oil) |
| Primary endpoint | 5-component MACE |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.85 |
| Assumed control rate | 5.5%/y |
| Spending | Lan-DeMets OBF, 3 looks (IF 0.60, 0.80, 1.0) |
| Target events | 1,612 |
| Planned N | 8,179 |
| Follow-up | Median 4.9 years |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 3, test.type = 1,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF,
  timing = c(0.60, 0.80, 1.0),
  hr = 0.85, hr0 = 1,
  lambdaC = -log(1 - 0.055),
  R = 45, minfup = 45, ratio = 1
)
# events ≈ 1,612; N ≈ 8,180
```

## What the trial found

- HR primary MACE = **0.75** (95% CI 0.68–0.83), p < 0.001.
- 25% relative risk reduction — much larger than planned 15%.
- Follow-up STRENGTH trial (omega-3 carboxylic acids with corn-oil placebo) found no benefit, fueling mineral-oil-placebo speculation.

## Caveats & teaching points

- **Placebo is not always neutral.** Mineral oil may have inflammatory effects; STRENGTH used corn oil and failed. Design-stage placebo choice has interpretation consequences beyond sample size.
- **Larger-than-expected effect doesn't always trigger early stop.** Trial was far enough into follow-up that waiting for the planned analyses was operationally simpler than DSMB-driven interim stop.
- **Ethnicity and population generalization.** REDUCE-IT enrolled 70% US/EU; effect in South/East Asian populations uncertain.

## How this case validates designr

- Standard 3-look GS with OBF spending.
- Agent teaching: placebo choice is a design parameter, not just a run detail.
- Comparison with STRENGTH for different placebo / same class.
