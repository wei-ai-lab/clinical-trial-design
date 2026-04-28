import { z } from "zod";
import { runR } from "../r-bridge.js";
import { ReasoningChainSchema } from "./common-schemas.js";

const PopulationSpecSchema = z
  .object({
    prevalence: z
      .number()
      .gt(0)
      .lte(1)
      .optional()
      .describe(
        "Fraction of the broadest population in this stratum (required for relation='nested'; ignored for 'disjoint')."
      ),
    effect: z
      .record(z.string().min(1), z.union([z.number(), z.string(), z.boolean()]))
      .describe(
        "Population-specific effect parameters that override the corresponding " +
          "fields in endpoint_args. Use {hazard_ratio: 0.65} for survival, " +
          "{p_treatment: 0.10} for binary, {delta: 0.4} for continuous."
      ),
  })
  .passthrough();

export const toolName = "design_multi_population";
export const schema = {
  endpoint_type: z
    .enum(["binary", "continuous", "survival"])
    .describe("Endpoint family — selects which design_<type> wrapper handles each population."),
  endpoint_args: z
    .record(z.string().min(1), z.unknown())
    .describe(
      "Shared endpoint design parameters (e.g., for survival: model, " +
        "design_class, control_median, accrual_duration, followup_duration, " +
        "dropout_rate). The effect parameter (hazard_ratio / p_treatment / " +
        "delta) is overridden per population."
    ),
  populations: z
    .record(z.string().min(1), PopulationSpecSchema)
    .describe(
      "Named map of populations. Each entry has `effect` (and `prevalence` " +
        "for nested mode)."
    ),
  relation: z
    .enum(["nested", "disjoint"])
    .default("nested")
    .describe(
      "How populations relate. `nested` (default): subgroups overlap, all " +
        "patients enroll into the broadest, total N = max of " +
        "implied-enrolled-N. `disjoint`: separate strata enrolled, total N = " +
        "sum of per-population N."
    ),
  strategy: z
    .enum(["fixed-sequence", "alpha-split", "bonferroni"])
    .default("fixed-sequence")
    .describe(
      "Multiplicity-control strategy across populations. `fixed-sequence` is " +
        "the canonical biomarker pattern (test strongest-effect subgroup " +
        "first, gate broader strata on rejection)."
    ),
  alpha: z.number().positive().lt(1).default(0.025),
  sided: z.union([z.literal(1), z.literal(2)]).default(1),
  power: z.number().gt(0).lt(1).default(0.8),
  allocation_ratio: z.number().positive().default(1),
  alpha_weights: z
    .record(z.string().min(1), z.number().nonnegative())
    .optional()
    .describe("For strategy='alpha-split' only. Names match `populations`; sum to 1."),
  ordering: z
    .array(z.string().min(1))
    .optional()
    .describe("For strategy='fixed-sequence' only. Population names in test order."),
  reasoning_chain: ReasoningChainSchema,
};

export const description =
  "Multi-population (subgroup) trial design with multiplicity control. Use " +
  "when a confirmatory trial tests the same endpoint in multiple " +
  "populations — biomarker-positive subgroup + ITT, nested PD-L1 strata, " +
  "etc. Pick relation='nested' (the canonical case: TPS≥50 ⊂ TPS≥20 ⊂ ITT, " +
  "all patients enroll into the broadest, total N driven by largest " +
  "implied-enrolled across strata) or 'disjoint' (strata enrolled " +
  "separately, total N = sum). Strategies: fixed-sequence (hierarchical), " +
  "alpha-split, bonferroni. For graphical multiplicity (Maurer-Bretz with " +
  "alpha recycling between populations), use design_graphical_multiplicity.";

export const handler = async (args: z.infer<z.ZodObject<typeof schema>>) => {
  return runR(toolName, args);
};
