# ENGAGE AF-TIMI 48 (2013) — Edoxaban NI vs warfarin, completes NOAC quartet

**Family:** fixed-non-inferiority · **Endpoint:** stroke or systemic embolism · **N:** 21,105 · **Design feature:** 2-dose Hochberg-adjusted NI vs warfarin

## Why this case is in the corpus

- **Fourth and final NOAC vs warfarin NI trial** — completes RE-LY / ROCKET-AF / ARISTOTLE / ENGAGE quartet.
- **2-dose Hochberg α-split** adjustment — unique in the NOAC quartet.
- Regulatory case of unexpected labeling: reduced efficacy at CrCl > 95 mL/min.
- Reference for NOAC class efficacy meta-analysis (71,683 patients across 4 trials).

## Citation

Giugliano RP, Ruff CT, Braunwald E, et al. *Edoxaban versus warfarin in patients with atrial fibrillation.* N Engl J Med. 2013;369(22):2093-2104. doi:10.1056/NEJMoa1310907. NCT00781391.

## Design summary

| | |
|---|---|
| Design | 3-arm double-blind double-dummy, NI vs warfarin |
| Population | Non-valvular AF, CHADS2 ≥ 2 |
| Arms | Edoxaban 60 mg, edoxaban 30 mg, warfarin INR 2-3 |
| Primary | Stroke or systemic embolism (on-treatment) |
| NI margin | HR ≤ 1.38 (50% preservation of warfarin-vs-placebo effect) |
| α (per dose) | 0.0125 (Hochberg for 2 comparisons) |
| FWER | 0.025 one-sided |
| Power | 0.80 per comparison |
| Warfarin TTR | 68.4% (moderate-to-high quality control) |
| Planned events | 672 |
| Planned N | 21,105 |

## Reproducing the design

```r
library(gsDesign)
# Per-comparison sample size (event-driven NI)
ss <- nSurv(
  lambdaC = -log(1 - 0.015),
  hr = 1.00,
  hr0 = 1.38,
  alpha = 0.0125,                # Hochberg per dose
  beta = 0.20,
  R = 30, minfup = 30, sided = 1
)
# ~ 400 events per comparison; ~ 7,000 per arm × 3 = 21,105

# Hochberg α-split for the two doses
library(gMCP)
hochberg_test(p_values = c(0.0005, 0.15), alpha = 0.025)
```

## Trial outcome

- **Edoxaban 60 mg**: stroke/SE HR 0.79 (97.5% CI 0.63-0.99), p < 0.001 NI; trend toward superiority (p = 0.04 two-sided, not significant with α-split).
- **Edoxaban 30 mg**: HR 1.07 (0.87-1.31) — NI met, trending higher ischemic stroke.
- **Major bleeding 60 mg**: HR 0.80 (0.71-0.91) — key safety win.
- **Intracranial hemorrhage**: HR 0.47 (0.34-0.63) — consistent with NOAC class.
- **Reduced efficacy at CrCl > 95**: HR 1.41 for stroke/SE; led to unusual labeling.

## How this case validates designr

- Standard NI margin 1.38 for AF NOAC class.
- Two-comparison Hochberg α-split implementation.
- Event-driven NI sample-size benchmark.
- Completes the NOAC quartet in the corpus (RE-LY, ROCKET-AF, ARISTOTLE, ENGAGE) — enables cross-trial class meta-analysis sensitivity.
