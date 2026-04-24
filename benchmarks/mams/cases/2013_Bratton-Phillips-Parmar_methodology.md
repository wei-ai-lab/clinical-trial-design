# Bratton-Phillips-Parmar (2013) — MAMS for binary outcomes with TB application

**Family:** mams · **Endpoint:** binary · **Design feature:** MAMS for binary primary endpoint (culture-negative rate in TB); canonical reference for MAMS outside oncology

## Why this case is in the corpus

- **Binary-endpoint MAMS** — the MAMS methodology was originally developed for TTE (STAMPEDE); this paper extends rigorously to binary outcomes with explicit TB example.
- Published by the UK MRC CTU authors (Bratton, Phillips, Parmar) who also designed STAMPEDE.
- Widely cited as the template for TB Phase 3 trials (REMoxTB, STAND, STREAM).

## Citation

Bratton DJ, Phillips PPJ, Parmar MKB. *A multi-arm multi-stage clinical trial design for binary outcomes with application to tuberculosis.* BMC Medical Research Methodology. 2013;13:139. doi:10.1186/1471-2288-13-139.

## The method

Adapts MAMS boundary computation to binary primary endpoints (responder/non-responder, culture conversion yes/no):

1. Pre-specify K experimental arms + control, J stages, target α and power.
2. Compute boundary z-values from multivariate normal approximation to the joint distribution of K(J) pairwise z-statistics.
3. At each stage j: compare observed z vs upper u_j (efficacy) and lower l_j (futility).
4. Apply Pocock, OBF, or triangular boundary shapes depending on desired spending.

## Illustrative TB design (from paper)

| | |
|---|---|
| Indication | Pulmonary tuberculosis treatment |
| Endpoint | Culture-negative at 8 weeks |
| K arms | 3 experimental regimens + standard RHZE |
| α / power | 0.05 (two-sided) / 0.90 |
| Control rate | 0.60 (60% culture-negative at 8 wk) |
| Experimental target | 0.75 |
| Stages | J = 3 |
| Information fractions | 0.33, 0.67, 1.0 |
| Planned N per stage | 100, 100, 100 per arm (400 per arm total) |

## Reproducing the design

```r
library(MAMS)
d <- mams(
  K = 3, J = 3,
  r = c(1, 2, 3), r0 = c(1, 2, 3),
  alpha = 0.025, power = 0.90,
  p = 0.75, p0 = 0.60,
  ushape = "obf", lshape = "obf",
  nstart = 100
)
# Boundaries and operating characteristics
d$u; d$l
d$N   # planned total
```

## Operating characteristics (typical)

- **Under global null** (all arms equal to control): ~0.05 FWER.
- **Under least-favorable alternative** (one arm at p = 0.75, others at 0.60): ~90% power to reject that arm.
- **Expected N savings** vs parallel Phase 3s: 25-40% depending on K and J.

## Caveats & teaching points

- **Binary MAMS requires careful effect-size parameterization.** Risk difference, odds ratio, and log-risk-ratio give different boundary computations. Paper shows the multivariate-normal approximation is accurate for moderate N per arm (≥ 50) and moderate p (0.2-0.8).
- **TB application lesson.** TB drug development has long needed MAMS — multiple candidate shorter regimens compete for the "replace 6-month RHZE" indication. MAMS enabled parallel testing without running 5 separate Phase 3s.
- **STREAM trial** (moxifloxacin MDR-TB) used this design template.

## How this case validates designr

- Binary-endpoint MAMS benchmark.
- Non-oncology MAMS case (infectious disease).
- Reference for MAMS R package binary workflow.
