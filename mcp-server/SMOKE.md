# clinical-trial-design MCP server — smoke matrix

Twelve prompts covering every MCP tool on the v0.0.7 unified surface. Each
should invoke the named MCP tool once and return a result without error.
Values are expected-order-of-magnitude checks, not strict regression targets
(the R-side benchmark regression lives in
`r-package/ClinicalTrialDesign/tests/testthat/`).

## How to run

With the plugin installed in Claude Code, paste each prompt into a fresh
chat, watch the MCP log for the expected tool call, and confirm the headline
number is in the stated range. Or run `node mcp-server/scripts/smoke.mjs`
for a non-interactive 14-case pass.

## 1. `design_binary` — fixed superiority

> Design a confirmatory trial for refractory unstable angina. Control 30-day
> event rate ≈ 15%, hoped-for treatment rate ≈ 9%, two-sided α = 0.05,
> power 80%, 1:1 allocation.

Expected: `design_binary` with `design_class = "fixed"`, total N ≈ 900–1,000.

## 2. `design_binary` — fixed non-inferiority

> Non-inferiority binary trial. Control success rate 85%, treatment assumed
> identical at 85%, non-inferiority margin 7 percentage points, one-sided
> α = 0.025, power 80%.

Expected: `design_binary` with `design_class = "fixed"`,
`comparison = "non-inferiority"`, `ni_margin = 0.07`.

## 3. `design_binary` — fixed + operational kernel

> Same superiority design as #1, but I want the agent to also size accrual:
> we can enroll 80 patients/month and want 3 months minimum follow-up.

Expected: `design_binary` with an `operational` block in the call;
`operational.accrual_duration ≈ N / 80`,
`operational.total_trial_duration ≈ accrual_duration + 3`.

## 4. `design_binary` — group-sequential

> Two-analysis GS trial, binary endpoint. Control rate 10%, treatment rate
> 5%, OBF spending at information fractions 0.5 and 1.0. α = 0.025
> one-sided, power 80%.

Expected: `design_binary` with `design_class = "group-sequential"`, 2
Z-boundaries (upper at IF=0.5 much higher than at final).

## 5. `design_continuous` — fixed superiority

> Continuous endpoint: 30-point mean difference, SD 70 in each arm.
> Two-sided α = 0.05, power 80%.

Expected: `design_continuous` with `design_class = "fixed"`,
N ≈ 220–240.

## 6. `design_survival` — PH fixed

> TTE under PH. Control median OS 30 months, target HR 0.75, accrual
> 100/month over 30 months, 24 months min follow-up, α = 0.025 one-sided,
> power 90%.

Expected: `design_survival` with `model = "ph"`,
`design_class = "fixed"`, events_total ≈ 380.

## 7. `design_survival` — PH group-sequential

> Same CVOT but two-analysis group-sequential with OBF spending.

Expected: `design_survival` with `model = "ph"`,
`design_class = "group-sequential"`, 2 Z-boundaries.

## 8. `design_survival` — MaxCombo (NPH fixed)

> Immunotherapy trial with delayed effect: 4-month delay, post-delay HR
> 0.60, control median 10 months, accrual 20/month for 18 months,
> 12 months follow-up, α = 0.025, power 90%.

Expected: `design_survival` with `model = "maxcombo"`,
`design_class = "fixed"`, FH weight set.

## 9. `design_survival` — RMST (NPH fixed)

> Same delayed-effect trial but the regulatory endpoint is RMST at
> 24 months.

Expected: `design_survival` with `model = "rmst"`, `tau = 24`.

## 10. `design_survival` — milestone (NPH fixed)

> Same delayed-effect trial but the endpoint is 2-year OS rate (milestone
> probability at 24 months).

Expected: `design_survival` with `model = "milestone"`, `tau = 24`.

## 11. `design_survival` — MaxCombo group-sequential

> Two-analysis NPH GS trial. Control median 12 months, 6-month delay,
> post-delay HR 0.6, accrual 30/month × 12 months, interim at 18 months,
> final at 30 months, α = 0.025, power 90%.

Expected: `design_survival` with `model = "maxcombo"`,
`design_class = "group-sequential"`, 2-element `boundaries.upper_z`.

## 12. `validate_against_benchmark`

> Validate the CAPTURE benchmark.

Expected: `validate_against_benchmark` with
`family = "fixed-superiority"`, `id = "1997_CAPTURE_abciximab"`,
returns `{tool: "design_binary", ...}` with diff vs expected within
tolerance.

## 13. `verify_design` (chained)

> Take the design from prompt #1 and Monte-Carlo verify it.

Expected: `verify_design` returning `family: "fixed_binary"`,
`passes: true`, empirical power within 2 pp of the target.

## 14. `design_report` (chained)

> Take the design from prompt #1 and produce a markdown summary.

Expected: `design_report` returning a markdown string with a
`# Fixed-sample binary endpoint` header and a `## Headline output` section.

## Pass criteria

Smoke pass = all 14 calls return a valid result without error. Matching
exact numbers is **not** required at the smoke-test level; the R-side
testthat suite handles that.
