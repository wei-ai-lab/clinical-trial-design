# Example 04 — KEYNOTE-189 (2018)

## Trial

Gandhi L et al. (2018). *Pembrolizumab plus Chemotherapy in Metastatic Non-Small-Cell Lung Cancer.* N Engl J Med 378:2078-2092. NCT02578680.

Phase 3 1L metastatic non-squamous NSCLC, no EGFR/ALK alterations. Pembrolizumab + pemetrexed/platinum vs placebo + pemetrexed/platinum, 2:1.

## Published design

- **Co-primary endpoints**: PFS (BICR) and OS.
- **Fixed-sequence (hierarchical) testing** — PFS first at full one-sided 0.025; OS tested at full 0.025 conditional on PFS rejection.
- 80% power per endpoint.
- Planned N = 600.
- Both endpoints rejected at the planned IA on PFS.

## Reproduction

```bash
R -e 'source("examples/04_keynote189_co_primary/run.R")'
```

Expected:
- Total N driven by OS (the slower-event-accruing endpoint at HR 0.70).
- **Both PFS and OS sized at full alpha = 0.025** — the agent must NOT alpha-split (a common multiplicity mistake).
- Planned ~370 PFS events, ~410 OS events.

## What this example demonstrates

- `design_co_primary` with `strategy = "fixed-sequence"`.
- Per-endpoint dispatch to `design_survival` at the same alpha (full alpha preserved by hierarchical testing).
- Reasoning chain encoding the multiplicity decision with `ich_guidance` source_type — the regulatory citation matters when this design is reviewed.
