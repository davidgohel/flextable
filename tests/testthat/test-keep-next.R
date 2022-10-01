context("check keep with next")

skip_on_cran()
skip_on_os("linux")
skip_on_os("solaris")

skip_if_not_installed("doconv")
skip_if_not_installed("magick")
skip_if_not_installed("webshot")
skip_if_not(locatexec::exec_available("word"))
skip_if_not(pandoc_version() >= numeric_version("2"))

source("to-img.R")
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

init_flextable_defaults()
