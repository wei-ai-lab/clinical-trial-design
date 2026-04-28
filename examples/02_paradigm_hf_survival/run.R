# PARADIGM-HF (2014) — sacubitril-valsartan in HFrEF
# Composite primary endpoint: CV death + first HHF.
# 1:1, HR 0.80, 80% power, alpha 0.025 one-sided.

library(ClinicalTrialDesign)

res <- design_survival(
  model       = "ph",
  design_class = "fixed",
  control_median = 30,             # median time to first composite event ~ 2.5 yr
  hazard_ratio   = 0.80,
  accrual_duration  = 36,
  followup_duration = 6,
  dropout_rate      = 0.01,        # ~1%/month
  alpha = 0.025,
  power = 0.80,
  sided = 1,
  reasoning_chain = list(
    list(decision = "hazard_ratio", value = 0.80,
         justification = "Pooled estimate from PEP-CHF + CHARM Alternative + I-PRESERVE precedents",
         source_type = "llm_precedent",
         source_ref  = "PEP-CHF, CHARM, I-PRESERVE"),
    list(decision = "control_median", value = 30,
         justification = "Standard-of-care registry estimate, contemporary HFrEF",
         source_type = "llm_precedent",
         source_ref  = "OPTIMIZE-HF registry"),
    list(decision = "dropout_rate", value = 0.01,
         justification = "Operational: 1%/month based on similar long-duration outcomes trials",
         source_type = "user_supplied")
  )
)

cat(sprintf("Total events (planned): %d  (published planned: ~1,500-2,300)\n",
            res$events_total))
cat(sprintf("Total N (operational defaults): %d\n",
            res$sample_size_total))
