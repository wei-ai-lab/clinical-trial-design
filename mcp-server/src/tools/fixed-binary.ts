import { z } from "zod";
import { runR } from "../r-bridge.js";
import {
  AlphaSchema,
  AllocationRatioSchema,
  ComparisonEnum,
  PowerSchema,
  SidedSchema,
} from "./common-schemas.js";

const ProbSchema = z.number().gt(0).lt(1);

export const toolName = "design_fixed_binary";
export const schema = {
  p_control: ProbSchema.describe("Event rate in the control arm (0,1)."),
  p_treatment: ProbSchema.describe("Event rate in the treatment arm (0,1)."),
  alpha: AlphaSchema,
  power: PowerSchema,
  sided: SidedSchema,
  allocation_ratio: AllocationRatioSchema,
  comparison: ComparisonEnum.default("superiority"),
  ni_margin: z.number().positive().optional().describe(
    "Non-inferiority margin on the risk-difference scale. Required when comparison='non-inferiority'."
  ),
  equiv_margin: z.number().positive().optional().describe(
    "Two-sided equivalence margin (TOST). Required when comparison='equivalence'."
  ),
};

export const description =
  "Fixed-sample two-arm binary-endpoint design (gsDesign::nBinomial). " +
  "Supports superiority, non-inferiority, and equivalence (TOST). Returns total sample size, per-arm sample size, and method metadata.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
