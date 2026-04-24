# NCI-MPACT (2017) — randomized matched-vs-non-matched umbrella

**Family:** umbrella · **Endpoint:** ORR · **N:** ~180 · **Design feature:** within-biomarker randomization to matched vs non-matched therapy

## Why this case is in the corpus

- **Early precision-oncology umbrella** pre-dating NCI-MATCH.
- Randomized matched-vs-non-matched design (stronger than single-arm per biomarker).
- Tests the biomarker-therapy hypothesis directly, not just the targeted-drug hypothesis.

## Citation

Do KT, O'Sullivan Coyne G, Hays JL, et al. *Phase I study of the mTOR inhibitor sapanisertib (TAK-228) in combination with the allosteric MEK inhibitor TAK-733 in patients with advanced solid tumors (NCI-MPACT).* Clin Cancer Res. 2021;27(15):4229-4237. doi:10.1158/1078-0432.CCR-20-5022. NCT01827384.

## Design summary

| | |
|---|---|
| Design | Randomized umbrella (matched vs non-matched) |
| Population | Advanced pre-treated solid tumors with actionable alteration |
| Pathway groups | DNA repair · PI3K/mTOR · RAS/RAF/MEK · Cell cycle |
| Randomization | 2:1 matched vs non-matched (within pathway) |
| Primary | ORR (RECIST) |
| α / power | 0.05 (two-sided) / 0.80 |
| Assumed RR | Matched 30% vs non-matched 10% |
| Planned N | ~180 across pathways |

## Reproducing the design

```r
library(gsDesign)
# Per-pathway: matched vs non-matched
d <- nBinomial(
  p1 = 0.30, p2 = 0.10,
  alpha = 0.05, beta = 0.20,
  ratio = 1,  # after randomization ratio adjustment
  sided = 2
)
```

## Trial outcome

- Small-N pathway-level signals observed.
- DNA repair (veliparib in BRCA/PALB2) showed matched > non-matched.
- PI3K pathway matched signal weaker.
- Supported biomarker-hypothesis testing as scientifically rigorous approach.
- Template for later umbrellas (MASTER, MoTriColor, ProfiLER).

## How this case validates designr

- Within-umbrella randomization design reference.
- Matched-vs-non-matched hypothesis test (distinct from single-arm basket).
- Pathway-level grouping template for molecular-target stratification.
