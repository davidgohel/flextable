# Transform an rtables object into a flextable

produce a flextable from a `TableTree` or `ElementaryTable` object
produced with the 'rtables' package.

The conversion uses
[`formatters::matrix_form()`](https://insightsengineering.github.io/formatters/latest-tag/reference/matrix_form.html)
to extract the formatted content, column spans, alignments, indentation
and footnotes, then maps them to flextable features.

Indentation of row labels is rendered with left padding.

Label rows (`LabelRow`) are displayed in bold in the first column.
Content rows (`ContentRow`) are displayed entirely in bold.

When `LabelRow` groups exist,
[`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)
is applied so that all rows belonging to the same group are kept
together on the same page in Word and RTF output.

To paginate the resulting flextable into multiple pages, use
[`split_to_pages()`](https://davidgohel.github.io/flextable/dev/reference/split_to_pages.md),
[`split_rows()`](https://davidgohel.github.io/flextable/dev/reference/split_rows.md),
or
[`split_columns()`](https://davidgohel.github.io/flextable/dev/reference/split_columns.md)
after calling
[`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md).

## Usage

``` r
# S3 method for class 'TableTree'
as_flextable(x, indent_padding = 4, ...)

# S3 method for class 'ElementaryTable'
as_flextable(x, indent_padding = 4, ...)
```

## Arguments

- x:

  a `TableTree` or `ElementaryTable` object produced by the 'rtables'
  package.

- indent_padding:

  base left padding in points per indentation level. Default is `4`.

- ...:

  unused arguments

## Value

a flextable object.

## See also

[`split_to_pages()`](https://davidgohel.github.io/flextable/dev/reference/split_to_pages.md),
[`split_rows()`](https://davidgohel.github.io/flextable/dev/reference/split_rows.md),
[`split_columns()`](https://davidgohel.github.io/flextable/dev/reference/split_columns.md)

## Examples

``` r
if (require("rtables", character.only = TRUE, quietly = TRUE)) {
  library(rtables)

  lyt <- basic_table(title = "Demographic Summary") %>%
    split_cols_by("ARM") %>%
    split_rows_by("SEX") %>%
    analyze("AGE", afun = mean, format = "xx.x")

  tbl <- build_table(lyt, DM)
  as_flextable(tbl)
}
#> 
#> Attaching package: ‘formatters’
#> The following object is masked from ‘package:base’:
#> 
#>     %||%
#> 
#> Attaching package: ‘rtables’
#> The following object is masked from ‘package:utils’:
#> 
#>     str


.cl-0046adfe{}.cl-003e56c2{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-003e56d6{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-004165ec{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-00416600{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-00416601{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:9pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-0041660a{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-00418914{width:0.793in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0041891e{width:1.017in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-00418928{width:1.087in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-00418929{width:1.463in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-00418932{width:0.793in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-00418933{width:1.017in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-00418934{width:1.087in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0041893c{width:1.463in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0041893d{width:0.793in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-00418946{width:1.017in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-00418950{width:1.087in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0041895a{width:1.463in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

Demographic Summary
```

A: Drug X

B: Placebo

C: Combination

F

mean

33.7

33.8

34.9

M

mean

36.5

32.1

34.3

U

mean

NA

NA

NA

UNDIFFERENTIATED

mean

NA

NA

NA
