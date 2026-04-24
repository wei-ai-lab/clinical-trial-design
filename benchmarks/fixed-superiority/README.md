# fixed-superiority

Fixed-sample-size Phase 3 superiority designs. No interim analyses for efficacy (a pure fixed design); any early-stopping is via DSMB judgment, not a pre-specified α-spending rule.

## When this family is the right choice

- Short-duration endpoints where enrollment completes before an interim would materially help.
- Binary or continuous primaries with tight effect-size assumptions.
- Regulatory contexts where simplicity is valued and the operational cost of a GS is not justified.
- Rare diseases where recruiting to the target is the constraint — an interim offers little upside.

## Common pitfalls

- **Optimistic effect assumption** — historical control rates tend to be optimistic. Sensitivity analysis is mandatory.
- **Dropout under-specification** — fixed designs are especially sensitive because there's no built-in re-estimation.
- **Semi-fixed reality** — many "fixed" trials have a DSMB with latitude to stop. Document honestly whether analytical adjustment was made.

## R packages that can reproduce this family

| Endpoint | Preferred R package(s) |
|---|---|
| Continuous | `stats::power.t.test`, `pwr::pwr.t.test`, `gsDesign::nNormal`, `rpact::getSampleSizeMeans` |
| Binary | `stats::power.prop.test`, `gsDesign::nBinomial`, `rpact::getSampleSizeRates` |
| TTE (PH) | `gsDesign::nSurv` (single analysis), `rpact::getSampleSizeSurvival` |
| Ordinal | `Hmisc::popower`, `rankPower` |

## Cases in this directory

See `cases/` for individual benchmark cases. Each is a `<id>.md` + `<id>.yaml` pair.
