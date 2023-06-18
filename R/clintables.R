c_if <- function(...) {
  by <- c(...)
  by <- Filter(function(z) !is.null(z), by)
  by <- na.omit(by)
  as.character(by)
}


full_shift_structure <- function(x, cn_is_baseline, baseline_identifier,
                                 cn_treatment, cn_lab_cat, cn_visit,
                                 cn_baseline, cn_grade,
                                 grade_levels) {
  DAT_UCAT <- as.data.table(x)
  DAT_UCAT <- DAT_UCAT[!DAT_UCAT[[cn_is_baseline]] %in% baseline_identifier, ]
  DAT_UCAT <- DAT_UCAT[, .SD, .SDcols = c_if(cn_treatment, cn_lab_cat, cn_visit)]
  DAT_UCAT <- unique(DAT_UCAT)
  DAT_UCAT$DUMMY_JOIN <- 1L

  RANGE_LEVELS_BASELINE <- c(grade_levels, "MISSING", "SUM")
  RANGE_LEVELS_SHIFT <- c(grade_levels, "MISSING")
  DAT_UBS <- expand.grid(
    X = RANGE_LEVELS_BASELINE,
    Y = RANGE_LEVELS_SHIFT,
    stringsAsFactors = FALSE)
  names(DAT_UBS) <- c(cn_baseline, cn_grade)
  DAT_UBS$DUMMY_JOIN <- 1L

  PIVOT_DATA <- merge(x = DAT_UCAT, y = DAT_UBS, by = "DUMMY_JOIN",
                      allow.cartesian = TRUE,
                      all.x = TRUE, all.y = TRUE)
  PIVOT_DATA$DUMMY_JOIN <- NULL
  setorderv(PIVOT_DATA, cols = c_if(cn_treatment, cn_lab_cat, cn_visit, cn_baseline, cn_grade))
  setDF(PIVOT_DATA)
  PIVOT_DATA
}

pivot_baseline <- function(x, cn_is_baseline, baseline_identifier, cn_visit, cn_usubjid, cn_grade, cn_lab_cat, cn_treatment, cn_baseline){

  BASELINE <- as.data.table(x)
  BASELINE <- BASELINE[BASELINE[[cn_is_baseline]] %in% baseline_identifier, ]
  BASELINE <- BASELINE[, .SD, .SDcols = c_if(cn_usubjid, cn_grade, cn_lab_cat, cn_treatment)]
  setnames(BASELINE, old = cn_grade, new = cn_baseline)

  DATAMART <- as.data.table(x)
  DATAMART <- DATAMART[!DATAMART[[cn_is_baseline]] %in% baseline_identifier, ]
  DATAMART <- DATAMART[, .SD, .SDcols = c_if(cn_usubjid, cn_visit, cn_grade, cn_lab_cat, cn_treatment)]
  DATAMART <- merge(DATAMART, BASELINE, by = c_if(cn_lab_cat, cn_treatment, cn_usubjid))
  setDF(DATAMART)
  DATAMART
}

#' @importFrom rlang new_function pairlist2
facfun_visit <- function(x, cn_visit = "VISIT", cn_visit_num = "VISITNUM"){
  LEV_VISIT <- as.data.table(x)
  LEV_VISIT <- LEV_VISIT[, .SD, .SDcols = c(cn_visit, cn_visit_num)]
  LEV_VISIT <- unique(LEV_VISIT)
  setorderv(LEV_VISIT, cols = cn_visit_num)

  levels_visit <- LEV_VISIT$VISIT

  ## function creation
  visit_as_factor <- new_function(
    pairlist2(x = , levels = levels_visit),
    quote(factor(x, levels = levels))
  )
  visit_as_factor
}

facfun_grade <- function(x, grade_levels = c("LOW", "NORMAL", "HIGH"), grade_labels = grade_levels){
  new_function(
    # categories "MISSING" and "SUM" are added
    pairlist2(
      x = ,
      levels = c(grade_levels, "MISSING", "SUM"),
      labels = c(grade_labels, "Missing", "Sum")
    ),
    quote(factor(x, levels = levels, labels = labels))
  )
}

