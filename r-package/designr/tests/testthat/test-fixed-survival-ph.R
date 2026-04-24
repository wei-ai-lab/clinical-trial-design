test_that("design_fixed_survival_ph returns sample size + events under PH", {
  res <- design_fixed_survival_ph(
    control_median    = 12,
    hazard_ratio      = 0.7,
    accrual_duration  = 24,
    followup_duration = 12,
    accrual_rate      = 30,
    dropout_rate      = log(2) / 60,
    alpha = 0.025, power = 0.9, sided = 1
  )
  expect_true(res$sample_size_total > 0)
  expect_true(res$events_total > 0)
  expect_true(res$events_total < res$sample_size_total)
  expect_equal(sum(res$sample_size_per_arm), res$sample_size_total)
  expect_match(res$method, "nSurv")
})

test_that("design_fixed_survival_ph supports non-inferiority via ni_hr", {
  res <- design_fixed_survival_ph(
    control_median    = 24,
    hazard_ratio      = 1,
    accrual_duration  = 18,
    followup_duration = 12,
    accrual_rate      = 40,
    alpha = 0.025, power = 0.9, sided = 1,
    comparison = "non-inferiority", ni_hr = 1.3
  )
  expect_true(res$events_total > 0)
  expect_match(res$method, "non-inferiority")
})

test_that("design_fixed_survival_ph rejects invalid inputs", {
  expect_error(
    design_fixed_survival_ph(control_median = -1, hazard_ratio = 0.7,
                             accrual_duration = 24, followup_duration = 12,
                             accrual_rate = 30),
    "designr_input_error: control_median"
  )
  expect_error(
    design_fixed_survival_ph(control_median = 12, hazard_ratio = 0.7,
                             accrual_duration = 24, followup_duration = 12,
                             accrual_rate = 30, comparison = "equivalence"),
    "designr_input_error: comparison"
  )
  expect_error(
    design_fixed_survival_ph(control_median = 12, hazard_ratio = 1,
                             accrual_duration = 24, followup_duration = 12,
                             accrual_rate = 30, comparison = "non-inferiority"),
    "designr_input_error: ni_hr"
  )
})
