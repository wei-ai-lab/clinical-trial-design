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

# v0.0.13: events_calc selector — Schoenfeld vs LachinFoulkes vs Freedman.
# Anchor: M4 issue-27 reproduction (median 11 vs 17, alpha 0.025 1-sided,
# 80% power, 2:1, OBF, k=3 timing 0.5/0.75/1.0). Schoenfeld should produce
# ~190 events (matching arm A's 191); LachinFoulkes (gsSurv default) ~185.
test_that("events_calc='schoenfeld' default reproduces M4 arm-A events count", {
  res <- design_survival(
    model = "ph", design_class = "group-sequential",
    control_median = 11, hazard_ratio = 11/17,
    accrual_rate = 20, accrual_duration = 18, followup_duration = 12,
    dropout_rate = -log(0.85)/12,
    k = 3, timing = c(0.5, 0.75, 1.0), sfu = "LDOF",
    alpha = 0.025, power = 0.80, sided = 1, allocation_ratio = 2
  )
  # Schoenfeld is the default
  expect_match(res$method, "events=schoenfeld")
  # Within ±3 of arm A's 191 events (M4 finding)
  expect_true(res$events_total >= 188 && res$events_total <= 194,
              info = sprintf("events_total = %d", res$events_total))
  # Boundaries should match published expected (2.963, 2.359, 2.014)
  bz <- res$boundaries$upper_z
  expect_equal(bz[1], 2.963, tolerance = 0.01)
  expect_equal(bz[2], 2.359, tolerance = 0.01)
  expect_equal(bz[3], 2.014, tolerance = 0.01)
})

test_that("events_calc='lachin-foulkes' preserves pre-v0.0.13 behavior", {
  res <- design_survival(
    model = "ph", design_class = "group-sequential",
    control_median = 11, hazard_ratio = 11/17,
    accrual_rate = 20, accrual_duration = 18, followup_duration = 12,
    dropout_rate = -log(0.85)/12,
    k = 3, timing = c(0.5, 0.75, 1.0), sfu = "LDOF",
    alpha = 0.025, power = 0.80, sided = 1, allocation_ratio = 2,
    events_calc = "lachin-foulkes"
  )
  expect_match(res$method, "events=lachin-foulkes")
  # LachinFoulkes gives ~185, lower than Schoenfeld
  expect_true(res$events_total >= 182 && res$events_total <= 188,
              info = sprintf("events_total = %d", res$events_total))
})

test_that("events_calc='schoenfeld' silently falls back for non-inferiority", {
  res <- design_survival(
    model = "ph", design_class = "group-sequential",
    control_median = 12, hazard_ratio = 1.0,
    accrual_rate = 50, accrual_duration = 24, followup_duration = 18,
    k = 2, sfu = "LDOF",
    comparison = "non-inferiority", hr_null = 1.3,
    alpha = 0.025, power = 0.80, sided = 1
  )
  # Default is schoenfeld but NI forces lachin-foulkes
  expect_match(res$method, "events=lachin-foulkes")
  expect_equal(res$inputs$events_calc, "lachin-foulkes")
  expect_true(res$events_total > 0)
})

# v0.0.13: control_hazard_rate as alternative to control_median.
# Annualized event rate is the natural CVOT input (e.g., 2.5%/yr).
# Conversion: median_months = 12 * log(2) / hazard_rate_per_year.

test_that("control_hazard_rate produces the same design as the equivalent median", {
  hr_rate <- 0.05    # 5%/yr — matches a contemporary HFrEF outcomes trial
  median_equiv <- 12 * log(2) / hr_rate
  res_a <- design_survival(
    model = "ph", design_class = "fixed",
    control_hazard_rate = hr_rate,
    hazard_ratio = 0.80,
    accrual_duration = 36, followup_duration = 12,
    alpha = 0.025, power = 0.80, sided = 1
  )
  res_b <- design_survival(
    model = "ph", design_class = "fixed",
    control_median = median_equiv,
    hazard_ratio = 0.80,
    accrual_duration = 36, followup_duration = 12,
    alpha = 0.025, power = 0.80, sided = 1
  )
  expect_equal(res_a$events_total, res_b$events_total)
  expect_equal(res_a$sample_size_total, res_b$sample_size_total)
})

test_that("supplying both control_median and control_hazard_rate raises", {
  expect_error(
    design_survival(
      model = "ph", design_class = "fixed",
      control_median = 30, control_hazard_rate = 0.05,
      hazard_ratio = 0.80,
      accrual_duration = 24, followup_duration = 12,
      alpha = 0.025, power = 0.80, sided = 1
    ),
    "designr_input_error: control_hazard_rate"
  )
})

test_that("supplying neither control_median nor control_hazard_rate raises", {
  expect_error(
    design_survival(
      model = "ph", design_class = "fixed",
      hazard_ratio = 0.80,
      accrual_duration = 24, followup_duration = 12,
      alpha = 0.025, power = 0.80, sided = 1
    ),
    "designr_input_error: control_median"
  )
})

test_that("events_calc rejects unknown values", {
  expect_error(
    design_survival(
      model = "ph", design_class = "group-sequential",
      control_median = 11, hazard_ratio = 0.65,
      accrual_rate = 20, accrual_duration = 18, followup_duration = 12,
      k = 2, sfu = "LDOF",
      alpha = 0.025, power = 0.80, sided = 1, allocation_ratio = 1,
      events_calc = "bogus"
    ),
    "designr_input_error: events_calc"
  )
})
