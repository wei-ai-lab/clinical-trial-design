test_that("design_graphical_multiplicity validates required inputs", {
  hyps <- list(
    H1 = list(type = "continuous", mean_diff = 0.4, sd = 1, sample_size_total = NULL),
    H2 = list(type = "continuous", mean_diff = 0.4, sd = 1)
  )
  expect_error(
    design_graphical_multiplicity(
      hypotheses = list(only_one = list(type = "continuous", mean_diff = 0.4, sd = 1)),
      initial_weights = c(only_one = 0.025),
      transition_matrix = matrix(0, 1, 1)
    ),
    "designr_input_error: hypotheses"
  )
  expect_error(
    design_graphical_multiplicity(
      hypotheses = hyps,
      initial_weights = c(WRONG_NAMES = 0.0125, OTHER = 0.0125),
      transition_matrix = matrix(c(0,1,1,0), 2, 2)
    ),
    "designr_input_error: initial_weights"
  )
  expect_error(
    design_graphical_multiplicity(
      hypotheses = hyps,
      initial_weights = c(H1 = 0.7, H2 = 0.7),  # sums > 1
      transition_matrix = matrix(c(0,1,1,0), 2, 2)
    ),
    "designr_input_error: initial_weights"
  )
})

test_that("transition matrix violations are caught", {
  hyps <- list(
    H1 = list(type = "continuous", mean_diff = 0.4, sd = 1),
    H2 = list(type = "continuous", mean_diff = 0.4, sd = 1)
  )
  # Row sum > 1
  expect_error(
    design_graphical_multiplicity(
      hypotheses = hyps,
      initial_weights = c(H1 = 0.0125, H2 = 0.0125),
      transition_matrix = matrix(c(0, 1.5, 0.5, 0), 2, 2, byrow = TRUE)
    ),
    "designr_input_error: transition_matrix"
  )
  # Self-loop on diagonal
  expect_error(
    design_graphical_multiplicity(
      hypotheses = hyps,
      initial_weights = c(H1 = 0.0125, H2 = 0.0125),
      transition_matrix = matrix(c(0.5, 0.5, 0.5, 0.0), 2, 2, byrow = TRUE)
    ),
    "designr_input_error: transition_matrix"
  )
  # Wrong dimension
  expect_error(
    design_graphical_multiplicity(
      hypotheses = hyps,
      initial_weights = c(H1 = 0.0125, H2 = 0.0125),
      transition_matrix = matrix(0, 3, 3)
    ),
    "designr_input_error: transition_matrix"
  )
})

test_that("Rule-3 gate_prereqs validator catches unreachable gating", {
  hyps <- list(
    H1 = list(type = "continuous", mean_diff = 0.4, sd = 1),
    H2 = list(type = "continuous", mean_diff = 0.4, sd = 1),
    H3 = list(type = "continuous", delta = 0.3, sd = 1)
  )
  # H3 is gated on H1, but transition matrix routes no alpha from H1 to H3
  expect_error(
    design_graphical_multiplicity(
      hypotheses = hyps,
      initial_weights = c(H1 = 0.0125, H2 = 0.0125, H3 = 0),
      transition_matrix = matrix(c(0, 1, 0,
                                   1, 0, 0,
                                   0, 0, 0), 3, 3, byrow = TRUE,
                                 dimnames = list(c("H1","H2","H3"),
                                                 c("H1","H2","H3"))),
      gate_prereqs = list(H3 = c("H1"))
    ),
    "designr_input_error: transition_matrix.*Rule-3"
  )
})

test_that("Maurer-Bretz canonical 4-hypothesis example sizes correctly", {
  res <- design_graphical_multiplicity(
    hypotheses = list(
      H1 = list(type = "continuous", mean_diff = 0.40, sd = 1.0),
      H2 = list(type = "continuous", mean_diff = 0.40, sd = 1.0),
      H3 = list(type = "continuous", mean_diff = 0.25, sd = 1.0),
      H4 = list(type = "continuous", mean_diff = 0.35, sd = 1.0)
    ),
    initial_weights = c(H1 = 0.5, H2 = 0.5, H3 = 0, H4 = 0),
    transition_matrix = matrix(c(0,   0.5, 0.5, 0,
                                  0.5, 0,   0,   0.5,
                                  0,   0,   0,   1,
                                  0,   0,   1,   0), nrow = 4, byrow = TRUE,
                                dimnames = list(c("H1","H2","H3","H4"),
                                                c("H1","H2","H3","H4"))),
    gate_prereqs = list(H3 = c("H1"), H4 = c("H2")),
    alpha = 0.025, power = 0.80, allocation_ratio = 1
  )
  # Each H1/H2 starts at weight 0.5 (= 0.0125 alpha when family=0.025)
  expect_equal(res$raw$multiplicity$worst_case_alpha$H1, 0.025 * 0.5,
               tolerance = 1e-9)
  # H3 starts at 0 → fallback to min(non-zero) = 0.5
  expect_equal(res$raw$multiplicity$worst_case_weights$H3, 0.5,
               tolerance = 1e-9)
  # All hypotheses get a sample-size result
  expect_named(res$raw$hypotheses, c("H1", "H2", "H3", "H4"))
  # Total N drives from a worst-case (likely H3 with smallest delta)
  expect_true(res$sample_size_total > 0)
  # Driver should be the hypothesis with smallest delta given equal alpha
  expect_equal(res$raw$driver, "H3")
})

test_that("graphicalMCP graph object is constructed with the right shape", {
  res <- design_graphical_multiplicity(
    hypotheses = list(
      H1 = list(type = "continuous", mean_diff = 0.4, sd = 1),
      H2 = list(type = "continuous", mean_diff = 0.4, sd = 1)
    ),
    initial_weights = c(H1 = 0.5, H2 = 0.5),
    transition_matrix = matrix(c(0, 1, 1, 0), 2, 2,
                               dimnames = list(c("H1","H2"),
                                               c("H1","H2"))),
    alpha = 0.025
  )
  expect_equal(res$method, "design_graphical_multiplicity[graphicalMCP]")
  expect_named(res$raw$graph, c("hypotheses", "transitions"))
})
