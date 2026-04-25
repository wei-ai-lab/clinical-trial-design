test_that("validate_against_benchmark: unknown case raises designr_input_error", {
  skip_if_not(dir.exists("/home/weiai/designr/benchmarks"),
              "benchmarks/ corpus not available")
  expect_error(
    validate_against_benchmark(family = "fixed-superiority",
                               id     = "NOT_A_REAL_CASE_ID"),
    "designr_input_error"
  )
})

test_that("validate_against_benchmark: runs on CAPTURE fixed-binary case", {
  skip_if_not(dir.exists("/home/weiai/designr/benchmarks"),
              "benchmarks/ corpus not available")
  case_file <- file.path("/home/weiai/designr/benchmarks/fixed-superiority/cases",
                         "1997_CAPTURE_abciximab.yaml")
  skip_if_not(file.exists(case_file), "CAPTURE case not available")

  res <- validate_against_benchmark(
    family = "fixed-superiority",
    id     = "1997_CAPTURE_abciximab"
  )
  expect_true(is.list(res))
  expect_equal(res$case_id, "1997_CAPTURE_abciximab")
  expect_equal(res$tool, "design_fixed_binary")
  expect_true(!is.null(res$computed$sample_size_total))
  expect_equal(res$expected$sample_size_total, 1400)
  expect_true(!is.null(res$diffs$sample_size_total))
})
