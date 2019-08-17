context("check proc_freq")

library(utils)
library(xml2)

test_that("proc_freq executes without errors", {
  dummy_df <- data.frame( values = rep(letters[1:3], each = 2), groups = rep(letters[1:3], each = 2), stringsAsFactors = FALSE )
  ft <- proc_freq(dummy_df, "values", "groups")
  expect_equivalent(class(ft), "flextable")
})

test_that("proc_freq can take options", {
  dummy_df <- data.frame( values = rep(letters[1:3], each = 2), groups = rep(letters[1:3], each = 2), stringsAsFactors = FALSE )
  ft <- proc_freq(dummy_df, "values", "groups", include.row_percent = FALSE, include.column_percent = FALSE, include.table_percent = FALSE, include.column_total = FALSE, include.row_total = FALSE, include.header_row = FALSE)
  expect_equivalent(class(ft), "flextable")
})
