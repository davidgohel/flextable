context("check various minor things")

test_that("print as log", {
  ft <- flextable(iris)
  expect_output(print(ft, preview = "log"), "a flextable object")
  expect_output(print(ft, preview = "log"), "header has 1 row")
  expect_output(print(ft, preview = "log"), "body has 150 row")
})

