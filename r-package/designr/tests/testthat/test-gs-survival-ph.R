test_that("GS survival PH: HR=0.7, OBF, 2 analyses", {
  res <- design_gs_survival_ph(
    control_median = 12, hazard_ratio = 0.7,
    accrual_rate = 30, accrual_duration = 12, followup_duration = 18,
    k = 2, sfu = "LDOF",
    alpha = 0.025, power = 0.90, sided = 1
  )
  expect_true(res$events_total > 300)
  expect_true(res$events_total < 400)
  expect_length(res$boundaries$upper_z, 2)
  expect_length(res$timing$events_per_analysis, 2)
  expect_equal(
    res$timing$events_per_analysis[2], res$events_total,
    tolerance = 2
  )
  expect_true(res$sample_size_total > res$events_total)
})

test_that("GS survival PH: non-inferiority with hr_null = 1.3", {
  res <- design_gs_survival_ph(
    control_median = 12, hazard_ratio = 1.0,
    accrual_rate = 50, accrual_duration = 24, followup_duration = 18,
    k = 2, sfu = "LDOF", comparison = "non-inferiority", hr_null = 1.3,
    alpha = 0.025, power = 0.80, sided = 1
  )
  expect_true(res$events_total > 0)
  expect_equal(res$inputs$hr_null, 1.3)
})

test_that("GS survival PH: input validation", {
  expect_error(
    design_gs_survival_ph(control_median = 12, hazard_ratio = 1.0,
                          accrual_rate = 30, accrual_duration = 12,
                          followup_duration = 18, k = 2),
    "designr_input_error"
  )
  expect_error(
    design_gs_survival_ph(control_median = 12, hazard_ratio = 1.0,
                          accrual_rate = 30, accrual_duration = 12,
                          followup_duration = 18, k = 2,
                          comparison = "non-inferiority"),
    "designr_input_error"
  )
  expect_error(
    design_gs_survival_ph(control_median = 12, hazard_ratio = 0.7,
                          accrual_rate = 30, accrual_duration = 12,
                          followup_duration = 18, k = 2,
                          comparison = "equivalence"),
    "designr_input_error"
  )
})
