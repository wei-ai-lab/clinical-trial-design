import { z } from "zod";
import { runR } from "../r-bridge.js";

export const toolName = "validate_against_benchmark";
export const schema = {
  family: z
    .string()
    .describe(
      "Benchmark family directory name under benchmarks/ (e.g. 'fixed-superiority', 'group-sequential', 'tte-nph')."
    ),
  id: z
    .string()
    .describe(
      "Case ID = YAML filename without extension, e.g. '1997_CAPTURE_abciximab'."
    ),
  tool: z
    .string()
    .optional()
    .describe("Override the design tool to dispatch. If omitted, inferred from case metadata."),
};

export const description =
  "Load a benchmark corpus case, re-run the matching design wrapper with its inputs, " +
  "and diff computed sample_size_total / events_total against expected within the case's tolerance.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) =>
  runR(toolName, args);
