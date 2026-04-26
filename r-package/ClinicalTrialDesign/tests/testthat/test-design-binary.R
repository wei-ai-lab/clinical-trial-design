test_that("design_binary fixed superiority matches CAPTURE-style vanilla calc", {
  case <- load_case("fixed-superiority", "1997_CAPTURE_abciximab")
  eff  <- case$design$effect
  res <- design_binary(
    p_control    = eff$control_rate,
    p_treatment  = eff$treatment_rate,
    design_class = "fixed",
    alpha        = case$design$alpha,
    sided        = case$design$sidedness,
    power        = case$design$power
  )
  # Vanilla gsDesign::nBinomial for (0.15, 0.09, alpha=0.05 two-sided, 80%
  # power) gives ~919. Trial-planned 1,400 reflects dropout/interim inflation.
  expect_equal(res$sample_size_total, 919, tolerance = 0.01)
  expect_length(res$sample_size_per_arm, 2)
  expect_equal(sum(res$sample_size_per_arm), res$sample_size_total)
  expect_match(res$method, "nBinomial")
})

test_that("design_binary fixed non-inferiority with equal rates uses ni_margin", {
  res <- design_binary(
    p_control    = 0.10, p_treatment = 0.10,
    design_class = "fixed",
    alpha = 0.025, sided = 1, power = 0.90,
    comparison   = "non-inferiority", ni_margin = 0.05
  )
  expect_true(res$sample_size_total > 0)
  expect_match(res$method, "non-inferiority")
})

test_that("design_binary fixed equivalence runs under symmetric TOST", {
  res <- design_binary(
    p_control = 0.10, p_treatment = 0.10,
    design_class = "fixed",
    alpha = 0.05, sided = 2, power = 0.9,
    comparison = "equivalence", equiv_margin = 0.05
  )
  expect_true(res$sample_size_total > 0)
  expect_match(res$method, "equivalence")
})

test_that("design_binary rejects out-of-range inputs", {
  expect_error(
    design_binary(p_control = -0.1, p_treatment = 0.09),
    "designr_input_error: p_control"
  )
  expect_error(
    design_binary(p_control = 0.1, p_treatment = 0.1),
    "designr_input_error: p_treatment"
  )
  expect_error(
    design_binary(p_control = 0.15, p_treatment = 0.09, alpha = 0.6),
    "designr_input_error: alpha"
  )
  expect_error(
    design_binary(p_control = 0.10, p_treatment = 0.10,
                  comparison = "non-inferiority"),
    "designr_input_error: ni_margin"
  )
  expect_error(
    design_binary(p_control = 0.1, p_treatment = 0.05,
                  design_class = "not-a-class"),
    "designr_input_error: design_class"
  )
})

test_that("design_binary group-sequential: 2 analyses OBF gives reasonable inflation", {
  res <- design_binary(
    p_control = 0.15, p_treatment = 0.09,
    design_class = "group-sequential",
    k = 2, sfu = "LDOF", sfl = "LDOF",
    alpha = 0.025, power = 0.90, sided = 1
  )
  expect_true(res$sample_size_total > 900)
  expect_true(res$sample_size_total < 1400)
  expect_length(res$boundaries$upper_z, 2)
  expect_length(res$timing$information_fraction, 2)
  expect_equal(res$timing$information_fraction[2], 1, tolerance = 1e-8)
  expect_true(res$boundaries$upper_z[1] > res$boundaries$upper_z[2])
})

test_that("design_binary group-sequential: Pocock has flatter boundaries than OBF", {
  obf <- design_binary(p_control = 0.10, p_treatment = 0.05,
                       design_class = "group-sequential",
                       k = 3, sfu = "LDOF",
                       alpha = 0.025, power = 0.80, sided = 1)
  poc <- design_binary(p_control = 0.10, p_treatment = 0.05,
                       design_class = "group-sequential",
                       k = 3, sfu = "LDPocock",
                       alpha = 0.025, power = 0.80, sided = 1)
  expect_true(poc$boundaries$upper_z[1] < obf$boundaries$upper_z[1])
  expect_true(poc$boundaries$upper_z[3] > obf$boundaries$upper_z[3])
})

test_that("design_binary group-sequential: input validation", {
  expect_error(
    design_binary(p_control = 0.1, p_treatment = 0.05,
                  design_class = "group-sequential", k = 1),
    "designr_input_error"
  )
  expect_error(
    design_binary(p_control = 0.1, p_treatment = 0.05,
                  design_class = "group-sequential", k = 2,
                  sfu = "NotASpendingFunction"),
    "designr_input_error"
  )
  expect_error(
    design_binary(p_control = 0.1, p_treatment = 0.05,
                  design_class = "group-sequential", k = 2,
                  timing = c(0.3, 0.5)),
    "designr_input_error"
  )
  expect_error(
    design_binary(p_control = 0.1, p_treatment = 0.05,
                  design_class = "group-sequential",
                  comparison = "equivalence"),
    "designr_input_error: comparison"
  )
})
