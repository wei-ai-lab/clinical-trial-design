## ----------------------------------------------------------------------
## solve_operational — direct unit tests on the kernel.
## Uses the internal entry to keep the test surface small and explicit.
## ----------------------------------------------------------------------

test_that("operational: derive accrual_duration from rate (binary)", {
  out <- ClinicalTrialDesign:::solve_operational(
    target_n = 200, endpoint_type = "binary",
    accrual_rate = 20, follow_up_duration = 6
  )
  expect_equal(out$accrual_rate, 20)
  expect_equal(out$accrual_duration, 10)
  expect_equal(out$follow_up_duration, 6)
  expect_equal(out$total_trial_duration, 16)
  expect_setequal(out$given, c("accrual_rate", "follow_up_duration"))
  expect_setequal(out$derived, c("accrual_duration", "total_trial_duration"))
})

test_that("operational: derive accrual_rate from accrual_duration (continuous)", {
  out <- ClinicalTrialDesign:::solve_operational(
    target_n = 240, endpoint_type = "continuous",
    accrual_duration = 12, follow_up_duration = 3
  )
  expect_equal(out$accrual_rate, 20)
  expect_equal(out$total_trial_duration, 15)
  expect_setequal(out$given, c("accrual_duration", "follow_up_duration"))
})

test_that("operational: derive follow_up_duration from total + accrual", {
  out <- ClinicalTrialDesign:::solve_operational(
    target_n = 100, endpoint_type = "binary",
    accrual_rate = 10, total_trial_duration = 18
  )
  expect_equal(out$accrual_duration, 10)
  expect_equal(out$follow_up_duration, 8)
  expect_equal(out$total_trial_duration, 18)
  expect_setequal(out$derived, c("accrual_duration", "follow_up_duration"))
})

test_that("operational: derive accrual_duration from total - follow_up", {
  out <- ClinicalTrialDesign:::solve_operational(
    target_n = 150, endpoint_type = "continuous",
    follow_up_duration = 6, total_trial_duration = 21
  )
  expect_equal(out$accrual_duration, 15)
  expect_equal(out$accrual_rate, 10)
  expect_equal(out$total_trial_duration, 21)
})

test_that("operational: 2-free survival case solves via uniroot", {
  out <- ClinicalTrialDesign:::solve_operational(
    target_n = 400, target_events = 200,
    endpoint_type = "survival",
    accrual_rate = 20,
    control_median = 12, hazard_ratio = 0.7,
    allocation_ratio = 1
  )
  expect_equal(out$accrual_duration, 20)
  expect_true(out$follow_up_duration > 0)
  expect_equal(out$total_trial_duration,
               out$accrual_duration + out$follow_up_duration)
  expect_true(!is.null(out$cumulative_event_rate))
  expect_equal(out$cumulative_event_rate * 400, 200, tolerance = 1)
})

test_that("operational: survival with all 4 ops + target_events validates", {
  # A=20, F=6, T=26 with control_median=12, HR=0.7, dropout=0 gives ~208 events
  # at target_n=400; target_events=208 is within the 10% tolerance.
  out <- ClinicalTrialDesign:::solve_operational(
    target_n = 400, target_events = 208,
    endpoint_type = "survival",
    accrual_rate = 20, accrual_duration = 20,
    follow_up_duration = 6, total_trial_duration = 26,
    control_median = 12, hazard_ratio = 0.7
  )
  expect_setequal(out$given, c("accrual_rate", "accrual_duration",
                               "follow_up_duration", "total_trial_duration"))
  expect_equal(length(out$derived), 0)
  expect_true(!is.null(out$cumulative_event_rate))
})

test_that("operational: rate × duration mismatch raises input error", {
  expect_error(
    ClinicalTrialDesign:::solve_operational(
      target_n = 200, endpoint_type = "binary",
      accrual_rate = 5, accrual_duration = 10,
      follow_up_duration = 6
    ),
    "designr_input_error: operational: inconsistent"
  )
})

test_that("operational: total < accrual raises input error", {
  expect_error(
    ClinicalTrialDesign:::solve_operational(
      target_n = 100, endpoint_type = "binary",
      accrual_rate = 10, accrual_duration = 10,
      total_trial_duration = 8
    ),
    "designr_input_error: operational: inconsistent"
  )
})

test_that("operational: only one supplied raises error", {
  expect_error(
    ClinicalTrialDesign:::solve_operational(
      target_n = 100, endpoint_type = "binary",
      accrual_rate = 10
    ),
    "designr_input_error: operational: must supply at least 2"
  )
})

test_that("operational: zero supplied raises error", {
  expect_error(
    ClinicalTrialDesign:::solve_operational(
      target_n = 100, endpoint_type = "binary"
    ),
    "designr_input_error: operational: must supply at least 2"
  )
})

test_that("operational: total + follow_up alone solves accrual via duration triangle", {
  out <- ClinicalTrialDesign:::solve_operational(
    target_n = 200, endpoint_type = "binary",
    follow_up_duration = 6, total_trial_duration = 20
  )
  expect_equal(out$accrual_duration, 14)
  expect_equal(out$accrual_rate, 200 / 14)
})

