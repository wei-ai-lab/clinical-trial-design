test_that("design_multi_population validates required inputs", {
  expect_error(
    design_multi_population(endpoint_type = "unknown",
                            endpoint_args = list(),
                            populations = list(A = list(effect = list(p_treatment = 0.1)),
                                               B = list(effect = list(p_treatment = 0.2)))),
    "designr_input_error: endpoint_type"
  )
  expect_error(
    design_multi_population(
      endpoint_type = "binary",
      endpoint_args = list(p_control = 0.30),
      populations = list(only_one = list(prevalence = 1, effect = list(p_treatment = 0.20)))
    ),
    "designr_input_error: populations"
  )
  expect_error(
    design_multi_population(
      endpoint_type = "binary",
      endpoint_args = list(p_control = 0.30),
      populations = list(
        A = list(effect = list(p_treatment = 0.20)),  # missing prevalence in nested mode
        B = list(prevalence = 0.5, effect = list(p_treatment = 0.20))
      ),
      relation = "nested"
    ),
    "designr_input_error: populations.*prevalence"
  )
})

test_that("nested + fixed-sequence: each population tested at full alpha", {
  res <- design_multi_population(
    endpoint_type = "survival",
    endpoint_args = list(model = "ph", design_class = "fixed",
                         control_median = 12.2,
                         accrual_duration = 25, followup_duration = 12,
                         dropout_rate = 0.0042),
    populations = list(
      "TPS_50" = list(prevalence = 0.47, effect = list(hazard_ratio = 0.65)),
      "TPS_20" = list(prevalence = 0.63, effect = list(hazard_ratio = 0.70)),
      "TPS_1"  = list(prevalence = 1.00, effect = list(hazard_ratio = 0.78))
    ),
    relation = "nested",
    strategy = "fixed-sequence",
    alpha = 0.025, power = 0.85, allocation_ratio = 1
  )

  # Full alpha per population in fixed-sequence
  expect_equal(res$raw$multiplicity$per_population_alpha$TPS_50, 0.025)
  expect_equal(res$raw$multiplicity$per_population_alpha$TPS_1,  0.025)

  # Driver should be the broadest stratum (TPS_1) because the smallest HR
  # to detect (0.78) requires the most events, and prevalence=1 means
  # no inflation of enrolled-N from prevalence.
  expect_equal(res$raw$driver, "TPS_1")

  # Total N is the implied-enrolled-N of the driver, not summed
  expect_equal(res$sample_size_total,
               res$raw$populations$TPS_1$N_implied_enrolled)

  # Each population reports both its in-population N and implied-enrolled N
  for (nm in c("TPS_50", "TPS_20", "TPS_1")) {
    expect_true(res$raw$populations[[nm]]$N_in_population > 0)
    expect_true(res$raw$populations[[nm]]$N_implied_enrolled >=
                res$raw$populations[[nm]]$N_in_population)
  }

  # For TPS_50 with prevalence 0.47, implied = ceiling(in_pop / 0.47)
  expect_equal(
    res$raw$populations$TPS_50$N_implied_enrolled,
    as.integer(ceiling(res$raw$populations$TPS_50$N_in_population / 0.47))
  )
})

test_that("disjoint relation sums per-population N", {
  res <- design_multi_population(
    endpoint_type = "binary",
    endpoint_args = list(p_control = 0.30),
    populations = list(
      A = list(prevalence = 0.5, effect = list(p_treatment = 0.20)),
      B = list(prevalence = 0.5, effect = list(p_treatment = 0.22))
    ),
    relation = "disjoint",
    strategy = "fixed-sequence",
    alpha = 0.025, power = 0.80
  )
  expect_equal(res$raw$relation, "disjoint")
  ns <- vapply(res$raw$populations, `[[`, numeric(1), "N_implied_enrolled")
  expect_equal(res$sample_size_total, sum(ns))
})

test_that("alpha-split applies weights across populations", {
  res <- design_multi_population(
    endpoint_type = "binary",
    endpoint_args = list(p_control = 0.30),
    populations = list(
      A = list(prevalence = 0.5, effect = list(p_treatment = 0.20)),
      B = list(prevalence = 0.5, effect = list(p_treatment = 0.22))
    ),
    relation = "nested",
    strategy = "alpha-split",
    alpha_weights = c(A = 0.6, B = 0.4),
    alpha = 0.025
  )
  expect_equal(res$raw$multiplicity$per_population_alpha$A, 0.025 * 0.6,
               tolerance = 1e-9)
  expect_equal(res$raw$multiplicity$per_population_alpha$B, 0.025 * 0.4,
               tolerance = 1e-9)
})
