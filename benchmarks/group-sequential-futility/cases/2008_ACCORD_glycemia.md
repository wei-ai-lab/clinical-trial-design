# ACCORD glycemia arm (2008) — intensive vs standard glycemic control in T2D

**Family:** group-sequential-futility (harm-stopped) · **Endpoint:** TTE MACE · **N:** 10,251 · **Design feature:** DSMB harm-stop on mortality

## Why this case is in the corpus

- **Harm-stop rather than futility-stop** — same GS monitoring framework handles both. Illustrates how a non-binding DSMB leverages the design's asymmetric structure for safety-driven decisions.
- **Factorial design** — glycemia × BP × lipid. One factor stopped while others continued.
- Teaching case for **mortality monitoring** in large CVOT programs.

## Citation

Action to Control Cardiovascular Risk in Diabetes Study Group. *Effects of intensive glucose lowering in type 2 diabetes.* N Engl J Med. 2008;358(24):2545-2559. doi:10.1056/NEJMoa0802743. NCT00000620.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, factorial (glycemia, BP, lipid) |
| Population | T2D at high CV risk |
| Arms (glycemia) | Intensive (HbA1c < 6.0%) · Standard (7.0-7.9%) |
| Primary endpoint | 3-component MACE |
| α / power | 0.05 (two-sided) / 0.89 |
| Assumed HR | 0.85 |
| Assumed control rate | ~3.5% per year |
| Spending | OBF α + OBF-like futility monitoring |
| Planned N (glycemia) | 10,251 |
| Target events | ~1,011 |
| Follow-up | Planned 5.6 y; actual 3.5 y |

## Reproducing the design

```r
library(gsDesign)
d <- gsSurv(
  k = 3, test.type = 4,
  alpha = 0.025, beta = 0.11,
  sfu = sfLDOF, sfl = sfHSD, sflpar = -2,
  hr = 0.85, hr0 = 1,
  lambdaC = -log(1 - 0.035),
  R = 24, minfup = 60, ratio = 1
)
```

## What the trial found

- Stopped at 3.5 y median follow-up on DSMB recommendation.
- HR MACE = **0.90** (95% CI 0.78–1.04).
- Critical finding: **all-cause mortality HR 1.22** (95% CI 1.01–1.46) — increased mortality in intensive arm.
- Harm signal on mortality overrode the ambiguous MACE result.
- Changed diabetes management paradigm — intensive glycemia abandoned as primary target for CV prevention.

## Caveats & teaching points

- **Harm-stop is not strictly "futility."** Futility = unlikely to show benefit; harm = evidence of worsening. Monitoring frameworks often encompass both, but regulators distinguish them for label purposes.
- **Factorial design independence.** ACCORD's BP and lipid arms continued past glycemia-arm stop, per factorial design assumption. Violations of independence (e.g. if BP medication efficacy depends on glycemia arm) complicate interpretation.
- **DSMB authority.** DSMB had pre-specified authority to stop for safety based on mortality patterns — not a formal z-boundary but clinically informed.

## How this case validates designr

- Safety-monitoring in parallel to efficacy/futility GS.
- Factorial design handling — agent should recognize independent vs dependent factor interactions.
- Interpretation of ambiguous MACE with harmful mortality signal — a common oncology/CVOT challenge.
