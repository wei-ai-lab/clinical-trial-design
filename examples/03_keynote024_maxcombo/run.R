# KEYNOTE-024 (2016) — pembrolizumab vs chemo in 1L PD-L1+ NSCLC
# Real-world delayed-effect non-proportional hazards pattern.
# Reproducing the design via a MaxCombo test with FH(0,1) weights.

library(ClinicalTrialDesign)

res <- design_survival(
  model       = "maxcombo",
  design_class = "fixed",
  control_median   = 6,             # median PFS chemo arm ~ 6 mo
  delay_months     = 3,             # initial 3-month period of HR ≈ 1
  post_delay_hr    = 0.55,          # post-delay HR ~ 0.55
  accrual_rate      = 20,           # ~20 patients/month
  accrual_duration  = 18,
  followup_duration = 12,
  alpha = 0.025,
  power = 0.85,
  sided = 1,
  reasoning_chain = list(
    list(decision = "model", value = "maxcombo",
         justification = "Checkpoint-inhibitor PFS curves show characteristic delayed separation; FH(0,1) weights capture late-departure better than naive log-rank",
         source_type = "ich_guidance",
         source_ref  = "FDA Guidance: Adjusting for Covariates in Randomized Clinical Trials (2023); Magirr-Burman MaxCombo paper"),
    list(decision = "delay_months", value = 3,
         justification = "Median time-to-onset of PD-1 separation in published checkpoint trials",
         source_type = "llm_precedent",
         source_ref  = "KEYNOTE-189 / KEYNOTE-407 pooled time-to-separation"),
    list(decision = "post_delay_hr", value = 0.55,
         justification = "Steady-state HR in the active phase of separation",
         source_type = "llm_precedent",
         source_ref  = "KEYNOTE-024 published SAP")
  )
)

cat(sprintf("Total events (planned): %d  (published planned: ~170)\n",
            res$events_total))
cat(sprintf("Total N (operational defaults): %d\n",
            res$sample_size_total))
