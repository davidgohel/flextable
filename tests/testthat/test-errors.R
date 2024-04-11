test_that("rows selections", {
  dummy_df <- data.frame(
    my_col = rep(letters[1:3], each = 2),
    row.names = letters[21:26],
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  expect_error(bold(ft, i = ~ my_col %in% "a", part = "header"))
  expect_error(bold(ft, i = 1L:8L), "invalid row selection")
  expect_error(bold(ft, i = -9), "invalid row selection")
  expect_error(bold(ft, i = rep(TRUE, 10)), "invalid row selection")
  expect_error(bold(ft, i = c("m", "n")), "invalid row selection")
})

test_that("columns selections", {
  ft <- flextable(iris)
  expect_error(bold(ft, j = ~ Sepalsd.Length + Species), "Sepalsd.Length")
  expect_error(bold(ft, j = 1:6), "invalid columns selection")
  expect_error(bold(ft, j = c("Sepalsd.Length")), "Sepalsd.Length")
})


test_that("part=header and formula selection for rows", {
  ft <- flextable(head(mtcars, n = 10))
  def_cell <- fp_cell(border = fp_border(color = "#00FFFF"))
  def_par <- fp_par(text.align = "center")
  expect_error(style(ft, i = ~ mpg < 20, pr_c = def_cell, pr_p = def_par, part = "all"))
  expect_error(bg(ft, i = ~ mpg < 20, bg = "#DDDDDD", part = "header"))
  expect_error(bold(ft, i = ~ mpg < 20, bold = TRUE, part = "header"))
  expect_error(fontsize(ft, i = ~ mpg < 20, size = 10, part = "header"))
  expect_error(italic(ft, i = ~ mpg < 20, italic = TRUE, part = "header"))
  expect_error(color(ft, i = ~ mpg < 20, color = "red", part = "header"))
  expect_error(padding(ft, i = ~ mpg < 20, padding = 3, part = "header"))
  expect_error(align(ft, i = ~ mpg < 20, align = "center", part = "header"))
  expect_error(border(ft,
    i = ~ mpg < 20, border = fp_border(color = "orange"),
    part = "header"
  ))
  expect_error(rotate(ft, i = ~ mpg < 20, rotation = "lrtb", align = "top", part = "header"))
})
