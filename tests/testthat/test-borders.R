context("check borders rendering")

init_flextable_defaults()

set.seed(2)

USUBJID <- sprintf("01-ABC-%04.0f", 1:200)
VISITS <- c("SCREENING 1", "WEEK 2", "MONTH 3")
LBTEST <- c("Albumin", "Sodium")
VISITNUM <- seq_along(VISITS)
LBBLFL <- rep(NA_character_, length(VISITNUM))
LBBLFL[1] <- "Y"

VISIT <- data.frame(VISIT = VISITS, VISITNUM = VISITNUM, LBBLFL = LBBLFL, stringsAsFactors = FALSE)
labdata <- expand.grid(USUBJID = USUBJID, LBTEST = LBTEST, VISITNUM = VISITNUM, stringsAsFactors = FALSE)
setDT(labdata)
labdata <- merge(labdata, VISIT, by = "VISITNUM")
labdata[, c("LBNRIND") := list(sample(x = c("LOW", "NORMAL", "HIGH"), size = .N, replace = TRUE, prob = c(.03, .9, .07)))]
setDF(labdata)

SHIFT_TABLE <- shift_table(
  x = labdata, cn_visit = "VISIT", cn_grade = "LBNRIND", cn_usubjid = "USUBJID",
  cn_lab_cat = "LBTEST", cn_is_baseline = "LBBLFL", baseline_identifier = "Y", grade_levels = c("LOW", "NORMAL", "HIGH")
)

SHIFT_TABLE_VISIT <- attr(SHIFT_TABLE, "VISIT_N")
SHIFT_TABLE$VISIT <- attr(SHIFT_TABLE, "FUN_VISIT")(SHIFT_TABLE$VISIT)
SHIFT_TABLE$BASELINE <- attr(SHIFT_TABLE, "FUN_GRADE")(SHIFT_TABLE$BASELINE)
SHIFT_TABLE$LBNRIND <- attr(SHIFT_TABLE, "FUN_GRADE")(SHIFT_TABLE$LBNRIND)
SHIFT_TABLE_VISIT$VISIT <- attr(SHIFT_TABLE, "FUN_VISIT")(SHIFT_TABLE_VISIT$VISIT)


tab <- tabulator(
  x = SHIFT_TABLE,
  hidden_data = SHIFT_TABLE_VISIT,
  row_compose = list(
    VISIT = as_paragraph(VISIT, "\n(N=", N_VISIT, ")")
  ),
  rows = c("LBTEST", "VISIT", "BASELINE"), columns = c("LBNRIND"),
  `n` = as_paragraph(N),
  `%` = as_paragraph(as_chunk(PCT, formatter = function(z) {
    formatC(z * 100, digits = 1, format = "f", flag = "0", width = 4)
  }))
)

ft_1 <- as_flextable(x = tab, separate_with = "VISIT", label_rows = c(LBTEST = "Lab Test", VISIT = "Visit", BASELINE = "Reference\nRange\nIndicator"))
ft_1 <- width(ft_1, j = 3, width = 1)

test_that("pptx borders", {
  skip_if_not_local_testing()
  doconv::expect_snapshot_doc(
    x = save_as_pptx(ft_1, path = tempfile(fileext = ".pptx")),
    name = "pptx-borders", engine = "testthat"
  )
})

test_that("docx borders", {
  skip_if_not_local_testing()
  doconv::expect_snapshot_doc(
    x = save_as_docx(ft_1, path = tempfile(fileext = ".docx")),
    name = "docx-borders", engine = "testthat"
  )
})

test_that("html borders", {
  skip_if_not_local_testing(check_html = TRUE)
  path <- save_as_html(ft_1, path = tempfile(fileext = ".html"))
  skip_if_not_installed("chromote")
  suppressMessages(is_there_chrome <- chromote::find_chrome())
  skip_if(is.null(is_there_chrome))
  doconv::expect_snapshot_html(name = "html-borders", path, engine = "testthat")
})


rmd_file_0 <- "rmd/borders.Rmd"
if (!file.exists(rmd_file_0)) { # just for dev purpose
  rmd_file_0 <- "tests/testthat/rmd/borders.Rmd"
}
rmd_file <- tempfile(fileext = ".Rmd")
file.copy(rmd_file_0, rmd_file, overwrite = TRUE)

html_file <- gsub("\\.Rmd$", ".html", rmd_file)
docx_file <- gsub("\\.Rmd$", ".docx", rmd_file)
pdf_file <- gsub("\\.Rmd$", ".pdf", rmd_file)
pptx_file <- gsub("\\.Rmd$", ".pptx", rmd_file)

test_that("pdf complex borders", {
  skip_if_not_local_testing(min_pandoc_version = "2.7.3")
  # skip_if_not_installed("rmarkdown") # in imports surely installed during tests
  # skip_if_not(pandoc_available()) # I guess this is in pandoc_version()
  # skip_if_not(pandoc_version() > numeric_version("2.7.3"))
  render(rmd_file,
    output_format = rmarkdown::pdf_document(latex_engine = "xelatex"),
    output_file = pdf_file,
    envir = new.env(),
    quiet = TRUE
  )
  skip_if_not_installed("doconv")
  doconv::expect_snapshot_doc(name = "pdf-complex-borders", pdf_file, engine = "testthat")
})

test_that("office complex borders", {
  skip_if_not_local_testing(min_pandoc_version = "2.7.3")
  render(rmd_file,
    output_format = word_document(),
    output_file = docx_file,
    envir = new.env(),
    quiet = TRUE
  )
  doconv::expect_snapshot_doc(name = "docx-complex-borders", docx_file, engine = "testthat")
  render(rmd_file,
    output_format = powerpoint_presentation(),
    output_file = pptx_file,
    envir = new.env(),
    quiet = TRUE
  )
  doconv::expect_snapshot_doc(name = "pptx-complex-borders", pptx_file, engine = "testthat")
})


init_flextable_defaults()
