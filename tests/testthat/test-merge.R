context("check merge operations")

library(utils)
library(xml2)

test_that("identical values within columns are merged", {
  dummy_df <- data.frame( values = rep(letters[1:3], each = 2), stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  ft <- merge_v(x = ft, j = "values" )
  expect_equivalent(ft$body$spans$columns[,1], rep( c(2,0), 3 ) )
})

test_that("identical values within rows are merged", {
  dummy_df <- data.frame(
    col1 = letters,
    col2 = letters,
    stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  ft <- merge_h(x = ft)
  ref <- matrix( c(rep(2,26), rep(0, 26)), ncol = 2 )
  expect_equivalent(ft$body$spans$rows, ref )
})


test_that("merged rows and merged columns can not meet", {
  dummy_df <- data.frame(
    col1 = rep("a", 5),
    col2 = rep("a", 5),
    stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  ft <- merge_h(x = ft)
  expect_error(merge_v(x = ft))
})

