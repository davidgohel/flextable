context("check as_flextable")

skip_on_cran()
skip_if_not_installed("doconv")
library(doconv)
skip_if_not(doconv::msoffice_available())
skip_if_not(pandoc_version() >= numeric_version("2"))
skip_if_not_installed("webshot2")

init_flextable_defaults()

data_co2 <-
  structure(
    list(
      Treatment = structure(c(3L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 4L, 4L),
        levels = c("nonchilled", "chilled", "zoubi", "bisou"), class = "factor"
      ),
      conc = c(85L, 95L, 175L, 250L, 350L, 500L, 675L, 1000L, 95L, 175L, 250L, 350L, 500L, 675L, 1000L, NA, 1000L),
      Quebec = c(
        12, 15.2666666666667, 30.0333333333333, 37.4, 40.3666666666667, 39.6, 41.5, 43.1666666666667,
        12.8666666666667, 24.1333333333333, 34.4666666666667, 35.8, 36.6666666666667,
        37.5, 40.8333333333333, 43, 43
      ),
      Mississippi = c(
        10, 11.3, 20.2, 27.5333333333333, 29.9, 30.6, 30.5333333333333, 31.6, 9.6, 14.7666666666667, 16.1,
        16.6, 16.6333333333333, 18.2666666666667, 18.7333333333333, 19, 19
      )
    ),
    row.names = c(NA, -17L),
    class = "data.frame"
  )
gdata <- as_grouped_data(x = data_co2, groups = c("Treatment"))

ft_1 <- as_flextable(gdata)
ft_1 <- colformat_double(ft_1, digits = 2)
ft_1 <- autofit(ft_1)

test_that("pptx grouped-data", {
  local_edition(3)
  path <- save_as_pptx(ft_1, path = tempfile(fileext = ".pptx"))
  expect_snapshot_doc(name = "pptx-grouped-data", x = path, engine = "testthat")
})

test_that("docx grouped-data", {
  local_edition(3)
  path <- save_as_docx(ft_1, path = tempfile(fileext = ".docx"))
  expect_snapshot_doc(x = path, name = "docx-grouped-data", engine = "testthat")
})

test_that("html grouped-data", {
  local_edition(3)
  path <- save_as_html(ft_1, path = tempfile(fileext = ".html"))
  expect_snapshot_html(name = "html-grouped-data", path, engine = "testthat")
})

gdata <- as_grouped_data(
  x = data_co2, groups = c("Treatment"),
  expand_single = FALSE
)

ft_2 <- as_flextable(gdata)
ft_2 <- colformat_double(ft_2, digits = 2)
ft_2 <- autofit(ft_2)

test_that("pptx grouped-data-no-single", {
  local_edition(3)
  path <- save_as_pptx(ft_2, path = tempfile(fileext = ".pptx"))
  expect_snapshot_doc(x = path, name = "pptx-grouped-data-no-single", engine = "testthat")
})

test_that("docx grouped-data-no-single", {
  local_edition(3)
  path <- save_as_docx(ft_2, path = tempfile(fileext = ".docx"))
  expect_snapshot_doc(x = path, name = "docx-grouped-data-no-single", engine = "testthat")
})

test_that("html grouped-data-no-single", {
  local_edition(3)
  path <- save_as_html(ft_2, path = tempfile(fileext = ".html"))
  expect_snapshot_html(name = "html-grouped-data-no-single", path, engine = "testthat")
})

init_flextable_defaults()
