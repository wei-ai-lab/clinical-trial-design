# ROCKET-AF (2011) — rivaroxaban vs warfarin in AF

**Family:** fixed-non-inferiority · **Endpoint:** TTE stroke/SE · **N:** 14,264 · **Design feature:** double-blind double-dummy, higher-risk population

## Why this case is in the corpus

- Second major NOAC NI trial — pairs with RE-LY, ARISTOTLE, ENGAGE AF-TIMI 48 as the NOAC quartet.
- **Double-blind double-dummy** design (vs PROBE in RE-LY/ARISTOTLE) — operationally complex but analytically cleaner.
- **Higher-risk population** (CHADS2 ≥ 2) concentrates events, reducing N relative to a general AF population despite similar effect assumptions.

## Citation

Patel MR, Mahaffey KW, Garg J, et al. *Rivaroxaban versus warfarin in nonvalvular atrial fibrillation.* N Engl J Med. 2011;365(10):883-891. doi:10.1056/NEJMoa1009638. NCT00403767.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, double-dummy, 1:1 |
| Population | Non-valvular AF, CHADS2 ≥ 2 |
| Arms | Rivaroxaban 20 mg (15 mg if CrCl 30-49) · Warfarin |
| Primary endpoint | Stroke or systemic embolism |
| Comparison | Non-inferiority, margin HR = 1.46 |
| α / power | 0.025 (one-sided) / 0.95 |
| Assumed HR | 0.83 |
| Assumed warfarin annual event rate | 2.2% |
| Target events | 405 |
| Planned N | 14,264 |

## Reproducing the calculation

```r
library(gsDesign)
nEvents(hr = 0.83, hr0 = 1.46, alpha = 0.025, beta = 0.05, ratio = 1)
# events ≈ 400

nSurv(
  lambdaC = -log(1 - 0.022),
  hr      = 0.83, hr0 = 1.46,
  alpha   = 0.025, beta = 0.05,
  T       = 47, minfup = 23, R = 24
)
# N ≈ 14,000
```

## What the trial found

- HR = **0.79** (95% CI 0.66–0.96) per-protocol, HR 0.88 (95% CI 0.74–1.03) ITT.
- NI met on primary per-protocol analysis.
- Superiority narrowly missed on ITT.
- Hybrid per-protocol primary for NI is standard — ITT can dilute NI by counting non-adherers' events against the experimental arm.

## Caveats & teaching points

- **Per-protocol vs ITT.** NI guidance (FDA 2016) recommends analyzing **both** and requiring NI on both for robustness. ROCKET-AF reported per-protocol as primary with ITT supportive — acceptable but sensitive to non-adherence patterns.
- **Double-dummy logistics.** Double-blinding warfarin (with sham INR) is operationally burdensome but eliminates open-label bias. The cost: slower enrollment, higher dropout.
- **Higher-risk enrollment enriches events.** Moving CHADS2 cutoff from ≥1 to ≥2 ~doubles the annual event rate, reducing required N by ~2×.

## How this case validates designr

- TTE NI with design-time HR assumption ≠ 1.0 (modest advantage assumed).
- Double-dummy blinding reflected in effect assumptions (no open-label ascertainment bias adjustment needed).
- Event-rate enrichment via population selection.
