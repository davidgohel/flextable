context("check merge operations")

library(utils)
library(xml2)

test_that("identical values within columns are merged", {
  dummy_df <- data.frame(values = rep(letters[1:3], each = 2), stringsAsFactors = FALSE)
  ft <- flextable(dummy_df)
  ft <- merge_v(x = ft, j = "values")
  expect_equivalent(ft$body$spans$columns[, 1], rep(c(2, 0), 3))
})

test_that("identical values within rows are merged", {
  dummy_df <- data.frame(
    col1 = letters,
    col2 = letters,
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  ft <- merge_h(x = ft)
  ref <- matrix(c(rep(2, 26), rep(0, 26)), ncol = 2)
  expect_equivalent(ft$body$spans$rows, ref)
})


test_that("span at", {
  dummy_df <- data.frame(
    col1 = letters,
    col2 = letters,
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  ft <- merge_at(x = ft, i = 1:4, j = 1:2)
  ref <- matrix(c(rep(2, 4), rep(1, 22), rep(0, 4), rep(1, 22)), ncol = 2)
  expect_equivalent(ft$body$spans$rows, ref)
  ref <- matrix(c(4, rep(0, 3), rep(1, 22), 4, rep(0, 3), rep(1, 22)), ncol = 2)
  expect_equivalent(ft$body$spans$columns, ref)
})


test_that("merged cells can be un-merged", {
  dummy_df <- data.frame(
    col1 = rep("a", 5),
    col2 = rep("a", 5),
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  ft <- merge_h(x = ft)
  expect_true(all(ft$body$spans$rows[, 1] == 2))
  ft <- merge_none(ft)
  expect_true(all(ft$body$spans$rows == 1))
  ft <- merge_v(x = ft)
  expect_true(all(ft$body$spans$columns[1, ] == 5))
  expect_true(all(ft$body$spans$columns[-1, ] == 0))
  ft <- merge_none(ft)
  expect_true(all(ft$body$spans$columns == 1))
})

test_that("separate_header", {
  x <- data.frame(
    Species = as.factor(c("setosa", "versicolor", "virginica")),
    Sepal.Length_mean_zzz = c(5.006, 5.936, 6.588),
    Sepal.Length_sd = c(0.35249, 0.51617, 0.63588),
    Sepal.Width_mean = c(3.428, 2.77, 2.974),
    Sepal.Width_sd_sfsf_dsfsdf = c(0.37906, 0.3138, 0.3225),
    Petal.Length_mean = c(1.462, 4.26, 5.552),
    Petal.Length_sd = c(0.17366, 0.46991, 0.55189),
    Petal.Width_mean = c(0.246, 1.326, 2.026),
    Petal.Width_sd = c(0.10539, 0.19775, 0.27465)
  )

  ft_1 <- flextable(x)
  ft_1 <- separate_header(x = ft_1,
                          opts = c("span-top", "bottom-vspan")
  )
  header_txt <- flextable:::fortify_run(ft_1) |>
    subset(.part %in% "header")
  expect_equal(
    object = header_txt$txt,
    expected =
      c("Species", "Sepal", "Sepal", "Sepal", "Sepal", "Petal", "Petal",
      "Petal", "Petal", "", "Length", "Length", "Width", "Width", "Length",
      "Length", "Width", "Width", "", "mean", "sd", "mean", "sd", "mean",
      "sd", "mean", "sd", "", "zzz", "", "", "sfsf", "", "", "", "",
      "", "", "", "", "dsfsdf", "", "", "", "")
  )

})
