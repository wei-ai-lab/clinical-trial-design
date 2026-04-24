# Group-sequential trials under non-proportional hazards (NPH)

Time-to-event group-sequential trials where the proportional hazards (PH) assumption is violated — the paradigmatic Phase 3 challenge in checkpoint immunotherapy, CAR-T, and some cardiovascular trials.

## What NPH looks like

| Pattern | Cause | Example trials |
|---|---|---|
| **Delayed effect** | Immune priming takes weeks; KM curves overlap early | CheckMate-067, PACIFIC, KEYNOTE-189 |
| **Crossing hazards** | Early harm, late benefit | CheckMate-057, some TAVR-in-low-risk |
| **Diminishing effect** | Benefit peaks then wanes | Some vaccine efficacy trials |
| **Long-term tail** | Cure-fraction / long-responders | CAR-T, pembrolizumab 5-yr landmarks |

## Why the GS framework needs care under NPH

- **Log-rank test loses power** when hazards are not proportional. Under delayed effect, a standard log-rank may require 30–50% more events than PH-assumed to achieve nominal power.
- **Interim analyses are biased toward "no effect"** — at early interims, most events come from the early-overlap period where KM curves haven't separated yet. Stopping for futility at an early interim is therefore **especially dangerous** under suspected delayed effect.
- **HR is not a single summary.** Reported HR depends on censoring distribution + follow-up length. Milestone (landmark) survival, RMST, or weighted log-rank may be more interpretable.

## Statistical tools for NPH GS

| Tool | Use case | R package |
|---|---|---|
| Standard log-rank + Cox HR | If PH is approximately true | survival, gsDesign |
| Weighted log-rank (Fleming-Harrington G(ρ,γ)) | Delayed effect (upweight later events) | survival, nphRCT, nph |
| Max-combo test | Robust to unknown NPH pattern | simtrial, nphRCT |
| Piecewise HR design | Known change-point in hazards | gsDesign2, nphDesign |
| RMST difference | Model-free summary, no PH assumption | survRM2 |
| Average HR (AHR) under piecewise exp | Planning under known delayed effect | gsDesign2 |
| Milestone survival difference | Landmark at τ months | survival::survfit |

## Design considerations

- **Pre-specify the test.** If delayed effect is anticipated, pre-specify max-combo or a Fleming-Harrington weighted log-rank — not log-rank. Regulators expect this to be committed before unblinding.
- **Event count under NPH.** Planning under piecewise exponential with a delay period requires ~10–30% more events than PH-equivalent HR at the late phase.
- **Futility rules need tempering.** Early interim futility (IF < 0.3) under delayed effect can kill a trial before the effect has emerged. Many modern IO Phase 3s either skip early futility or use conditional-power computed under a delayed-effect alternative.
- **Information fraction ≠ time fraction.** Under NPH, information accumulates faster than events relative to calendar time during the delayed-onset period.

## R package landscape

- `gsDesign2` — piecewise HR, average HR, non-proportional hazard GS design (successor to `gsDesign` for NPH).
- `simtrial` — event simulation under user-defined hazard functions; supports max-combo, weighted LR.
- `nphDesign` / `nphRCT` — power calculation and analysis under NPH.
- `rpact` — extending to NPH via piecewise exp in a secondary workflow.
- `survRM2` — RMST-based design and analysis.

## Corpus

Six IO oncology and delayed-effect trials span the pattern space:

- 2015_CheckMate-067_melanoma — combo IO, delayed + sustained separation
- 2015_CheckMate-057_nsclc — crossing curves, early harm then benefit
- 2016_KEYNOTE-024_nsclc — PD-L1 selection, rapid early separation
- 2017_PACIFIC_nsclc — consolidation durvalumab, clear delayed PFS effect
- 2018_KEYNOTE-189_nsclc — pembro+chemo combo, early efficacy (chemo mask)
- 2018_IMpower150_nsclc — atezo+bev+chemo, multiple-arm NPH

## Caveats

- Original design papers often used log-rank + PH, then the published post-hoc analyses switched to max-combo or RMST once NPH became evident. The corpus records *both* the as-designed computation and the as-analyzed summary.
- For some trials (e.g. CheckMate-067 where Eastern Cooperative Oncology Group endpoint and alpha-splitting made multiplicity complex), the GS multiplicity scheme is non-trivial and warrants close reading.
