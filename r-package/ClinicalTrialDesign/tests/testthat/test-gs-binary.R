test_that("GS binary: 2 analyses OBF gives reasonable inflation", {
  res <- design_gs_binary(
    p_control = 0.15, p_treatment = 0.09,
    k = 2, sfu = "LDOF", sfl = "LDOF",
    alpha = 0.025, power = 0.90, sided = 1
  )
  expect_true(res$sample_size_total > 900)
  expect_true(res$sample_size_total < 1400)
  expect_length(res$boundaries$upper_z, 2)
  expect_length(res$timing$information_fraction, 2)
  expect_equal(res$timing$information_fraction[2], 1, tolerance = 1e-8)
  expect_true(res$boundaries$upper_z[1] > res$boundaries$upper_z[2])
})

test_that("GS binary: 3-analysis Pocock has flatter boundaries than OBF", {
  obf <- design_gs_binary(p_control = 0.10, p_treatment = 0.05,
                          k = 3, sfu = "LDOF",
                          alpha = 0.025, power = 0.80, sided = 1)
  poc <- design_gs_binary(p_control = 0.10, p_treatment = 0.05,
                          k = 3, sfu = "LDPocock",
                          alpha = 0.025, power = 0.80, sided = 1)
  expect_true(poc$boundaries$upper_z[1] < obf$boundaries$upper_z[1])
  expect_true(poc$boundaries$upper_z[3] > obf$boundaries$upper_z[3])
})

test_that("GS binary: input validation", {
  expect_error(
    design_gs_binary(p_control = 0.1, p_treatment = 0.05, k = 1),
    "designr_input_error"
  )
  expect_error(
    design_gs_binary(p_control = 0.1, p_treatment = 0.05, k = 2,
                     sfu = "NotASpendingFunction"),
    "designr_input_error"
  )
  expect_error(
    design_gs_binary(p_control = 0.1, p_treatment = 0.05, k = 2,
                     timing = c(0.3, 0.5)),
    "designr_input_error"
  )
})
