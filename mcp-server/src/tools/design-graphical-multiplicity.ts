import { z } from "zod";
import { runR } from "../r-bridge.js";

const HypothesisSpecSchema = z
  .object({
    type: z
      .enum(["binary", "continuous", "survival"])
      .describe("Endpoint family for this hypothesis."),
  })
  .passthrough();

export const toolName = "design_graphical_multiplicity";
export const schema = {
  hypotheses: z
    .record(z.string().min(1), HypothesisSpecSchema)
    .describe(
      "Named map of hypotheses. Each entry has `type` plus the parameters " +
        "the matching design_<type> wrapper accepts. Continuous uses `mean_diff`, " +
        "binary uses `p_treatment`, survival uses `hazard_ratio`."
    ),
  initial_weights: z
    .record(z.string().min(1), z.number().nonnegative())
    .describe(
      "Per-hypothesis initial alpha weights. Names match `hypotheses`; sum to <= 1. " +
        "Hypotheses with weight 0 start un-testable and become testable only " +
        "after alpha is recycled to them through the transition matrix."
    ),
  transition_matrix: z
    .array(z.array(z.number().min(0).max(1)))
    .describe(
      "Square (k x k) transition matrix. Row i column j = weight of alpha " +
        "re-allocated from hypothesis i to hypothesis j upon rejection of i. " +
        "Each row sums to <= 1; diagonal must be 0 (no self-loops). Order " +
        "of rows/columns matches the order of `hypotheses`."
    ),
  gate_prereqs: z
    .record(z.string().min(1), z.array(z.string().min(1)))
    .optional()
    .describe(
      "Optional per-hypothesis prerequisite map. Each entry is the list of " +
        "hypothesis names that must be rejected before this one can be tested. " +
        "Used by the Rule-3 validator: every prerequisite must have a non-zero " +
        "transition into the gated hypothesis."
    ),
  alpha: z.number().positive().lt(1).default(0.025),
  sided: z.union([z.literal(1), z.literal(2)]).default(1),
  power: z.number().gt(0).lt(1).default(0.8),
  allocation_ratio: z.number().positive().default(1),
  worst_case_weights: z
    .record(z.string().min(1), z.number().nonnegative())
    .optional()
    .describe(
      "Optional override of the per-hypothesis worst-case weight used for " +
        "sample-size sizing. Default: max(initial_weight_i, fallback) where " +
        "fallback = smallest non-zero initial weight."
    ),
};

export const description =
  "Graphical multiplicity (Maurer-Bretz) trial design with alpha recycling. " +
  "Use when a confirmatory trial has 2+ hypotheses (mixed primary + " +
  "secondary, dose-response, parent + derived endpoints) where a graph-based " +
  "procedure preserves family-wise alpha better than Bonferroni. Validates " +
  "the transition matrix (Rule-3 + row sums) and constructs a graphicalMCP " +
  "graph object. Sizes each hypothesis at its worst-case alpha; total N is " +
  "the max across hypotheses. For simpler co-primary or multi-population " +
  "designs use design_co_primary or design_multi_population instead.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  return runR(toolName, args);
};
