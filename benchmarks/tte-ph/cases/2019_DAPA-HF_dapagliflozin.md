# DAPA-HF (2019) — Dapagliflozin in HFrEF

**Family:** tte-ph · **Kind:** landmark Phase 3 · **Scope:** placebo-controlled event-driven PH on top of GDMT

## Why this case is in the corpus

- **Fourth-pillar HFrEF trial** — established SGLT2i on top of ARNI/BB/MRA quadruple therapy.
- First HF outcomes trial testing SGLT2i in **non-diabetic** HFrEF.
- Classic **event-driven PH** design with 90% power, placebo-controlled.
- Hierarchical secondary endpoint testing preserves family-wise error.
- Foundation for DELIVER (HFpEF), EMPEROR-Reduced, EMPEROR-Preserved SGLT2i HF programs.

## Citation

- McMurray JJV, Solomon SD, Inzucchi SE, et al. *Dapagliflozin in patients with heart failure and reduced ejection fraction.* N Engl J Med. 2019 Nov 21;381(21):1995-2008.
- McMurray JJV, DeMets DL, Inzucchi SE, et al. *Rationale for and design of DAPA-HF.* Eur J Heart Fail. 2019 May;21(5):665-675.

## Design summary

| Parameter | Value |
|---|---|
| Indication | HFrEF (LVEF ≤ 40%), NYHA II-IV, elevated NT-proBNP |
| Arms | Dapagliflozin 10 mg OD vs placebo (1:1) |
| Primary endpoint | Worsening HF event or CV death (composite TTE) |
| α / power | 0.05 (2-sided) / 90% |
| Assumed HR | 0.80 |
| Placebo annual event rate | ~11% |
| Target events | 844 |
| Randomized N | 4,744 |
| Accrual / follow-up | 18 / 24 months planned |

## Event-driven calculation (gsDesign2-style)

```r
library(gsDesign)

# DAPA-HF-like sizing
d <- gsSurv(
  k = 2,
  alpha = 0.025,            # one-sided
  beta = 0.10,              # 90% power
  lambdaC = -log(0.89)/1,   # ~11% annual hazard on placebo
  hr = 0.80,
  eta = 0,                  # no dropout assumed
  T = 24, minfup = 18,
  test.type = 2,
  sfu = sfLDOF
)
print(d)
# Target events ~ 844
# Sample size ~ 4750
```

## Stratification & baseline

- Type 2 diabetes status (~55% diabetic, ~45% non-diabetic) — pre-randomization stratification.
- Background therapy (contemporary GDMT):
  - ACEi/ARB/ARNI: ~95% (ARNI ~10%).
  - Beta-blocker: ~96%.
  - MRA: ~71%.
  - ICD / CRT: ~26% / ~8%.

## Results

| Outcome | Dapa | Placebo | HR (95% CI) |
|---|---|---|---|
| Primary composite | 386 (16.3%) | 502 (21.2%) | **0.74 (0.65-0.85)** |
| CV death | 227 | 273 | 0.82 (0.69-0.98) |
| HF hospitalization | 231 | 318 | 0.70 (0.59-0.83) |
| All-cause death | 276 | 329 | 0.83 (0.71-0.97) |
| KCCQ ≥ 5 point improvement | 58.3% | 50.9% | OR 1.15 |

Interaction by diabetes status: P = 0.89 (consistent).

## Hierarchical testing order

1. Primary composite — significant (P < 0.001).
2. Total HF hospitalizations + CV death (joint frailty) — significant.
3. KCCQ change — significant.
4. Kidney composite — NS (but trend).
5. All-cause death — significant.

Hierarchical gatekeeping preserved α across endpoints.

## Why PH held

- Mechanism (SGLT2i): osmotic diuresis, cardiac metabolism, preload reduction — effect begins within 28 days.
- KM curves separated early and diverged linearly (log-cumulative-hazard parallel).
- Schoenfeld residuals: no significant deviation from PH.
- Log-rank and Cox valid.

## Design lineage (HFrEF GDMT pillars)

| Year | Trial | Therapy | Event HR |
|---|---|---|---|
| 1991 | SOLVD-treatment (in corpus) | Enalapril (ACEi) | 0.84 |
| 1999 | MERIT-HF | Metoprolol (BB) | 0.65 |
| 2001 | COPERNICUS | Carvedilol (BB) | 0.65 |
| 2003 | EMPHASIS-HF | Eplerenone (MRA) | 0.76 |
| 2014 | PARADIGM-HF (in corpus) | Sacubitril/valsartan | 0.80 |
| 2019 | **DAPA-HF (this case)** | Dapagliflozin | **0.74** |
| 2020 | EMPEROR-Reduced | Empagliflozin | 0.75 |

## Regulatory & clinical impact

- FDA approval May 2020 for HFrEF regardless of diabetes status.
- 2022 AHA/ACC/HFSA HF guidelines: Class I (HFrEF) recommendation.
- Extended to HFpEF via DELIVER (2022) and EMPEROR-Preserved (2021).

## How this case validates designr

- Adds a **modern event-driven PH HF trial** to tte-ph alongside PARADIGM-HF.
- `designr` should reproduce target events / N via `gsDesign::gsSurv` with Haybittle-Peto-like interim.
- Hierarchical testing of secondaries: demonstrates gatekeeping in TTE design.
- Teaches: adding a pillar on top of existing GDMT is still powered when residual risk remains high.
- Companion to PARADIGM-HF showing HFrEF design lineage 2014-2019.
