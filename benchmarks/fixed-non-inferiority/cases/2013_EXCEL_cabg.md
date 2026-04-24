# EXCEL (2016) — PCI vs CABG for left main CAD

**Family:** fixed-non-inferiority · **Endpoint:** binary 3-year composite · **N:** 1,900 · **Design feature:** landmark K-M rate analysis, device NI

## Why this case is in the corpus

- **Device/procedure NI** with absolute risk-difference margin on a K-M landmark endpoint (not HR).
- Long-duration follow-up (3 years) — tests the difference between HR-margin and rate-difference NI approaches.
- **Post-hoc controversy** about MI definition — teaching case for how endpoint-definition sensitivity propagates into NI conclusion.

## Citation

Stone GW, Sabik JF, Serruys PW, et al. *Everolimus-eluting stents or bypass surgery for left main coronary artery disease.* N Engl J Med. 2016;375(23):2223-2235. doi:10.1056/NEJMoa1610227. NCT01205776.

## Design summary

| | |
|---|---|
| Phase | 3 (device) |
| Design | Randomized 1:1, open-label (procedural), blinded endpoint adjudication |
| Arms | PCI with EES · CABG |
| Primary endpoint | 3-year composite: death + stroke + MI (K-M rates) |
| Comparison | Non-inferiority, absolute RD margin Δ = 4.25% |
| α / power | 0.025 (one-sided) / 0.80 |
| Assumed rate (both arms) | ~11% at 3y |
| Planned N | 1,900 |

## Reproducing the calculation

Binary NI with absolute margin on rate difference at 3-year landmark:

```r
library(gsDesign)
nBinomial(p1 = 0.11, p2 = 0.11, delta0 = 0.0425,
          alpha = 0.025, beta = 0.20, sided = 1)
# n per arm ≈ 950 → total 1,900
```

Note: this is approximate. A more precise calculation uses the variance of the K-M estimator at 3y, which requires specifying censoring distribution. For design-stage planning, the binary approximation is standard and ~matches the planned N.

## What the trial found

- 3-year primary composite: PCI 15.4%, CABG 14.7%, RD = +0.7% (95% CI −1.5 to +2.9).
- NI met (upper 95% CI bound 2.9% < 4.25% margin).
- 5-year follow-up subsequently showed PCI had higher all-cause mortality, reversing clinical interpretation and generating significant controversy.

## Caveats & teaching points

- **Landmark analysis vs HR.** When disease progression curves are non-parallel (crossing or delayed effects), HR summaries are misleading; landmark K-M rates are interpretable. EXCEL's choice was design-appropriate.
- **Endpoint definition sensitivity.** The trial used a CK-MB–based MI definition that was later criticized for underestimating peri-procedural MI in the PCI arm. A more-recent Universal Definition of MI would have yielded different results — a cautionary example for NI trials where the margin is close to the observed difference.
- **Follow-up extension changes interpretation.** Primary was at 3 y; extended follow-up (5 y) showed different patterns. NI at planned analysis ≠ long-term equivalence.

## How this case validates designr

- Binary NI with absolute rate-difference margin at fixed landmark.
- Agent reasoning about when landmark analysis is preferred to HR (non-PH, surgical trials, device trials).
- Highlighting endpoint-definition sensitivity as a design risk.
