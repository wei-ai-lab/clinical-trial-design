#!/usr/bin/env node
// Programmatic smoke pass against the v0.0.7 unified tool surface.
// Returns exit code 0 if all succeed, 1 otherwise.

import { runR, DesignrToolError } from "../build/r-bridge.js";

const cases = [
  // --- design_binary -------------------------------------------------
  ["design_binary fixed superiority",
   { p_control: 0.15, p_treatment: 0.09, design_class: "fixed",
     alpha: 0.025, power: 0.8, sided: 2 },
   "design_binary",
   (r) => r.sample_size_total > 900 && r.sample_size_total < 1300],

  ["design_binary fixed non-inferiority",
   { p_control: 0.85, p_treatment: 0.85, design_class: "fixed",
     comparison: "non-inferiority", ni_margin: 0.07,
     alpha: 0.025, power: 0.8, sided: 1 },
   "design_binary",
   (r) => r.sample_size_total > 0 && r.method.includes("non-inferiority")],

  ["design_binary fixed + operational kernel",
   { p_control: 0.15, p_treatment: 0.09, design_class: "fixed",
     alpha: 0.05, power: 0.8, sided: 2,
     operational: { accrual_rate: 80, follow_up_duration: 3 } },
   "design_binary",
   (r) => r.operational && r.operational.accrual_duration > 0 &&
          r.operational.given.includes("accrual_rate")],

  ["design_binary group-sequential",
   { p_control: 0.10, p_treatment: 0.05, design_class: "group-sequential",
     k: 2, sfu: "LDOF", sfl: "LDOF",
     alpha: 0.025, power: 0.8, sided: 1 },
   "design_binary",
   (r) => r.boundaries && r.boundaries.upper_z.length === 2 &&
          r.boundaries.upper_z[0] > r.boundaries.upper_z[1]],

  // --- design_continuous ---------------------------------------------
  ["design_continuous fixed superiority",
   { mean_diff: 30, sd: 70, design_class: "fixed",
     alpha: 0.025, power: 0.8, sided: 2 },
   "design_continuous",
   (r) => r.sample_size_total > 100 && r.sample_size_total < 400],

  // --- design_survival (PH) ------------------------------------------
  ["design_survival ph fixed",
   { model: "ph", design_class: "fixed",
     control_median: 30, hazard_ratio: 0.75,
     accrual_rate: 100, accrual_duration: 30, followup_duration: 24,
     alpha: 0.025, power: 0.9, sided: 1 },
   "design_survival",
   (r) => r.events_total > 300 && r.events_total < 700],

  ["design_survival ph group-sequential",
   { model: "ph", design_class: "group-sequential",
     control_median: 30, hazard_ratio: 0.75,
     accrual_rate: 100, accrual_duration: 30, followup_duration: 24,
     k: 2, sfu: "LDOF",
     alpha: 0.025, power: 0.9, sided: 1 },
   "design_survival",
   (r) => r.events_total > 300 && r.events_total < 700 &&
          r.boundaries && r.boundaries.upper_z.length === 2],

  // --- design_survival (NPH fixed) -----------------------------------
  ["design_survival maxcombo fixed",
   { model: "maxcombo", design_class: "fixed",
     control_median: 10, delay_months: 4, post_delay_hr: 0.6,
     accrual_rate: 20, accrual_duration: 18, followup_duration: 12,
     alpha: 0.025, power: 0.9 },
   "design_survival",
   (r) => r.events_total > 0 && r.sample_size_total > 0],

  ["design_survival rmst fixed",
   { model: "rmst", design_class: "fixed",
     control_median: 10, delay_months: 4, post_delay_hr: 0.6,
     accrual_rate: 20, accrual_duration: 18, followup_duration: 12, tau: 24,
     alpha: 0.025, power: 0.9 },
   "design_survival",
   (r) => r.events_total > 0 && r.sample_size_total > 0],

  ["design_survival milestone fixed",
   { model: "milestone", design_class: "fixed",
     control_median: 10, delay_months: 4, post_delay_hr: 0.6,
     accrual_rate: 20, accrual_duration: 18, followup_duration: 12, tau: 24,
     alpha: 0.025, power: 0.9 },
   "design_survival",
   (r) => r.events_total > 0 && r.sample_size_total > 0],

  // --- design_survival (NPH GS) --------------------------------------
  ["design_survival maxcombo group-sequential",
   { model: "maxcombo", design_class: "group-sequential",
     control_median: 12, delay_months: 6, post_delay_hr: 0.6,
     accrual_rate: 30, accrual_duration: 12,
     analysis_times: [18, 30],
     alpha: 0.025, power: 0.9 },
   "design_survival",
   (r) => r.events_total > 0 && r.boundaries.upper_z.length === 2],

  // --- benchmark validator -------------------------------------------
  ["validate_against_benchmark CAPTURE",
   { family: "fixed-superiority", id: "1997_CAPTURE_abciximab" },
   "validate_against_benchmark",
   (r) => r.case_id === "1997_CAPTURE_abciximab" &&
          r.tool === "design_binary"],
];

let passed = 0, failed = 0;
for (const [label, args, tool, check] of cases) {
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

// Chained: verify_design and design_report take a design result as input.
const seedDesign = await runR("design_binary",
  { p_control: 0.15, p_treatment: 0.09, design_class: "fixed",
    alpha: 0.05, power: 0.8, sided: 2 });

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
