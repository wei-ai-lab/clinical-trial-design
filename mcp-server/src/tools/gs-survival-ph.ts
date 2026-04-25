import { z } from "zod";
import { runR } from "../r-bridge.js";
import {
  AlphaSchema,
  AllocationRatioSchema,
  ComparisonEnum,
  KSchema,
  PowerSchema,
  SpendingFnEnum,
  TestTypeSchema,
  TimingSchema,
} from "./common-schemas.js";

export const toolName = "design_gs_survival_ph";
export const schema = {
  control_median: z.number().positive(),
  hazard_ratio: z.number().positive(),
  accrual_rate: z.number().positive(),
  accrual_duration: z.number().positive(),
  followup_duration: z.number().positive(),
  dropout_rate: z.number().nonnegative().default(0.001),
  k: KSchema,
  timing: TimingSchema,
  sfu: SpendingFnEnum.default("LDOF"),
  sfl: SpendingFnEnum.default("LDOF"),
  sfupar: z.number().optional(),
  sflpar: z.number().optional(),
  test_type: TestTypeSchema,
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: z.literal(1).default(1),
  allocation_ratio: AllocationRatioSchema,
  comparison: ComparisonEnum.default("superiority"),
  hr_null: z.number().positive().optional().describe("Null HR for NI (e.g. 1.3)."),
  ni_hr: z.number().positive().optional().describe("Alias for hr_null."),
};

export const description =
  "Group-sequential TTE design under proportional hazards (gsDesign::gsSurv). " +
  "Returns max events, per-analysis events and Z-boundaries, accrual/follow-up timing.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  const { test_type, ...rest } = args;
  return runR(toolName, { ...rest, "test.type": test_type });
};
