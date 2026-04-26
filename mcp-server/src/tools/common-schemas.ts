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
  })
  .optional()
  .describe(
    "Optional operational kernel inputs. Supply any 0-4 of " +
      "{accrual_rate, accrual_duration, follow_up_duration, total_trial_duration}; " +
      "the solver fills in the missing values from rate*duration = N and " +
      "A + F = T (plus target_events for survival). Result is attached as " +
      "result.operational with audit fields (given, derived)."
  );
