context("check images")

library(xml2)
library(officer)

data <- iris[c(1:3, 51:53, 101:104),]
col_keys <- c("Species", "sep_1", "Sepal.Length", "Sepal.Width", "sep_2",  "Petal.Length", "Petal.Width" )
img.file <- file.path( Sys.getenv("R_HOME"), "doc", "html", "logo.jpg" )
file.copy(img.file, "rlogo.jpg")

test_that("images", {
  ft <- flextable(data, col_keys = col_keys )
  ft <- display( ft, col_key = "Sepal.Length",
                 pattern = "blah blah {{r_logo}} {{Sepal.Length}}",
                 formatters = list(
                   r_logo ~ as_image(Sepal.Length, src = "rlogo.jpg", width = .20, height = .15),
                   Sepal.Length ~ sprintf("val: %.1f", Sepal.Length) ),
                 fprops = list(Sepal.Length = fp_text(color = "orange", vertical.align = "superscript"))
  )
  ft <- display( ft, col_key = "sep_1",
                 pattern = " {{r_logo}}",
                 formatters = list(
                   r_logo ~ as_image(Sepal.Length,
                                     src = "rlogo.jpg", width = .20, height = .15) )
  )
  ft <- display( ft, col_key = "Petal.Length",
                 pattern = "blah blah {{Sepal.Length}}",
                 formatters = list(Sepal.Length ~ sprintf("val: %.1f", Sepal.Length) ),
                 fprops = list(Sepal.Length = fp_text(color = "orange", vertical.align = "superscript") )
  )
  ft <- style(ft, pr_c = fp_cell(margin = 0, border = fp_border(width = 0) ),
              pr_p = fp_par(padding = 0, border = fp_border(width = 0) ),
              pr_t = fp_text(font.size = 10), part = "all" )
  ft <- autofit(ft, add_w = 0, add_h = 0)

  dims <- ft$body$colwidths
  dim_all <- setNames(dims["Sepal.Length"], NULL)
  dim_composite <- setNames((dims["sep_1"] + dims["Petal.Length"]), NULL)
  expect_equal( dim_all, dim_composite, tolerance = .002)


  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = ft)
  expect_error({
    print(doc, target = docx_file)
  }, NA)

})

unlink("rlogo.jpg")
