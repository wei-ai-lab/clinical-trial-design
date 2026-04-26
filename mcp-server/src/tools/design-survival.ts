import { z } from "zod";
import { runR } from "../r-bridge.js";
import {
  AlphaSchema,
  AllocationRatioSchema,
  ComparisonEnum,
  DesignClassEnum,
  KSchema,
  OperationalBlockSchema,
  PowerSchema,
  SpendingFnEnum,
  SurvivalModelEnum,
  TestTypeSchema,
  TimingSchema,
} from "./common-schemas.js";

export const toolName = "design_survival";
export const schema = {
  model: SurvivalModelEnum.default("ph"),
  design_class: DesignClassEnum.default("fixed"),
  control_median: z.number().positive().describe("Control-arm median survival (months)."),
  hazard_ratio: z
    .number()
    .positive()
    .optional()
    .describe(
      "Target HR (PH only). < 1 favors treatment. For NI with hr_null > 1, the assumed true HR is often 1."
    ),
  hr_null: z
    .number()
    .positive()
    .optional()
    .describe("Null-hypothesis HR for non-inferiority (typically > 1, e.g. 1.3)."),
  ni_hr: z.number().positive().optional().describe("Alias for hr_null."),
  delay_months: z
    .number()
    .nonnegative()
    .default(0)
    .describe("Duration of HR=1 period preceding the effect (NPH models)."),
  post_delay_hr: z
    .number()
    .positive()
    .optional()
    .describe("HR after delay_months (NPH models)."),
  accrual_rate: z
    .number()
    .positive()
    .optional()
    .describe("Enrollment rate (subjects/month)."),
  accrual_duration: z
    .number()
    .positive()
    .default(12)
    .describe("Accrual period (months)."),
  followup_duration: z
    .number()
    .nonnegative()
    .default(12)
    .describe("Minimum follow-up after last enrollment (months)."),
  dropout_rate: z.number().nonnegative().default(0).describe("Per-month dropout hazard."),
  tau: z
    .number()
    .positive()
    .optional()
    .describe(
      "Landmark time for RMST / milestone (months). Defaults to total study duration."
    ),
  rho: z
    .array(z.number())
    .optional()
    .describe("Fleming-Harrington rho weights (MaxCombo / WLR)."),
  gamma: z
    .array(z.number())
    .optional()
    .describe("Fleming-Harrington gamma weights (MaxCombo / WLR)."),
  tau_fh: z
    .union([z.number(), z.array(z.number())])
    .optional()
    .describe("Fleming-Harrington tau (MaxCombo / WLR)."),
  k: KSchema,
  timing: TimingSchema,
  sfu: SpendingFnEnum.default("LDOF"),
  sfl: SpendingFnEnum.default("LDOF"),
  sfupar: z.number().optional(),
  sflpar: z.number().optional(),
  test_type: TestTypeSchema,
  analysis_times: z
    .array(z.number().positive())
    .optional()
    .describe("Calendar times of k planned analyses (NPH GS); last = study duration."),
  binding: z
    .boolean()
    .default(false)
    .describe("Whether the futility boundary is binding (NPH GS)."),
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: z.literal(1).default(1).describe("TTE designs are one-sided."),
  allocation_ratio: AllocationRatioSchema,
  comparison: ComparisonEnum.default("superiority"),
  operational: OperationalBlockSchema,
};

export const description =
  "Two-arm time-to-event trial design. Pick `model` for the test statistic " +
  "(ph, maxcombo, rmst, milestone, wlr, ahr) and `design_class` (fixed, " +
  "group-sequential). PH backends are gsDesign::nSurv / gsSurv; NPH backends " +
  "are gsDesign2::fixed_design_* / gs_design_*. Returns total events, total N, " +
  "per-arm N, accrual / follow-up timing, and (for GS) interim boundaries. " +
  "Optionally solves the operational kernel via the `operational` block.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  const { test_type, ...rest } = args;
  return runR(toolName, { ...rest, "test.type": test_type });
};
