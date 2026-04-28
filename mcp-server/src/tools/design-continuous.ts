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
  SidedSchema,
  SpendingFnEnum,
  TestTypeSchema,
  TimingSchema,
} from "./common-schemas.js";

export const toolName = "design_continuous";
export const schema = {
  mean_diff: z.number().describe("Assumed mean difference (treatment - control)."),
  sd: z.number().positive().describe("Common within-arm SD."),
  design_class: DesignClassEnum.default("fixed"),
  comparison: ComparisonEnum.default("superiority"),
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: SidedSchema,
  allocation_ratio: AllocationRatioSchema,
  ni_margin: z
    .number()
    .positive()
    .optional()
    .describe("Non-inferiority margin on the mean-difference scale."),
  equiv_margin: z
    .number()
    .positive()
    .optional()
    .describe("Two-sided equivalence margin (TOST). Fixed-sample only."),
  k: KSchema,
  timing: TimingSchema,
  sfu: SpendingFnEnum.default("LDOF"),
  sfl: SpendingFnEnum.default("LDOF"),
  sfupar: z.number().optional(),
  sflpar: z.number().optional(),
  test_type: TestTypeSchema,
  operational: OperationalBlockSchema,
};

export const description =
  "Use when the user wants two-arm Phase 2/3 sample size with a CONTINUOUS " +
  "primary endpoint — change from baseline in a measured score (HAM-D-17, " +
  "PANSS, HbA1c reduction, eGFR slope, BP), QoL scale, biomarker level. " +
  "Provide mean_diff (assumed treatment - control mean) and the common " +
  "within-arm sd. Set comparison='superiority' (default), 'non-inferiority' " +
  "(provide ni_margin), or 'equivalence' (provide equiv_margin; fixed-sample " +
  "only). Set design_class='group-sequential' for interim analyses with " +
  "alpha-spending. Supports the same `operational` block as design_binary " +
  "and design_survival. For multi-endpoint designs, use design_co_primary.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  const { test_type, ...rest } = args;
  return runR(toolName, { ...rest, "test.type": test_type });
};
