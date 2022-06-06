context("check various minor things")

ft <- flextable(iris)

test_that("print as log", {
  expect_output(print(ft, preview = "log"), "a flextable object")
  expect_output(print(ft, preview = "log"), "header has 1 row")
  expect_output(print(ft, preview = "log"), "body has 150 row")
})


test_that("selectors", {
  ft <- flextable(iris)

  expect_equal(
    flextable:::as_col_keys(ft$body, 2),
    "Sepal.Width")

  expect_equal(
    flextable:::as_col_keys(ft$body, c(1, 2)),
    c("Sepal.Length", "Sepal.Width"))

  expect_equal(
    flextable:::as_col_keys(ft$body, NULL),
    names(iris))

  expect_equal(
    flextable:::as_col_keys(ft$body, c(TRUE, FALSE, TRUE, FALSE, TRUE)),
    c("Sepal.Length", "Petal.Length", "Species"))

  expect_equal(
    flextable:::as_col_keys(ft$body, "Julio-Iglesias"),
    character(0))
})

