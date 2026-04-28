import { z } from "zod";
import { runR } from "../r-bridge.js";

const EndpointTypeEnum = z.enum(["binary", "continuous", "survival"]);

// We accept arbitrary keys per endpoint because the schema of an endpoint
// matches the wrapper that handles its `type`. Heavy validation happens in
// the R wrapper (`design_co_primary` dispatches to `design_<type>` and
// surfaces designr_input_error: endpoints: '<name>': <field>: <why>).
const EndpointSpecSchema = z
  .object({
    type: EndpointTypeEnum.describe(
      "Endpoint family — selects which design_<type> wrapper handles this endpoint."
    ),
  })
  .passthrough();

export const toolName = "design_co_primary";
export const schema = {
  endpoints: z
    .record(z.string().min(1), EndpointSpecSchema)
    .describe(
      "Named map of co-primary endpoints. Each entry has `type` plus the parameters " +
        "the matching design_<type> wrapper accepts (e.g., for survival: model, " +
        "design_class, control_median, hazard_ratio, accrual_duration, followup_duration)."
    ),
  strategy: z
    .enum(["fixed-sequence", "alpha-split", "bonferroni"])
    .default("fixed-sequence")
    .describe(
      "Multiplicity-control strategy. `fixed-sequence` (hierarchical) tests each " +
        "endpoint at the full family alpha conditional on prior rejection — preserves " +
        "alpha by closed testing, no per-test discount. `alpha-split` partitions alpha " +
        "by user weights. `bonferroni` is equal-weight alpha-split (alpha/k)."
    ),
  alpha: z
    .number()
    .positive()
    .lt(1)
    .default(0.025)
    .describe("Family-wise type I error (default 0.025, one-sided)."),
  sided: z.union([z.literal(1), z.literal(2)]).default(1).describe("Sidedness."),
  power: z
    .number()
    .gt(0)
    .lt(1)
    .default(0.8)
    .describe("Per-endpoint power (default 0.80)."),
  allocation_ratio: z
    .number()
    .positive()
    .default(1)
    .describe("Treatment-to-control allocation ratio, shared across endpoints."),
  alpha_weights: z
    .record(z.string().min(1), z.number().nonnegative())
    .optional()
    .describe(
      "For strategy='alpha-split' only. Named numeric vector summing to 1. " +
        "Default (when omitted with alpha-split): equal weights 1/k."
    ),
  ordering: z
    .array(z.string().min(1))
    .optional()
    .describe(
      "For strategy='fixed-sequence' only. Endpoint names in test order. " +
        "Default: order in which `endpoints` was supplied."
    ),
};

export const description =
  "Multi-endpoint co-primary trial design with multiplicity control. Use " +
  "when a confirmatory trial requires positive results on two or more " +
  "primary endpoints (oncology PFS+OS, CV death+HHF, etc.). Strategies: " +
  "fixed-sequence (hierarchical, full alpha per test, the canonical " +
  "approach for ordered co-primary), alpha-split (partition alpha by " +
  "weights), bonferroni (equal alpha-split). Each endpoint is sized at its " +
  "effective alpha via the matching design_<type> wrapper; total N is the " +
  "max across endpoints. For graphical multiplicity (Maurer-Bretz with " +
  "alpha recycling), use `design_graphical_multiplicity` instead.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  return runR(toolName, args);
};
