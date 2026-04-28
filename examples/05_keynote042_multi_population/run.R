# KEYNOTE-042 (2019) — pembrolizumab vs chemo in PD-L1+ 1L NSCLC
# Same OS endpoint tested in three nested PD-L1 strata.

library(ClinicalTrialDesign)

res <- design_multi_population(
  endpoint_type = "survival",
  endpoint_args = list(
    model = "ph", design_class = "fixed",
    control_median = 12.2,
    accrual_duration = 25, followup_duration = 12,
    dropout_rate = 0.0042
  ),
  populations = list(
    "TPS_50" = list(prevalence = 0.47, effect = list(hazard_ratio = 0.65)),
    "TPS_20" = list(prevalence = 0.63, effect = list(hazard_ratio = 0.70)),
    "TPS_1"  = list(prevalence = 1.00, effect = list(hazard_ratio = 0.78))
  ),
  relation         = "nested",
  strategy         = "fixed-sequence",
  alpha            = 0.025,
  power            = 0.85,
  allocation_ratio = 1,
  reasoning_chain = list(
    list(decision = "relation", value = "nested",
         justification = "PD-L1 strata are nested: TPS≥50 ⊂ TPS≥20 ⊂ TPS≥1 (ITT). All patients enroll into the broadest population.",
         source_type = "user_supplied"),
    list(decision = "strategy", value = "fixed-sequence",
         justification = "Hierarchical sequential subgroup testing from strongest expected effect (TPS≥50) to broadest (TPS≥1). Preserves family-wise alpha without splitting.",
         source_type = "ich_guidance",
         source_ref  = "EMA reflection paper on subgroup analyses (2014); ICH E9 (1998)"),
    list(decision = "hazard_ratio_TPS_50", value = 0.65,
         justification = "Stronger effect in PD-L1 high subgroup, consistent with checkpoint-inhibitor mechanism",
         source_type = "llm_precedent",
         source_ref  = "KEYNOTE-024 (TPS≥50 only)")
  )
)

cat(sprintf("Total N (driven by broadest stratum): %d\n", res$sample_size_total))
cat(sprintf("Driver: %s\n", res$raw$driver))
for (nm in names(res$raw$populations)) {
  p <- res$raw$populations[[nm]]
  cat(sprintf("  %s: in-pop N = %d, implied enrolled = %d, events = %d\n",
              nm,
              p$N_in_population,
              p$N_implied_enrolled,
              p$events_total %||% NA))
}
