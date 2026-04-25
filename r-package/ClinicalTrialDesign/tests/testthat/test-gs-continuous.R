test_that("GS continuous: 2 analyses OBF inflates over fixed", {
  fx <- design_fixed_continuous(mean_diff = 30, sd = 70,
                                alpha = 0.025, power = 0.90, sided = 1)
  gs <- design_gs_continuous(mean_diff = 30, sd = 70,
                             k = 2, sfu = "LDOF",
                             alpha = 0.025, power = 0.90, sided = 1)
  expect_true(gs$sample_size_total >= fx$sample_size_total)
  expect_true(gs$sample_size_total <= fx$sample_size_total * 1.10)
  expect_length(gs$boundaries$upper_z, 2)
})

test_that("GS continuous: input validation", {
  expect_error(
    design_gs_continuous(mean_diff = 0, sd = 70, k = 2),
    "designr_input_error"
  )
  expect_error(
    design_gs_continuous(mean_diff = 30, sd = -1, k = 2),
    "designr_input_error"
  )
})
