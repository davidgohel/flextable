context("check keep with next")

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

zzzzz_script <- "zzzzz.R"
if (!file.exists(zzzzz_script)) {#just for dev purpose
  zzzzz_script <- "tests/testthat/zzzzz.R"
}
source(zzzzz_script)

init_flextable_defaults()

ft_1 <- qflextable(head(cars, n = 20))

test_that("docx-keep-with-next", {
  local_edition(3)

  docx <- read_docx()
  docx <- body_add_par(docx, value = "a text")
  docx <- body_add_flextable(docx, ft_1, keepnext = FALSE)
  docx <- body_add_flextable(docx, ft_1, keepnext = FALSE)

  expect_snapshot_rdocx(name = "docx-keep-with-next-false", docx)

  docx <- read_docx()
  docx <- body_add_par(docx, value = "a text")
  docx <- body_add_flextable(docx, ft_1, keepnext = TRUE)
  docx <- body_add_flextable(docx, ft_1, keepnext = TRUE)

  expect_snapshot_rdocx(name = "docx-keep-with-next-true", docx)
})


rmd_file_0 <- "rmd/captions.Rmd"
if (!file.exists(rmd_file_0)) {#just for dev purpose
  rmd_file_0 <- "tests/testthat/rmd/captions.Rmd"
}
rmd_file <- tempfile(fileext = ".Rmd")
file.copy(rmd_file_0, rmd_file, overwrite = TRUE)

test_that("rdocx_document and keep-with-next", {
  local_edition(3)

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/keep-next.Rmd", rmd_file)
  render(rmd_file, output_format = "officedown::rdocx_document", envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "rdocx_document", get_output_file(rmd_file), format = "docx")
  render(rmd_file, output_format = "word_document", envir = new.env(), quiet = TRUE)
  expect_snapshot_rmd(name = "word_document", get_output_file(rmd_file), format = "docx")
})

init_flextable_defaults()
