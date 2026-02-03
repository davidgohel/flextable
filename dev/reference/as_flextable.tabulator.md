# Transform a 'tabulator' object into a flextable

[`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md)
object can be transformed as a flextable with method
[`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md).

## Usage

``` r
# S3 method for class 'tabulator'
as_flextable(
  x,
  separate_with = character(0),
  big_border = fp_border_default(width = 1.5),
  small_border = fp_border_default(width = 0.75),
  rows_alignment = "left",
  columns_alignment = "center",
  label_rows = x$rows,
  spread_first_col = FALSE,
  expand_single = FALSE,
  sep_w = 0.05,
  unit = "in",
  ...
)
```

## Arguments

- x:

  result from
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md)

- separate_with:

  columns used to sepatate the groups with an horizontal line.

- big_border, small_border:

  big and small border properties defined by a call to
  [`fp_border_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_border_default.md)
  or
  [`officer::fp_border()`](https://davidgohel.github.io/officer/reference/fp_border.html).

- rows_alignment, columns_alignment:

  alignments to apply to columns corresponding to `rows` and `columns`;
  see arguments `rows` and `columns` in
  [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md).

- label_rows:

  labels to use for the first column names, i.e. the *row* column names.
  It must be a named vector, the values will be matched based on the
  names.

- spread_first_col:

  if TRUE, first row is spread as a new line separator instead of being
  a column. This helps to reduce the width and allows for clear
  divisions.

- expand_single:

  if FALSE (the default), groups with only one row will not be expanded
  with a title row. If TRUE, single row groups and multi-row groups are
  all restructured.

- sep_w:

  blank column separators'width to be used. If 0, blank column
  separators will not be used.

- unit:

  unit of argument `sep_w`, one of "in", "cm", "mm".

- ...:

  unused argument

## See also

[`summarizor()`](https://davidgohel.github.io/flextable/dev/reference/summarizor.md),
[`as_grouped_data()`](https://davidgohel.github.io/flextable/dev/reference/as_grouped_data.md)

Other as_flextable methods:
[`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md),
[`as_flextable.compact_summary()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.compact_summary.md),
[`as_flextable.data.frame()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.data.frame.md),
[`as_flextable.gam()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.gam.md),
[`as_flextable.glm()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.glm.md),
[`as_flextable.grouped_data()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.grouped_data.md),
[`as_flextable.htest()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.htest.md),
[`as_flextable.kmeans()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.kmeans.md),
[`as_flextable.lm()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.lm.md),
[`as_flextable.merMod()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md),
[`as_flextable.pam()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.pam.md),
[`as_flextable.summarizor()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.summarizor.md),
[`as_flextable.table()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.table.md),
[`as_flextable.tabular()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabular.md),
[`as_flextable.xtable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.xtable.md),
[`compact_summary()`](https://davidgohel.github.io/flextable/dev/reference/compact_summary.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(flextable)

set_flextable_defaults(digits = 2, border.color = "gray")

if (require("stats")) {
  dat <- aggregate(breaks ~ wool + tension,
    data = warpbreaks, mean
  )

  cft_1 <- tabulator(
    x = dat,
    rows = "wool",
    columns = "tension",
    `mean` = as_paragraph(as_chunk(breaks)),
    `(N)` = as_paragraph(
      as_chunk(length(breaks))
    )
  )

  ft_1 <- as_flextable(cft_1, sep_w = .1)
  ft_1
}

if (require("stats")) {
  set_flextable_defaults(
    padding = 1, font.size = 9,
    border.color = "orange"
  )

  ft_2 <- as_flextable(cft_1, sep_w = 0)
  ft_2
}

if (require("stats")) {
  set_flextable_defaults(
    padding = 6, font.size = 11,
    border.color = "white",
    font.color = "white",
    background.color = "#333333"
  )

  ft_3 <- as_flextable(
    x = cft_1, sep_w = 0,
    rows_alignment = "center",
    columns_alignment = "right"
  )
  ft_3
}

init_flextable_defaults()
} # }
```
