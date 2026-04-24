# SUSTAIN-6 (2016) — semaglutide CVOT

**Family:** fixed-superiority (NI-sized, superiority achieved) · **Endpoint:** TTE MACE · **N:** 3,297

## Why this case is in the corpus

- **Small CVOT sized for NI only** — powered for NI margin 1.8 under HR = 1.0 (~122 events), not superiority. Illustrates the "NI-sized but superiority-achieved" pattern that recurs in diabetes Phase 3.
- Hierarchical testing chain: **NI(1.8) → NI(1.3) → superiority**, each at full α conditional on passing the previous.
- Contrast with CANVAS — similar regulatory construct, very different sizing (688 events vs 122).

## Citation

Marso SP, Bain SC, Consoli A, et al. *Semaglutide and cardiovascular outcomes in patients with type 2 diabetes.* N Engl J Med. 2016;375(19):1834-1844. doi:10.1056/NEJMoa1607141. NCT01720446.

## Design summary

| | |
|---|---|
| Phase | 3 |
| Design | RDBPC, 2×2 factorial-style (two doses × placebo) |
| Arms | Semaglutide 0.5 mg · Semaglutide 1.0 mg · Placebo (2 × placebo pools) |
| Allocation | 1:1:1:1 (four cells), active pooled vs placebo pooled → 1:1 |
| Primary endpoint | MACE: CV death + non-fatal MI + non-fatal stroke |
| Hypothesis ladder | NI @ margin 1.8 → NI @ margin 1.3 → Superiority |
| α / power | 0.025 (one-sided) / 0.90 |
| Sizing anchor | NI at margin 1.8 under HR = 1.0 |
| Target events | 122 (for NI @ 1.8 sizing) |
| Planned N | 3,297 |

## Reproducing the calculation

For NI at margin HR₀ = 1.8 under point alternative HR = 1.0:

```r
library(gsDesign)
nEvents(hr = 1.0, hr0 = 1.8, alpha = 0.025, beta = 0.10, ratio = 1)
# events ≈ 122
```

Translating events to subjects under ~3.6% annual MACE rate and 26-month median follow-up gives N ≈ 3,300.

## What the trial found

- HR = **0.74** (95% CI 0.58–0.95), p = 0.02 for superiority, p < 0.001 for NI.
- Semaglutide passed all three hierarchical tests despite being sized only for the first.
- Retinopathy complication signal — the safety finding that shaped labeling.

## Caveats & teaching points

- **Powered for NI only — superiority is a lottery ticket.** Under the 2008 FDA CVOT guidance, compounds with a true HR around 0.75 often pass superiority on 120 events even when nominal 90% power for superiority would require 500+.
- **Event count variability matters.** With only 122 events, the CI is wide; a slightly unfavorable play of chance could have shown no superiority. Replicates of SUSTAIN-6 with the same true effect would show superiority ~70% of the time at this event count.
- **Hierarchical chain is cheap.** Ladder of NI(1.8) → NI(1.3) → superiority is all-or-nothing for conservativeness: each step can only be reached if the prior rejected, so α stays at 0.025 throughout.

## How this case validates designr

- Event-driven NI sizing (margin 1.8).
- Agent reasoning about the hierarchical chain and why the sizing anchor is the weakest test.
- Explaining the gap between "powered for" and "achieved" — conditional power of observed superiority given planned N.
