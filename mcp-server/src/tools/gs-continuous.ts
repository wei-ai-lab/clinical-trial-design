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

export const toolName = "design_gs_continuous";
export const schema = {
  mean_diff: z.number(),
  sd: z.number().positive(),
  k: KSchema,
  timing: TimingSchema,
  sfu: SpendingFnEnum.default("LDOF"),
  sfl: SpendingFnEnum.default("LDOF"),
  sfupar: z.number().optional(),
  sflpar: z.number().optional(),
  test_type: TestTypeSchema,
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: SidedSchema,
  allocation_ratio: AllocationRatioSchema,
  comparison: ComparisonEnum.default("superiority"),
  ni_margin: z.number().positive().optional(),
};

export const description =
  "Group-sequential two-arm continuous-endpoint design (gsDesign::gsDesign + nNormal).";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  const { test_type, ...rest } = args;
  return runR(toolName, { ...rest, "test.type": test_type });
};
