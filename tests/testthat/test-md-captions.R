context("check markdown captions")

library(rmarkdown)
library(xml2)
library(officer)

skip_on_cran()
skip_on_os("linux")
skip_on_os("solaris")

skip_if_not_installed("doconv")
skip_if_not_installed("magick")
skip_if_not_installed("webshot")
skip_if_not(locatexec::exec_available("word"))
skip_if_not(pandoc_version() >= numeric_version("2"))

to_image_script <- "to-img.R"
if (!file.exists(to_image_script)) {#just for dev purpose
  to_image_script <- "tests/testthat/to-img.R"
}
source(to_image_script)


init_flextable_defaults()

get_output_file <- function(rmd){
  basen <- tools::file_path_sans_ext(basename(rmd))
  list.files(path = dirname(rmd), pattern = paste0(basen, ".(html|pdf|docx|pptx)$"),
             full.names = TRUE)
}

test_that("rmarkdown caption", {
  local_edition(3)

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/rmarkdown.Rmd", rmd_file)
  render(rmd_file, output_format = rmarkdown::pdf_document(latex_engine = "xelatex"),
         envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "rmarkdown_pdf_document", get_output_file(rmd_file), format = "pdf")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/rmarkdown.Rmd", rmd_file)
  render(rmd_file, output_format = "rmarkdown::word_document", envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "rmarkdown_word_document", get_output_file(rmd_file), format = "docx")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/rmarkdown.Rmd", rmd_file)
  render(rmd_file, output_format = "rmarkdown::html_document", envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "rmarkdown_html_document", get_output_file(rmd_file), format = "html")
})

test_that("bookdown caption", {
  local_edition(3)

  skip_if_not_installed("bookdown")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/bookdown.Rmd", rmd_file)
  render(rmd_file, output_format = bookdown::pdf_document2(latex_engine = "xelatex"),
         envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "bookdown_pdf_document2", get_output_file(rmd_file), format = "pdf")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/bookdown.Rmd", rmd_file)
  render(rmd_file, output_format = "bookdown::word_document2", envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "bookdown_word_document2", get_output_file(rmd_file), format = "docx")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/bookdown.Rmd", rmd_file)
  render(rmd_file, output_format = "bookdown::html_document2", envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "bookdown_html_document2", get_output_file(rmd_file), format = "html")
})

test_that("rdocx caption", {
  local_edition(3)

  skip_if_not_installed("bookdown")
  skip_if_not_installed("officedown")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/bookdown.Rmd", rmd_file)
  render(rmd_file, output_format = bookdown::markdown_document2(base_format = "officedown::rdocx_document"),
         envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "officedown_word_document2", get_output_file(rmd_file), format = "docx")
})


init_flextable_defaults()
