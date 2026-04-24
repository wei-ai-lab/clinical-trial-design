# FOCUS4 (2014-2022) — UK Colorectal Cancer Umbrella-MAMS

**Family:** umbrella · **Kind:** primary-results · **N:** ~1,400 (across cohorts) · **Endpoint:** PFS per cohort · **Design:** molecular-stratified umbrella with MAMS per cohort

## Why this case is in the corpus

- **Canonical European umbrella** for colorectal cancer maintenance — UK MRC Clinical Trials Unit-led, 5 parallel biomarker-defined cohorts plus an all-comers cohort.
- **Hybrid umbrella-MAMS architecture**: each cohort uses MAMS (Jaki-Magirr) design with interim drop-arm possibility.
- Complements Lung-MAP (NSCLC), NCI-MATCH, and BATTLE in the corpus as the canonical European variant.
- Informed FDA 2022 Master Protocols guidance and subsequent UK master-protocol trials.

## Citation

- Kaplan R, Maughan T, Crook A, Fisher D, Wilson R, Brown L, Parmar M. *Evaluating many treatments and biomarkers in oncology: a new design.* J Clin Oncol. 2013 Dec 20;31(36):4562-8.
- Adams RA, et al. *Capecitabine versus active monitoring in stable or responding metastatic colorectal cancer after 16 weeks of first-line therapy: results of the randomized FOCUS4-N trial.* JCO 2018.

## Architecture

| Cohort | Biomarker | Intervention |
|---|---|---|
| FOCUS4-A | HER2-amplified | Trastuzumab + lapatinib |
| FOCUS4-B | BRAF-mutant | Encorafenib + binimetinib + cetuximab |
| FOCUS4-C | PIK3CA-mutant / PTEN-loss | Capecitabine +/- aspirin |
| FOCUS4-D | KRAS-mutant | AZD6244 + AKT inhibitor |
| FOCUS4-N | Any (all-comers) | Capecitabine vs active monitoring |

## Per-cohort MAMS design

```r
# MAMS per cohort (Jaki-Magirr-Whitehead)
library(MAMS)
mams(
  K = 2,           # 2 experimental arms per cohort
  J = 2,           # 2 stages
  alpha = 0.025, power = 0.80,
  r = c(1, 2), r0 = c(1, 2),
  p0 = 0.5, p = 0.7
)

# Alternative: survival-based MAMS
library(gsDesign)
gsSurv(
  k = 2,
  test.type = 4,
  alpha = 0.025, beta = 0.20, sided = 1,
  sfu = sfLDOF,
  lambdaC = log(2)/10,
  hr = 0.67,
  R = c(6,12), T = 36
)
```

## FOCUS4-N primary result

- 254 patients, capecitabine vs active monitoring in post-first-line mCRC maintenance.
- PFS improved with capecitabine (HR ~ 0.4) but OS not significantly different.
- Established capecitabine maintenance as an option in selected patients.

## Accrual dynamics

- Overall target: 1,400 patients over 8 years.
- FOCUS4-N (all-comers): accrued fastest; primary report 2018.
- FOCUS4-C (aspirin in PIK3CA): closed negative 2022.
- FOCUS4-B (BRAF encorafenib): insufficient accrual → closed.
- FOCUS4-A (HER2): closed due to drug availability / accrual.
- FOCUS4-D: early closure.

## Biomarker prevalence reality

| Biomarker | Prevalence in mCRC | Accrual feasibility |
|---|---|---|
| BRAF V600E | ~ 8% | Marginal |
| HER2 amplification | ~ 2-5% | Very slow |
| PIK3CA mutation | ~ 15% | OK |
| KRAS mutation | ~ 40% | Fast |
| All-comers | 100% | Fastest |

## Impact

- **FDA 2022 Master Protocols guidance**: cited FOCUS4 as umbrella+MAMS hybrid exemplar.
- **UK MRC** subsequently launched multiple umbrella-MAMS variants (CELESTIAL, MATCHPOINT).
- Demonstrated feasibility of multi-biomarker MRC-led academic umbrella.

## How this case validates designr

- Complements Lung-MAP and BATTLE-2 in the umbrella corpus with a **MAMS-per-cohort hybrid** variant.
- `designr` should support nesting MAMS within an umbrella master protocol — shared screening + per-cohort MAMS sizing.
- Teaches operational realities: biomarker-matched cohorts require prevalence-aware feasibility analysis before committing.
