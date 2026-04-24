# Lung-MAP (2014-present) — Squamous NSCLC Umbrella

**Family:** umbrella · **Kind:** primary-results · **N:** ~6,000 screened · **Endpoint:** per-sub-study PFS/OS · **Design:** molecularly-stratified umbrella with 7-10 concurrent sub-studies

## Why this case is in the corpus

- **Canonical long-running molecular umbrella** for squamous cell lung cancer — 10+ years of operation with many sub-studies.
- Decade of operational evidence demonstrates feasibility, challenges, and evolving methodology of umbrella trials.
- FDA / SWOG / NCI partnership; template for subsequent umbrellas (Precision Promise pancreatic, I-SPY2 breast).
- Informed FDA 2022 Master Protocols guidance.

## Citation

Herbst RS, Gandara DR, Hirsch FR, et al. *Lung Master Protocol (Lung-MAP)-A Biomarker-Driven Protocol for Accelerating Development of Therapies for Squamous Cell Lung Cancer: SWOG S1400.* Clin Cancer Res. 2015 Apr 1;21(7):1514-24.

## Design architecture

| Element | Value |
|---|---|
| Disease | Advanced squamous NSCLC |
| Screening | Single NGS panel (FoundationOne CDx) |
| Structure | Multiple concurrent sub-studies (S1400A-I, etc.) |
| Biomarker-matched arms | Target-specific targeted therapies |
| Biomarker-unmatched arm | Immunotherapy (S1400A durvalumab) |
| Per-sub-study design | Phase 2 or 2/3, tailored to mechanism |

## Sub-studies (selected)

| Sub-study | Target | Drug | Status |
|---|---|---|---|
| S1400A | Non-matched | Durvalumab | Complete, ORR ~ 16% |
| S1400B | PIK3CA-mutant | Taselisib | Discontinued (toxicity) |
| S1400C | CDK4/6 amplif | Palbociclib | Mixed results |
| S1400D | FGFR altered | AZD4547 | Early PFS signal |
| S1400E | MET-positive | Rilotumumab+erlotinib | Negative |
| S1400G | HR-deficient | Talazoparib | Early signal |
| S1400I | Any | Nivolumab+ipilimumab vs nivolumab | Closed futility 2020 |
| S1800A | Non-matched | Ramucirumab+pembrolizumab | Graduated to Phase 3 |

## Per-sub-study design

```r
# Phase 2 sub-study (most sub-studies): Simon 2-stage
library(clinfun)
ph2simon(
  pu = 0.10, pa = 0.30,
  ep1 = 0.10, ep2 = 0.10,
  nmax = 60
)
# Typical: n1 = 10-15, total n = 40-60

# Phase 2/3 randomized sub-study (S1400I type)
library(gsDesign)
gsSurv(
  k = 2,
  test.type = 4,   # asymmetric boundaries
  alpha = 0.025, beta = 0.10, sided = 1,
  sfu = sfLDOF,
  lambdaC = log(2)/10,  # control median 10 months PFS
  hr = 0.67,            # target HR
  eta = 0, gamma = c(0,0,30),
  R = c(6,12,18), T = 36
)
```

## Accrual dynamics (2024)

- ~6,000 patients screened since 2014.
- ~50-60% biomarker-positive in some analyte bucket.
- ~30-40% assigned to a sub-study.
- Biomarker-matched sub-studies accrue slowly due to low prevalence.

## Operational lessons learned

- **Shared screening infrastructure** — single protocol, centralized NGS, multi-site accrual.
- **Sub-study heterogeneity** — each with own PI, sponsor, statistical plan.
- **Design flexibility** — Phase 2 Simon 2-stage to Phase 3 randomized GS.
- **Futility at scale** — several sub-studies closed early for negative results.
- **Graduation to confirmatory** — S1800A example of Phase 2 → Phase 3 within platform.

## Regulatory impact

- FDA accepted Lung-MAP-derived evidence for several accelerated approvals.
- Model for other molecular umbrellas.
- Informed **FDA 2022 Master Protocols guidance** — Lung-MAP is the prototype mature master protocol.
- PMDA and EMA familiar with design via SWOG international collaborations.

## How this case validates designr

- Adds the **largest operational umbrella** to the corpus — complements smaller academic umbrellas (BATTLE, ALCHEMIST).
- Per-sub-study design can be Phase 2 Simon 2-stage, Phase 2/3 GS, or full Phase 3 — `designr` must accommodate all these as sub-components within a master-protocol API.
- Teaches biomarker prevalence realities: umbrella viability requires sufficient frequency of target alterations (squamous NSCLC is a hard case).
