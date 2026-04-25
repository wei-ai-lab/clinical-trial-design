import { z } from "zod";
import { runR } from "../r-bridge.js";
import {
  AlphaSchema,
  AllocationRatioSchema,
  ComparisonEnum,
  PowerSchema,
  SidedSchema,
} from "./common-schemas.js";

export const toolName = "design_fixed_continuous";
export const schema = {
  mean_diff: z
    .number()
    .describe("Assumed mean difference (treatment − control)."),
  sd: z.number().positive().describe("Common within-arm SD."),
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: SidedSchema,
  allocation_ratio: AllocationRatioSchema,
  comparison: ComparisonEnum.default("superiority"),
  ni_margin: z
    .number()
    .positive()
    .optional()
    .describe("Non-inferiority margin on the mean-difference scale."),
  equiv_margin: z
    .number()
    .positive()
    .optional()
    .describe("Two-sided equivalence margin (TOST)."),
};

export const description =
  "Fixed-sample two-arm continuous-endpoint design (gsDesign::nNormal). " +
  "Supports superiority, non-inferiority, and equivalence (TOST).";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
