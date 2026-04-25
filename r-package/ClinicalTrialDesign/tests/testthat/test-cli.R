test_that("designr_dispatch returns ok for a valid tool call", {
  input <- jsonlite::toJSON(
    list(tool = "design_fixed_binary",
         args = list(p_control = 0.15, p_treatment = 0.09,
                     alpha = 0.05, sided = 2, power = 0.8)),
    auto_unbox = TRUE
  )
  out <- capture.output(designr_dispatch(textConnection(input)))
  res <- jsonlite::fromJSON(paste(out, collapse = "\n"), simplifyVector = TRUE,
                            simplifyDataFrame = FALSE)
  expect_true(res$ok)
  expect_true(res$result$sample_size_total > 0)
  expect_equal(res$result$method, "gsDesign::nBinomial (superiority)")
})

test_that("designr_dispatch emits structured input_error for bad inputs", {
  input <- jsonlite::toJSON(
    list(tool = "design_fixed_binary",
         args = list(p_control = -0.1, p_treatment = 0.09)),
    auto_unbox = TRUE
  )
  out <- capture.output(designr_dispatch(textConnection(input)))
  res <- jsonlite::fromJSON(paste(out, collapse = "\n"), simplifyVector = TRUE,
                            simplifyDataFrame = FALSE)
  expect_false(res$ok)
  expect_equal(res$error$class, "input_error")
  expect_equal(res$error$field, "p_control")
})

test_that("designr_dispatch rejects unknown tools", {
  input <- jsonlite::toJSON(
    list(tool = "design_fake", args = list()), auto_unbox = TRUE
  )
  out <- capture.output(designr_dispatch(textConnection(input)))
  res <- jsonlite::fromJSON(paste(out, collapse = "\n"), simplifyVector = TRUE,
                            simplifyDataFrame = FALSE)
  expect_false(res$ok)
  expect_equal(res$error$class, "unknown_tool")
})
