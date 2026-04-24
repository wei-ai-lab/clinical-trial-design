# ONTARGET (2008) — Telmisartan vs ramipril NI in high-risk CV patients

**Family:** fixed-non-inferiority · **Endpoint:** 4-point MACE+HHF composite · **N:** 25,620 · **Design feature:** canonical 50%-preservation-of-effect NI margin derivation

## Why this case is in the corpus

- **Canonical 50%-preservation-of-effect NI margin derivation** — textbook worked example.
- Large-scale NI trial (N = 25,620) in high-risk vascular disease.
- Established ARB (telmisartan) as alternative to ACEi (ramipril) for vascular protection.
- Template for subsequent CV NI trials including the NOAC quartet.

## Citation

ONTARGET Investigators; Yusuf S, Teo KK, Pogue J, et al. *Telmisartan, ramipril, or both in patients at high risk for vascular events.* N Engl J Med. 2008;358(15):1547-1559. doi:10.1056/NEJMoa0801317. NCT00153101.

## Design summary

| | |
|---|---|
| Design | 3-arm double-blind double-dummy |
| Population | High-risk vascular (CAD, PAD, CVD, or high-risk DM) ≥ 55 y |
| Arms | Telmisartan 80, ramipril 10, combination |
| Primary | CV death, MI, stroke, or HHF |
| Comparison | Telmisartan vs ramipril (NI); combination vs ramipril (NI) |
| NI margin | HR ≤ 1.13 (50% preservation of HOPE-trial benefit) |
| α | 0.025 one-sided |
| Power | 0.80 under HR = 1.00 |
| Control event rate | ~4.5% annual |
| Planned events | 4,002 |
| Planned N | 25,620 |

## NI margin derivation (textbook worked example)

```r
# Step 1: Historical effect of ramipril vs placebo (HOPE trial)
#   HR = 0.78, 95% CI [0.70, 0.86]
#   log-HR = -0.248, SE = 0.052
#   95% upper bound on log-HR = -0.145 → placebo vs ramipril upper bound HR ~ 1.16
#   Note: original HOPE upper bound on placebo/ramipril HR ~ 1.30

# Step 2: Preserve 50% of the effect
#   NI margin on telmisartan/ramipril HR:
#     ln(δ_NI) = 0.50 × ln(1.30) = 0.50 × 0.262 = 0.131
#     δ_NI = exp(0.131) ≈ 1.14 → rounded to 1.13

library(gsDesign)
ss <- nSurv(
  lambdaC = -log(1 - 0.045),
  hr = 1.00,                     # assumed true HR
  hr0 = 1.13,                    # NI margin
  alpha = 0.025, beta = 0.20,
  R = 36, minfup = 30, sided = 1
)
# ~ 4,000 events; ~ 25,600 subjects
```

## Trial outcome

- **Telmisartan vs ramipril**: HR 1.01 (95% CI 0.94-1.09), upper CI < 1.13 → **NI declared**.
- **Combination vs ramipril**: HR 0.99 (0.92-1.07) → NI; but higher AE rate (hyperkalemia, renal dysfunction, hypotension).
- Telmisartan better tolerated (lower cough, angioedema); more hypotension.
- Reshaped guidelines: ARB recommended alternative when ACEi intolerant in vascular protection.

## How this case validates designr

- **Canonical NI margin derivation** via 50% preservation of effect.
- Event-driven sample-size calculation benchmark for CV NI trials.
- Teaching reference for FDA 2016 NI Guidance preservation-based methodology.
- Historical anchor for subsequent CV NI trials (NOACs, novel antiplatelets, novel lipid-lowering vs statin).
