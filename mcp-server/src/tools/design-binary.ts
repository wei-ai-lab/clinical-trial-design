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

const ProbSchema = z.number().gt(0).lt(1);

export const toolName = "design_binary";
export const schema = {
  p_control: ProbSchema.describe("Event rate in the control arm (0,1)."),
  p_treatment: ProbSchema.describe("Event rate in the treatment arm (0,1)."),
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
    .describe(
      "Non-inferiority margin on the risk-difference scale. Required when comparison='non-inferiority'."
    ),
  equiv_margin: z
    .number()
    .positive()
    .optional()
    .describe(
      "Two-sided equivalence margin (TOST). Required when comparison='equivalence'. Fixed-sample only."
    ),
  k: KSchema,
  timing: TimingSchema,
  sfu: SpendingFnEnum.default("LDOF"),
  sfl: SpendingFnEnum.default("LDOF"),
  sfupar: z.number().optional().describe("Numeric parameter for HSD / Power upper sf."),
  sflpar: z.number().optional().describe("Numeric parameter for HSD / Power lower sf."),
  test_type: TestTypeSchema,
  operational: OperationalBlockSchema,
};

export const description =
  "Use when the user wants two-arm Phase 2/3 sample size with a BINARY " +
  "primary endpoint — responder rate, fixed-time mortality, ORR, ACR20, " +
  "remission/cure, anything that resolves to event-or-no-event per " +
  "subject. Set comparison='superiority' (default), 'non-inferiority' " +
  "(then provide ni_margin), or 'equivalence' (then provide equiv_margin; " +
  "fixed-sample only). Set design_class='group-sequential' for interim " +
  "analyses with alpha-spending. Supply an optional `operational` block " +
  "(any 0–4 of accrual_rate, accrual_duration, follow_up_duration, " +
  "total_trial_duration) and the kernel fills in the rest. For two or " +
  "more co-primary binary endpoints with multiplicity control, use " +
  "design_co_primary instead.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  const { test_type, ...rest } = args;
  return runR(toolName, { ...rest, "test.type": test_type });
};
