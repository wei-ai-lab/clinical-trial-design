import { z } from "zod";
import { runR } from "../r-bridge.js";
import {
  AlphaSchema,
  AllocationRatioSchema,
  PowerSchema,
  SpendingFnEnum,
} from "./common-schemas.js";

export const toolName = "design_gs_survival_nph_combo";
export const schema = {
  control_median: z.number().positive(),
  delay_months: z.number().nonnegative(),
  post_delay_hr: z.number().positive(),
  accrual_rate: z.number().positive(),
  accrual_duration: z.number().positive(),
  analysis_times: z
    .array(z.number().positive())
    .min(2)
    .describe("Calendar times (months) of the k planned analyses; strictly increasing."),
  dropout_rate: z.number().nonnegative().default(0.001),
  test: z
    .enum(["maxcombo", "wlr", "ahr"])
    .default("maxcombo")
    .describe(
      "Statistic: maxcombo = FH MaxCombo (default), wlr = weighted log-rank, ahr = average hazard ratio."
    ),
  rho: z.array(z.number()).default([0, 0, 1]),
  gamma: z.array(z.number()).default([0, 1, 0]),
  tau: z.array(z.number()).default([-1, -1, -1]),
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: z.literal(1).default(1),
  allocation_ratio: AllocationRatioSchema,
  sfu: SpendingFnEnum.default("LDOF"),
  binding: z.boolean().default(false).describe("Whether the futility boundary is binding."),
};

export const description =
  "Group-sequential TTE design under NPH using MaxCombo / weighted log-rank / AHR " +
  "(gsDesign2::gs_design_combo / gs_design_wlr / gs_design_ahr).";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
