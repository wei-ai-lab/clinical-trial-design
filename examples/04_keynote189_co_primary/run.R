# KEYNOTE-189 (2018) — pembro + chemo vs placebo + chemo in 1L NSCLC
# Co-primary PFS + OS, hierarchical (PFS first, then OS at full alpha).

library(ClinicalTrialDesign)

res <- design_co_primary(
  endpoints = list(
    PFS = list(type = "survival", model = "ph", design_class = "fixed",
               control_median = 4.7, hazard_ratio = 0.50,
               accrual_duration = 20, followup_duration = 12,
               dropout_rate = 0.0042),
    OS  = list(type = "survival", model = "ph", design_class = "fixed",
               control_median = 17.0, hazard_ratio = 0.70,
               accrual_duration = 20, followup_duration = 24,
               dropout_rate = 0.0042)
  ),
  strategy         = "fixed-sequence",
  alpha            = 0.025,
  power            = 0.80,
  allocation_ratio = 2,
  reasoning_chain = list(
    list(decision = "strategy", value = "fixed-sequence",
         justification = "Co-primary PFS+OS with hierarchical testing — PFS first, OS conditional on PFS rejection. Preserves family-wise alpha by closed testing without per-test discount",
         source_type = "ich_guidance",
         source_ref  = "ICH E9 (1998); CHMP Multiple Endpoints guideline 2017"),
    list(decision = "hazard_ratio_pfs", value = 0.50,
         justification = "Pooled estimate from PD-1 + chemotherapy combination trials",
         source_type = "llm_precedent",
         source_ref  = "KEYNOTE-021 cohort G + IMpower-150 PFS"),
    list(decision = "hazard_ratio_os", value = 0.70,
         justification = "Conservative for OS given the PFS effect; reflects regulatory-typical attenuation factor",
         source_type = "llm_precedent",
         source_ref  = "Pooled checkpoint inhibitor PFS-to-OS HR ratio")
  )
)

cat(sprintf("Total N (max of per-endpoint): %d\n", res$sample_size_total))
cat(sprintf("Driver: %s\n", res$raw$driver))
cat(sprintf("PFS events: %d, OS events: %d\n",
            res$raw$endpoints$PFS$events_total,
            res$raw$endpoints$OS$events_total))
cat(sprintf("Per-endpoint alpha: PFS=%.4f, OS=%.4f (both at full alpha — fixed-sequence)\n",
            res$raw$multiplicity$per_endpoint_alpha$PFS,
            res$raw$multiplicity$per_endpoint_alpha$OS))
