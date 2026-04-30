import { z } from "zod";

export const ComparisonEnum = z
  .enum(["superiority", "non-inferiority", "equivalence"])
  .describe(
    "Hypothesis type. 'superiority' (default) tests for a difference; " +
      "'non-inferiority' requires ni_margin; 'equivalence' requires equiv_margin."
  );

export const DesignClassEnum = z
  .enum(["fixed", "group-sequential"])
  .describe(
    "Design class. 'fixed' = single final analysis; 'group-sequential' = " +
      "interim looks with alpha-spending. Group-sequential params (k, timing, " +
      "sfu/sfl, test_type) are ignored when design_class = 'fixed'."
  );

export const SurvivalModelEnum = z
  .enum(["ph", "maxcombo", "rmst", "milestone", "wlr", "ahr"])
  .describe(
    "Survival statistical model. 'ph' = log-rank under proportional hazards " +
      "(gsDesign::nSurv / gsSurv). 'maxcombo' / 'rmst' / 'milestone' are NPH " +
      "fixed-sample (gsDesign2::fixed_design_*). 'wlr' / 'ahr' are NPH " +
      "group-sequential (gsDesign2::gs_design_wlr / gs_design_ahr)."
  );

export const SpendingFnEnum = z
  .enum(["OF", "Pocock", "HSD", "Power", "LDOF", "LDPocock", "none"])
  .describe(
    "Alpha-spending function. OF = O'Brien-Fleming, Pocock = Pocock, " +
      "HSD = Hwang-Shih-DeCani (needs sfupar), Power = power family (needs sfupar), " +
      "LDOF / LDPocock = Lan-DeMets approximations (the standard), 'none' disables."
  );

export const AlphaSchema = z
  .number()
  .positive()
  .max(0.5)
  .default(0.025)
  .describe("Type I error rate. For a standard two-sided 0.05 test use 0.025 with sided = 2.");

export const PowerSchema = z
  .number()
  .positive()
  .max(0.999)
  .default(0.9)
  .describe("1 - beta. Targeted power of the test (default 0.9).");

export const SidedSchema = z.union([z.literal(1), z.literal(2)]).default(1).describe(
  "1 = one-sided test (default), 2 = two-sided. Many modern designs use sided = 1 with alpha = 0.025 to match the two-sided 0.05 convention."
);

export const AllocationRatioSchema = z
  .number()
  .positive()
  .default(1)
  .describe("Treatment / control allocation ratio. 1 = balanced 1:1.");

export const KSchema = z
  .number()
  .int()
  .min(2)
  .max(10)
  .default(2)
  .describe("Number of planned analyses including the final one. Integer in [2, 10].");

export const TimingSchema = z
  .array(z.number().positive().max(1))
  .optional()
  .describe(
    "Information fractions at each analysis, length k, strictly increasing in (0,1], last = 1. " +
      "Defaults to equal spacing 1/k, 2/k, ..., 1."
  );

export const TestTypeSchema = z
  .number()
  .int()
  .min(1)
  .max(6)
  .default(1)
  .describe(
    "gsDesign test.type. 1 = efficacy-only, 2 = symmetric efficacy+futility, " +
      "3 = non-binding futility, 4 = binding futility, 5/6 = same with lower beta-spending."
  );

export const OperationalBlockSchema = z
  .object({
    accrual_rate: z.number().positive().optional(),
    accrual_duration: z.number().positive().optional(),
    follow_up_duration: z.number().nonnegative().optional(),
    total_trial_duration: z.number().positive().optional(),
    max_n: z
      .number()
      .positive()
      .optional()
      .describe(
        "Optional sample-size cap. If the design exceeds it, a structured " +
          "feasibility_warnings entry is attached to result.operational " +
          "explaining the over-by-X% gap. Does NOT change the design — the " +
          "agent uses the warning to suggest tradeoffs (relax effect size, " +
          "raise the cap, accept reduced power)."
      ),
    max_duration: z
      .number()
      .positive()
      .optional()
      .describe(
        "Optional total-trial-duration cap (months). Same warning shape as " +
          "max_n. Useful when the trial has a hard business deadline that " +
          "the design must respect."
      ),
  })
  .optional()
  .describe(
    "Optional operational kernel inputs. Supply any 0-4 of " +
      "{accrual_rate, accrual_duration, follow_up_duration, total_trial_duration}; " +
      "the solver fills in the missing values from rate*duration = N and " +
      "A + F = T (plus target_events for survival). Result is attached as " +
      "result.operational with audit fields (given, derived). Supply max_n " +
      "and/or max_duration to surface feasibility warnings rather than " +
      "silently returning a design that violates user-stated caps."
  );

// Reasoning chain — structured citation trail. The LLM (or user) populates
// each entry with its source. Allowed source_type values:
//   llm_precedent       — public-trial precedent the agent surfaced
//   fda_guidance        — citation to a specific FDA guidance document
//   ich_guidance        — citation to ICH E9 / E9-R1 / etc.
//   user_supplied       — the user told the agent this directly
//   package_default     — fell out of a tool's default value
//   sponsor_confidential — internal data (Phase 2 readout, pipeline)
// The package validates the shape and surfaces sponsor_confidential entries
// in design_report() as a redaction prompt before external sharing.
export const ReasoningSourceTypeEnum = z
  .enum([
    "llm_precedent",
    "fda_guidance",
    "ich_guidance",
    "user_supplied",
    "package_default",
    "sponsor_confidential",
  ])
  .describe(
    "Provenance tag for a reasoning-chain entry. Drives the design_report " +
      "redaction prompt (sponsor_confidential entries flagged before sharing)."
  );

export const ReasoningEntrySchema = z
  .object({
    decision: z
      .string()
      .min(1)
      .describe("Short label for the design choice (e.g., 'alpha', 'hazard_ratio')."),
    value: z
      .union([z.number(), z.string(), z.boolean(), z.null()])
      .describe("The chosen value (numeric, string, or boolean)."),
    justification: z
      .string()
      .describe("One sentence explaining why this value was chosen."),
    source_type: ReasoningSourceTypeEnum,
    source_ref: z
      .string()
      .optional()
      .describe(
        "Free-text reference (citation, NCT id, internal protocol number). Optional but encouraged for non-default entries."
      ),
  })
  .describe(
    "One reasoning-chain entry — a single design decision with its provenance. The LLM and user fill the content; the package validates the shape."
  );

export const ReasoningChainSchema = z
  .array(ReasoningEntrySchema)
  .optional()
  .describe(
    "Optional structured citation trail. Each entry: {decision, value, " +
      "justification, source_type, source_ref?}. design_report() renders " +
      "this inline; sponsor_confidential entries trigger a redaction prompt."
  );
