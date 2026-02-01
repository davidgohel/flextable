ft <- flextable(iris[1:5, ])
ft <- footnote(
  x = ft, i = 1:3, j = 1:3,
  ref_symbols = "a",
  value = as_paragraph("This is footnote one")
)
text_data <- information_data_chunk(ft)
setDT(text_data)


test_that("symbols are inserted at the end", {
  cell_1 <- text_data[.row_id %in% 1 & .col_id %in% "Sepal.Length" & .part %in% "body"]
  expect_equal(cell_1$txt, c("5.1", "a"))
  cell_2 <- text_data[.row_id %in% 2 & .col_id %in% "Sepal.Width" & .part %in% "body"]
  expect_equal(cell_2$txt, c("3.0", "a"))
  cell_3 <- text_data[.row_id %in% 3 & .col_id %in% "Petal.Length" & .part %in% "body"]
  expect_equal(cell_3$txt, c("1.3", "a"))
})


test_that("footnotes are in the footer", {
  cell_1 <- text_data[.part %in% "footer" & .col_id %in% "Sepal.Length"]
  expect_equal(cell_1$txt, c("a", "This is footnote one"))
})


test_that("symbols are not inserted as a rectangular selection", {
  cell_1 <- text_data[.row_id %in% 2 & .col_id %in% "Sepal.Length" & .part %in% "body"]
  expect_equal(cell_1$txt, c("4.9"))
})


test_that("footnote with zero matching rows does not error", {
  ft_zero <- flextable(data.frame(a = 1:5))
  expect_silent(
    ft_result <- footnote(
      x = ft_zero,
      i = ~ a > 10,
      j = "a",
      value = as_paragraph("big")
    )
  )
  expect_equal(
    nrow_part(ft_result, "footer"), 0L
  )
})


test_that("symbol_sep separates multiple footnotes in same cell", {
  ft_sep <- flextable(head(iris))
  ft_sep <- footnote(ft_sep,
    i = 1, j = 1,
    value = as_paragraph("note one"),
    ref_symbols = "1", part = "header"
  )
  ft_sep <- footnote(ft_sep,
    i = 1, j = 1,
    value = as_paragraph("note two"),
    ref_symbols = "2", part = "header",
    symbol_sep = ","
  )
  td <- information_data_chunk(ft_sep)
  setDT(td)
  cell <- td[
    .row_id %in% 1 &
      .col_id %in% "Sepal.Length" &
      .part %in% "header"
  ]
  expect_equal(cell$txt, c("Sepal.Length", "1", ",", "2"))
})

test_that("symbol_sep not added on first footnote", {
  ft_sep <- flextable(head(iris))
  ft_sep <- footnote(ft_sep,
    i = 1, j = 1,
    value = as_paragraph("note one"),
    ref_symbols = "1", part = "header",
    symbol_sep = ","
  )
  td <- information_data_chunk(ft_sep)
  setDT(td)
  cell <- td[
    .row_id %in% 1 &
      .col_id %in% "Sepal.Length" &
      .part %in% "header"
  ]
  expect_equal(cell$txt, c("Sepal.Length", "1"))
})

test_that("symbol_sep works with three footnotes on same cell", {
  ft_sep <- flextable(head(iris))
  for (k in 1:3) {
    ft_sep <- footnote(ft_sep,
      i = 1, j = 1,
      value = as_paragraph(paste("note", k)),
      ref_symbols = as.character(k),
      part = "header", symbol_sep = ","
    )
  }
  td <- information_data_chunk(ft_sep)
  setDT(td)
  cell <- td[
    .row_id %in% 1 &
      .col_id %in% "Sepal.Length" &
      .part %in% "header"
  ]
  expect_equal(
    cell$txt,
    c("Sepal.Length", "1", ",", "2", ",", "3")
  )
})

test_that("symbol_sep does not affect different cells", {
  ft_sep <- flextable(head(iris))
  ft_sep <- footnote(ft_sep,
    i = 1, j = 1,
    value = as_paragraph("note one"),
    ref_symbols = "a", part = "header",
    symbol_sep = ","
  )
  ft_sep <- footnote(ft_sep,
    i = 1, j = 2,
    value = as_paragraph("note two"),
    ref_symbols = "b", part = "header",
    symbol_sep = ","
  )
  td <- information_data_chunk(ft_sep)
  setDT(td)
  cell1 <- td[
    .row_id %in% 1 &
      .col_id %in% "Sepal.Length" &
      .part %in% "header"
  ]
  cell2 <- td[
    .row_id %in% 1 &
      .col_id %in% "Sepal.Width" &
      .part %in% "header"
  ]
  expect_equal(cell1$txt, c("Sepal.Length", "a"))
  expect_equal(cell2$txt, c("Sepal.Width", "b"))
})


ft <- flextable(iris[1:5, ])
ft <- footnote(
  x = ft, i = 1:3, j = 1:3,
  ref_symbols = c("a", "b", "c"),
  value = as_paragraph(paste("This is footnote", 1:3))
)
text_data <- information_data_chunk(ft)
setDT(text_data)

test_that("more than a symbol and more than a footnote", {
  cell_1 <- text_data[.row_id %in% 1 & .col_id %in% "Sepal.Length" & .part %in% "body"]
  expect_equal(cell_1$txt, c("5.1", "a"))
  cell_2 <- text_data[.row_id %in% 2 & .col_id %in% "Sepal.Width" & .part %in% "body"]
  expect_equal(cell_2$txt, c("3.0", "b"))
  cell_3 <- text_data[.row_id %in% 3 & .col_id %in% "Petal.Length" & .part %in% "body"]
  expect_equal(cell_3$txt, c("1.3", "c"))

  note_1 <- text_data[.row_id %in% 1 & .part %in% "footer" & .col_id %in% "Sepal.Length"]
  expect_equal(note_1$txt, c("a", "This is footnote 1"))
  note_2 <- text_data[.row_id %in% 2 & .part %in% "footer" & .col_id %in% "Sepal.Length"]
  expect_equal(note_2$txt, c("b", "This is footnote 2"))
  note_3 <- text_data[.row_id %in% 3 & .part %in% "footer" & .col_id %in% "Sepal.Length"]
  expect_equal(note_3$txt, c("c", "This is footnote 3"))
})
