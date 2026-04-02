# Create a shift table

Create a shift table ready to be used with
[`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md).

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
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md).

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
#>   2: 01-ABC-0002   Placebo
#>   3: 01-ABC-0003   Placebo
#>   4: 01-ABC-0004 Treatment
#>   5: 01-ABC-0005   Placebo
#>  ---                      
#> 196: 01-ABC-0196 Treatment
#> 197: 01-ABC-0197 Treatment
#> 198: 01-ABC-0198 Treatment
#> 199: 01-ABC-0199   Placebo
#> 200: 01-ABC-0200 Treatment
subject_elts[, c("TREAT") := list(
  factor(.SD$TREAT, levels = c("Treatment", "Placebo"))
)]
#>          USUBJID     TREAT
#>           <char>    <fctr>
#>   1: 01-ABC-0001   Placebo
#>   2: 01-ABC-0002   Placebo
#>   3: 01-ABC-0003   Placebo
#>   4: 01-ABC-0004 Treatment
#>   5: 01-ABC-0005   Placebo
#>  ---                      
#> 196: 01-ABC-0196 Treatment
#> 197: 01-ABC-0197 Treatment
#> 198: 01-ABC-0198 Treatment
#> 199: 01-ABC-0199   Placebo
#> 200: 01-ABC-0200 Treatment
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
#>           USUBJID VISITNUM  LBTEST       VISIT LBBLFL     TREAT LBNRIND
#>            <char>    <int>  <char>      <char> <char>    <fctr>  <char>
#>    1: 01-ABC-0001        1 Albumin SCREENING 1      Y   Placebo  NORMAL
#>    2: 01-ABC-0001        1  Sodium SCREENING 1      Y   Placebo  NORMAL
#>    3: 01-ABC-0001        2 Albumin      WEEK 2   <NA>   Placebo  NORMAL
#>    4: 01-ABC-0001        2  Sodium      WEEK 2   <NA>   Placebo    HIGH
#>    5: 01-ABC-0001        3 Albumin     MONTH 3   <NA>   Placebo  NORMAL
#>   ---                                                                  
#> 1196: 01-ABC-0200        1  Sodium SCREENING 1      Y Treatment  NORMAL
#> 1197: 01-ABC-0200        2 Albumin      WEEK 2   <NA> Treatment  NORMAL
#> 1198: 01-ABC-0200        2  Sodium      WEEK 2   <NA> Treatment  NORMAL
#> 1199: 01-ABC-0200        3 Albumin     MONTH 3   <NA> Treatment  NORMAL
#> 1200: 01-ABC-0200        3  Sodium     MONTH 3   <NA> Treatment  NORMAL

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


.cl-2baf6586{}.cl-2ba0a334{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-2ba558f2{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2ba55906{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:0;padding-top:0;padding-left:0;padding-right:0;line-height: 1;background-color:transparent;}.cl-2ba55907{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2ba55908{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:0;padding-top:0;padding-left:0;padding-right:0;line-height: 1;background-color:transparent;}.cl-2ba55910{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2ba55911{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:0;padding-top:0;padding-left:0;padding-right:0;line-height: 1;background-color:transparent;}.cl-2ba5591a{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2ba596fa{width:0.915in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5970e{width:0.984in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59718{width:2.303in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59719{width:0.079in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5971a{width:0.361in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5971b{width:0.604in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59722{width:0.458in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5972c{width:0.915in;background-color:transparent;vertical-align: bottom;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5972d{width:0.984in;background-color:transparent;vertical-align: bottom;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59736{width:2.303in;background-color:transparent;vertical-align: bottom;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59737{width:0.079in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59738{width:0.361in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59740{width:0.604in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59741{width:0.458in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5974a{width:0.915in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5974b{width:0.984in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59754{width:2.303in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59755{width:0.079in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5975e{width:0.361in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5975f{width:0.604in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59768{width:0.458in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59769{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59772{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59773{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59774{width:0.079in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5977c{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5977d{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59786{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59787{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59788{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59790{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59791{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba59792{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5979a{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba5979b{width:0.079in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597a4{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597a5{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597ae{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597af{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597b8{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597b9{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597c2{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597c3{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597c4{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597c5{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597cc{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597cd{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597d6{width:0.915in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597d7{width:0.984in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597e0{width:2.303in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597ea{width:0.079in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597eb{width:0.361in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597f4{width:0.604in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2ba597f5{width:0.458in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



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
(N=94)

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

0

00.0

2

01.9

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

0

00.0

2

01.9

0

00.0

Normal

5

05.3

75

79.8

5

05.3

0

00.0

4

03.8

87

82.1

8

07.5

0

00.0

5

05.3

75

79.8

5

05.3

0

00.0

4

03.8

87

82.1

8

07.5

0

00.0

High

0

00.0

5

05.3

1

01.1

0

00.0

0

00.0

4

03.8

1

00.9

0

00.0

0

00.0

5

05.3

1

01.1

0

00.0

0

00.0

4

03.8

1

00.9

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

83

88.3

6

06.4

0

00.0

4

03.8

91

85.8

11

10.4

0

00.0

5

05.3

83

88.3

6

06.4

0

00.0

4

03.8

91

85.8

11

10.4

0

00.0

MONTH 3  
(N=94)

Low

0

00.0

2

02.1

1

01.1

0

00.0

0

00.0

2

01.9

0

00.0

0

00.0

0

00.0

2

02.1

1

01.1

0

00.0

0

00.0

2

01.9

0

00.0

0

00.0

Normal

4

04.3

70

74.5

11

11.7

0

00.0

4

03.8

90

84.9

5

04.7

0

00.0

4

04.3

70

74.5

11

11.7

0

00.0

4

03.8

90

84.9

5

04.7

0

00.0

High

0

00.0

5

05.3

1

01.1

0

00.0

0

00.0

4

03.8

1

00.9

0

00.0

0

00.0

5

05.3

1

01.1

0

00.0

0

00.0

4

03.8

1

00.9

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

04.3

77

81.9

13

13.8

0

00.0

4

03.8

96

90.6

6

05.7

0

00.0

4

04.3

77

81.9

13

13.8

0

00.0

4

03.8

96

90.6

6

05.7

0

00.0

Sodium

WEEK 2  
(N=94)

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

2

01.9

1

00.9

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

2

01.9

1

00.9

0

00.0

Normal

3

03.2

71

75.5

8

08.5

0

00.0

4

03.8

83

78.3

10

09.4

0

00.0

3

03.2

71

75.5

8

08.5

0

00.0

4

03.8

83

78.3

10

09.4

0

00.0

High

0

00.0

9

09.6

0

00.0

0

00.0

0

00.0

6

05.7

0

00.0

0

00.0

0

00.0

9

09.6

0

00.0

0

00.0

0

00.0

6

05.7

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

83

88.3

8

08.5

0

00.0

4

03.8

91

85.8

11

10.4

0

00.0

3

03.2

83

88.3

8

08.5

0

00.0

4

03.8

91

85.8

11

10.4

0

00.0

MONTH 3  
(N=94)

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

3

02.8

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

3

02.8

0

00.0

0

00.0

Normal

2

02.1

75

79.8

5

05.3

0

00.0

6

05.7

86

81.1

5

04.7

0

00.0

2

02.1

75

79.8

5

05.3

0

00.0

6

05.7

86

81.1

5

04.7

0

00.0

High

1

01.1

8

08.5

0

00.0

0

00.0

0

00.0

5

04.7

1

00.9

0

00.0

1

01.1

8

08.5

0

00.0

0

00.0

0

00.0

5

04.7

1

00.9

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

91.5

5

05.3

0

00.0

6

05.7

94

88.7

6

05.7

0

00.0

3

03.2

86

91.5

5

05.3

0

00.0

6

05.7

94

88.7

6

05.7

0

00.0
