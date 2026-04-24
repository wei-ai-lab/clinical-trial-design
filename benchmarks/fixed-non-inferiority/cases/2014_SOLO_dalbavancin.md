# SOLO I & II (2014) — dalbavancin for ABSSSI

**Family:** fixed-non-inferiority · **Endpoint:** binary early clinical response · **N:** 1,289 per trial (two trials) · **Design feature:** FDA ABSSSI guidance margin, two-trial requirement

## Why this case is in the corpus

- **Antibiotic NI with FDA-specified absolute margin.** The ABSSSI guidance (2013) mandates 10% absolute margin on early clinical response — a classic regulatory-specified margin.
- **Two-trial pivotal requirement.** FDA antibacterial guidance requires two adequate and well-controlled trials; SOLO I and II were identically designed and run in parallel.
- **Early clinical response (ECR) endpoint** at 48-72 h — short, objectively measurable, population-enriched for treatment effect.

## Citation

Boucher HW, Wilcox M, Talbot GH, et al. *Once-weekly dalbavancin versus daily conventional therapy for skin infection.* N Engl J Med. 2014;370(23):2169-2179. doi:10.1056/NEJMoa1310480. NCT01339091 (SOLO I) + NCT01431339 (SOLO II).

FDA Guidance: *Acute Bacterial Skin and Skin Structure Infections: Developing Drugs for Treatment* (2013).

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC (with sham daily injection in dalbavancin arm), 1:1 |
| Arms | Dalbavancin (1 g day 1 + 500 mg day 8) · Vancomycin/linezolid × ≥ 10 days |
| Primary endpoint | Early clinical response at 48-72 h |
| Comparison | Non-inferiority, absolute margin Δ = 10% |
| α / power | 0.025 (one-sided) / 0.90 |
| Assumed response rate | 80% (both arms under H₀: NI) |
| Planned N per trial | 1,289 |

## Reproducing the calculation

For binary NI with absolute margin Δ = 0.10, p = 0.80:

```r
library(gsDesign)
nBinomial(p1 = 0.80, p2 = 0.80, delta0 = 0.10,
          alpha = 0.025, beta = 0.10, sided = 1)
# n per arm ≈ 630 → total ≈ 1,260 per trial
```

## What the trial found

| Trial | Dalbavancin ECR | Comparator ECR | Difference | NI met? |
|---|---|---|---|---|
| SOLO I | 83.3% | 81.8% | +1.5% (95% CI −4.0 to +7.0) | ✅ |
| SOLO II | 76.8% | 78.3% | −1.5% (95% CI −7.4 to +4.3) | ✅ |

Both trials independently demonstrated NI. Approved by FDA in 2014.

## Caveats & teaching points

- **Two-trial requirement nuance.** Neither trial needs to independently reject at a stricter α; the regulatory standard is two independent demonstrations at α = 0.025 one-sided. Effective type I error across the program is ~0.025² = 0.000625 (approximately, ignoring correlations).
- **FDA-mandated margin** removes design discretion — the sponsor cannot argue for a 15% margin even if clinical context suggests it's acceptable.
- **ECR endpoint enrichment.** Using 48-72h ECR rather than 14-day test-of-cure concentrates events and reduces N — a standard methodological shift in post-2010 ABSSSI trials.

## How this case validates designr

- Binary NI with absolute margin (most common antibiotic scenario).
- Agent reasoning about FDA-mandated guidance margins — should NOT recompute if guidance specifies Δ.
- Two-trial pivotal package structure.