#' @export
#' @title Create a shift table
#' @description Create a shift table ready to be used with `tabulator()`.
#'
#' The function is transforming a dataset representing some
#' 'Laboratory Tests Results' structured as *CDISC clinical trial
#' data sets* format to a dataset representing the shift table.
#'
#' Shift tables are tables used in clinical trial analysis.
#' They show the progression of change from the baseline, with the progression
#' often being along time; the number of subjects is displayed in different
#' range (e.g. low, normal, or high) at baseline and at selected time points
#' or intervals.
#' @param x Laboratory Tests Results data frame.
#' @param cn_visit column name containing visit names, default to "VISIT".
#' @param cn_visit_num column name containing visit numbers, default to "VISITNUM".
#' @param cn_grade column name containing reference range indicators, default to "LBNRIND".
#' @param cn_usubjid column name containing unique subject inditifiers, default to "USUBJID".
#' @param cn_lab_cat column name containing lab tests or examination names, default to "LBTEST".
#' @param cn_is_baseline column name containing baseline flags, default to "LBBLFL".
#' @param baseline_identifier baseline flag value to use for baseline
#' identification. Its default is "Y".
#' @param cn_treatment column name containing treatment names, default to `NA`.
#' @param grade_levels levels to use for reference range indicators
#' @param grade_labels labels to use for reference range indicators
#' @family tools for clinical reporting
#' @return the shift table as a data.frame. Additionnal elements are provided
#' in attributes:
#'
#' - "VISIT_N": count of unique subject id per visits, labs and eventually
#' treatments. This element is supposed to be used as value for argument
#' `hidden_data` of function `tabulator()`.
#' - "FUN_VISIT": a utility function to easily turn *visit* column as a factor
#' column. It should be applied after the shift table creation.
#' - "FUN_GRADE": a utility function to easily turn *grade* column as a factor
#' column. It adds "MISSING/Missing" and "SUM/Sum" at the end of the set of values specified
#' in arguments `grade_levels` and `grade_labels`. It should be applied after the shift
#' table creation.
#' @examples
#' \dontrun{
#' library(data.table)
#' library(flextable)
#'
#' # data simulation ----
#' USUBJID <- sprintf("01-ABC-%04.0f", 1:200)
#' VISITS <- c("SCREENING 1", "WEEK 2", "MONTH 3")
#' LBTEST <- c("Albumin", "Sodium")
#'
#' VISITNUM <- seq_along(VISITS)
#' LBBLFL <- rep(NA_character_, length(VISITNUM))
#' LBBLFL[1] <- "Y"
#'
#' VISIT <- data.frame(VISIT = VISITS, VISITNUM = VISITNUM,
#'   LBBLFL = LBBLFL, stringsAsFactors = FALSE)
#' labdata <- expand.grid(USUBJID = USUBJID,  LBTEST = LBTEST,
#'                     VISITNUM = VISITNUM,
#'                     stringsAsFactors = FALSE)
#' setDT(labdata)
#'
#' labdata <- merge(labdata, VISIT, by = "VISITNUM")
#'
#' subject_elts <- unique(labdata[, .SD, .SDcols = "USUBJID"])
#' subject_elts <- unique(subject_elts)
#' subject_elts[, c("TREAT") := list(
#'   sample(x = c("Treatment", "Placebo"), size = .N, replace = TRUE))]
#' subject_elts[, c("TREAT"):= list(
#'   factor(.SD$TREAT, levels = c("Treatment", "Placebo")))]
#' setDF(subject_elts)
#' labdata <- merge(labdata, subject_elts,
#'   by = "USUBJID", all.x = TRUE, all.y = FALSE)
#' labdata[, c("LBNRIND"):= list(
#'   sample(x = c("LOW", "NORMAL", "HIGH"), size = .N,
#'          replace = TRUE, prob = c(.03, .9, .07)))]
#'
#' setDF(labdata)
#'
#'
#'
#'
#' # shift table calculation ----
#'
#' SHIFT_TABLE <- shift_table(
#'   x = labdata, cn_visit = "VISIT",
#'   cn_grade = "LBNRIND",
#'   cn_usubjid = "USUBJID",
#'   cn_lab_cat = "LBTEST",
#'   cn_treatment = "TREAT",
#'   cn_is_baseline = "LBBLFL",
#'   baseline_identifier = "Y",
#'   grade_levels = c("LOW", "NORMAL", "HIGH"))
#'
#' # get attrs for post treatment ----
#' SHIFT_TABLE_VISIT <- attr(SHIFT_TABLE, "VISIT_N")
#' visit_as_factor <- attr(SHIFT_TABLE, "FUN_VISIT")
#' range_as_factor <- attr(SHIFT_TABLE, "FUN_GRADE")
#'
#' # post treatments ----
#' SHIFT_TABLE$VISIT = visit_as_factor(SHIFT_TABLE$VISIT)
#' SHIFT_TABLE$BASELINE = range_as_factor(SHIFT_TABLE$BASELINE)
#' SHIFT_TABLE$LBNRIND = range_as_factor(SHIFT_TABLE$LBNRIND)
#'
#' SHIFT_TABLE_VISIT$VISIT = visit_as_factor(SHIFT_TABLE_VISIT$VISIT)
#'
#' # tabulator ----
#'
#' my_format <- function(z) {
#'   formatC(z * 100, digits = 1, format = "f",
#'           flag = "0", width = 4)
#' }
#'
#' tab <- tabulator(
#'   x = SHIFT_TABLE,
#'   hidden_data = SHIFT_TABLE_VISIT,
#'   row_compose = list(
#'     VISIT = as_paragraph(VISIT, "\n(N=", N_VISIT, ")")
#'   ),
#'   rows = c("LBTEST", "VISIT", "BASELINE"),
#'   columns = c("TREAT", "LBNRIND"),
#'   `n` = as_paragraph(N),
#'   `%` = as_paragraph(as_chunk(PCT, formatter = my_format))
#' )
#'
#' # as_flextable ----
#'
#' ft_1 <- as_flextable(
#'   x = tab, separate_with = "VISIT",
#'   label_rows = c(LBTEST = "Lab Test", VISIT = "Visit",
#'                  BASELINE = "Reference Range Indicator"))
#'
#' ft_1
#' }
shift_table <- function(
    x,
    cn_visit = "VISIT", cn_visit_num = "VISITNUM", cn_grade = "LBNRIND",
    cn_usubjid = "USUBJID", cn_lab_cat = NA_character_, cn_is_baseline = "LBBLFL",
    baseline_identifier = "Y", cn_treatment = NA_character_,
    grade_levels = c("LOW", "NORMAL", "HIGH"),
    grade_labels = c("Low", "Normal", "High")
    ) {

  cn_baseline <- "BASELINE"

  PIVOT_DATA <- full_shift_structure(
    x = x, cn_is_baseline = cn_is_baseline, baseline_identifier = baseline_identifier,
    cn_treatment = cn_treatment, cn_lab_cat = cn_lab_cat,
    cn_visit = cn_visit,
    cn_baseline = cn_baseline,
    cn_grade = cn_grade,
    grade_levels = grade_levels
  )

  DATAMART <- pivot_baseline(
    x = x, cn_is_baseline = cn_is_baseline, baseline_identifier = baseline_identifier,
    cn_visit = cn_visit,
    cn_usubjid = cn_usubjid,
    cn_grade = cn_grade,
    cn_treatment = cn_treatment, cn_lab_cat = cn_lab_cat,
    cn_baseline = cn_baseline)

  SHIFT_TABLE_VISIT <- as.data.table(DATAMART)
  by <- c_if(cn_lab_cat, cn_treatment, cn_visit)
  SHIFT_TABLE_VISIT <- SHIFT_TABLE_VISIT[, list(N_VISIT = length(.SD[[cn_usubjid]])), by = by]
  setDF(SHIFT_TABLE_VISIT)

  SHIFT_TABLE_CT <- as.data.table(DATAMART)
  by <- c_if(cn_treatment, cn_lab_cat, cn_visit, cn_baseline, cn_grade)
  SHIFT_TABLE_CT <- SHIFT_TABLE_CT[, list(N = .N), by = by]
  setDF(SHIFT_TABLE_CT)

  SHIFT_TABLE_DETAIL <- as.data.table(SHIFT_TABLE_CT)
  by <- c_if(cn_treatment, cn_lab_cat, cn_visit)
  SHIFT_TABLE_DETAIL[, c("PCT") := list(.SD[["N"]] / sum(.SD[["N"]], na.rm = TRUE)), by = by]

  SHIFT_TABLE_SUM <- as.data.table(SHIFT_TABLE_CT)
  by <- c_if(cn_treatment, cn_lab_cat, cn_visit, cn_grade)
  SHIFT_TABLE_SUM <- SHIFT_TABLE_SUM[, list(N = sum(.SD[["N"]], na.rm = TRUE)), by = by]
  by <- c_if(cn_treatment, cn_lab_cat, cn_visit)
  SHIFT_TABLE_SUM[, c("PCT") := list(.SD[["N"]] / sum(.SD[["N"]], na.rm = TRUE)), by = by]
  SHIFT_TABLE_SUM[[cn_baseline]] <- "SUM"

  replct <- list("MISSING", "MISSING", N = 0L, PCT = 0.0)
  names(replct) <- c(cn_baseline, cn_grade, 'N', 'PCT')

  SHIFT_TABLE <- rbind(SHIFT_TABLE_DETAIL, SHIFT_TABLE_SUM)
  setDF(SHIFT_TABLE_DETAIL)
  setDF(SHIFT_TABLE_SUM)
  for(j in names(replct)) {
    set(SHIFT_TABLE, i = which(is.na(SHIFT_TABLE[[j]])), j = j, value = replct[[j]])
  }

  setDT(PIVOT_DATA)
  by <- c_if(cn_treatment, cn_lab_cat, cn_visit, cn_baseline, cn_grade)
  SHIFT_TABLE <- merge(PIVOT_DATA, SHIFT_TABLE,
                       by = by, all.x = TRUE, all.y = TRUE)
  for(j in names(replct)) {
    set(SHIFT_TABLE, i = which(is.na(SHIFT_TABLE[[j]])), j = j, value = replct[[j]])
  }

  setDF(SHIFT_TABLE)

  attr(SHIFT_TABLE, "VISIT_N") <- SHIFT_TABLE_VISIT
  attr(SHIFT_TABLE, "FUN_VISIT") <- facfun_visit(x, cn_visit = cn_visit, cn_visit_num = cn_visit_num)
  attr(SHIFT_TABLE, "FUN_GRADE") <- facfun_grade(x, grade_levels = grade_levels, grade_labels = grade_labels)
  SHIFT_TABLE
}

