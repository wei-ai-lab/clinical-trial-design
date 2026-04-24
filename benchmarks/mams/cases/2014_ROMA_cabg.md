# ROMA (2014-) — multi-arm radial vs saphenous vein conduits in CABG

**Family:** mams · **Endpoint:** TTE MACE · **N:** 4,300 (enrolled 2014-2021) · **Design feature:** surgical multi-arm MAMS (device/technique comparison, not drug)

## Why this case is in the corpus

- **Surgical Phase 3 MAMS** — demonstrates MAMS outside oncology and infectious disease.
- **Technique comparison**: multiple arterial conduit strategies vs SVG control in multi-vessel CABG.
- Teaching case for **surgical MAMS with long follow-up** — MACE at 5 years requires careful interim timing.

## Citation

Gaudino M, Benedetto U, Fremes S, et al. *Radial-artery or saphenous-vein grafts in coronary-artery bypass surgery.* N Engl J Med. 2018;378(22):2069-2077. (ROMA precursor).

ROMA Investigators (Gaudino M, et al.). *The ROMA trial: why it is needed.* J Thorac Cardiovasc Surg. 2018;156(4):1393-1397. doi:10.1016/j.jtcvs.2018.05.106. NCT03217006.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | Open-label MAMS, multi-arm surgical technique |
| Population | Multi-vessel CAD requiring CABG |
| Arms | LIMA + multiple arterial grafts (radial, RIMA) vs LIMA + SVG control |
| Primary endpoint | Composite MACCE at 5 years (death, MI, stroke, repeat revasc) |
| α / power | 0.05 (two-sided) / 0.90 |
| Assumed HR | 0.80 (multiple arterial vs SVG) |
| Assumed 5-yr MACCE | 18% control |
| Spending | MAMS boundaries with lack-of-benefit drops |
| Planned looks | 2 interim + final |
| Planned N | 4,300 |

## Reproducing the design

```r
library(MAMS)
d <- mams(
  K = 2, J = 3,
  r = c(1, 2, 3), r0 = c(1, 2, 3),
  alpha = 0.025, power = 0.90,
  p = 0.145,    # 5-yr MACCE under HR 0.80
  p0 = 0.18,
  ushape = "obf", lshape = "obf",
  nstart = 700
)
```

## What the trial has reported (as of 2026)

- Enrollment complete 2021; primary 5-year endpoint maturing through 2026.
- Interim analyses per SAP; final MACCE readout expected ~2026-2027.
- Ancillary endpoints (angiographic patency, repeat intervention) reported separately.

## Caveats & teaching points

- **Surgical MAMS complications** — surgeon experience and center volume introduce heterogeneity. Stratified randomization and center-pair matching partially address.
- **5-year primary** — long MAMS trials need careful interim timing (e.g., 2 y and 3.5 y interims); MACCE event rate informs information fractions.
- **Non-drug technique trial** — no Type-I control for "placebo response"; blinding of outcome adjudicators is important.

## How this case validates designr

- Surgical Phase 3 MAMS benchmark.
- Long-follow-up TTE MAMS design.
- Non-oncology, non-infectious MAMS case.
