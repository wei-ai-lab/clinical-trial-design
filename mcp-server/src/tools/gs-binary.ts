import { z } from "zod";
import { runR } from "../r-bridge.js";
import {
  AlphaSchema,
  AllocationRatioSchema,
  ComparisonEnum,
  KSchema,
  PowerSchema,
  SidedSchema,
  SpendingFnEnum,
  TestTypeSchema,
  TimingSchema,
} from "./common-schemas.js";

const ProbSchema = z.number().gt(0).lt(1);

export const toolName = "design_gs_binary";
export const schema = {
  p_control: ProbSchema,
  p_treatment: ProbSchema,
  k: KSchema,
  timing: TimingSchema,
  sfu: SpendingFnEnum.default("LDOF"),
  sfl: SpendingFnEnum.default("LDOF"),
  sfupar: z.number().optional().describe("Numeric parameter for HSD / Power upper sf."),
  sflpar: z.number().optional().describe("Numeric parameter for HSD / Power lower sf."),
  test_type: TestTypeSchema,
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: SidedSchema,
  allocation_ratio: AllocationRatioSchema,
  comparison: ComparisonEnum.default("superiority"),
  ni_margin: z.number().positive().optional(),
};

export const description =
  "Group-sequential two-arm binary-endpoint design (gsDesign::gsDesign + nBinomial). " +
  "Returns max N, per-analysis N, and Z/p boundaries from the chosen alpha-spending function.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  const { test_type, ...rest } = args;
  return runR(toolName, { ...rest, "test.type": test_type });
};
