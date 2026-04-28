test_that("design_co_primary validates required inputs", {
  expect_error(
    design_co_primary(endpoints = list(only_one = list(type = "binary"))),
    "designr_input_error: endpoints"
  )
  expect_error(
    design_co_primary(endpoints = list(
      A = list(type = "binary",     p_control = 0.20, p_treatment = 0.10),
      B = list(type = "unsupported", foo = 1)
    )),
    "designr_input_error: endpoints.*unsupported"
  )
  expect_error(
    design_co_primary(
      endpoints = list(
        A = list(type = "binary", p_control = 0.20, p_treatment = 0.10),
        B = list(type = "binary", p_control = 0.20, p_treatment = 0.10)
      ),
      strategy = "graphical"
    ),
    "designr_input_error: strategy"
  )
  expect_error(
    design_co_primary(
      endpoints = list(
        A = list(type = "binary", p_control = 0.20, p_treatment = 0.10),
        B = list(type = "binary", p_control = 0.20, p_treatment = 0.10)
      ),
      strategy = "alpha-split",
      alpha_weights = c(A = 0.6, B = 0.6)
    ),
    "designr_input_error: alpha_weights"
  )
})

test_that("fixed-sequence preserves full alpha per endpoint", {
  res <- design_co_primary(
    endpoints = list(
      PFS = list(type = "survival", model = "ph", design_class = "fixed",
                 control_median = 4.7, hazard_ratio = 0.50,
                 accrual_duration = 20, followup_duration = 12,
                 dropout_rate = 0.0042),
      OS  = list(type = "survival", model = "ph", design_class = "fixed",
                 control_median = 17.0, hazard_ratio = 0.70,
                 accrual_duration = 20, followup_duration = 24,
                 dropout_rate = 0.0042)
    ),
    strategy         = "fixed-sequence",
    alpha            = 0.025,
    power            = 0.80,
    allocation_ratio = 2
  )

  # Both endpoints should be tested at the full alpha (0.025), not split
  expect_equal(res$raw$multiplicity$per_endpoint_alpha$PFS, 0.025)
  expect_equal(res$raw$multiplicity$per_endpoint_alpha$OS,  0.025)
  expect_equal(res$raw$multiplicity$strategy, "fixed-sequence")

  # Each endpoint gets its own design result
  expect_named(res$raw$endpoints, c("PFS", "OS"))
  expect_true(res$raw$endpoints$PFS$events_total > 0)
  expect_true(res$raw$endpoints$OS$events_total > 0)

  # Total N is max across endpoints, not sum
  ep_ns <- vapply(res$raw$endpoints, `[[`, numeric(1), "sample_size_total")
  expect_equal(res$sample_size_total, max(ep_ns))
  expect_equal(res$raw$driver, names(ep_ns)[which.max(ep_ns)])
})

test_that("alpha-split partitions alpha by weights", {
  res <- design_co_primary(
    endpoints = list(
      A = list(type = "binary", p_control = 0.20, p_treatment = 0.10),
      B = list(type = "binary", p_control = 0.30, p_treatment = 0.20)
    ),
    strategy      = "alpha-split",
    alpha         = 0.025,
    alpha_weights = c(A = 0.7, B = 0.3),
    power         = 0.80
  )

  expect_equal(res$raw$multiplicity$per_endpoint_alpha$A, 0.025 * 0.7,
               tolerance = 1e-9)
  expect_equal(res$raw$multiplicity$per_endpoint_alpha$B, 0.025 * 0.3,
               tolerance = 1e-9)
  expect_equal(res$raw$multiplicity$strategy, "alpha-split")
})

test_that("bonferroni == equal alpha-split", {
  res_bonf <- design_co_primary(
    endpoints = list(
      A = list(type = "binary", p_control = 0.20, p_treatment = 0.10),
      B = list(type = "binary", p_control = 0.30, p_treatment = 0.20)
    ),
    strategy = "bonferroni",
    alpha    = 0.025,
    power    = 0.80
  )
  expect_equal(res_bonf$raw$multiplicity$per_endpoint_alpha$A, 0.0125)
  expect_equal(res_bonf$raw$multiplicity$per_endpoint_alpha$B, 0.0125)
})

test_that("KEYNOTE-189 anchor: hierarchical PFS+OS yields N within tolerance", {
  res <- design_co_primary(
    endpoints = list(
      PFS = list(type = "survival", model = "ph", design_class = "fixed",
                 control_median = 4.7, hazard_ratio = 0.50,
                 accrual_duration = 20, followup_duration = 12,
                 dropout_rate = 0.0042),
      OS  = list(type = "survival", model = "ph", design_class = "fixed",
                 control_median = 17.0, hazard_ratio = 0.70,
                 accrual_duration = 20, followup_duration = 24,
                 dropout_rate = 0.0042)
    ),
    strategy         = "fixed-sequence",
    alpha            = 0.025,
    power            = 0.80,
    allocation_ratio = 2
  )
  # Published planned N = 600. Tolerance 25% (operational defaults
  # without the published accrual schedule give ~450-650 range; the
  # math driver — events — is what the design_survival anchor tests
  # check tightly).
  expect_true(res$sample_size_total >= 400 &&
              res$sample_size_total <= 800,
              info = sprintf("got N=%d", res$sample_size_total))
  # OS is the driver (largest events requirement at HR=0.7, median 17)
  expect_equal(res$raw$driver, "OS")
})
