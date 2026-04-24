# PARADIGM-HF (2014) — Sacubitril/Valsartan vs Enalapril in HFrEF

**Family:** tte-ph · **Kind:** landmark Phase 3 · **Scope:** active-comparator event-driven superiority with early stopping

## Why this case is in the corpus

- **Landmark HFrEF trial** — first Phase 3 in decades to show superiority vs. an active ACEi comparator.
- Classic **event-driven PH** design: composite CV death + HF hospitalization, target 2,410 events.
- **Stopped early for efficacy** at pre-specified interim — teaches O'Brien-Fleming boundary in practice.
- **Run-in design** to exclude intolerant patients before randomization.
- FDA-approved Entresto (2015); changed HFrEF standard of care.

## Citation

- McMurray JJV, Packer M, Desai AS, et al. *Angiotensin-neprilysin inhibition versus enalapril in heart failure.* N Engl J Med. 2014 Sep 11;371(11):993-1004.
- McMurray JJ, Packer M, Desai AS, et al. *Rationale for and design of PARADIGM-HF.* Eur J Heart Fail. 2013 Sep;15(9):1062-73.

## Design summary

| Parameter | Value |
|---|---|
| Indication | HFrEF (LVEF ≤ 35%), NYHA II-IV, elevated natriuretic peptides |
| Arms | Sacubitril/valsartan 200 mg BID vs enalapril 10 mg BID (1:1) |
| Primary endpoint | CV death or first HF hospitalization (composite TTE) |
| α / power | 0.05 (2-sided) / 80% |
| Assumed HR | 0.85 |
| Control annual event rate | ~11.5% |
| Target events | 2,410 |
| Randomized N | 8,442 |
| Accrual / follow-up | 27 / 34 months planned |
| Interim | DSMB, O'Brien-Fleming efficacy boundary |

## Run-in design

1. **Enalapril run-in** (2 weeks, 10 mg BID): tolerance + washout.
2. **LCZ696 run-in** (4-6 weeks, uptitrated to 200 mg BID): tolerance.
3. Only patients tolerating both randomized — ~20% dropped in run-in.

Rationale: minimizes early discontinuation (power protection) but raises generalizability concerns.

## Early stopping

- Pre-specified O'Brien-Fleming-like efficacy boundary at interim.
- Median follow-up ~27 months at interim.
- Observed HR = 0.80 (0.73-0.87), P < 0.001 — crossed efficacy boundary.
- DSMB unanimously recommended stop March 2014.
- 2,031 events at stop (below 2,410 target).

## Operating characteristics (as planned)

```r
library(gsDesign)

# PARADIGM-HF-like design
d <- gsSurv(
  k = 2,                   # 1 interim + final
  alpha = 0.025,           # one-sided
  beta = 0.20,             # 80% power
  lambdaC = log(2) / (log(1/0.885)/0.115),  # control hazard from 11.5% annual
  hr = 0.85,               # alternative HR
  eta = 0.0,
  T = 34, minfup = 24,
  test.type = 2,           # O'Brien-Fleming
  sfu = sfLDOF
)
print(d)
# Target events ~ 2410
# Sample size ~ 8400
```

## Why PH was reasonable

- Composite CV death + HF hospitalization over 2-3 years.
- No mechanism expected to produce delayed effect (both drugs modulate RAAS/NEP).
- Log-rank and Cox proportional hazards appropriate.
- Schoenfeld residual check later confirmed PH held.

## Results

| Outcome | LCZ696 | Enalapril | HR (95% CI) |
|---|---|---|---|
| Primary composite | 914 (21.8%) | 1,117 (26.5%) | 0.80 (0.73-0.87) |
| CV death | 558 | 693 | 0.80 (0.71-0.89) |
| HF hospitalization | 537 | 658 | 0.79 (0.71-0.89) |
| All-cause death | 711 | 835 | 0.84 (0.76-0.93) |

## Regulatory & clinical impact

- FDA approval (Entresto, Novartis) July 2015.
- 2016+ ACC/AHA/HFSA HF guidelines: Class I recommendation ARNI > ACEi/ARB in HFrEF.
- Subsequent PIONEER-HF (in-hospital), PARAGON-HF (HFpEF), PARADISE-MI (post-MI).
- Foundation for subsequent HFrEF pillar additions (DAPA-HF SGLT2i).

## How this case validates designr

- Adds a **classic event-driven PH trial** to tte-ph with full parameters + early stopping.
- `designr` should reproduce target events / N / boundaries via `gsDesign::gsSurv` or `rpact`.
- Teaches: run-in design, active-comparator sizing, O'Brien-Fleming early stop, composite TTE endpoint.
- Companion to SOLVD-treatment (in corpus, 1991 enalapril) showing HFrEF design evolution.
