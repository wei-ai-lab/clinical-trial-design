# Lung-MAP (2014) — biomarker-driven master protocol for squamous NSCLC

**Family:** platform · **Endpoint:** per-sub-study OS or PFS · **Design feature:** shared biomarker screening + biomarker-matched sub-studies

## Why this case is in the corpus

- **First NCI-MATCH-style master protocol** in NSCLC.
- Single genomic screen assigns patients to matched targeted-therapy sub-studies.
- Public-private partnership: SWOG + FDA + Friends of Cancer Research + FNIH.

## Citation

Herbst RS, Gandara DR, Hirsch FR, et al. *Lung Master Protocol (Lung-MAP) — a biomarker-driven protocol for accelerating development of therapies for squamous cell lung cancer: SWOG S1400.* Clin Cancer Res. 2015;21(7):1514-1524. doi:10.1158/1078-0432.CCR-13-3473. NCT02154490.

## Design summary

| | |
|---|---|
| Design | Umbrella master protocol |
| Disease | Previously-treated squamous NSCLC (later all NSCLC) |
| Biomarker | FoundationOne CDx NGS |
| Arms (sub-studies) | PI3KCA→taselisib · CDK4/6→palbociclib · FGFR→AZD4547 · HGF/MET→rilotumumab · Non-match→immunotherapy |
| Per-sub-study design | Phase 2/3 OS or PFS |
| Shared | Screening, DSMB, infrastructure |
| α / power | Per-sub-study 0.05 / 0.90 |

## Reproducing the design

Per sub-study (example PFS with HR 0.65):

```r
library(gsDesign)
d <- nSurv(
  lambdaC = log(2)/4, hr = 0.65,
  alpha = 0.025, beta = 0.10,
  R = 24, minfup = 12
)
```

Platform element:
- No platform-level α control; each sub-study independent.
- Shared screening reduces per-arm biomarker-screening cost.
- Sub-studies can close (futility, obsolescence) or launch (new target) independently.

## Trial outcome (selected)

- Multiple sub-studies activated and completed since 2014.
- Palbociclib sub-study: PFS did not show benefit in CDK-alt cohort.
- Durvalumab + tremelimumab sub-study in non-match: tested Phase 2/3.
- Ongoing as of 2025 with IO and new-target expansions.
- Framework template for FOCUS4 (colorectal), Lung-MAP-2 extensions.

## How this case validates designr

- Umbrella-style master protocol reference.
- Biomarker-umbrella architecture (single screen, multiple matched therapies).
- Public-private partnership template.
