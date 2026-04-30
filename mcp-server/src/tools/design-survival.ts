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
  ReasoningChainSchema,
  SpendingFnEnum,
  SurvivalModelEnum,
  TestTypeSchema,
  TimingSchema,
} from "./common-schemas.js";

export const toolName = "design_survival";
export const schema = {
  model: SurvivalModelEnum.default("ph"),
  design_class: DesignClassEnum.default("fixed"),
  control_median: z
    .number()
    .positive()
    .optional()
    .describe(
      "Control-arm median survival (months). Mutually exclusive with " +
        "control_hazard_rate; supply exactly one."
    ),
  control_hazard_rate: z
    .number()
    .positive()
    .optional()
    .describe(
      "Annualized control-arm event rate, in events per patient-year (e.g., " +
        "0.025 for a 2.5%/year CVOT control rate). Useful when the trial " +
        "characterizes the control arm by hazard rather than median time-to-" +
        "event. Internally converted to median = 12 * log(2) / control_hazard_rate. " +
        "Mutually exclusive with control_median."
    ),
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
  reasoning_chain: ReasoningChainSchema,
  events_calc: z
    .enum(["schoenfeld", "lachin-foulkes", "freedman"])
    .optional()
    .describe(
      "PH group-sequential only. Selects gsSurv's events-calculation method: " +
        "'schoenfeld' (default) matches Schoenfeld + OBF inflation, the " +
        "regulatory convention; 'lachin-foulkes' is gsSurv's pre-v0.0.13 " +
        "default (slightly anti-conservative on events, ~3% lower); 'freedman' " +
        "is conservative-leaning, rarely used. Non-inferiority designs " +
        "auto-fall-back to lachin-foulkes (Schoenfeld requires hr0 = 1)."
    ),
};

export const description =
  "Use when the user wants Phase 2/3 sample size with a TIME-TO-EVENT primary " +
  "endpoint — overall survival, PFS, time to first hospitalization, time to " +
  "progression, time to a CV composite, etc. Choose the test statistic via " +
  "`model`: 'ph' (default — log-rank under proportional hazards, gsDesign::" +
  "nSurv / gsSurv), 'maxcombo' (delayed effect / non-proportional hazards via " +
  "Fleming-Harrington combo), 'rmst' (restricted mean survival to landmark " +
  "tau), 'milestone' (survival probability at landmark t*), 'wlr' / 'ahr' " +
  "(weighted log-rank / average HR for GS NPH). Set design_class='group-" +
  "sequential' for interim analyses with alpha-spending. Always provide " +
  "control_median + the relevant effect parameter (hazard_ratio for PH; " +
  "delay_months + post_delay_hr for NPH models). The `operational` block " +
  "can solve any 0–4 of {accrual_rate, accrual_duration, followup_duration, " +
  "total_trial_duration} via the events-tied uniroot. For two co-primary " +
  "TTE endpoints (PFS+OS) use design_co_primary; for nested PD-L1 strata or " +
  "biomarker subgroup + ITT use design_multi_population.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  const { test_type, ...rest } = args;
  return runR(toolName, { ...rest, "test.type": test_type });
};
