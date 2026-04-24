# ARISTOTLE (2011) — apixaban vs warfarin in AF

**Family:** fixed-non-inferiority · **Endpoint:** TTE stroke/SE · **N:** 18,201 · **Design feature:** multi-endpoint hierarchical chain

## Why this case is in the corpus

- **Multi-endpoint hierarchical testing** — primary NI → superiority on primary → superiority on major bleeding → superiority on all-cause mortality. All four hypotheses rejected — a rare all-wins outcome.
- Slightly tighter NI margin (1.44 vs 1.46 in RE-LY/ROCKET) illustrates sensitivity of sample size to small margin changes.

## Citation

Granger CB, Alexander JH, McMurray JJV, et al. *Apixaban versus warfarin in patients with atrial fibrillation.* N Engl J Med. 2011;365(11):981-992. doi:10.1056/NEJMoa1107039. NCT00412984.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, double-dummy, 1:1 |
| Arms | Apixaban 5 mg bid · Warfarin |
| Primary endpoint | Stroke or systemic embolism |
| Comparison | Non-inferiority, margin HR = 1.44 |
| α / power | 0.025 (one-sided) / 0.90 |
| Assumed HR | 0.85 |
| Assumed warfarin annual event rate | 1.6% |
| Target events | 448 |
| Planned N | 18,201 |
| Follow-up | Median 22 months |

## Hierarchical hypothesis testing chain

1. Primary NI on stroke/SE (margin 1.44) — if met, go to step 2.
2. Superiority on stroke/SE — if met, go to step 3.
3. Superiority on major bleeding — if met, go to step 4.
4. Superiority on all-cause mortality.

α = 0.05 (two-sided) preserved at each step because each is conditional on the prior. No α-splitting required.

## Reproducing the calculation

```r
library(gsDesign)
nEvents(hr = 0.85, hr0 = 1.44, alpha = 0.025, beta = 0.10, ratio = 1)
# events ≈ 450

nSurv(
  lambdaC = -log(1 - 0.016),
  hr      = 0.85, hr0 = 1.44,
  alpha   = 0.025, beta = 0.10,
  T       = 46, minfup = 22, R = 24
)
# N ≈ 18,000
```

## What the trial found

All four hypotheses rejected:

| Test | Result | p |
|---|---|---|
| NI on stroke/SE | HR 0.79 (95% CI 0.66–0.95) | < 0.001 |
| Superiority on stroke/SE | same | 0.01 |
| Superiority on major bleeding | HR 0.69 (0.60–0.80) | < 0.001 |
| Superiority on mortality | HR 0.89 (0.80–0.998) | 0.047 |

The mortality result was the first NOAC trial to demonstrate mortality benefit.

## Caveats & teaching points

- **Hierarchical chains multiplicate via ordering.** Reordering the chain would change which hypotheses get tested if earlier ones fail. In ARISTOTLE, efficacy-first ordering maximized the chance of reaching mortality (the weakest signal).
- **Tight margins require large N.** Reducing margin from 1.46 to 1.44 increases required events by ~5%. The difference is mostly operational preference.
- **All-wins rare.** Most NI NOAC trials achieve NI but not full superiority on all secondary hypotheses.

## How this case validates designr

- TTE NI sizing at tight margin (1.44).
- Agent reasoning about pre-specified hierarchical chains across endpoints.
- Interpretation of multi-endpoint success and its rarity.
