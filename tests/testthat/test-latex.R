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

  # no \multirow should be used (removed in favour of row placement)
  expect_false(any(grepl("\\\\multirow", lines)))

  # "X" should appear in first body row (with value "1")
  x_line <- grep("X", lines)[1]
  expect_true(grepl("1", lines[x_line]))

  # "Y" should appear in first row of its group (with value "3")
  y_line <- grep("Y", lines)[1]
  expect_true(grepl("3", lines[y_line]))
})

test_that("valign works in merged cells with varying row heights", {
  ft <- flextable(data.frame(col1 = c("A1", "A1", "A1"), col2 = c("B1", "long text", "B3")))
  ft <- merge_at(ft, i = 1:3, j = 1)

  lines_for <- function(va) {
    ft2 <- valign(ft, valign = va)
    latex_str <- flextable:::gen_raw_latex(ft2)
    strsplit(latex_str, "\n")[[1]]
  }

  # top: A1 in first row, no multirow
  top_lines <- lines_for("top")
  top_body <- grep("A1|B1|B3", top_lines, value = TRUE)
  a1_line <- grep("A1", top_lines)[1]
  b1_line <- grep("B1", top_lines)[1]
  expect_equal(a1_line, b1_line) # A1 and B1 on same line
  expect_false(any(grepl("\\\\multirow", top_body)))

  # center: A1 in middle row (row 2), no multirow
  ctr_lines <- lines_for("center")
  a1_line <- grep("A1", ctr_lines)[1]
  b1_line <- grep("B1", ctr_lines)[1]
  b3_line <- grep("B3", ctr_lines)[1]
  expect_true(a1_line > b1_line) # A1 is after B1 (not in first row)
  expect_true(a1_line < b3_line) # A1 is before B3 (not in last row)
  expect_false(any(grepl("\\\\multirow", grep("A1", ctr_lines, value = TRUE))))

  # bottom: A1 in last row, no multirow
  bot_lines <- lines_for("bottom")
  bot_body <- grep("A1|B1|B3", bot_lines, value = TRUE)
  a1_line <- grep("A1", bot_lines)[1]
  b3_line <- grep("B3", bot_lines)[1]
  expect_equal(a1_line, b3_line) # A1 and B3 on same line
  expect_false(any(grepl("\\\\multirow", bot_body)))
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
