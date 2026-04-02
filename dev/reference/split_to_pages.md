# Split a flextable into pages by rows and columns

Split a flextable into a list of flextables that fit within the given
height and width constraints. Rows are split first, then columns are
split within each row page.

This is a convenience wrapper around
[`split_rows()`](https://davidgohel.github.io/flextable/dev/reference/split_rows.md)
and
[`split_columns()`](https://davidgohel.github.io/flextable/dev/reference/split_columns.md).

## Usage

``` r
split_to_pages(
  x,
  max_width = NULL,
  max_height = NULL,
  rep_cols = NULL,
  group = integer(0),
  unit = "in"
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- max_width:

  Maximum width per page (in inches by default). `NULL` means no column
  splitting.

- max_height:

  Maximum height per page, including header and footer (in inches by
  default). `NULL` means no row splitting.

- rep_cols:

  Columns to repeat on every horizontal page. Can be a character vector
  of column names, an integer vector of column positions, or `NULL`
  (default, no repetition).

- group:

  Integer vector of body row indices that start a new group. Default is
  `integer(0)`.

- unit:

  Unit for `max_width` and `max_height`, one of `"in"`, `"cm"`, `"mm"`.

## Value

A list of flextable objects.

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
[`split_columns()`](https://davidgohel.github.io/flextable/dev/reference/split_columns.md),
[`split_rows()`](https://davidgohel.github.io/flextable/dev/reference/split_rows.md)

## Examples

``` r
ft <- flextable(iris)
ft_pages <- split_to_pages(ft, max_width = 4, max_height = 5)
length(ft_pages)
#> [1] 22
```
