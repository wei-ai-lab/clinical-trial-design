import { z } from "zod";
import { runR } from "../r-bridge.js";
import {
  AlphaSchema,
  AllocationRatioSchema,
  ComparisonEnum,
  PowerSchema,
} from "./common-schemas.js";

export const toolName = "design_fixed_survival_ph";
export const schema = {
  control_median: z.number().positive().describe("Control-arm median survival (months)."),
  hazard_ratio: z.number().positive().describe(
    "Target treatment/control HR. < 1 favors treatment. For NI with hr_null > 1, the assumed true HR is often 1."
  ),
  accrual_rate: z.number().positive().describe("Enrollment rate (subjects/month)."),
  accrual_duration: z.number().positive().describe("Accrual period (months)."),
  followup_duration: z
    .number()
    .positive()
    .describe("Minimum follow-up after last enrollment (months)."),
  dropout_rate: z.number().nonnegative().default(0.001).describe("Per-month dropout hazard."),
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: z.literal(1).default(1).describe("One-sided only for TTE (use 1)."),
  allocation_ratio: AllocationRatioSchema,
  comparison: ComparisonEnum.default("superiority"),
  hr_null: z
    .number()
    .positive()
    .optional()
    .describe("Null-hypothesis HR for non-inferiority (typically > 1, e.g. 1.3)."),
  ni_hr: z
    .number()
    .positive()
    .optional()
    .describe("Alias for hr_null."),
};

export const description =
  "Fixed-sample TTE design under proportional hazards (gsDesign::nSurv). " +
  "Returns total events, total sample size, accrual/follow-up durations.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