test_that("operational: implied events vs target_events inconsistency errors", {
  expect_error(
    ClinicalTrialDesign:::solve_operational(
      target_n = 400, target_events = 50,
      endpoint_type = "survival",
      accrual_rate = 20, accrual_duration = 20,
      follow_up_duration = 24,
      control_median = 12, hazard_ratio = 0.7
    ),
    "designr_input_error: operational: inconsistent"
  )
})

test_that("design_binary threads operational into result", {
  res <- design_binary(
    p_control = 0.15, p_treatment = 0.09,
    design_class = "fixed",
    alpha = 0.05, sided = 2, power = 0.80,
    operational = list(accrual_rate = 80, follow_up_duration = 3)
  )
  expect_true(!is.null(res$operational))
  expect_equal(res$operational$accrual_rate, 80)
  expect_equal(res$operational$follow_up_duration, 3)
  expect_equal(res$operational$accrual_duration,
               res$sample_size_total / 80)
})

test_that("design_continuous threads operational into result", {
  res <- design_continuous(
    mean_diff = 0.5, sd = 1,
    design_class = "fixed",
    alpha = 0.05, sided = 2, power = 0.80,
    operational = list(accrual_duration = 12, follow_up_duration = 3)
  )
  expect_true(!is.null(res$operational))
  expect_equal(res$operational$accrual_duration, 12)
  expect_equal(res$operational$accrual_rate,
               res$sample_size_total / 12)
})

test_that("design_survival threads operational into result with cumulative event rate", {
  # Solver receives target_n from the design and infers accrual_duration from
  # accrual_rate; consistency check is automatically satisfied.
  res <- design_survival(
    control_median = 12, hazard_ratio = 0.7,
    accrual_duration = 20, followup_duration = 12,
    accrual_rate = 20, dropout_rate = 0,
    design_class = "fixed", model = "ph",
    alpha = 0.025, sided = 1, power = 0.90,
    operational = list(accrual_rate = 20, follow_up_duration = 12)
  )
  expect_true(!is.null(res$operational))
  expect_true(!is.null(res$operational$cumulative_event_rate))
  expect_equal(res$operational$accrual_rate, 20)
  expect_equal(res$operational$follow_up_duration, 12)
  expect_equal(res$operational$accrual_duration,
               res$sample_size_total / 20)
})

# v0.0.13: feasibility_warnings — silent caps from M3 issue-21 finding.

test_that("feasibility_warnings: max_n exceeded surfaces a warning", {
  res <- design_binary(
    p_control = 0.15, p_treatment = 0.09,
    design_class = "fixed", alpha = 0.025, power = 0.80, sided = 1,
    operational = list(accrual_rate = 80, follow_up_duration = 3,
                       max_n = 500)
  )
  expect_true(!is.null(res$operational$feasibility_warnings))
  warns <- res$operational$feasibility_warnings
  expect_equal(length(warns), 1L)
  expect_equal(warns[[1]]$field, "sample_size_total")
  expect_true(warns[[1]]$value > warns[[1]]$limit)
  expect_match(warns[[1]]$message, "max_n cap is 500")
})

test_that("feasibility_warnings: max_duration exceeded surfaces a warning", {
  res <- design_survival(
    model = "ph", design_class = "fixed",
    control_median = 30, hazard_ratio = 0.80,
    accrual_duration = 36, followup_duration = 6,
    alpha = 0.025, power = 0.80, sided = 1,
    operational = list(accrual_rate = 50, follow_up_duration = 6,
                       max_duration = 24)
  )
  expect_true(!is.null(res$operational$feasibility_warnings))
  warns <- res$operational$feasibility_warnings
  expect_true(any(vapply(warns, function(w) w$field == "total_trial_duration",
                         logical(1))))
})

test_that("feasibility_warnings: no warnings when caps not violated", {
  res <- design_binary(
    p_control = 0.15, p_treatment = 0.09,
    design_class = "fixed", alpha = 0.025, power = 0.80, sided = 1,
    operational = list(accrual_rate = 80, follow_up_duration = 3,
                       max_n = 5000)
  )
  expect_null(res$operational$feasibility_warnings)
})

test_that("feasibility_warnings: both caps violated produces two warnings", {
  res <- design_survival(
    model = "ph", design_class = "fixed",
    control_median = 30, hazard_ratio = 0.80,
    accrual_duration = 36, followup_duration = 6,
    alpha = 0.025, power = 0.80, sided = 1,
    operational = list(accrual_rate = 50, follow_up_duration = 6,
                       max_n = 100, max_duration = 12)
  )
  warns <- res$operational$feasibility_warnings
  expect_equal(length(warns), 2L)
  fields <- vapply(warns, `[[`, character(1), "field")
  expect_setequal(fields, c("sample_size_total", "total_trial_duration"))
})
