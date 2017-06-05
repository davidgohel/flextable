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


test_that("span at", {
  dummy_df <- data.frame(
    col1 = letters,
    col2 = letters,
    stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  ft <- merge_at(x = ft, i = 1:4, j = 1:2)
  ref <- matrix( c(rep(2,4), rep(1,22), rep(0, 4), rep(1,22)), ncol = 2 )
  expect_equivalent(ft$body$spans$rows, ref )
  ref <- matrix( c(4, rep(0,3), rep(1,22), 4, rep(0,3), rep(1,22)), ncol = 2 )
  expect_equivalent(ft$body$spans$columns, ref )
})


test_that("merged cells can be un-merged", {
  dummy_df <- data.frame(
    col1 = rep("a", 5),
    col2 = rep("a", 5),
    stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  ft <- merge_h(x = ft)
  expect_true( all( ft$body$spans$rows[,1] == 2 ) )
  ft <- merge_none(ft)
  expect_true( all( ft$body$spans$rows == 1 ) )
  ft <- merge_v(x = ft)
  expect_true( all( ft$body$spans$columns[1,] == 5 ) )
  expect_true( all( ft$body$spans$columns[-1,] == 0 ) )
  ft <- merge_none(ft)
  expect_true( all( ft$body$spans$columns == 1 ) )
})


