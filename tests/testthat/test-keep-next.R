context("check keep with next")

skip_on_cran()
skip_if_not_installed("doconv")
library(doconv)
skip_if_not(doconv::msoffice_available())
skip_if_not(pandoc_version() >= numeric_version("2"))

init_flextable_defaults()

iris_sum <- summarizor(iris, by = "Species")
ft_1 <- as_flextable(iris_sum)
ft_1 <- set_caption(ft_1, "a caption")

test_that("docx-keep-with-next", {
  local_edition(3)

  docx <- read_docx()
  docx <- body_add_par(docx, value = "a text")
  docx <- body_add_flextable(docx, ft_1, keepnext = FALSE)
  docx <- body_add_flextable(docx, ft_1, keepnext = FALSE)

  expect_snapshot_doc(name = "docx-keep-with-next-false", x = docx, engine = "testthat")

  docx <- read_docx()
  docx <- body_add_par(docx, value = "a text")
  docx <- body_add_flextable(docx, ft_1, keepnext = TRUE)
  docx <- body_add_flextable(docx, ft_1, keepnext = TRUE)

  expect_snapshot_doc(name = "docx-keep-with-next-true", x = docx, engine = "testthat")
})


rmd_file_0 <- "rmd/captions.Rmd"
if (!file.exists(rmd_file_0)) {#just for dev purpose
  rmd_file_0 <- "tests/testthat/rmd/captions.Rmd"
}
rmd_file <- tempfile(fileext = ".Rmd")
file.copy(rmd_file_0, rmd_file, overwrite = TRUE)

test_that("rdocx_document and keep-with-next", {
  local_edition(3)
  require(doconv)
  rmd_file <- tempfile(fileext = ".Rmd")
  outfile <- tempfile(fileext = ".docx")
  file.copy("rmd/keep-next.Rmd", rmd_file)
  render(rmd_file, output_file = outfile, output_format = "officedown::rdocx_document", envir = new.env(), quiet = TRUE)
  expect_snapshot_doc(x = outfile, name = "rdocx_document", engine = "testthat")
  outfile <- tempfile(fileext = ".docx")
  render(rmd_file, output_format = "word_document", output_file = outfile, envir = new.env(), quiet = TRUE)
  expect_snapshot_doc(x = outfile, name = "word_document", engine = "testthat")
})

init_flextable_defaults()
