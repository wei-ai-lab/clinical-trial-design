test_that("design_fixed_binary (superiority) matches CAPTURE-style vanilla calc", {
  case <- load_case("fixed-superiority", "1997_CAPTURE_abciximab")
  eff  <- case$design$effect
  res <- design_fixed_binary(
    p_control   = eff$control_rate,
    p_treatment = eff$treatment_rate,
    alpha       = case$design$alpha,
    sided       = case$design$sidedness,
    power       = case$design$power
  )
  # Vanilla gsDesign::nBinomial for (0.15, 0.09, α=.05 two-sided, 80% power)
  # gives ~919. The corpus' expected 1,400 reflects trial-planned N with
  # dropout/interim inflation, captured in notes but not in the raw inputs.
  # We assert on the vanilla value; the corpus comparison lives in the
  # validate_against_benchmark tool (M2).
  expect_equal(res$sample_size_total, 919, tolerance = 0.01)
  expect_length(res$sample_size_per_arm, 2)
  expect_equal(sum(res$sample_size_per_arm), res$sample_size_total)
  expect_match(res$method, "nBinomial")
})

test_that("design_fixed_binary non-inferiority with equal rates uses ni_margin", {
  res <- design_fixed_binary(
    p_control   = 0.10, p_treatment = 0.10,
    alpha = 0.025, sided = 1, power = 0.90,
    comparison  = "non-inferiority", ni_margin = 0.05
  )
  expect_true(res$sample_size_total > 0)
  expect_match(res$method, "non-inferiority")
})

test_that("design_fixed_binary equivalence runs under symmetric TOST", {
  res <- design_fixed_binary(
    p_control = 0.10, p_treatment = 0.10,
    alpha = 0.05, sided = 2, power = 0.9,
    comparison = "equivalence", equiv_margin = 0.05
  )
  expect_true(res$sample_size_total > 0)
  expect_match(res$method, "equivalence")
})

test_that("design_fixed_binary rejects out-of-range inputs", {
  expect_error(
    design_fixed_binary(p_control = -0.1, p_treatment = 0.09),
    "designr_input_error: p_control"
  )
  expect_error(
    design_fixed_binary(p_control = 0.1, p_treatment = 0.1),
    "designr_input_error: p_treatment"
  )
  expect_error(
    design_fixed_binary(p_control = 0.15, p_treatment = 0.09, alpha = 0.6),
    "designr_input_error: alpha"
  )
  expect_error(
    design_fixed_binary(p_control = 0.10, p_treatment = 0.10,
                        comparison = "non-inferiority"),
    "designr_input_error: ni_margin"
  )
})
