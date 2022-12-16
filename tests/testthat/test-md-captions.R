context("check markdown captions")

skip_on_cran()
skip_if_not_installed("doconv")
library(doconv)
skip_if_not(doconv::msoffice_available())
skip_if_not(pandoc_version() >= numeric_version("2"))
skip_if_not_installed("webshot2")

library(rmarkdown)
library(xml2)
library(officer)

init_flextable_defaults()

test_that("rmarkdown caption", {
  local_edition(3)

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/rmarkdown.Rmd", rmd_file)
  outfile <- tempfile(fileext = ".pdf")
  render(rmd_file, output_file = outfile, output_format = rmarkdown::pdf_document(latex_engine = "xelatex"),
         envir = new.env(), quiet = TRUE)
  expect_snapshot_doc(x = outfile, name = "rmarkdown_pdf_document", engine = "testthat")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/rmarkdown.Rmd", rmd_file)
  outfile <- tempfile(fileext = ".docx")
  render(
    input = rmd_file,
    output_format = "rmarkdown::word_document",
    output_file = outfile,
    envir = new.env(), quiet = TRUE)
  expect_snapshot_doc(name = "rmarkdown_word_document", x = outfile, engine = "testthat")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/rmarkdown.Rmd", rmd_file)
  outfile <- tempfile(fileext = ".html")
  render(rmd_file, output_format = "rmarkdown::html_document", output_file = outfile, envir = new.env(), quiet = TRUE)
  expect_snapshot_html(name = "rmarkdown_html_document", outfile, engine = "testthat",
                       zoom = 3, expand = 10)
})

test_that("bookdown caption", {
  local_edition(3)

  skip_if_not_installed("bookdown")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/bookdown.Rmd", rmd_file)
  outfile <- tempfile(fileext = ".pdf")
  render(rmd_file, output_file = outfile, output_format = bookdown::pdf_document2(latex_engine = "xelatex"),
         envir = new.env(), quiet = TRUE)
  expect_snapshot_doc(x = outfile, name = "bookdown_pdf_document2", engine = "testthat")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/bookdown.Rmd", rmd_file)
  outfile <- tempfile(fileext = ".docx")
  render(
    input = rmd_file,
    output_format = "bookdown::word_document2",
    output_file = outfile,
    envir = new.env(), quiet = TRUE)
  expect_snapshot_doc(name = "bookdown_word_document2", x = outfile, engine = "testthat")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/bookdown.Rmd", rmd_file)
  outfile <- tempfile(fileext = ".html")
  render(rmd_file, output_format = "bookdown::html_document2", output_file = outfile, envir = new.env(), quiet = TRUE)
  expect_snapshot_html(name = "bookdown_html_document2", outfile, engine = "testthat",
                       zoom = 3, expand = 10)
})

test_that("rdocx caption", {
  local_edition(3)

  skip_if_not_installed("bookdown")
  skip_if_not_installed("officedown")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/bookdown.Rmd", rmd_file)
  outfile <- tempfile(fileext = ".docx")
  render(
    input = rmd_file,
    output_format = bookdown::markdown_document2(base_format = "officedown::rdocx_document"),
    output_file = outfile,
    envir = new.env(), quiet = TRUE)
  expect_snapshot_doc(name = "officedown_word_document2", x = outfile, engine = "testthat")
})


init_flextable_defaults()
