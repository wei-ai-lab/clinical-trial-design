test_that("design_continuous fixed superiority matches a 2-sample t-test baseline", {
  res <- design_continuous(
    mean_diff    = 30, sd = 70,
    design_class = "fixed",
    alpha = 0.05, sided = 2, power = 0.9
  )
  # nNormal gives ~230 total (115 per arm, ± ceil)
  expect_gte(res$sample_size_total, 228)
  expect_lte(res$sample_size_total, 234)
  expect_equal(sum(res$sample_size_per_arm), res$sample_size_total)
  expect_match(res$method, "nNormal")
})

test_that("design_continuous fixed supports NI and equivalence", {
  ni <- design_continuous(
    mean_diff = 0, sd = 10,
    design_class = "fixed",
    alpha = 0.025, sided = 1, power = 0.9,
    comparison = "non-inferiority", ni_margin = 3
  )
  expect_true(ni$sample_size_total > 0)
  expect_match(ni$method, "non-inferiority")

  eq <- design_continuous(
    mean_diff = 0, sd = 10,
    design_class = "fixed",
    alpha = 0.05, sided = 2, power = 0.9,
    comparison = "equivalence", equiv_margin = 5
  )
  expect_true(eq$sample_size_total > 0)
  expect_match(eq$method, "equivalence")
})

test_that("design_continuous fixed rejects zero effect for superiority", {
  expect_error(
    design_continuous(mean_diff = 0, sd = 1, design_class = "fixed"),
    "designr_input_error: mean_diff"
  )
  expect_error(
    design_continuous(mean_diff = 10, sd = -1, design_class = "fixed"),
    "designr_input_error: sd"
  )
})

test_that("design_continuous group-sequential: 2 analyses OBF inflates over fixed", {
  fx <- design_continuous(mean_diff = 30, sd = 70,
                          design_class = "fixed",
                          alpha = 0.025, power = 0.90, sided = 1)
  gs <- design_continuous(mean_diff = 30, sd = 70,
                          design_class = "group-sequential",
                          k = 2, sfu = "LDOF",
                          alpha = 0.025, power = 0.90, sided = 1)
  expect_true(gs$sample_size_total >= fx$sample_size_total)
  expect_true(gs$sample_size_total <= fx$sample_size_total * 1.10)
  expect_length(gs$boundaries$upper_z, 2)
})

test_that("design_continuous group-sequential: input validation", {
  expect_error(
    design_continuous(mean_diff = 0, sd = 70,
                      design_class = "group-sequential", k = 2),
    "designr_input_error"
  )
  expect_error(
    design_continuous(mean_diff = 30, sd = -1,
                      design_class = "group-sequential", k = 2),
    "designr_input_error"
  )
  expect_error(
    design_continuous(mean_diff = 30, sd = 70,
                      design_class = "group-sequential",
                      comparison = "equivalence"),
    "designr_input_error: comparison"
  )
})
