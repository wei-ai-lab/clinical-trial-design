# designr MCP server — smoke matrix

Thirteen prompts covering every MCP tool. Each should invoke the named MCP tool once and return a result without error. Values are expected-order-of-magnitude checks, not strict regression targets (the R-side benchmark regression lives in `r-package/designr/tests/testthat/`).

## How to run

With the plugin installed in Claude Code, paste each prompt into a fresh chat, watch the MCP log for the expected tool call, and confirm the headline number is in the stated range.

## 1. `design_fixed_binary` — superiority

> Design a Phase 3 trial for refractory unstable angina. Control 30-day event rate ≈ 15%, hoped-for treatment rate ≈ 9%, two-sided α = 0.05, power 80%, 1:1 allocation.

Expected: `design_fixed_binary`, total N ≈ 1,000–1,200.

## 2. `design_fixed_binary` — non-inferiority

> Design a non-inferiority trial with binary endpoint. Control success rate 85%, treatment assumed identical at 85%, non-inferiority margin 7 percentage points, one-sided α = 0.025, power 80%.

Expected: `design_fixed_binary` with `comparison = "non-inferiority"`, `ni_margin = 0.07`.

## 3. `design_fixed_continuous` — superiority

> Continuous endpoint: we expect a 30-point mean difference with SD 70 in each arm. Two-sided α = 0.05, power 80%.

Expected: `design_fixed_continuous`, N ≈ 220–240.

## 4. `design_fixed_survival_ph` — superiority

> TTE PH design. Control median OS 30 months, target HR 0.75, accrual 100/month over 30 months, 24 months min follow-up, α = 0.025 one-sided, power 90%.

Expected: `design_fixed_survival_ph`, events_total ≈ 380.

## 5. `design_fixed_survival_maxcombo` — NPH

> Immunotherapy trial with delayed effect: 4-month delay, post-delay HR 0.60, control median 10 months, accrual 20/month for 18 months, study duration 30 months, α = 0.025, power 90%.

Expected: `design_fixed_survival_maxcombo` with FH weight set.

## 6. `design_fixed_survival_rmst` — NPH

> Same trial as above but the regulatory endpoint is RMST at 24 months, not log-rank.

Expected: `design_fixed_survival_rmst` with `tau = 24`.

## 7. `design_fixed_survival_milestone`

> Same trial but regulatory endpoint is 2-year OS rate (milestone probability at 24 months).

Expected: `design_fixed_survival_milestone` with `tau = 24`.

## 8. `design_gs_binary` — group-sequential

> Two-analysis GS trial, binary endpoint. Control rate 10%, treatment rate 5%, OBF spending at information fractions 0.5 and 1.0. α = 0.025 one-sided, power 80%.

Expected: `design_gs_binary` with 2 Z-boundaries (upper at IF=0.5 much higher than at final).

## 9. `design_gs_survival_ph` — group-sequential PH

> Two-analysis group-sequential CVOT. Control median 30 months, HR 0.75, accrual 100/month × 30 months, 24 months min follow-up, OBF spending, α = 0.025, power 90%.

Expected: `design_gs_survival_ph`, events at final ≈ 380–420 (slight GS inflation over fixed).

## 10. `design_gs_survival_nph_combo` — group-sequential NPH

> Two-analysis MaxCombo design. Control median 12 months, 6-month delay, post-delay HR 0.6, accrual 30/month × 12 months, interim at 18 months and final at 30 months. α = 0.025, power 90%.

Expected: `design_gs_survival_nph_combo` with `test = "maxcombo"`, 2 analyses, events_per_analysis populated.

## 11. `validate_against_benchmark` — meta

> Validate the CAPTURE benchmark case against designr.

Expected: `validate_against_benchmark(family="fixed-superiority", id="1997_CAPTURE_abciximab")` returning `within_tolerance: false` (vanilla formula lands at ~1,100; CAPTURE's 1,400 includes real-trial inflation) but structurally correct output.

## 12. `verify_design` — Monte Carlo cross-check

> Take the CAPTURE-style fixed binary design (control 15%, treatment 9%, two-sided α = 0.05, power 80%) and verify it by Monte Carlo simulation with 3000 replicates.

Expected: `verify_design` with `family = "fixed_binary"`, `empirical_power` ≈ 0.80 (within ±2 pp), `empirical_type_I` ≈ 0.05 (within ±0.5 pp), `passes = true`.

## 13. `design_report` — markdown summary

> Produce a markdown design report for that same fixed binary design.

Expected: `design_report` returning a markdown string containing the section headers `# Fixed-sample binary endpoint`, `## Design overview`, `## Key inputs`, `## Headline output`, and `## Method & version`.

## Pass criteria

Smoke pass = all 13 calls return a valid result without error. Matching exact numbers is **not** required at the smoke-test level; the R-side testthat suite handles that.
