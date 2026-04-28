# Example 03 — KEYNOTE-024 (2016)

## Trial

Reck M et al. (2016). *Pembrolizumab versus chemotherapy for PD-L1-positive non-small-cell lung cancer.* N Engl J Med 375:1823-1833. NCT02142738.

Phase 3 1L NSCLC PD-L1 TPS ≥ 50% pembrolizumab vs platinum-doublet chemotherapy.

## Published design

- Primary endpoint: PFS (BICR).
- Two-sided α = 0.025 (one-sided 0.0125 PFS, 0.0125 OS hierarchical), 85% power for PFS.
- **Non-proportional hazards** — delayed treatment effect pattern is well-documented in checkpoint inhibitor trials.
- Planned events ~170 for the PFS test.
- Stopped early at planned IA on PFS.

## Reproduction

```bash
R -e 'source("examples/03_keynote024_maxcombo/run.R")'
```

Expected: ~140-200 PFS events using a MaxCombo test with FH(0,1) weights, delayed-effect model with 3-month delay and 0.55 post-delay HR.

## What this example demonstrates

- `design_survival(model = "maxcombo", design_class = "fixed")` for an NPH design.
- Recognition that "delayed effect" + "checkpoint inhibitor" → MaxCombo (not naive log-rank) per ICH/FDA NPH guidance.
- The agent must pass `delay_months` + `post_delay_hr` (NOT `hazard_ratio`) for NPH models.
