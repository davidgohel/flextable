context("check borders rendering")


skip_on_cran()
skip_if_not_installed("doconv")
library(doconv)
skip_if_not(doconv::msoffice_available())
skip_if_not(pandoc_version() >= numeric_version("2"))
skip_if_not_installed("webshot2")

init_flextable_defaults()

library(data.table)
set.seed(2)

USUBJID <- sprintf("01-ABC-%04.0f", 1:200)
VISITS <- c("SCREENING 1", "WEEK 2", "MONTH 3")
LBTEST <- c("Albumin", "Sodium")
VISITNUM <- seq_along(VISITS)
LBBLFL <- rep(NA_character_, length(VISITNUM))
LBBLFL[1] <- "Y"

VISIT <- data.frame(VISIT = VISITS, VISITNUM = VISITNUM, LBBLFL = LBBLFL, stringsAsFactors = FALSE)
labdata <- expand.grid(USUBJID = USUBJID,  LBTEST = LBTEST, VISITNUM = VISITNUM, stringsAsFactors = FALSE)
setDT(labdata)
labdata <- merge(labdata, VISIT, by = "VISITNUM")
labdata[, c("LBNRIND"):= list(sample(x = c("LOW", "NORMAL", "HIGH"), size = .N, replace = TRUE, prob = c(.03, .9, .07)))]
setDF(labdata)

SHIFT_TABLE <- shift_table(x = labdata, cn_visit = "VISIT", cn_grade = "LBNRIND", cn_usubjid = "USUBJID",
  cn_lab_cat = "LBTEST", cn_is_baseline = "LBBLFL", baseline_identifier = "Y", grade_levels = c("LOW", "NORMAL", "HIGH"))

SHIFT_TABLE_VISIT <- attr(SHIFT_TABLE, "VISIT_N")
SHIFT_TABLE$VISIT = attr(SHIFT_TABLE, "FUN_VISIT")(SHIFT_TABLE$VISIT)
SHIFT_TABLE$BASELINE = attr(SHIFT_TABLE, "FUN_GRADE")(SHIFT_TABLE$BASELINE)
SHIFT_TABLE$LBNRIND = attr(SHIFT_TABLE, "FUN_GRADE")(SHIFT_TABLE$LBNRIND)
SHIFT_TABLE_VISIT$VISIT = attr(SHIFT_TABLE, "FUN_VISIT")(SHIFT_TABLE_VISIT$VISIT)


tab <- tabulator(x = SHIFT_TABLE,
  hidden_data = SHIFT_TABLE_VISIT,
  row_compose = list(
    VISIT = as_paragraph(VISIT, "\n(N=", N_VISIT, ")")
  ),
  rows = c("LBTEST", "VISIT", "BASELINE"), columns = c("LBNRIND"),
  `n` = as_paragraph(N),
  `%` = as_paragraph(as_chunk(PCT, formatter = function(z) { formatC(z * 100, digits = 1, format = "f", flag = "0", width = 4) }))
)

ft_1 <- as_flextable(x = tab, separate_with = "VISIT", label_rows = c(LBTEST = "Lab Test", VISIT = "Visit", BASELINE = "Reference\nRange\nIndicator"))
ft_1 <- width(ft_1, j = 3, width = 1)

test_that("pptx borders", {
  local_edition(3)
  expect_snapshot_doc(x = save_as_pptx(ft_1, path = tempfile(fileext = ".pptx")),
                      name = "pptx-borders", engine = "testthat")
})

test_that("docx borders", {
  local_edition(3)
  expect_snapshot_doc(x = save_as_docx(ft_1, path = tempfile(fileext = ".docx")),
                      name = "docx-borders", engine = "testthat")
})

test_that("html borders", {
  local_edition(3)
  path <- save_as_html(ft_1, path = tempfile(fileext = ".html"))
  expect_snapshot_html(name = "html-borders", path, engine = "testthat")
})


init_flextable_defaults()
