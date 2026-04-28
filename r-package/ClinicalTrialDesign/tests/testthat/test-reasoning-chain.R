test_that("check_reasoning_chain accepts NULL and empty list", {
  expect_null(check_reasoning_chain(NULL))
  expect_equal(length(check_reasoning_chain(list())), 0L)
})

test_that("check_reasoning_chain validates entry shape", {
  expect_error(
    check_reasoning_chain("not a list"),
    "designr_input_error: reasoning_chain"
  )
  # missing required keys
  expect_error(
    check_reasoning_chain(list(list(decision = "alpha"))),
    "designr_input_error: reasoning_chain.*missing required key"
  )
  # source_type not in enum
  expect_error(
    check_reasoning_chain(list(list(
      decision = "alpha", value = 0.025,
      justification = "default", source_type = "invented_source"
    ))),
    "designr_input_error: reasoning_chain.*source_type"
  )
  # decision must be non-empty
  expect_error(
    check_reasoning_chain(list(list(
      decision = "", value = 0.025,
      justification = "default", source_type = "package_default"
    ))),
    "designr_input_error: reasoning_chain.*decision"
  )
})

test_that("check_reasoning_chain accepts a well-formed chain", {
  rc <- list(
    list(decision = "alpha", value = 0.025,
         justification = "FDA standard for confirmatory survival trials",
         source_type = "fda_guidance",
         source_ref  = "FDA Guidance E9 (1998)"),
    list(decision = "hazard_ratio", value = 0.65,
         justification = "Pooled estimate from KEYNOTE-189 + KEYNOTE-407",
         source_type = "llm_precedent"),
    list(decision = "control_median", value = 4.7,
         justification = "Internal Phase 2 readout (sponsor)",
         source_type = "sponsor_confidential")
  )
  validated <- check_reasoning_chain(rc)
  expect_equal(length(validated), 3L)
  expect_equal(validated[[3]]$source_type, "sponsor_confidential")
})

test_that("reasoning_has_confidential detects sponsor_confidential entries", {
  expect_false(reasoning_has_confidential(NULL))
  expect_false(reasoning_has_confidential(list()))
  expect_false(reasoning_has_confidential(list(list(
    decision = "alpha", value = 0.025,
    justification = "default", source_type = "package_default"))))
  expect_true(reasoning_has_confidential(list(list(
    decision = "p_treatment", value = 0.10,
    justification = "internal study P3-A1",
    source_type = "sponsor_confidential"))))
})

test_that("design_binary attaches reasoning_chain to the result", {
  rc <- list(
    list(decision = "alpha", value = 0.05,
         justification = "convention", source_type = "package_default"),
    list(decision = "p_control", value = 0.30,
         justification = "Phase 2 readout, internal", source_type = "sponsor_confidential")
  )
  res <- design_binary(p_control = 0.30, p_treatment = 0.20,
                       alpha = 0.05, power = 0.80, sided = 2,
                       reasoning_chain = rc)
  expect_equal(length(res$reasoning_chain), 2L)
  expect_equal(res$reasoning_chain[[1]]$decision, "alpha")
  expect_equal(res$reasoning_chain[[2]]$source_type, "sponsor_confidential")
})

test_that("design_survival attaches reasoning_chain to the result", {
  rc <- list(list(decision = "hazard_ratio", value = 0.70,
                  justification = "industry-standard for IO survival",
                  source_type = "llm_precedent"))
  res <- design_survival(model = "ph", design_class = "fixed",
                         control_median = 17, hazard_ratio = 0.70,
                         accrual_duration = 20, followup_duration = 24,
                         alpha = 0.025, power = 0.80, sided = 1,
                         reasoning_chain = rc)
  expect_equal(length(res$reasoning_chain), 1L)
  expect_equal(res$reasoning_chain[[1]]$decision, "hazard_ratio")
})

test_that("invalid reasoning_chain raises designr_input_error from a design tool", {
  bad_rc <- list(list(decision = "alpha", value = 0.05))  # missing keys
  expect_error(
    design_binary(p_control = 0.30, p_treatment = 0.20,
                  alpha = 0.05, power = 0.80, sided = 2,
                  reasoning_chain = bad_rc),
    "designr_input_error: reasoning_chain"
  )
})

test_that("design_co_primary / multi_population / graphical accept reasoning_chain", {
  rc <- list(list(decision = "strategy", value = "fixed-sequence",
                  justification = "co-primary regulatory convention",
                  source_type = "ich_guidance",
                  source_ref  = "ICH E9 (1998)"))
  res_cop <- design_co_primary(
    endpoints = list(
      A = list(type = "binary", p_control = 0.20, p_treatment = 0.10),
      B = list(type = "binary", p_control = 0.30, p_treatment = 0.20)
    ),
    strategy = "fixed-sequence",
    reasoning_chain = rc
  )
  expect_equal(res_cop$reasoning_chain[[1]]$decision, "strategy")

  res_mp <- design_multi_population(
    endpoint_type = "binary",
    endpoint_args = list(p_control = 0.30),
    populations = list(
      A = list(prevalence = 0.5, effect = list(p_treatment = 0.20)),
      B = list(prevalence = 0.5, effect = list(p_treatment = 0.22))
    ),
    relation = "nested", strategy = "fixed-sequence",
    reasoning_chain = rc
  )
  expect_equal(length(res_mp$reasoning_chain), 1L)

  res_gm <- design_graphical_multiplicity(
    hypotheses = list(
      H1 = list(type = "continuous", mean_diff = 0.4, sd = 1),
      H2 = list(type = "continuous", mean_diff = 0.4, sd = 1)
    ),
    initial_weights = c(H1 = 0.5, H2 = 0.5),
    transition_matrix = matrix(c(0,1,1,0), 2, 2,
                               dimnames = list(c("H1","H2"), c("H1","H2"))),
    reasoning_chain = rc
  )
  expect_equal(res_gm$reasoning_chain[[1]]$source_type, "ich_guidance")
})
