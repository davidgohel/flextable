# Split a flextable into pages by rows

Split a flextable into a list of flextables whose body rows fit within a
given height (in inches). Header and footer are repeated on every page.
An optional `group` argument keeps row groups together (no page break
inside a group).

## Usage

``` r
split_rows(x, max_height, group = integer(0), unit = "in")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- max_height:

  Maximum height for each page, including header and footer (in inches
  by default).

- group:

  Integer vector of body row indices that start a new group. Rows
  belonging to the same group are kept together on a single page.
  Default is `integer(0)` (no grouping, every row is independent).

- unit:

  Unit for `max_height`, one of `"in"`, `"cm"`, `"mm"`.

## Value

A list of flextable objects. If no splitting is needed, a single-element
list is returned.

## Note

Footnotes are currently repeated on every page, even when they reference
rows that only appear on a specific page. This limitation will be
resolved in a future version when footnotes are restructured to track
their association with body rows.

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
[`split_to_pages()`](https://davidgohel.github.io/flextable/dev/reference/split_to_pages.md)

## Examples

``` r
ft <- flextable(iris)
ft_pages <- split_rows(ft, max_height = 3)
length(ft_pages)
#> [1] 19
```
