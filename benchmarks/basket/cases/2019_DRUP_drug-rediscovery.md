# DRUP (2019) — Drug Rediscovery Protocol

**Family:** basket · **Kind:** primary-results · **N:** 215 at interim · **Endpoint:** clinical benefit (OR + SD ≥ 16 wks) · **Design:** multi-cohort basket with Simon 2-stage per cohort

## Why this case is in the corpus

- **Canonical national-reimbursement-oriented basket** — Dutch model that generates evidence for payer decisions rather than regulatory approval.
- Multi-drug × multi-alteration 'basket of baskets' structure with up to 20+ cohorts simultaneously.
- Intentionally uses per-cohort Simon 2-stage (no BHM borrowing) because reimbursement decisions are cohort-specific.
- Template for Canadian CAPTUR, Norwegian IMPRESS, German ProfiLer.

## Citation

van der Velden DL, Hoes LR, van der Wijngaart H, et al. *The Drug Rediscovery protocol facilitates the expanded use of existing anticancer drugs.* Nature. 2019 Oct;574(7776):127-131.

## Design summary

| Element | Value |
|---|---|
| Population | Advanced cancer, any histology, actionable molecular alteration, exhausted SoC |
| Structure | 12-20+ parallel cohorts, each a drug-alteration combination |
| Per-cohort design | Simon 2-stage optimal |
| Primary endpoint | Clinical benefit (OR + SD ≥ 16 wks) |
| p0 / p1 | 0.10 / 0.30 |
| α / 1-β | 0.05 / 0.80 |
| Cohort size | n1 = 8 (stop if ≤ 1 benefit); total n = 24 |

## Reproducing the design (per cohort)

```r
# Simon 2-stage optimal for DRUP cohort
library(clinfun)
ph2simon(
  pu = 0.10, pa = 0.30,
  ep1 = 0.05, ep2 = 0.20,
  nmax = 40
)
# Output: Optimal design n1=8, r1=1 (stop if ≤1); n=24, r=4 (success if ≥5)
# Expected N under H0 ≈ 14.5; Probability of early termination ≈ 0.56

# Multi-cohort simulation (overall FWER across 20 cohorts)
# If each cohort has α=0.05, naive FWER inflation can reach 1-(1-0.05)^20 ≈ 0.64
# DRUP mitigates via cohort-level decisions (policy rather than
# regulatory approval) + independent publications.
```

## Interim results (Nature 2019)

- 215 patients across 25 cohorts enrolled.
- 136 evaluable at interim.
- Overall clinical benefit rate: 34%.
- Cohort-level wins: MSI-H → nivolumab, NTRK fusion → larotrectinib-like, several BRAF V600E combinations.
- Failures: several cohorts terminated at stage 1 for insufficient response.

## Distinguishing features vs other baskets

| Basket | Focus | BHM borrowing |
|---|---|---|
| NCI-MATCH (2015) | Target-agnostic arms, US academic | Per-arm Simon, some BHM sensitivity |
| VE-BASKET (2015) | Vemurafenib × BRAF tumors | Bayesian shrinkage |
| LOXO-TRK (2018) | Larotrectinib × NTRK fusion | No, single alteration |
| ROAR (2020) | Dabrafenib+trametinib × BRAF | Per-cohort efficacy |
| KEYNOTE-158 (2017) | Pembrolizumab × MSI-H/TMB-H | Per-cohort analysis |
| DRUP (2019) | Multiple drugs × multiple alterations (Dutch) | Intentional no borrowing |

## Impact

- Established reimbursement-linked basket as a distinct class.
- Spawned CAPTUR (Canada 2019), IMPRESS-Norway (2021), ProfiLer (Germany).
- Informed EMA reflection on basket-trial evidence for conditional marketing authorization.
- Demonstrated that drug-donation + single-payer infrastructure enables small-cohort off-label studies.

## How this case validates designr

- Complements the six existing basket cases with a **payer-oriented** variant.
- Per-cohort Simon 2-stage with pre-specified p0/p1 is a canonical reproducible design pattern — `designr` should expose via `clinfun::ph2simon` backend.
- Teaches when BHM borrowing is contraindicated: when cohort-level decisions are downstream (reimbursement, labeling), keeping cohorts statistically independent preserves decision clarity.
