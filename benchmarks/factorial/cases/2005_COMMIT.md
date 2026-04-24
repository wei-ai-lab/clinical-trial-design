# COMMIT (2005) — 2×2 factorial metoprolol + clopidogrel in acute MI

**Family:** factorial · **Endpoint:** in-hospital composite + death · **N:** 45,852 · **Design feature:** mega-factorial in acute MI

## Why this case is in the corpus

- **Mega-scale 2×2 factorial CVOT** — efficiency of factorial design at massive N.
- Acute MI management setting (short follow-up, high event rate).
- Established clopidogrel as post-MI SOC antiplatelet; reshaped IV β-blocker use.

## Citation

Chen ZM, Jiang LX, Chen YP, et al. *Addition of clopidogrel to aspirin in 45,852 patients with acute myocardial infarction: randomised placebo-controlled trial (COMMIT).* Lancet. 2005;366(9497):1607-1621. doi:10.1016/S0140-6736(05)67660-X.

## Design summary

| | |
|---|---|
| Design | 2×2 factorial RDBPC, mega-scale |
| Population | Acute MI within 24 h (Chinese hospitals) |
| Factor 1 | Clopidogrel 75 mg vs placebo |
| Factor 2 | Metoprolol (IV then oral) vs placebo |
| Co-primary 1 | Composite: death, reinfarction, stroke |
| Co-primary 2 | Death any cause |
| Follow-up | In-hospital (~15 d median) |
| α per factor | 0.05 (two-sided) |
| Power | 0.90 |
| Planned N | 45,852 |
| Expected events | ~5,000 |

## Reproducing the design

```r
library(rpact)
# Per factor, binary composite outcome
d <- getSampleSizeRates(
  alpha = 0.025, beta = 0.10,
  pi1 = 0.108, pi2 = 0.120,   # OR 0.90 from base 12%
  sided = 1
)
# N ≈ 45,000 for 5,000 events on composite
```

## Trial outcome

- **Clopidogrel factor**: composite OR **0.91** (95% CI 0.86-0.97), p = 0.002 — positive. Reshaped post-MI SOC.
- **Metoprolol factor**: composite OR **0.96** (0.90-1.01), p = 0.10 — not significant. IV β-blocker benefit offset by early hemodynamic harm.
- Death any cause: clopidogrel OR 0.93; metoprolol OR 0.99.
- No interaction between factors (each analyzed across both levels of other).
- Led to widespread clopidogrel adoption post-MI.

## How this case validates designr

- Mega-scale factorial reference.
- Short-term acute-MI management design vs long-term CVOT contrast.
- No-interaction assumption in factorial analysis.
- Binary composite outcome with risk-ratio primary.
