context("check errors")


test_that("rows selections", {
  dummy_df <- data.frame( my_col = rep(letters[1:3], each = 2),
                          row.names = letters[21:26],
                          stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  expect_error(bold(ft, i = ~ my_col %in% "a", part = "header" ), "cannot adress part 'header'")
  expect_error(bold(ft, i = 1L:8L ), "invalid row selection")
  expect_error(bold(ft, i = -9 ), "invalid row selection")
  expect_error(bold(ft, i = rep(TRUE, 10) ), "invalid row selection")
  expect_error(bold(ft, i = c("m", "n") ), "invalid row selection")
})

test_that("columns selections", {
  ft <- flextable(iris)
  expect_error(bold(ft, j = ~ Sepalsd.Length + Species ), "invalid columns selection")
  expect_error(bold(ft, j = 1:6 ), "invalid columns selection")
  expect_error(bold(ft, j = c("Sepalsd.Length") ), "invalid columns selection")
})



test_that("display usage", {
  ft <- flextable(head( mtcars, n = 10))
  expect_error(display(ft, col_key = "carb", pattern = "# {{carb}}",
                       fprops = list(carb = fp_text(color="orange") ) ),
               "missing definition for display")
  expect_error(display(ft, col_key = "carb", pattern = "# {{carb}}",
                       formatters = list(carb ~ sprintf("%.1f", carb)),
                       fprops = list(carb = "sdf" ) ),
               "argument fprops should be a list of fp_text")
})

