context("df_printer and utilities")

test_that("use_model_printer and use_df_printer works", {
  expect_silent(use_model_printer())
  expect_silent(use_df_printer())
})
