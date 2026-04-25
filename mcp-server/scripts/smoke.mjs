#!/usr/bin/env node
// Programmatic smoke pass: runs each of the 13 MCP tools through the
// r-bridge directly. Returns exit code 0 if all succeed, 1 otherwise.

import { runR, DesignrToolError } from "../dist/r-bridge.js";

const cases = [
  ["design_fixed_binary",
   { p_control: 0.15, p_treatment: 0.09, alpha: 0.025, power: 0.8, sided: 2 },
   (r) => r.sample_size_total > 900 && r.sample_size_total < 1300],
  ["design_fixed_binary (NI)",
   { p_control: 0.85, p_treatment: 0.85, comparison: "non-inferiority",
     ni_margin: 0.07, alpha: 0.025, power: 0.8, sided: 1 },
   (r) => r.sample_size_total > 0, "design_fixed_binary"],
  ["design_fixed_continuous",
   { mean_diff: 30, sd: 70, alpha: 0.025, power: 0.8, sided: 2 },
   (r) => r.sample_size_total > 100 && r.sample_size_total < 400],
  ["design_fixed_survival_ph",
   { control_median: 30, hazard_ratio: 0.75, accrual_rate: 100,
     accrual_duration: 30, followup_duration: 24,
     alpha: 0.025, power: 0.9, sided: 1 },
   (r) => r.events_total > 300 && r.events_total < 700],
  ["design_fixed_survival_maxcombo",
   { control_median: 10, delay_months: 4, post_delay_hr: 0.6,
     accrual_rate: 20, accrual_duration: 18, study_duration: 30,
     alpha: 0.025, power: 0.9 },
   (r) => r.events_total > 0 && r.sample_size_total > 0],
  ["design_fixed_survival_rmst",
   { control_median: 10, delay_months: 4, post_delay_hr: 0.6,
     accrual_rate: 20, accrual_duration: 18, study_duration: 30, tau: 24,
     alpha: 0.025, power: 0.9 },
   (r) => r.events_total > 0 && r.sample_size_total > 0],
  ["design_fixed_survival_milestone",
   { control_median: 10, delay_months: 4, post_delay_hr: 0.6,
     accrual_rate: 20, accrual_duration: 18, study_duration: 30, tau: 24,
     alpha: 0.025, power: 0.9 },
   (r) => r.events_total > 0 && r.sample_size_total > 0],
  ["design_gs_binary",
   { p_control: 0.10, p_treatment: 0.05, k: 2, sfu: "LDOF", sfl: "LDOF",
     alpha: 0.025, power: 0.8, sided: 1 },
   (r) => r.boundaries.upper_z.length === 2 &&
          r.boundaries.upper_z[0] > r.boundaries.upper_z[1]],
  ["design_gs_survival_ph",
   { control_median: 30, hazard_ratio: 0.75, accrual_rate: 100,
     accrual_duration: 30, followup_duration: 24, k: 2, sfu: "LDOF",
     alpha: 0.025, power: 0.9, sided: 1 },
   (r) => r.events_total > 300 && r.events_total < 700 &&
          r.boundaries && r.boundaries.upper_z.length === 2],
  ["design_gs_survival_nph_combo",
   { control_median: 12, delay_months: 6, post_delay_hr: 0.6,
     accrual_rate: 30, accrual_duration: 12,
     analysis_times: [18, 30], test: "maxcombo",
     alpha: 0.025, power: 0.9 },
   (r) => r.events_total > 0 && r.boundaries.upper_z.length === 2],
  ["validate_against_benchmark",
   { family: "fixed-superiority", id: "1997_CAPTURE_abciximab" },
   (r) => r.case_id === "1997_CAPTURE_abciximab" &&
          r.tool === "design_fixed_binary"],
];

let passed = 0, failed = 0;
for (const [label, args, check, toolOverride] of cases) {
  const tool = toolOverride ?? label.split(" ")[0];
  process.stdout.write(`[${tool}] ${label} ... `);
  try {
    const res = await runR(tool, args);
    if (check(res)) {
      console.log("OK");
      passed++;
    } else {
      console.log("FAIL (result did not match expected shape)");
      console.log("   result:", JSON.stringify(res).slice(0, 200));
      failed++;
    }
  } catch (e) {
    const msg = e instanceof DesignrToolError
      ? `[${e.cls}] ${e.message}`
      : e.message;
    console.log("ERROR:", msg);
    failed++;
  }
}

// Chained cases: verify_design and design_report take the result of another
// design_* tool as input, so they run after the main loop using a fresh
// fixed-binary design as the seed.
const seedDesign = await runR("design_fixed_binary",
  { p_control: 0.15, p_treatment: 0.09, alpha: 0.05, power: 0.8, sided: 2 });

const chained = [
  ["verify_design",
   { result: seedDesign, n_sim: 1500, seed: 1 },
   (r) => r.family === "fixed_binary" && r.passes === true],
  ["design_report",
   { result: seedDesign, format: "markdown" },
   (r) => typeof r === "string" &&
          r.includes("# Fixed-sample binary endpoint") &&
          r.includes("## Headline output")],
];

for (const [tool, args, check] of chained) {
  process.stdout.write(`[${tool}] ${tool} (chained) ... `);
  try {
    const res = await runR(tool, args);
    if (check(res)) {
      console.log("OK");
      passed++;
    } else {
      console.log("FAIL (result did not match expected shape)");
      console.log("   result:", JSON.stringify(res).slice(0, 200));
      failed++;
    }
  } catch (e) {
    const msg = e instanceof DesignrToolError
      ? `[${e.cls}] ${e.message}`
      : e.message;
    console.log("ERROR:", msg);
    failed++;
  }
}

const total = cases.length + chained.length;
console.log(`\n${passed} pass / ${failed} fail / ${total} total`);
process.exit(failed === 0 ? 0 : 1);
