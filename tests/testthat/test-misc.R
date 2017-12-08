context("check various minor things")

test_that("print as log", {
  ft <- regulartable(iris)
  expect_output(print(ft, preview = "log"), "type: regulartable object")
  expect_output(print(ft, preview = "log"), "header has 1 row")
  expect_output(print(ft, preview = "log"), "body has 150 row")
})

