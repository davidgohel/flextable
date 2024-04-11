test_that("white spaces are protected", {
  ft <- flextable(data.frame(x = ""))
  ft <- delete_part(ft, part = "header")
  ft <- mk_par(ft, 1, 1, as_paragraph("foo", " ", "bar"))
  str <- flextable:::gen_raw_latex(ft)
  expect_true(grepl("{\\ }", str, fixed = TRUE))
})


test_that("fonts are defined in latex", {
  gdtools::register_liberationsans()
  ft <- flextable::flextable(head(cars, n = 1)) |>
    flextable::font(fontname = "Liberation Sans", part = "body")

  # R Markdown with pdflatex
  knitr::opts_knit$set("quarto.version" = NULL)
  latex_str <- flextable:::gen_raw_latex(ft, quarto = FALSE)
  expect_no_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)

  knitr::opts_knit$set("rmarkdown.pandoc.args" = c("--pdf-engine", "xelatex"))
  latex_str <- flextable:::gen_raw_latex(ft, quarto = FALSE)
  expect_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)
  knitr::opts_knit$set("rmarkdown.pandoc.args" = NULL)

  # quarto
  knitr::opts_knit$set("quarto.version" = numeric_version("1.0"))
  latex_str <- flextable:::gen_raw_latex(ft, quarto = TRUE)
  expect_match(latex_str, regexp = "Liberation Sans", fixed = TRUE)
})
