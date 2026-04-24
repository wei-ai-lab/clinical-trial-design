# Adaptive sample-size re-estimation (SSR)

Phase 3 trials that modify the planned sample size at a pre-specified interim based on accumulating data — either **blinded** (using only nuisance-parameter estimates like pooled variance or overall event rate) or **unblinded** (using an estimate of the treatment effect).

## Key references

- Bauer & Köhne. *Evaluation of experiments with adaptive interim analyses.* Biometrics 1994.
- Cui, Hung, Wang. *Modification of sample size in group sequential clinical trials.* Biometrics 1999 — CHW weighted statistic.
- Proschan & Hunsberger. *Designed extension of studies based on conditional power.* Biometrics 1995.
- Friede & Kieser. *Sample size recalculation in internal pilot designs: a review.* Biometrical J 2006.
- Mehta & Pocock. *Adaptive increase in sample size when interim results are promising: a practical guide with examples.* Stat Med 2011 — promising-zone design.
- Chen, DeMets, Lan. *Increasing the sample size when the unblinded interim result is promising.* Stat Med 2004.
- FDA Guidance: *Adaptive Designs for Clinical Trials of Drugs and Biologics.* 2019.
- EMA Reflection Paper on adaptive designs, 2007.

## Core statistical tools

| Approach | Blinded? | Test statistic | Typical use |
|---|---|---|---|
| **Internal pilot** (Wittes-Brittain) | Blinded | Conventional z on pooled variance | Continuous endpoint, variance unknown |
| **Bauer-Köhne combination** | Unblinded | Fisher combination of p-values from stages | Any endpoint, strict Type-I control |
| **Cui-Hung-Wang (CHW)** | Unblinded | Weighted z with pre-specified weights | Normal/log-HR, preserves α with arbitrary N₂ |
| **Proschan-Hunsberger CP** | Unblinded | Conditional-power-triggered N increase | Only allow increase in "promising zone" |
| **Mehta-Pocock promising zone** | Unblinded | CHW with PZ boundary | Modern standard; avoid aggressive SSR in unpromising zone |
| **Friede-Kieser blinded binary** | Blinded | Pooled event rate recalc | Binary endpoint |
| **Gao-Liu-Mehta** | Blinded | Blinded variance/rate for binary | Binary, strict Type-I control |

## When SSR helps

- **Poorly known nuisance** — σ², event rate, or control-arm mean is highly uncertain at design time. Internal-pilot and blinded SSR nearly always offer efficiency gain with minimal Type-I inflation.
- **Unknown treatment effect** — when expected HR / Δ is uncertain, promising-zone unblinded SSR allows rescuing under-powered trials without committing upfront to a larger, potentially-wasted trial.

## When SSR is *not* the right tool

- **If the trial will succeed under the assumed effect**, SSR adds complexity without benefit — a standard GS design is cleaner.
- **If the effect size at interim is in the "futility zone"**, increasing N rarely rescues the trial — stop for futility instead.
- **If regulators are skeptical** of the sponsor's ability to pre-specify adaptation rules — unblinded SSR requires rigorous pre-specification of the promising-zone boundary, the max N, and the conditional-power target.

## R package landscape

- `rpact` — full support for Bauer-Köhne combination, CHW, Mehta-Pocock PZ, inverse-normal combination.
- `adaptTest` — Bauer-Köhne combination tests.
- `AGSDest` — adaptive GS design with SSR (point + CI adjustment post-adaptation).
- `samplesizeCMH` — simple blinded SSR utilities.
- `gsDesign` — does GS but not native SSR; pair with `rpact` for combined workflow.

## Corpus

Five methodology-canonical cases from the SSR literature, each illustrating a distinct statistical technique:

- 1999_Cui-Hung-Wang_weighted-ssr — CHW weighted statistic (unblinded SSR preserving α)
- 2002_Friede-Kieser_blinded-ssr — blinded internal-pilot for continuous endpoint
- 2004_Chen-DeMets-Lan_cp-ssr — conditional-power-triggered promising-zone
- 2011_Mehta-Pocock_promising-zone — PZ design with CHW weighting (modern standard)
- 2012_Gao-Liu-Mehta_blinded-binary-ssr — blinded SSR for binary endpoints

## Caveats

- SSR is best treated as a **methodology family** in the corpus because the canonical Phase 3 trials that deployed SSR rarely publish complete SAPs; the reference cases are primarily the methodology papers that define them. Where a real trial deployed a method (e.g., CHAMPION-HF used CHW-like SSR), the YAML records both the published trial and the methodology reference.
- Unlike GS, SSR Type-I preservation requires *exact* pre-specification of weights or PZ bounds. Post-hoc adaptation breaks the adjustment — this is a recurring regulatory concern.
