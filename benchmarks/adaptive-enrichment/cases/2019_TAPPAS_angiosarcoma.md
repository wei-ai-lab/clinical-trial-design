# TAPPAS (2019) — TRC105 + pazopanib in advanced angiosarcoma

**Family:** adaptive-enrichment · **Endpoint:** TTE PFS · **N:** 128 · **Design feature:** Phase 3 adaptive enrichment using Jenkins-Stone-Jennison-like framework; trial failed at interim for futility

## Why this case is in the corpus

- **Real Phase 3 adaptive enrichment** executed to completion — rare example in a rare cancer setting.
- Biomarker-defined cutaneous angiosarcoma subgroup vs all-comers angiosarcoma.
- Teaching case for adaptive enrichment **failure mode** — selection rule triggered, but effect did not materialize in selected subgroup either.

## Citation

Jones RL, Ravi V, Brohl AS, et al. *Results of the TAPPAS trial: an adaptive enrichment phase III trial of TRC105 and pazopanib versus pazopanib alone in patients with advanced angiosarcoma (AS).* Annals of Oncology. 2019;30(suppl_5):v683-v684. doi:10.1093/annonc/mdz283.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Adaptive enrichment, randomized 1:1 |
| Population | Advanced angiosarcoma (cutaneous + non-cutaneous) |
| Arms | TRC105 (carotuximab) + pazopanib · Pazopanib |
| Primary endpoint | PFS |
| α / power | 0.025 (one-sided) / 0.80 |
| Assumed HR (full) | 0.67 |
| Assumed HR (cutaneous) | 0.50 |
| Biomarker | Cutaneous subtype (clinical, not molecular; ~50% prevalence) |
| Spending | Inverse-normal combination test with closed testing |
| Planned N | 340 (120 stage 1, 220 stage 2) |
| Actual N | 128 (stopped early) |

## Reproducing the design

```r
library(asd)
library(rpact)
d <- getDesignInverseNormal(
  kMax = 2, alpha = 0.025, beta = 0.20,
  typeOfDesign = "OF"
)
# Jenkins-Stone-Jennison style: stage 1 all-comers, select cutaneous vs full at interim
```

## What the trial found

- Interim analysis triggered **selection / stop decision**. Based on DMC's application of the pre-specified rule, the trial was stopped for futility.
- Point estimates: Full population HR ~0.98; cutaneous subgroup HR ~0.82 — neither met pre-specified thresholds.
- Sponsor (Tracon Pharma) terminated TRC105 development in angiosarcoma.

## Caveats & teaching points

- **Adaptive enrichment cannot save a drug with no true signal.** The selection rule correctly identified lack of efficacy and triggered futility — working as designed.
- **Clinical subtype biomarker.** Unlike molecular biomarkers (PD-L1, EGFR), cutaneous-vs-non-cutaneous is a clinical distinction; this simplified enrollment logistics (no assay turnaround) at the cost of biological specificity.
- **Rare-disease adaptive design** has unique challenges — stage 1 sample sizes are small, so biomarker selection power is low. TAPPAS is a useful example of what operational risk looks like.
- **Data sharing** — TAPPAS published Full + interim data, which is valuable for the adaptive-enrichment methodology literature.

## How this case validates designr

- Real Phase 3 adaptive enrichment with published operational details.
- Illustrates futility stopping under adaptive enrichment rule.
- Rare-disease Phase 3 context — different design trade-offs than large oncology.
