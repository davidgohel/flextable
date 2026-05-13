# Add header rows with one value per column

Add new rows to the header where each value maps to a named column.
Unlike
[`add_header_row()`](https://davidgohel.github.io/flextable/dev/reference/add_header_row.md)
where labels can span multiple columns, here each value fills exactly
one column.

If some columns are not provided, they will be replaced by `NA` and
displayed as empty.

![add_header
illustration](https://www.ardata.fr/img/flextable-imgs/flextable-016.png)

## Usage

``` r
add_header(x, top = TRUE, ..., values = NULL)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- top:

  should the rows be inserted at the top or the bottom.

- ...:

  named arguments (names are data colnames) of values to add. It is
  important to insert data of the same type as the original data,
  otherwise it will be transformed (probably into strings if you add a
  `character` where a `double` is expected). This makes possible to
  still format cell contents with the `colformat_*` functions, for
  example
  [`colformat_num()`](https://davidgohel.github.io/flextable/dev/reference/colformat_num.md).

- values:

  a list of name-value pairs of labels or values, names should be
  existing col_key values. This argument can be used instead of `...`
  for programming purpose (If `values` is supplied argument `...` is
  ignored).

## Note

when repeating values, they can be merged together with function
[`merge_h()`](https://davidgohel.github.io/flextable/dev/reference/merge_h.md)
and
[`merge_v()`](https://davidgohel.github.io/flextable/dev/reference/merge_v.md).

## See also

Other row and column operations:
[`add_body()`](https://davidgohel.github.io/flextable/dev/reference/add_body.md),
[`add_body_row()`](https://davidgohel.github.io/flextable/dev/reference/add_body_row.md),
[`add_footer()`](https://davidgohel.github.io/flextable/dev/reference/add_footer.md),
[`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md),
[`add_footer_row()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_row.md),
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

fun <- function(x) {
  paste0(
    c("min: ", "max: "),
    formatC(range(x))
  )
}
new_row <- list(
  Sepal.Length = fun(iris$Sepal.Length),
  Sepal.Width =  fun(iris$Sepal.Width),
  Petal.Width =  fun(iris$Petal.Width),
  Petal.Length = fun(iris$Petal.Length)
)

ft_1 <- flextable(data = head(iris))
ft_1 <- add_header(ft_1, values = new_row, top = FALSE)
ft_1 <- append_chunks(ft_1, part = "header", i = 2, )
ft_1 <- theme_booktabs(ft_1, bold_header = TRUE)
ft_1 <- align(ft_1, align = "center", part = "all")
ft_1


.cl-c5b91162{}.cl-c5b150d0{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-c5b150da{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-c5b50ca2{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c5b53204{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c5b53205{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c5b5320e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c5b5320f{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c5b53218{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Sepal.Length
```
