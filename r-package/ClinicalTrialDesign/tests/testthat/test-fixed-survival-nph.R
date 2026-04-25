test_that("design_fixed_survival_maxcombo runs with a delayed-effect schedule", {
  res <- design_fixed_survival_maxcombo(
    control_median   = 15,
    delay_months     = 4,
    post_delay_hr    = 0.65,
    accrual_rate     = 30,
    accrual_duration = 12,
    study_duration   = 36,
    alpha = 0.025, power = 0.9
  )
  expect_true(res$sample_size_total > 0)
  expect_true(res$events_total > 0)
  expect_match(res$method, "maxcombo")
  # Sanity: MaxCombo under delayed effect should need > log-rank sample size
  expect_gte(res$sample_size_total, 400)
})

test_that("design_fixed_survival_rmst runs at the default tau", {
  res <- design_fixed_survival_rmst(
    control_median   = 15,
    delay_months     = 4,
    post_delay_hr    = 0.65,
    accrual_rate     = 30,
    accrual_duration = 12,
    study_duration   = 36,
    tau = 30,
    alpha = 0.025, power = 0.9
  )
  expect_true(res$sample_size_total > 0)
  expect_true(res$events_total > 0)
  expect_match(res$method, "rmst")
})

test_that("design_fixed_survival_milestone runs at tau", {
  res <- design_fixed_survival_milestone(
    control_median   = 15,
    delay_months     = 4,
    post_delay_hr    = 0.65,
    accrual_rate     = 30,
    accrual_duration = 12,
    study_duration   = 36,
    tau = 30,
    alpha = 0.025, power = 0.9
  )
  expect_true(res$sample_size_total > 0)
  expect_true(res$events_total > 0)
  expect_match(res$method, "milestone")
})

test_that("NPH fixed-design wrappers reject invalid inputs", {
  expect_error(
    design_fixed_survival_maxcombo(
      control_median = 15, delay_months = 4, post_delay_hr = 0.65,
      accrual_rate = 30, accrual_duration = 24, study_duration = 12
    ),
    "designr_input_error: study_duration"
  )
  expect_error(
    design_fixed_survival_rmst(
      control_median = 15, delay_months = 4, post_delay_hr = 0.65,
      accrual_rate = 30, accrual_duration = 12, study_duration = 36, sided = 2
    ),
    "designr_input_error: sided"
  )
})
