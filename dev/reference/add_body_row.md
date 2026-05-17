# Add a body row with spanning labels

Add a single row to the body where labels can span multiple columns
(merged cells) via the `colwidths` argument.

Labels are associated with a number of columns to merge that default to
one if not specified. In this case, you have to make sure that the
number of labels is equal to the number of columns displayed.

The function can add only one single row by call.

Labels can also be formatted with
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md).

## Usage

``` r
add_body_row(x, top = TRUE, values = list(), colwidths = integer(0))
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- top:

  should the row be inserted at the top or the bottom.

- values:

  values to add. It can be a `list`, a
  [`character()`](https://rdrr.io/r/base/character.html) vector or a
  call to
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md).

  If it is a list, it can be a named list with the names of the columns
  of the original data.frame or the `colkeys`; this is the recommended
  method because it allows to keep the original data types and therefore
  allows to perform conditional formatting. If a character, columns of
  the original data.frame stored in the flextable object are changed to
  [`character()`](https://rdrr.io/r/base/character.html); this is often
  not an issue with footer and header but can be inconvenient if adding
  rows into body as it will change data types to character and prevent
  efficient conditional formatting.

- colwidths:

  the number of columns to merge in the row for each label

## See also

[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md),
[`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md)

Other row and column operations:
[`add_body()`](https://davidgohel.github.io/flextable/dev/reference/add_body.md),
[`add_footer()`](https://davidgohel.github.io/flextable/dev/reference/add_footer.md),
[`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md),
[`add_footer_row()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_row.md),
[`add_header()`](https://davidgohel.github.io/flextable/dev/reference/add_header.md),
[`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md),
[`add_header_row()`](https://davidgohel.github.io/flextable/dev/reference/add_header_row.md),
[`delete_columns()`](https://davidgohel.github.io/flextable/dev/reference/delete_columns.md),
[`delete_part()`](https://davidgohel.github.io/flextable/dev/reference/delete_part.md),
[`delete_rows()`](https://davidgohel.github.io/flextable/dev/reference/delete_rows.md),
[`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md),
[`separate_header()`](https://davidgohel.github.io/flextable/dev/reference/separate_header.md),
[`set_header_footer_df`](https://davidgohel.github.io/flextable/dev/reference/set_header_footer_df.md),
[`set_header_labels()`](https://davidgohel.github.io/flextable/dev/reference/set_header_labels.md),
[`split_columns()`](https://davidgohel.github.io/flextable/dev/reference/split_columns.md),
[`split_rows()`](https://davidgohel.github.io/flextable/dev/reference/split_rows.md),
[`split_to_pages()`](https://davidgohel.github.io/flextable/dev/reference/split_to_pages.md)

## Examples

``` r
library(flextable)

ft01 <- fp_text_default(color = "red")
ft02 <- fp_text_default(color = "orange")

pars <- as_paragraph(
  as_chunk(c("(1)", "(2)"), props = ft02), " ",
  as_chunk(
    c(
      "My tailor is rich",
      "My baker is rich"
    ),
    props = ft01
  )
)

ft_1 <- flextable(head(mtcars))
ft_1 <- add_body_row(ft_1,
  values = pars,
  colwidths = c(5, 6), top = FALSE
)
ft_1 <- add_body_row(ft_1,
  values = pars,
  colwidths = c(3, 8), top = TRUE
)
ft_1 <- theme_box(ft_1)
ft_1


.cl-a3bbd818{}.cl-a3b49094{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-a3b490a8{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 165, 0, 1.00);background-color:transparent;}.cl-a3b490a9{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-a3b490b2{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 0, 0, 1.00);background-color:transparent;}.cl-a3b79afa{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-a3b7c458{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a3b7c462{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


mpg
```
