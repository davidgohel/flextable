
test_that("a border under some columns of a merged cell is kept (#399)", {
  ft <- flextable(head(iris, 2))
  ft <- set_header_labels(ft, Sepal.Width = "")
  ft <- border_remove(ft)
  ft <- merge_at(ft, i = 1, j = 1:2, part = "header")
  ft <- hline_top(ft, j = 2, border = officer::fp_border(width = 2), part = "body")
  fixed <- fix_border_issues(ft)
  # copied to the top of the cell below the hidden cell, only there
  expect_equal(
    unname(fixed$body$styles$cells$border.width.top$data[1, 1:3]),
    c(0, 2, 0)
  )
  # drawn by the cell below in grid
  dat <- flextable:::get_grid_data(fixed, autowidths = TRUE, wrapping = TRUE)
  dat <- flextable:::grid_data_add_cell_info(dat, fixed)
  row1 <- dat[dat$.part == "body" & dat$.row_id == 1, ]
  n_top <- vapply(
    row1$borders,
    function(b) {
      b <- Filter(Negate(is.null), b)
      sum(vapply(b, function(s) s$y0 == 1 && s$y1 == 1, NA))
    },
    1L
  )
  names(n_top) <- as.character(row1$.col_id)
  expect_equal(unname(n_top[c("Sepal.Length", "Sepal.Width")]), c(0L, 1L))
  # in HTML, the top border of the cell below
  expect_match(gen_raw_html(fixed), "border-top: 2(\\.0+)?pt solid", perl = TRUE)
})

test_that("a border drawn by the merged cell is not drawn twice", {
  ft <- flextable(head(iris, 2))
  ft <- add_header_row(ft, values = c("Sepal", "Petal", "Sp"), colwidths = c(2, 2, 1))
  ft <- border_inner(ft, part = "all")
  fixed <- fix_border_issues(ft)
  # the bottom border of "Sepal" is drawn by the merged cell, not copied
  expect_identical(
    fixed$header$styles$cells$border.width.top$data[2, ],
    ft$header$styles$cells$border.width.top$data[2, ]
  )
})
