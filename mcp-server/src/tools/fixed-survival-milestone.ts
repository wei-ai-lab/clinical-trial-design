import { z } from "zod";
import { runR } from "../r-bridge.js";
import { AlphaSchema, AllocationRatioSchema, PowerSchema } from "./common-schemas.js";

export const toolName = "design_fixed_survival_milestone";
export const schema = {
  control_median: z.number().positive().describe("Control-arm median survival (months)."),
  delay_months: z.number().nonnegative().describe("Delay before treatment effect starts (NPH)."),
  post_delay_hr: z.number().positive().describe("Hazard ratio after delay_months."),
  accrual_rate: z.number().positive().describe("Enrollment rate (subjects/month)."),
  accrual_duration: z.number().positive().describe("Accrual period (months)."),
  study_duration: z
    .number()
    .positive()
    .describe("Total study duration (months); must exceed accrual_duration."),
  tau: z
    .number()
    .positive()
    .optional()
    .describe("Milestone time for S(tau) comparison (months). Defaults to study_duration."),
  dropout_rate: z.number().nonnegative().default(0.001),
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: z.literal(1).default(1),
  allocation_ratio: AllocationRatioSchema,
};

export const description =
  "Fixed-sample TTE design based on milestone survival probability S(tau) (gsDesign2::fixed_design_milestone).";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
