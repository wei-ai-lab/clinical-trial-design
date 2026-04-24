# PARTNER 3 (2019) — TAVR in low-risk aortic stenosis

**Family:** fixed-superiority (NI-then-superiority) · **Endpoint:** binary composite at 1y · **N:** 1,000 · **Design feature:** Bayesian primary analysis, frequentist sizing

## Why this case is in the corpus

- **Device trial** with binary composite primary at fixed time — contrast with drug CVOTs that are event-driven.
- **NI-then-superiority** on binary risk difference (not hazard ratio), with 6% NI margin.
- **Bayesian primary analysis** but frequentist sample-size planning — a common pragmatic pattern the agent should recognize.

## Citation

Mack MJ, Leon MB, Thourani VH, et al. *Transcatheter aortic-valve replacement with a balloon-expandable valve in low-risk patients.* N Engl J Med. 2019;380(18):1695-1705. doi:10.1056/NEJMoa1814052. NCT02675114.

## Design summary

| | |
|---|---|
| Phase | 3 (device, pre-market) |
| Design | Randomized, 1:1, open-label (device), blinded endpoint adjudication |
| Arms | TAVR (SAPIEN 3) · Surgical AVR |
| Primary endpoint | Composite: all-cause death + stroke + rehospitalization at 1 year |
| Comparison | NI @ Δ = 6% (risk difference) then superiority, Bayesian posterior |
| α / power | 0.025 (one-sided) / 0.85 |
| Assumed control rate | ~14% at 1 year |
| Assumed treatment rate | ~10% |
| Planned N | 1,000 |
| Accrual | 18 months |
| Follow-up to primary | 1 year |

## Reproducing the calculation (frequentist)

For NI on risk difference, margin Δ = 0.06, expected p_c = 0.14, p_t = 0.10:

```r
library(gsDesign)
nBinomial(p1 = 0.10, p2 = 0.14, delta0 = 0.06, alpha = 0.025,
          beta = 0.15, sided = 1, outtype = 1)
# N per arm ≈ 500 → total ~1000
```

## What the trial found

- Composite event rate: TAVR 8.5%, SAVR 15.1%.
- Difference: **−6.6%** (95% CI −10.8 to −2.5), posterior P(NI) > 0.999, p < 0.001 for superiority.
- Superiority achieved — TAVR now preferred for low-risk patients pending long-term data.

## Caveats & teaching points

- **Binary fixed-time endpoint** — no HR, no event accrual over time; the N is fully determined at 1-year follow-up point.
- **Bayesian analysis with non-informative priors** behaves close to the frequentist NI test for sample-size planning.
- **Risk-difference margin** (vs relative margin) is standard for device NI trials per FDA guidance.

## How this case validates designr

- Binary endpoint fixed-sample calculation.
- NI on risk-difference scale (vs HR scale in CVOTs).
- Agent reasoning about Bayesian-analysis / frequentist-sizing hybrid.
