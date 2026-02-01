test_that("white spaces are protected", {
  ft <- flextable(data.frame(x = ""))
  ft <- delete_part(ft, part = "header")
  ft <- mk_par(ft, 1, 1, as_paragraph("foo", " ", "bar"))
  str <- flextable:::gen_raw_latex(ft)
  expect_true(grepl("{\\ }", str, fixed = TRUE))
})


test_that("merge_v places content at top of merged range", {
  ft <- flextable(data.frame(a = c("X", "X", "Y", "Y"), b = 1:4))
  ft <- merge_v(ft, j = "a")
  latex_str <- flextable:::gen_raw_latex(ft)

  lines <- unlist(strsplit(latex_str, "\n"))
  body_lines <- grep("multirow|\\{\\}", lines, value = TRUE)

  # first body row should contain the multirow command with positive count
  multirow_line <- grep("\\\\multirow", body_lines, value = TRUE)[1]
  expect_match(multirow_line, "\\multirow[", fixed = TRUE)
  expect_match(multirow_line, "]{2}{", fixed = TRUE)
  expect_false(grepl("]{-2}{", multirow_line, fixed = TRUE))

  # the multirow for "X" should appear before value "1"
  multirow_pos <- grep("\\\\multirow", lines)[1]
  x_in_multirow <- grepl("X", lines[multirow_pos])
  expect_true(x_in_multirow)

  # the empty cell {} should come after the multirow row
  empty_pos <- grep("\\{\\}.*&.*\\{2\\}", lines)
  if (length(empty_pos) == 0) {
    empty_pos <- grep("\\{\\}", lines)
    empty_pos <- empty_pos[empty_pos > multirow_pos]
  }
  expect_true(length(empty_pos) > 0)
})

test_that("fonts are defined in latex", {
  gdtools::register_liberationsans()
  ft <- flextable::flextable(head(cars, n = 1))
  ft <- flextable::font(ft, fontname = "Liberation Sans", part = "body")

  # R Markdown with pdflatex
  knitr::opts_knit$set("quarto.version" = NULL)
  latex_str <- flextable:::gen_raw_latex(ft, quarto = FALSE)
  expect_no_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)

  knitr::opts_knit$set("rmarkdown.pandoc.args" = c("--pdf-engine", "xelatex"))
  latex_str <- flextable:::gen_raw_latex(ft, quarto = FALSE)
  expect_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  # quarto
  flextable:::fake_quarto()
  latex_str <- flextable:::gen_raw_latex(ft, quarto = TRUE)
  expect_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)
})
