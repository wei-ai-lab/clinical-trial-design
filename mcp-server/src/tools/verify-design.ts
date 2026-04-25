import { z } from "zod";
import { runR } from "../r-bridge.js";

export const toolName = "verify_design";
export const schema = {
  result: z
    .record(z.unknown())
    .describe(
      "A designr result object as returned by any design_* tool (the JSON payload, " +
      "including $method, $inputs, and (for GS) $boundaries / $timing)."
    ),
  n_sim: z
    .number()
    .int()
    .positive()
    .optional()
    .describe("Monte Carlo replicate count. Default 5000."),
  seed: z
    .number()
    .int()
    .optional()
    .describe("RNG seed for reproducibility. Default 1."),
  tolerance_power_pp: z
    .number()
    .positive()
    .optional()
    .describe("Allowed deviation from target power, in percentage points. Default 2."),
  tolerance_type_I_pp: z
    .number()
    .positive()
    .optional()
    .describe("Allowed deviation from target alpha, in percentage points. Default 0.5."),
};

export const description =
  "Monte Carlo simulation cross-check for a designr result. Closed-form simulation " +
  "(rbinom / rnorm / rexp) drives empirical power and Type I error estimates against the " +
  "design's target alpha and power. Supports fixed and group-sequential families on binary, " +
  "continuous, and PH survival endpoints. NPH families (MaxCombo, RMST, milestone) and " +
  "equivalence designs are not yet supported and return a clean error.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
