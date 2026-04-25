test_that("design_fixed_continuous matches a 2-sample t-test baseline", {
  # Vanilla: Δ=30, SD=70, α=0.05 two-sided, 90% power → ~115 per arm (see
  # PATENT-1 YAML notes). Since our wrapper is a 2-arm form over nNormal,
  # the vanilla comparison is what we anchor against.
  res <- design_fixed_continuous(
    mean_diff = 30, sd = 70,
    alpha = 0.05, sided = 2, power = 0.9
  )
  # nNormal gives ~230 total (115 per arm, ± ceil)
  expect_gte(res$sample_size_total, 228)
  expect_lte(res$sample_size_total, 234)
  expect_equal(sum(res$sample_size_per_arm), res$sample_size_total)
  expect_match(res$method, "nNormal")
})

test_that("design_fixed_continuous supports NI and equivalence", {
  ni <- design_fixed_continuous(
    mean_diff = 0, sd = 10,
    alpha = 0.025, sided = 1, power = 0.9,
    comparison = "non-inferiority", ni_margin = 3
  )
  expect_true(ni$sample_size_total > 0)
  expect_match(ni$method, "non-inferiority")

  eq <- design_fixed_continuous(
    mean_diff = 0, sd = 10,
    alpha = 0.05, sided = 2, power = 0.9,
    comparison = "equivalence", equiv_margin = 5
  )
  expect_true(eq$sample_size_total > 0)
  expect_match(eq$method, "equivalence")
})

test_that("design_fixed_continuous rejects zero effect for superiority", {
  expect_error(
    design_fixed_continuous(mean_diff = 0, sd = 1),
    "designr_input_error: mean_diff"
  )
  expect_error(
    design_fixed_continuous(mean_diff = 10, sd = -1),
    "designr_input_error: sd"
  )
})
