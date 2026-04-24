# EMA Bioequivalence Guideline (2010) — EU BE Reference

**Family:** crossover · **Kind:** regulatory-guidance · **Scope:** EU framework for BE demonstration including NTI and RSABE

## Why this case is in the corpus

- **Canonical EU regulatory reference** for BE studies — counterpart to FDA ABE (2001) and NTI BE (2015) in the corpus.
- Defines the 80-125% standard limits, NTI-specific tighter limits (90-111%), and highly-variable drug RSABE (EMA k=0.760).
- Diverges from FDA on both NTI handling and RSABE scaling — critical for multi-region development.
- Most-referenced BE document in EU applications (DCP, CP, MRP).

## Citation

European Medicines Agency. *Guideline on the Investigation of Bioequivalence.* CPMP/EWP/QWP/1401/98 Rev. 1/ Corr. January 20, 2010. (Later amended by EMA bioequivalence statistical addendum 2015.)

## BE framework summary

| Drug category | Cmax limit | AUC limit | Design |
|---|---|---|---|
| Standard | 80.00-125.00% | 80.00-125.00% | 2x2 or replicate |
| NTI (EMA list) | 90.00-111.11% | 90.00-111.11% | Replicate |
| Highly variable (CV_W Cmax > 30%) | Scaled, up to 69.84-143.19% | 80.00-125.00% | Replicate required |

## RSABE scaling (EMA variant)

```r
# EMA reference-scaled ABE for highly variable Cmax (CV_WR > 30%)
# Scaling constant k = 0.760 (vs FDA's k = 0.89291)
# Upper limit (scaled) = exp(k * sigma_WR)
# Lower limit (scaled) = 1 / Upper
# Plus: point estimate (test/reference GMR) constrained to [80%, 125%]

library(PowerTOST)

# Example: CV_WR = 0.40 for Cmax, target 90% power, GMR = 0.95
sampleN.scABEL(
  alpha = 0.05, targetpower = 0.90,
  theta0 = 0.95,
  CV = 0.40,
  design = "2x3x3",   # 3-period partial replicate
  regulator = "EMA"   # uses k = 0.760 scaling
)
# Typical result: 28-36 subjects

# Standard ABE (non-replicate) for comparison
sampleN.TOST(
  alpha = 0.05, targetpower = 0.90,
  theta0 = 0.95, CV = 0.20,
  design = "2x2x2"
)
```

## NTI drug list (EMA-specific)

- Ciclosporin, tacrolimus, sirolimus, everolimus
- Levothyroxine
- Phenytoin, carbamazepine
- Lithium
- Warfarin, digoxin
- Theophylline

## Sample-size magnitudes

- Standard 2×2, CV_W = 0.20, GMR = 0.95: ~24 subjects for 80% power.
- RSABE 2×2×4 replicate, CV_W = 0.40, GMR = 0.95: ~32 subjects for 90% power.
- NTI 2×2×4 replicate, CV_W = 0.10, GMR = 0.95: ~24-30 subjects for 90% power.

## Key EU vs US differences

| Issue | EMA (2010) | FDA |
|---|---|---|
| RSABE scaling | k=0.760 | k=0.89291 |
| NTI limits | Static 90-111% (AUC + Cmax) | Reference-scaled NTI-specific |
| Highly variable AUC | Not scaled | Scaled with RSABE |
| Endogenous compound baseline | Required | Product-specific guidance |

## ICH M13A harmonization (2022-2023)

- Working draft converges FDA/EMA/PMDA methodologies.
- Finalized 2023 (preliminary); implementation in regional guidelines ongoing.
- Expected to reduce regulatory divergence on RSABE and NTI.

## How this case validates designr

- Adds the **EU regulatory counterpart** to the US BE references already in the corpus.
- `designr` should expose `PowerTOST::sampleN.scABEL(regulator = "EMA")` as a design class alongside FDA variants.
- Teaching case: multi-region development requires both FDA and EMA BE sizing — understanding divergence is essential for global generic programs.
