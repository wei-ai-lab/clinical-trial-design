import { z } from "zod";
import { runR } from "../r-bridge.js";
import { AlphaSchema, AllocationRatioSchema, PowerSchema } from "./common-schemas.js";

export const toolName = "design_fixed_survival_maxcombo";
export const schema = {
  control_median: z.number().positive().describe("Control-arm median survival (months)."),
  delay_months: z
    .number()
    .nonnegative()
    .describe("Duration of the no-effect period before treatment benefit starts. 0 = immediate PH."),
  post_delay_hr: z.number().positive().describe("Hazard ratio after delay_months."),
  accrual_rate: z.number().positive().describe("Enrollment rate (subjects/month)."),
  accrual_duration: z.number().positive().describe("Accrual period (months)."),
  study_duration: z
    .number()
    .positive()
    .describe("Total study duration from first enrollment to final analysis (months). Must exceed accrual_duration."),
  dropout_rate: z.number().nonnegative().default(0.001).describe("Per-month dropout hazard."),
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: z.literal(1).default(1).describe("MaxCombo is one-sided only."),
  allocation_ratio: AllocationRatioSchema,
  rho: z
    .array(z.number())
    .default([0, 0, 1])
    .describe("Fleming-Harrington rho for each weight combination."),
  gamma: z
    .array(z.number())
    .default([0, 1, 0])
    .describe("Fleming-Harrington gamma for each weight combination."),
  tau: z
    .array(z.number())
    .default([-1, -1, -1])
    .describe("Tau for each weight (-1 = unbounded)."),
};

export const description =
  "Fixed-sample TTE design using MaxCombo under NPH (gsDesign2::fixed_design_maxcombo). " +
  "Handles delayed / crossing-hazard effects via FH-weighted log-rank combos.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
