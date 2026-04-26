test_that("design_survival PH fixed returns sample size + events under PH", {
  res <- design_survival(
    model             = "ph",
    design_class      = "fixed",
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

test_that("design_survival PH fixed supports non-inferiority via ni_hr", {
  res <- design_survival(
    model             = "ph",
    design_class      = "fixed",
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

test_that("design_survival PH fixed rejects invalid inputs", {
  expect_error(
    design_survival(model = "ph", design_class = "fixed",
                    control_median = -1, hazard_ratio = 0.7,
                    accrual_duration = 24, followup_duration = 12,
                    accrual_rate = 30),
    "designr_input_error: control_median"
  )
  expect_error(
    design_survival(model = "ph", design_class = "fixed",
                    control_median = 12, hazard_ratio = 0.7,
                    accrual_duration = 24, followup_duration = 12,
                    accrual_rate = 30, comparison = "equivalence"),
    "designr_input_error: comparison"
  )
  expect_error(
    design_survival(model = "ph", design_class = "fixed",
                    control_median = 12, hazard_ratio = 1,
                    accrual_duration = 24, followup_duration = 12,
                    accrual_rate = 30, comparison = "non-inferiority"),
    "designr_input_error: ni_hr"
  )
})

test_that("design_survival maxcombo fixed runs with delayed-effect schedule", {
  res <- design_survival(
    model             = "maxcombo",
    design_class      = "fixed",
    control_median    = 15,
    delay_months      = 4,
    post_delay_hr     = 0.65,
    accrual_rate      = 30,
    accrual_duration  = 12,
    followup_duration = 24,
    alpha = 0.025, power = 0.9
  )
  expect_true(res$sample_size_total > 0)
  expect_true(res$events_total > 0)
  expect_match(res$method, "maxcombo")
  expect_gte(res$sample_size_total, 400)
})

test_that("design_survival rmst fixed runs at the supplied tau", {
  res <- design_survival(
    model             = "rmst",
    design_class      = "fixed",
    control_median    = 15,
    delay_months      = 4,
    post_delay_hr     = 0.65,
    accrual_rate      = 30,
    accrual_duration  = 12,
    followup_duration = 24,
    tau               = 30,
    alpha = 0.025, power = 0.9
  )
  expect_true(res$sample_size_total > 0)
  expect_true(res$events_total > 0)
  expect_match(res$method, "rmst")
})

test_that("design_survival milestone fixed runs at tau", {
  res <- design_survival(
    model             = "milestone",
    design_class      = "fixed",
    control_median    = 15,
    delay_months      = 4,
    post_delay_hr     = 0.65,
    accrual_rate      = 30,
    accrual_duration  = 12,
    followup_duration = 24,
    tau               = 30,
    alpha = 0.025, power = 0.9
  )
  expect_true(res$sample_size_total > 0)
  expect_true(res$events_total > 0)
  expect_match(res$method, "milestone")
})

test_that("design_survival NPH fixed wrappers reject invalid inputs", {
  expect_error(
    design_survival(model = "maxcombo", design_class = "fixed",
                    control_median = 15, delay_months = 4, post_delay_hr = 0.65,
                    accrual_rate = 30, accrual_duration = 12,
                    followup_duration = 24, sided = 2),
    "designr_input_error: sided"
  )
})

test_that("design_survival PH GS: HR=0.7, OBF, 2 analyses", {
  res <- design_survival(
    model             = "ph",
    design_class      = "group-sequential",
    control_median    = 12,
    hazard_ratio      = 0.7,
    accrual_rate      = 30,
    accrual_duration  = 12,
    followup_duration = 18,
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

test_that("design_survival PH GS: non-inferiority with hr_null = 1.3", {
  res <- design_survival(
    model             = "ph",
    design_class      = "group-sequential",
    control_median    = 12,
    hazard_ratio      = 1.0,
    accrual_rate      = 50,
    accrual_duration  = 24,
    followup_duration = 18,
    k = 2, sfu = "LDOF", comparison = "non-inferiority", hr_null = 1.3,
    alpha = 0.025, power = 0.80, sided = 1
  )
  expect_true(res$events_total > 0)
  expect_equal(res$inputs$hr_null, 1.3)
})

test_that("design_survival PH GS: input validation", {
  expect_error(
    design_survival(model = "ph", design_class = "group-sequential",
                    control_median = 12, hazard_ratio = 1.0,
                    accrual_rate = 30, accrual_duration = 12,
                    followup_duration = 18, k = 2),
    "designr_input_error"
  )
  expect_error(
    design_survival(model = "ph", design_class = "group-sequential",
                    control_median = 12, hazard_ratio = 1.0,
                    accrual_rate = 30, accrual_duration = 12,
                    followup_duration = 18, k = 2,
                    comparison = "non-inferiority"),
    "designr_input_error"
  )
  expect_error(
    design_survival(model = "ph", design_class = "group-sequential",
                    control_median = 12, hazard_ratio = 0.7,
                    accrual_rate = 30, accrual_duration = 12,
                    followup_duration = 18, k = 2,
                    comparison = "equivalence"),
    "designr_input_error"
  )
})

test_that("design_survival maxcombo GS: delayed effect, 2 analyses", {
  res <- design_survival(
    model             = "maxcombo",
    design_class      = "group-sequential",
    control_median    = 12,
    delay_months      = 6,
    post_delay_hr     = 0.6,
    accrual_rate      = 30,
    accrual_duration  = 12,
    analysis_times    = c(18, 30),
    rho = c(0, 0, 1), gamma = c(0, 1, 0), tau_fh = rep(-1, 3),
    alpha = 0.025, power = 0.90, sided = 1
  )
  expect_true(res$events_total > 0)
  expect_true(res$sample_size_total > 0)
  expect_length(res$boundaries$upper_z, 2)
  expect_length(res$timing$events_per_analysis, 2)
})

test_that("design_survival ahr GS: delayed effect, 2 analyses", {
  res <- design_survival(
    model             = "ahr",
    design_class      = "group-sequential",
    control_median    = 12,
    delay_months      = 4,
    post_delay_hr     = 0.65,
    accrual_rate      = 40,
    accrual_duration  = 12,
    analysis_times    = c(20, 30),
    alpha = 0.025, power = 0.90, sided = 1
  )
  expect_true(res$events_total > 0)
  expect_length(res$boundaries$upper_z, 2)
})

test_that("design_survival NPH GS: input validation", {
  expect_error(
    design_survival(model = "maxcombo", design_class = "group-sequential",
                    control_median = 12, delay_months = 6, post_delay_hr = 0.6,
                    accrual_rate = 30, accrual_duration = 12,
                    analysis_times = c(30)),
    "designr_input_error"
  )
  expect_error(
    design_survival(model = "maxcombo", design_class = "group-sequential",
                    control_median = 12, delay_months = 6, post_delay_hr = 0.6,
                    accrual_rate = 30, accrual_duration = 12,
                    analysis_times = c(30, 20)),
    "designr_input_error"
  )
  expect_error(
    design_survival(model = "maxcombo", design_class = "group-sequential",
                    control_median = 12, delay_months = 6, post_delay_hr = 0.6,
                    accrual_rate = 30, accrual_duration = 12,
                    analysis_times = c(18, 30), sided = 2),
    "designr_input_error"
  )
})

test_that("design_survival rejects unsupported (model, design_class) combos", {
  expect_error(
    design_survival(model = "rmst", design_class = "group-sequential",
                    control_median = 12, delay_months = 4, post_delay_hr = 0.65,
                    accrual_rate = 30, accrual_duration = 12,
                    analysis_times = c(18, 30)),
    "designr_input_error: model"
  )
  expect_error(
    design_survival(model = "wlr", design_class = "fixed",
                    control_median = 12, delay_months = 4, post_delay_hr = 0.65,
                    accrual_rate = 30, accrual_duration = 12,
                    followup_duration = 18),
    "designr_input_error: model"
  )
})
