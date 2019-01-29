context("check images")

library(xml2)
library(officer)

data <- iris[c(1:3, 51:53, 101:104),]
col_keys <- c("Species", "sep_1", "Sepal.Length", "Sepal.Width", "sep_2",  "Petal.Length", "Petal.Width" )
img.file <- file.path( R.home("doc"), "html", "logo.jpg" )
file.copy(img.file, "rlogo.jpg")

test_that("images", {
  ft <- flextable(data, col_keys = col_keys )
  ft <- define_text( ft, j = "Sepal.Length",
                     value = as_paragraph(
                       as_chunk("blah blah "),
                       as_image("rlogo.jpg", width = .3, height = 0.23), " ",
                       as_chunk(sprintf("val: %.1f", Sepal.Length), props = fp_text(color = "orange", vertical.align = "superscript") )
                       )
  )
  ft <- define_text( ft, j = "sep_1",
                     value = as_paragraph(
                       as_image("rlogo.jpg", width = .3, height = 0.23))
                     )
  ft <- define_text( ft, j = "Petal.Length",
                     value = as_paragraph(
                       "blah blah ",
                       as_chunk(Sepal.Length, props = fp_text(color = "orange", vertical.align = "superscript") ))
                     )
  ft <- style(ft, pr_c = fp_cell(margin = 0, border = fp_border(width = 0) ),
              pr_p = fp_par(padding = 0, border = fp_border(width = 0) ),
              pr_t = fp_text(font.size = 10), part = "all" )
  ft <- autofit(ft, add_w = 0, add_h = 0)
  autofit(ft)$body$colwidths

  dims <- ft$body$colwidths
  expect_equal( as.vector(dims["sep_1"]), .3, tolerance = .00001)


  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = ft)
  expect_error({
    print(doc, target = docx_file)
  }, NA)

})

unlink("rlogo.jpg")
