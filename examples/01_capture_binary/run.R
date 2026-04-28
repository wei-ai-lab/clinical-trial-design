# CAPTURE (1997) — abciximab in refractory unstable angina
# NEJM-equivalent placebo arm 15% 30-day composite event rate;
# active arm assumed 9%. Two-sided alpha = 0.05, 80% power, 1:1.

library(ClinicalTrialDesign)

res <- design_binary(
  p_control   = 0.15,
  p_treatment = 0.09,
  design_class = "fixed",
  comparison   = "superiority",
  alpha        = 0.025,    # one-sided 0.025 = two-sided 0.05
  power        = 0.80,
  sided        = 1,
  reasoning_chain = list(
    list(decision = "alpha", value = 0.025,
         justification = "Two-sided 0.05 standard for confirmatory CV trials",
         source_type = "fda_guidance",
         source_ref  = "FDA Guidance E9 (1998)"),
    list(decision = "p_control", value = 0.15,
         justification = "Pre-trial registry rate for refractory UA progressing to MI",
         source_type = "llm_precedent",
         source_ref  = "EPILOG / EPISTENT predecessors")
  )
)

cat(sprintf("Total N (planned): %d  (published planned: 1,400)\n",
            res$sample_size_total))
cat(sprintf("Per arm: control = %d, treatment = %d\n",
            res$sample_size_per_arm["control"],
            res$sample_size_per_arm["treatment"]))
