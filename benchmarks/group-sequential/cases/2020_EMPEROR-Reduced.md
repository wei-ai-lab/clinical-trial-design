# EMPEROR-Reduced (2020) — empagliflozin in HFrEF

**Family:** group-sequential · **Endpoint:** TTE composite · **N:** 3,730 · **Design feature:** 2-look GS with late interim (IF=0.80)

## Why this case is in the corpus

- **Parallel modern SGLT2i HF trial** to DAPA-HF. Different sponsor, different dose, different spending-function timing.
- **Late single interim (IF=0.80)** — more α preserved for final vs IF=0.60. Illustrates flexibility in look timing.
- Ran to final — standard outcome for well-calibrated modern GS.

## Citation

Packer M, Anker SD, Butler J, et al. *Cardiovascular and renal outcomes with empagliflozin in heart failure.* N Engl J Med. 2020;383(15):1413-1424. doi:10.1056/NEJMoa2022190. NCT03057977.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 1:1, GS |
| Arms | Empagliflozin 10 mg · Placebo |
| Primary endpoint | CV death + HF hospitalization |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.80 |
| Assumed control rate | ~14.5% per year |
| Spending | Lan-DeMets OBF, 2 looks (IF 0.80, 1.0) |
| Target events | 841 |
| Planned N | 3,730 |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 2, test.type = 1,
  alpha = 0.025, beta = 0.10,
  sfu = sfLDOF,
  timing = c(0.80, 1.0),
  hr = 0.80, hr0 = 1,
  lambdaC = -log(1 - 0.145),
  R = 18, minfup = 16, ratio = 1
)
# events ≈ 840; N ≈ 3,700; z-bounds ~ 2.25 / 2.00
```

## What the trial found

- HR primary = **0.75** (95% CI 0.65–0.86), p < 0.001.
- Consistent with DAPA-HF finding in the same class (SGLT2i in HFrEF).
- Cross-validation of the drug class on two independent modern trials — a powerful evidence base for guideline updates.

## Caveats & teaching points

- **Interim timing trade-off.** Late interim (IF=0.80) → stricter final boundary (2.00 not 2.05) but earlier interims are easier. Choice depends on expected-stop probability and operational cost of running longer.
- **Class effect validation.** DAPA-HF and EMPEROR-Reduced are independent with similar designs and similar results — a robust replication pattern that contrasts with cases where second trial fails (ENHANCE/IMPROVE-IT).
- **Event-driven sizing stability.** Both SGLT2i HFrEF trials required ~840 events under similar HR/α/power and similar control rates. Design parameters converge across sponsors.

## How this case validates designr

- Late-interim 2-look GS.
- Agent reasoning about interim timing trade-offs.
- Cross-trial consistency check (DAPA-HF vs EMPEROR-Reduced).
