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
  "Two-arm continuous-endpoint trial design (gsDesign::nNormal / gsDesign). " +
  "Supports superiority, non-inferiority, and equivalence (TOST). Set " +
  "design_class='group-sequential' for interim analyses with alpha-spending " +
  "(equivalence is fixed-sample only).";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  const { test_type, ...rest } = args;
  return runR(toolName, { ...rest, "test.type": test_type });
};
