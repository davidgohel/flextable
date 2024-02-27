context("check grid grob")

skip_on_cran()
skip_if_not_installed("doconv")
skip_if_not(doconv::msoffice_available())
library(doconv)
library(officer)
library(gdtools)
register_liberationsans()

init_flextable_defaults()
set_flextable_defaults(font.family = "Liberation Sans")

test_that("merged borders", {
  local_edition(3)

  dat <- data.frame(a = c(1, 1, 2, 2, 5), b = 6:10)

  ft <- flextable(dat)
  ft <- merge_v(ft, ~a, part = "body")
  ft <- hline(
    x = ft,
    i = 2, part = "body",
    border = fp_border(color = "red")
  )

  path <- save_as_image(ft, path = tempfile(fileext = ".png"), res = 150)
  expect_snapshot_doc(name = "vmerged-borders", x = path, engine = "testthat")
})

test_that("text wrapping", {
  local_edition(3)

  text <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
  source1 <- "DATA_SOURCE_A.COURSE_TITLE\nDATA_SOURCE_A.SUBJECT_DESCR\nDATA_SOURCE_A.CATALOG_NUMBER"
  source2 <- "DATA_SOURCE_A.GRADING_BASIS\nDATA_SOURCE_A.OFFICIAL_GRADE\nDATA_SOURCE_B.STUDENT_GROUP"

  temp_dat <- data.frame(
    label = c("Sources", "", "Notes"),
    col1 = c(source1, "", text),
    col2 = c(source2, "", text)
  )

  # Create table
  ft <- flextable(temp_dat)
  ft <- merge_h(ft, part = "body")

  path <- save_as_image(ft, path = tempfile(fileext = ".png"), res = 150)
  expect_snapshot_doc(name = "long-text-wrapping", x = path, engine = "testthat")
})
