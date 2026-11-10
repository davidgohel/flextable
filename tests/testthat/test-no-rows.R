no_rows_table <- function() {
  ft <- flextable(data.frame(a = character(0), b = character(0)))
  delete_part(ft, part = "header")
}

test_that("a flextable without any row stops with an explicit error", {
  ft <- no_rows_table()
  msg <- "no row to display"
  expect_error(flextable:::gen_raw_html(ft), msg)
  expect_error(flextable:::gen_raw_wml(ft), msg)
  expect_error(flextable:::gen_raw_pml(ft), msg)
  expect_error(flextable:::gen_raw_latex(ft), msg)
  expect_error(gen_grob(ft), msg)
})

test_that("column widths are kept when a flextable has no row", {
  ft <- no_rows_table()
  expect_equal(dim(ft)$widths, c(a = 0.75, b = 0.75))
  ft <- add_footer_lines(ft, "no data")
  expect_equal(ft$footer$colwidths, c(a = 0.75, b = 0.75))
  expect_no_error(flextable:::gen_raw_html(ft))
  expect_no_error(flextable:::gen_raw_wml(ft))
})
