# Example 05 — KEYNOTE-042 (2019)

## Trial

Mok TSK et al. (2019). *Pembrolizumab versus chemotherapy for previously untreated, PD-L1-expressing, locally advanced or metastatic non-small-cell lung cancer (KEYNOTE-042): a randomised, open-label, controlled, phase 3 trial.* Lancet 393:1819-1830. NCT02220894.

Phase 3 1L NSCLC. Pembrolizumab vs investigator-choice chemotherapy, 1:1, in patients with PD-L1 TPS ≥ 1%.

## Published design

- **Same OS endpoint tested in three nested populations** in order of decreasing biomarker expression: TPS≥50, TPS≥20, TPS≥1.
- Hierarchical testing — full alpha = 0.025 one-sided at each step, conditional on prior subgroup rejection.
- 85% power per population.
- Planned N = 1,240 (driven by the broadest population, TPS≥1).
- All three sequential population tests rejected.

## Reproduction

```bash
R -e 'source("examples/05_keynote042_multi_population/run.R")'
```

Expected:
- Driver = TPS_1 (broadest stratum).
- Total enrolled N driven by the implied-enrolled-N for TPS_1 (no prevalence inflation).
- Per-stratum events scale with prevalence: TPS≥50 (47% of total) needs ~285 events in that subgroup, TPS≥1 needs ~690 events overall.

## What this example demonstrates

- `design_multi_population` with `relation = "nested"` and `strategy = "fixed-sequence"`.
- The `prevalence` parameter — the agent must size N to capture enough events in the smallest subgroup, given prevalence dilution.
- Reasoning chain with the multiplicity decision tagged `ich_guidance` — important for regulatory review of subgroup-driven designs.
