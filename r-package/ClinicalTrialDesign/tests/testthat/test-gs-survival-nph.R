test_that("GS NPH MaxCombo: delayed effect, 2 analyses", {
  res <- design_gs_survival_nph_combo(
    control_median   = 12, delay_months = 6, post_delay_hr = 0.6,
    accrual_rate     = 30, accrual_duration = 12,
    analysis_times   = c(18, 30),
    test             = "maxcombo",
    rho = c(0, 0, 1), gamma = c(0, 1, 0), tau = rep(-1, 3),
    alpha = 0.025, power = 0.90, sided = 1
  )
  expect_true(res$events_total > 0)
  expect_true(res$sample_size_total > 0)
  expect_length(res$boundaries$upper_z, 2)
  expect_length(res$timing$events_per_analysis, 2)
})

test_that("GS NPH AHR: delayed effect, 2 analyses", {
  res <- design_gs_survival_nph_combo(
    control_median   = 12, delay_months = 4, post_delay_hr = 0.65,
    accrual_rate     = 40, accrual_duration = 12,
    analysis_times   = c(20, 30),
    test             = "ahr",
    alpha = 0.025, power = 0.90, sided = 1
  )
  expect_true(res$events_total > 0)
  expect_length(res$boundaries$upper_z, 2)
})

test_that("GS NPH combo: input validation", {
  expect_error(
    design_gs_survival_nph_combo(
      control_median = 12, delay_months = 6, post_delay_hr = 0.6,
      accrual_rate = 30, accrual_duration = 12,
      analysis_times = c(30)
    ),
    "designr_input_error"
  )
  expect_error(
    design_gs_survival_nph_combo(
      control_median = 12, delay_months = 6, post_delay_hr = 0.6,
      accrual_rate = 30, accrual_duration = 12,
      analysis_times = c(30, 20)
    ),
    "designr_input_error"
  )
  expect_error(
    design_gs_survival_nph_combo(
      control_median = 12, delay_months = 6, post_delay_hr = 0.6,
      accrual_rate = 30, accrual_duration = 12,
      analysis_times = c(18, 30), sided = 2
    ),
    "designr_input_error"
  )
})
