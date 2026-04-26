test_that("design_report renders a fixed binary design", {
  d <- design_binary(
    p_control = 0.15, p_treatment = 0.09,
    design_class = "fixed",
    alpha = 0.05, power = 0.8, sided = 2
  )
  md <- design_report(d)
  expect_type(md, "character")
  expect_length(md, 1L)
  expect_true(grepl("# Fixed-sample binary endpoint", md, fixed = TRUE))
  expect_true(grepl("## Design overview", md, fixed = TRUE))
  expect_true(grepl("## Key inputs", md, fixed = TRUE))
  expect_true(grepl("## Headline output", md, fixed = TRUE))
  expect_true(grepl("Total sample size", md, fixed = TRUE))
  expect_true(grepl("## Method & version", md, fixed = TRUE))
  # No GS sections on a fixed-sample design.
  expect_false(grepl("## Analysis plan", md, fixed = TRUE))
})

test_that("design_report renders a fixed continuous design", {
  d <- design_continuous(
    mean_diff = 30, sd = 70,
    design_class = "fixed",
    alpha = 0.05, power = 0.8, sided = 2
  )
  md <- design_report(d)
  expect_true(grepl("# Fixed-sample continuous endpoint", md, fixed = TRUE))
  expect_true(grepl("Mean difference", md, fixed = TRUE))
  expect_true(grepl("Common SD", md, fixed = TRUE))
})

test_that("design_report renders a fixed PH survival design with events", {
  d <- design_survival(
    model = "ph", design_class = "fixed",
    control_median = 30, hazard_ratio = 0.75,
    accrual_rate = 100, accrual_duration = 30, followup_duration = 24,
    alpha = 0.025, power = 0.9, sided = 1
  )
  md <- design_report(d)
  expect_true(grepl("# Fixed-sample time-to-event \\(PH log-rank\\)", md))
  expect_true(grepl("Total events", md, fixed = TRUE))
  expect_true(grepl("Control median", md, fixed = TRUE))
  expect_true(grepl("Hazard ratio", md, fixed = TRUE))
})

test_that("design_report renders a GS PH survival design with boundaries + timing", {
  d <- design_survival(
    model = "ph", design_class = "group-sequential",
    control_median = 30, hazard_ratio = 0.75,
    accrual_rate = 100, accrual_duration = 30, followup_duration = 24,
    k = 2, sfu = "LDOF",
    alpha = 0.025, power = 0.9, sided = 1
  )
  md <- design_report(d)
  expect_true(grepl("# Group-sequential time-to-event", md))
  expect_true(grepl("## Analysis plan", md, fixed = TRUE))
  expect_true(grepl("Upper Z-boundaries", md, fixed = TRUE))
  expect_true(grepl("Information fractions", md, fixed = TRUE))
  expect_true(grepl("Events per analysis", md, fixed = TRUE))
})

test_that("design_report renders a NPH MaxCombo design", {
  d <- design_survival(
    model = "maxcombo", design_class = "fixed",
    control_median = 10, delay_months = 4, post_delay_hr = 0.6,
    accrual_rate = 20, accrual_duration = 18, followup_duration = 12,
    alpha = 0.025, power = 0.9
  )
  md <- design_report(d)
  expect_true(grepl("MaxCombo", md, fixed = TRUE))
  expect_true(grepl("Delay \\(months\\)", md))
  expect_true(grepl("Post-delay HR", md, fixed = TRUE))
})

test_that("design_report rejects malformed input", {
  expect_error(design_report(list(foo = 1)),
               "designr_input_error: result:")
  expect_error(design_report("not a list"),
               "designr_input_error: result:")
})
