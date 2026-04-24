# LIFE (1999) — losartan vs atenolol in hypertension with LVH

**Family:** tte-ph · **Endpoint:** TTE composite MACE · **N:** 9,193 · **Design feature:** active-comparator PH-superiority in hypertension

## Why this case is in the corpus

- **Active-comparator PH-superiority** — not placebo-controlled; both arms lower BP, so endpoint benefit must exceed atenolol.
- First trial to show **ARB superiority over β-blocker** for CV outcomes.
- Teaches PH design with two active treatments at BP parity.

## Citation

Dahlén B, Devereux RB, Kjeldsen SE, et al. *Cardiovascular morbidity and mortality in the Losartan Intervention for Endpoint reduction in hypertension study (LIFE).* Lancet. 2002;359(9311):995-1003.

## Design summary

| | |
|---|---|
| Design | RDBPC, 1:1 active-comparator |
| Population | HTN with LVH on ECG, age 55-80 |
| Arms | Losartan 50-100 mg · Atenolol 50-100 mg |
| Primary endpoint | Composite: CV death + MI + stroke |
| α / power | 0.05 (two-sided) / 0.80 |
| Assumed HR | 0.85 |
| Assumed 4-yr MACE rate | 11% atenolol arm |
| Planned N | 9,193 |
| Target events | ~1,040 |

## Reproducing the design

```r
library(gsDesign)
d <- nSurv(
  lambdaC = -log(0.89)/4, hr = 0.85,
  alpha = 0.025, beta = 0.20,
  R = 18, minfup = 48
)
# events ≈ 1040, N ≈ 9200
```

## Trial outcome

- Median follow-up 4.8 years.
- Primary: HR **0.87** (95% CI 0.77-0.98), p = 0.021.
- Stroke: HR 0.75 (driver of composite).
- BP reduction similar between arms (~30/16 mmHg) — benefit attributed to losartan-specific effects.

## How this case validates designr

- Active-comparator PH-superiority design.
- Composite endpoint handling.
- Design-to-outcome agreement (HR 0.87 vs assumed 0.85).
