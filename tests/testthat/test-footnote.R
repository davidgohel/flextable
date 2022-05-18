context("check footnotes")

library(data.table)

ft <- flextable(iris[1:5, ])
ft <- footnote(
  x = ft, i = 1:3, j = 1:3,
  ref_symbols = "a",
  value = as_paragraph("This is footnote one")
)
text_data <- flextable:::as_table_text(ft)
setDT(text_data)


test_that("symbols are inserted at the end", {
  cell_1 <- text_data[ft_row_id %in% 1 & col_id %in% "Sepal.Length" & part %in% "body"]
  expect_equal(cell_1$txt, c("5.1", "a"))
  cell_2 <- text_data[ft_row_id %in% 2 & col_id %in% "Sepal.Width" & part %in% "body"]
  expect_equal(cell_2$txt, c("3.0", "a"))
  cell_3 <- text_data[ft_row_id %in% 3 & col_id %in% "Petal.Length" & part %in% "body"]
  expect_equal(cell_3$txt, c("1.3", "a"))
})


test_that("footnotes are in the footer", {
  cell_1 <- text_data[part %in% "footer" & col_id %in% "Sepal.Length"]
  expect_equal(cell_1$txt, c("a", "This is footnote one"))
})


test_that("symbols are not inserted as a rectangular selection", {
  cell_1 <- text_data[ft_row_id %in% 2 & col_id %in% "Sepal.Length" & part %in% "body"]
  expect_equal(cell_1$txt, c("4.9"))
})


ft <- flextable(iris[1:5, ])
ft <- footnote(
  x = ft, i = 1:3, j = 1:3,
  ref_symbols = c("a", "b", "c"),
  value = as_paragraph(paste("This is footnote", 1:3))
)
text_data <- flextable:::as_table_text(ft)
setDT(text_data)

test_that("more than a symbol and more than a footnote", {
  cell_1 <- text_data[ft_row_id %in% 1 & col_id %in% "Sepal.Length" & part %in% "body"]
  expect_equal(cell_1$txt, c("5.1", "a"))
  cell_2 <- text_data[ft_row_id %in% 2 & col_id %in% "Sepal.Width" & part %in% "body"]
  expect_equal(cell_2$txt, c("3.0", "b"))
  cell_3 <- text_data[ft_row_id %in% 3 & col_id %in% "Petal.Length" & part %in% "body"]
  expect_equal(cell_3$txt, c("1.3", "c"))

  note_1 <- text_data[ft_row_id %in% 1 & part %in% "footer" & col_id %in% "Sepal.Length"]
  expect_equal(note_1$txt, c("a", "This is footnote 1"))
  note_2 <- text_data[ft_row_id %in% 2 & part %in% "footer" & col_id %in% "Sepal.Length"]
  expect_equal(note_2$txt, c("b", "This is footnote 2"))
  note_3 <- text_data[ft_row_id %in% 3 & part %in% "footer" & col_id %in% "Sepal.Length"]
  expect_equal(note_3$txt, c("c", "This is footnote 3"))
})

