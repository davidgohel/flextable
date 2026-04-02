# Split a flextable into pages by columns

Split a flextable into a list of flextables whose columns fit within a
given width (in inches). This is useful for paginating wide tables in
Word or PowerPoint output.

## Usage

``` r
split_columns(x, max_width, rep_cols = NULL)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- max_width:

  Maximum width in inches for each page.

- rep_cols:

  Columns to repeat on every page. Can be a character vector of column
  names or an integer vector of column positions. `NULL` (default) means
  no repetition. Repeated columns appear at the beginning of each page
  in the order specified.

## Value

A list of flextable objects. If no splitting is needed, a single-element
list is returned.

## See also

Other row and column operations:
[`add_body()`](https://davidgohel.github.io/flextable/dev/reference/add_body.md),
[`add_body_row()`](https://davidgohel.github.io/flextable/dev/reference/add_body_row.md),
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
[`split_rows()`](https://davidgohel.github.io/flextable/dev/reference/split_rows.md)

## Examples

``` r
ft <- flextable(head(mtcars))
ft_pages <- split_columns(ft, max_width = 5)
length(ft_pages)
#> [1] 2
```
