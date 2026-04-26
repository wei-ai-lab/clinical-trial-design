test_that("verify_design passes on a canonical fixed binary superiority design", {
  d <- design_binary(
    p_control = 0.15, p_treatment = 0.09,
    design_class = "fixed",
    alpha = 0.05, power = 0.8, sided = 2
  )
  v <- verify_design(d, n_sim = 3000, seed = 1)
  expect_equal(v$family, "fixed_binary")
  expect_equal(v$target_power, 0.8)
  expect_equal(v$target_alpha, 0.05)
  expect_true(abs(v$empirical_power  - 0.8)  * 100 < 3)
  expect_true(abs(v$empirical_type_I - 0.05) * 100 < 1)
  expect_true(v$passes)
})

test_that("verify_design passes on a fixed continuous superiority design", {
  d <- design_continuous(
    mean_diff = 30, sd = 70,
    design_class = "fixed",
    alpha = 0.05, power = 0.8, sided = 2
  )
  v <- verify_design(d, n_sim = 3000, seed = 1)
  expect_equal(v$family, "fixed_continuous")
  expect_true(v$passes)
})

test_that("verify_design errors cleanly on NPH families", {
  d <- design_survival(
    model = "maxcombo", design_class = "fixed",
    control_median = 10, delay_months = 4, post_delay_hr = 0.6,
    accrual_rate = 20, accrual_duration = 18, followup_duration = 12,
    alpha = 0.025, power = 0.9
  )
  expect_error(verify_design(d, n_sim = 200),
               "designr_input_error: result:.*NPH verification")
})

test_that("verify_design errors cleanly on equivalence designs", {
  d <- design_binary(
    p_control = 0.85, p_treatment = 0.85,
    design_class = "fixed",
    alpha = 0.05, power = 0.8, sided = 2,
    comparison = "equivalence", equiv_margin = 0.10
  )
  expect_error(verify_design(d),
               "designr_input_error: result:.*equivalence")
})

test_that("verify_design rejects a malformed result", {
  expect_error(verify_design(list(foo = 1)),
               "designr_input_error: result:")
})

test_that("verify_design passes on a GS PH survival superiority design", {
  skip_on_cran()
  d <- design_survival(
    model = "ph", design_class = "group-sequential",
    control_median = 30, hazard_ratio = 0.75,
    accrual_rate = 100, accrual_duration = 30, followup_duration = 24,
    k = 2, sfu = "LDOF",
    alpha = 0.025, power = 0.9, sided = 1
  )
  v <- verify_design(d, n_sim = 1500, seed = 1)
  expect_equal(v$family, "gs_survival_ph")
  expect_true(abs(v$empirical_power  - 0.9)   < 0.04)
  expect_true(abs(v$empirical_type_I - 0.025) < 0.01)
})

test_that("verify_design passes on a GS binary superiority design", {
  d <- design_binary(
    p_control = 0.10, p_treatment = 0.05,
    design_class = "group-sequential",
    k = 2, sfu = "LDOF", sfl = "LDOF",
    alpha = 0.025, power = 0.8, sided = 1
  )
  v <- verify_design(d, n_sim = 2000, seed = 1)
  expect_equal(v$family, "gs_binary")
  expect_true(v$passes)
})
