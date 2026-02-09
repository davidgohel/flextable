init_flextable_defaults()

library(data.table)

set.seed(42)

USUBJID <- sprintf("01-ABC-%04.0f", 1:50)
VISITS <- c("SCREENING 1", "WEEK 2", "MONTH 3")
LBTEST <- c("Albumin", "Sodium")
VISITNUM <- seq_along(VISITS)
LBBLFL <- rep(NA_character_, length(VISITNUM))
LBBLFL[1] <- "Y"

VISIT <- data.frame(
  VISIT = VISITS, VISITNUM = VISITNUM,
  LBBLFL = LBBLFL, stringsAsFactors = FALSE
)
labdata <- expand.grid(
  USUBJID = USUBJID, LBTEST = LBTEST,
  VISITNUM = VISITNUM, stringsAsFactors = FALSE
)
setDT(labdata)
labdata <- merge(labdata, VISIT, by = "VISITNUM")
labdata[, c("LBNRIND") := list(
  sample(
    x = c("LOW", "NORMAL", "HIGH"), size = .N,
    replace = TRUE, prob = c(.03, .9, .07)
  )
)]
setDF(labdata)

test_that("shift_table without treatment", {
  st <- shift_table(
    x = labdata, cn_visit = "VISIT",
    cn_grade = "LBNRIND", cn_usubjid = "USUBJID",
    cn_lab_cat = "LBTEST", cn_is_baseline = "LBBLFL",
    baseline_identifier = "Y",
    grade_levels = c("LOW", "NORMAL", "HIGH")
  )

  expect_s3_class(st, "data.frame")
  expect_true("BASELINE" %in% names(st))
  expect_true("N" %in% names(st))
  expect_true("PCT" %in% names(st))

  # attributes
  visit_n <- attr(st, "VISIT_N")
  expect_s3_class(visit_n, "data.frame")
  expect_true("N_VISIT" %in% names(visit_n))

  fun_visit <- attr(st, "FUN_VISIT")
  fun_grade <- attr(st, "FUN_GRADE")
  expect_type(fun_visit, "closure")
  expect_type(fun_grade, "closure")

  # factor functions work
  st$VISIT <- fun_visit(st$VISIT)
  expect_s3_class(st$VISIT, "factor")
  expect_equal(levels(st$VISIT), VISITS)

  st$BASELINE <- fun_grade(st$BASELINE)
  expect_s3_class(st$BASELINE, "factor")
  expect_true("Missing" %in% levels(st$BASELINE))
  expect_true("Sum" %in% levels(st$BASELINE))

  # all PCT values between 0 and 1
  expect_true(all(st$PCT >= 0 & st$PCT <= 1))
})

test_that("shift_table with treatment", {
  subject_elts <- unique(labdata[, "USUBJID", drop = FALSE])
  subject_elts$TREAT <- sample(
    c("Treatment", "Placebo"),
    size = nrow(subject_elts), replace = TRUE
  )
  labdata_treat <- merge(labdata, subject_elts, by = "USUBJID")

  st <- shift_table(
    x = labdata_treat, cn_visit = "VISIT",
    cn_grade = "LBNRIND", cn_usubjid = "USUBJID",
    cn_lab_cat = "LBTEST", cn_treatment = "TREAT",
    cn_is_baseline = "LBBLFL",
    baseline_identifier = "Y",
    grade_levels = c("LOW", "NORMAL", "HIGH")
  )

  expect_s3_class(st, "data.frame")
  expect_true("TREAT" %in% names(st))

  visit_n <- attr(st, "VISIT_N")
  expect_true("TREAT" %in% names(visit_n))
})

test_that("shift_table works with tabulator and as_flextable", {
  st <- shift_table(
    x = labdata, cn_visit = "VISIT",
    cn_grade = "LBNRIND", cn_usubjid = "USUBJID",
    cn_lab_cat = "LBTEST", cn_is_baseline = "LBBLFL",
    baseline_identifier = "Y",
    grade_levels = c("LOW", "NORMAL", "HIGH")
  )

  visit_n <- attr(st, "VISIT_N")
  fun_visit <- attr(st, "FUN_VISIT")
  fun_grade <- attr(st, "FUN_GRADE")

  st$VISIT <- fun_visit(st$VISIT)
  st$BASELINE <- fun_grade(st$BASELINE)
  st$LBNRIND <- fun_grade(st$LBNRIND)
  visit_n$VISIT <- fun_visit(visit_n$VISIT)

  tab <- tabulator(
    x = st, hidden_data = visit_n,
    row_compose = list(
      VISIT = as_paragraph(VISIT, "\n(N=", N_VISIT, ")")
    ),
    rows = c("LBTEST", "VISIT", "BASELINE"),
    columns = "LBNRIND",
    `n` = as_paragraph(N)
  )

  ft <- as_flextable(tab, separate_with = "VISIT")
  expect_s3_class(ft, "flextable")
  expect_true(nrow_part(ft, "body") > 0)
})

test_that("shift_table with custom labels", {
  st <- shift_table(
    x = labdata, cn_visit = "VISIT",
    cn_grade = "LBNRIND", cn_usubjid = "USUBJID",
    cn_lab_cat = "LBTEST", cn_is_baseline = "LBBLFL",
    baseline_identifier = "Y",
    grade_levels = c("LOW", "NORMAL", "HIGH"),
    grade_labels = c("Bas", "Normal", "Haut")
  )

  fun_grade <- attr(st, "FUN_GRADE")
  levs <- levels(fun_grade(st$BASELINE))
  expect_equal(levs, c("Bas", "Normal", "Haut", "Missing", "Sum"))
})

init_flextable_defaults()
