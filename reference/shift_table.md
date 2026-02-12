# Create a shift table

Create a shift table ready to be used with
[`tabulator()`](https://davidgohel.github.io/flextable/reference/tabulator.md).

The function is transforming a dataset representing some 'Laboratory
Tests Results' structured as *CDISC clinical trial data sets* format to
a dataset representing the shift table.

Shift tables are tables used in clinical trial analysis. They show the
progression of change from the baseline, with the progression often
being along time; the number of subjects is displayed in different range
(e.g. low, normal, or high) at baseline and at selected time points or
intervals.

## Usage

``` r
shift_table(
  x,
  cn_visit = "VISIT",
  cn_visit_num = "VISITNUM",
  cn_grade = "LBNRIND",
  cn_usubjid = "USUBJID",
  cn_lab_cat = NA_character_,
  cn_is_baseline = "LBBLFL",
  baseline_identifier = "Y",
  cn_treatment = NA_character_,
  grade_levels = c("LOW", "NORMAL", "HIGH"),
  grade_labels = c("Low", "Normal", "High")
)
```

## Arguments

- x:

  Laboratory Tests Results data frame.

- cn_visit:

  column name containing visit names, default to "VISIT".

- cn_visit_num:

  column name containing visit numbers, default to "VISITNUM".

- cn_grade:

  column name containing reference range indicators, default to
  "LBNRIND".

- cn_usubjid:

  column name containing unique subject inditifiers, default to
  "USUBJID".

- cn_lab_cat:

  column name containing lab tests or examination names, default to
  "LBTEST".

- cn_is_baseline:

  column name containing baseline flags, default to "LBBLFL".

- baseline_identifier:

  baseline flag value to use for baseline identification. Its default is
  "Y".

- cn_treatment:

  column name containing treatment names, default to `NA`.

- grade_levels:

  levels to use for reference range indicators

- grade_labels:

  labels to use for reference range indicators

## Value

the shift table as a data.frame. Additionnal elements are provided in
attributes:

- "VISIT_N": count of unique subject id per visits, labs and eventually
  treatments. This element is supposed to be used as value for argument
  `hidden_data` of function
  [`tabulator()`](https://davidgohel.github.io/flextable/reference/tabulator.md).

- "FUN_VISIT": a utility function to easily turn *visit* column as a
  factor column. It should be applied after the shift table creation.

- "FUN_GRADE": a utility function to easily turn *grade* column as a
  factor column. It adds "MISSING/Missing" and "SUM/Sum" at the end of
  the set of values specified in arguments `grade_levels` and
  `grade_labels`. It should be applied after the shift table creation.

## Examples

``` r
library(data.table)
library(flextable)

# data simulation ----
USUBJID <- sprintf("01-ABC-%04.0f", 1:200)
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
  VISITNUM = VISITNUM,
  stringsAsFactors = FALSE
)
setDT(labdata)

labdata <- merge(labdata, VISIT, by = "VISITNUM")

subject_elts <- unique(labdata[, .SD, .SDcols = "USUBJID"])
subject_elts <- unique(subject_elts)
subject_elts[, c("TREAT") := list(
  sample(x = c("Treatment", "Placebo"), size = .N, replace = TRUE)
)]
#>          USUBJID     TREAT
#>           <char>    <char>
#>   1: 01-ABC-0001   Placebo
#>   2: 01-ABC-0002 Treatment
#>   3: 01-ABC-0003   Placebo
#>   4: 01-ABC-0004   Placebo
#>   5: 01-ABC-0005 Treatment
#>  ---                      
#> 196: 01-ABC-0196 Treatment
#> 197: 01-ABC-0197   Placebo
#> 198: 01-ABC-0198 Treatment
#> 199: 01-ABC-0199 Treatment
#> 200: 01-ABC-0200   Placebo
subject_elts[, c("TREAT") := list(
  factor(.SD$TREAT, levels = c("Treatment", "Placebo"))
)]
#>          USUBJID     TREAT
#>           <char>    <fctr>
#>   1: 01-ABC-0001   Placebo
#>   2: 01-ABC-0002 Treatment
#>   3: 01-ABC-0003   Placebo
#>   4: 01-ABC-0004   Placebo
#>   5: 01-ABC-0005 Treatment
#>  ---                      
#> 196: 01-ABC-0196 Treatment
#> 197: 01-ABC-0197   Placebo
#> 198: 01-ABC-0198 Treatment
#> 199: 01-ABC-0199 Treatment
#> 200: 01-ABC-0200   Placebo
setDF(subject_elts)
labdata <- merge(labdata, subject_elts,
  by = "USUBJID", all.x = TRUE, all.y = FALSE
)
labdata[, c("LBNRIND") := list(
  sample(
    x = c("LOW", "NORMAL", "HIGH"), size = .N,
    replace = TRUE, prob = c(.03, .9, .07)
  )
)]
#> Key: <USUBJID>
#>           USUBJID VISITNUM  LBTEST       VISIT LBBLFL   TREAT LBNRIND
#>            <char>    <int>  <char>      <char> <char>  <fctr>  <char>
#>    1: 01-ABC-0001        1 Albumin SCREENING 1      Y Placebo  NORMAL
#>    2: 01-ABC-0001        1  Sodium SCREENING 1      Y Placebo    HIGH
#>    3: 01-ABC-0001        2 Albumin      WEEK 2   <NA> Placebo  NORMAL
#>    4: 01-ABC-0001        2  Sodium      WEEK 2   <NA> Placebo  NORMAL
#>    5: 01-ABC-0001        3 Albumin     MONTH 3   <NA> Placebo  NORMAL
#>   ---                                                                
#> 1196: 01-ABC-0200        1  Sodium SCREENING 1      Y Placebo  NORMAL
#> 1197: 01-ABC-0200        2 Albumin      WEEK 2   <NA> Placebo  NORMAL
#> 1198: 01-ABC-0200        2  Sodium      WEEK 2   <NA> Placebo  NORMAL
#> 1199: 01-ABC-0200        3 Albumin     MONTH 3   <NA> Placebo  NORMAL
#> 1200: 01-ABC-0200        3  Sodium     MONTH 3   <NA> Placebo    HIGH

setDF(labdata)




# shift table calculation ----

SHIFT_TABLE <- shift_table(
  x = labdata, cn_visit = "VISIT",
  cn_grade = "LBNRIND",
  cn_usubjid = "USUBJID",
  cn_lab_cat = "LBTEST",
  cn_treatment = "TREAT",
  cn_is_baseline = "LBBLFL",
  baseline_identifier = "Y",
  grade_levels = c("LOW", "NORMAL", "HIGH")
)

# get attrs for post treatment ----
SHIFT_TABLE_VISIT <- attr(SHIFT_TABLE, "VISIT_N")
visit_as_factor <- attr(SHIFT_TABLE, "FUN_VISIT")
range_as_factor <- attr(SHIFT_TABLE, "FUN_GRADE")

# post treatments ----
SHIFT_TABLE$VISIT <- visit_as_factor(SHIFT_TABLE$VISIT)
SHIFT_TABLE$BASELINE <- range_as_factor(SHIFT_TABLE$BASELINE)
SHIFT_TABLE$LBNRIND <- range_as_factor(SHIFT_TABLE$LBNRIND)

SHIFT_TABLE_VISIT$VISIT <- visit_as_factor(SHIFT_TABLE_VISIT$VISIT)

# tabulator ----

my_format <- function(z) {
  formatC(z * 100,
    digits = 1, format = "f",
    flag = "0", width = 4
  )
}

tab <- tabulator(
  x = SHIFT_TABLE,
  hidden_data = SHIFT_TABLE_VISIT,
  row_compose = list(
    VISIT = as_paragraph(VISIT, "\n(N=", N_VISIT, ")")
  ),
  rows = c("LBTEST", "VISIT", "BASELINE"),
  columns = c("TREAT", "LBNRIND"),
  `n` = as_paragraph(N),
  `%` = as_paragraph(as_chunk(PCT, formatter = my_format))
)

# as_flextable ----

ft_1 <- as_flextable(
  x = tab, separate_with = "VISIT",
  label_rows = c(
    LBTEST = "Lab Test", VISIT = "Visit",
    BASELINE = "Reference Range Indicator"
  )
)

ft_1


.cl-3047f9a2{}.cl-30396c5c{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-303dfe34{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-303dfe3e{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:0;padding-top:0;padding-left:0;padding-right:0;line-height: 1;background-color:transparent;}.cl-303dfe48{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-303dfe52{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:0;padding-top:0;padding-left:0;padding-right:0;line-height: 1;background-color:transparent;}.cl-303dfe53{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-303dfe5c{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:0;padding-top:0;padding-left:0;padding-right:0;line-height: 1;background-color:transparent;}.cl-303dfe5d{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-303e3a48{width:0.915in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a52{width:0.984in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a53{width:2.303in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a5c{width:0.079in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a66{width:0.361in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a67{width:0.604in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a68{width:0.458in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a70{width:0.915in;background-color:transparent;vertical-align: bottom;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a71{width:0.984in;background-color:transparent;vertical-align: bottom;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a7a{width:2.303in;background-color:transparent;vertical-align: bottom;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a7b{width:0.361in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a7c{width:0.604in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a84{width:0.458in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a85{width:0.915in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a8e{width:0.984in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a98{width:2.303in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a99{width:0.079in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3a9a{width:0.361in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3aa2{width:0.604in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3aa3{width:0.458in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3aac{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3aad{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3aae{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ab6{width:0.079in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ab7{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ab8{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ab9{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ac0{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ac1{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ac2{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3aca{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3acb{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3acc{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ad4{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ad5{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ade{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3adf{width:0.079in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ae8{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3ae9{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3aea{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3aeb{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3af2{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3af3{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3af4{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3afc{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3afd{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3afe{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b06{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b07{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b08{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b09{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b0a{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b10{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b11{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b12{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b1a{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b1b{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b1c{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b24{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b25{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b2e{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b2f{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b30{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b38{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-303e3b39{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Lab Test
```

Visit

Reference Range Indicator

Treatment

Placebo

Low

Normal

High

Missing

Low

Normal

High

Missing

n

%

n

%

n

%

n

%

n

%

n

%

n

%

n

%

Albumin

WEEK 2  
(N=95)

Low

0

00.0

4

04.2

1

01.1

0

00.0

0

00.0

4

03.8

0

00.0

0

00.0

0

00.0

4

04.2

1

01.1

0

00.0

0

00.0

4

03.8

0

00.0

0

00.0

Normal

4

04.2

72

75.8

5

05.3

0

00.0

4

03.8

76

72.4

13

12.4

0

00.0

4

04.2

72

75.8

5

05.3

0

00.0

4

03.8

76

72.4

13

12.4

0

00.0

High

0

00.0

9

09.5

0

00.0

0

00.0

0

00.0

8

07.6

0

00.0

0

00.0

0

00.0

9

09.5

0

00.0

0

00.0

0

00.0

8

07.6

0

00.0

0

00.0

Missing

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

Sum

4

04.2

85

89.5

6

06.3

0

00.0

4

03.8

88

83.8

13

12.4

0

00.0

4

04.2

85

89.5

6

06.3

0

00.0

4

03.8

88

83.8

13

12.4

0

00.0

MONTH 3  
(N=95)

Low

0

00.0

5

05.3

0

00.0

0

00.0

0

00.0

4

03.8

0

00.0

0

00.0

0

00.0

5

05.3

0

00.0

0

00.0

0

00.0

4

03.8

0

00.0

0

00.0

Normal

2

02.1

75

78.9

4

04.2

0

00.0

3

02.9

84

80.0

6

05.7

0

00.0

2

02.1

75

78.9

4

04.2

0

00.0

3

02.9

84

80.0

6

05.7

0

00.0

High

0

00.0

8

08.4

1

01.1

0

00.0

0

00.0

8

07.6

0

00.0

0

00.0

0

00.0

8

08.4

1

01.1

0

00.0

0

00.0

8

07.6

0

00.0

0

00.0

Missing

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

Sum

2

02.1

88

92.6

5

05.3

0

00.0

3

02.9

96

91.4

6

05.7

0

00.0

2

02.1

88

92.6

5

05.3

0

00.0

3

02.9

96

91.4

6

05.7

0

00.0

Sodium

WEEK 2  
(N=95)

Low

0

00.0

3

03.2

0

00.0

0

00.0

0

00.0

4

03.8

0

00.0

0

00.0

0

00.0

3

03.2

0

00.0

0

00.0

0

00.0

4

03.8

0

00.0

0

00.0

Normal

5

05.3

70

73.7

3

03.2

0

00.0

4

03.8

86

81.9

6

05.7

0

00.0

5

05.3

70

73.7

3

03.2

0

00.0

4

03.8

86

81.9

6

05.7

0

00.0

High

0

00.0

13

13.7

1

01.1

0

00.0

0

00.0

4

03.8

1

01.0

0

00.0

0

00.0

13

13.7

1

01.1

0

00.0

0

00.0

4

03.8

1

01.0

0

00.0

Missing

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

Sum

5

05.3

86

90.5

4

04.2

0

00.0

4

03.8

94

89.5

7

06.7

0

00.0

5

05.3

86

90.5

4

04.2

0

00.0

4

03.8

94

89.5

7

06.7

0

00.0

MONTH 3  
(N=95)

Low

0

00.0

3

03.2

0

00.0

0

00.0

0

00.0

4

03.8

0

00.0

0

00.0

0

00.0

3

03.2

0

00.0

0

00.0

0

00.0

4

03.8

0

00.0

0

00.0

Normal

2

02.1

71

74.7

5

05.3

0

00.0

3

02.9

83

79.0

10

09.5

0

00.0

2

02.1

71

74.7

5

05.3

0

00.0

3

02.9

83

79.0

10

09.5

0

00.0

High

1

01.1

12

12.6

1

01.1

0

00.0

0

00.0

5

04.8

0

00.0

0

00.0

1

01.1

12

12.6

1

01.1

0

00.0

0

00.0

5

04.8

0

00.0

0

00.0

Missing

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

0

00.0

Sum

3

03.2

86

90.5

6

06.3

0

00.0

3

02.9

92

87.6

10

09.5

0

00.0

3

03.2

86

90.5

6

06.3

0

00.0

3

02.9

92

87.6

10

09.5

0

00.0
