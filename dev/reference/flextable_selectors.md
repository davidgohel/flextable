# Selectors in flextable

Selectors are a core feature of flextable that allow you to specify
which parts (`part`), rows (`i`) and columns (`j`) should be affected by
formatting, styling, or content operations.

Many flextable functions support these selectors, including
[`bg()`](https://davidgohel.github.io/flextable/dev/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/dev/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/dev/reference/color.md),
[`padding()`](https://davidgohel.github.io/flextable/dev/reference/padding.md),
[`fontsize()`](https://davidgohel.github.io/flextable/dev/reference/fontsize.md),
[`italic()`](https://davidgohel.github.io/flextable/dev/reference/italic.md),
[`align()`](https://davidgohel.github.io/flextable/dev/reference/align.md),
[`mk_par()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md),
[`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md),
and many others.

Selectors make conditional formatting easy and enable seamless piping of
multiple operations using `%>%` or `|>`.

## Row selection with the `i` parameter

The `i` parameter is used to select specific rows in a flextable for
formatting, styling, or content operations.

When `i = NULL` (the default), operations apply to all rows.

    i = ~ condition           # Formula (body only)
    i = 1:5                   # Integer vector
    i = c(TRUE, FALSE, ...)   # Logical vector
    i = NULL                  # All rows (default)

Best practices:

- Use formulas (`i = ~ condition`) for conditional selection in body

- Use integers for positional selection in any part.

- Use
  [`nrow_part()`](https://davidgohel.github.io/flextable/dev/reference/nrow_part.md)
  for dynamic row selection

## Column selection with the `j` parameter

The `j` parameter is used to select specific columns in a flextable for
formatting, styling, or content operations.

When `j = NULL` (the default), operations apply to all columns.

    j = ~ col1 + col2         # Formula (select multiple)
    j = ~ . - col1            # Formula (exclude columns)
    j = c("col1", "col2")     # Character vector (recommended)
    j = 1:5                   # Integer vector
    j = c(TRUE, FALSE, ...)   # Logical vector
    j = NULL                  # All columns (default)

Best practices:

- Use character vectors (`j = c("col1", "col2")`) for clarity and
  maintainability.

- Use formulas (`j = ~ col1 + col2`) for excluding columns.

- Avoid integer positions when possible (less maintainable).

- Column selectors work with all parts (header, body, footer, all).

## Part selection with the `part` parameter

The `part` parameter specifies which section of the flextable should be
affected by formatting, styling, or content operations.

    part = "body"    # Data rows (default)
    part = "header"  # Header rows
    part = "footer"  # Footer rows
    part = "all"     # All parts

- When `part = "body"` (the default), operations apply only to the data
  rows.

- When `part = "all"`, the operation is applied to each part
  independently.

Formula row selectors (`i = ~ condition`) CANNOT be used with:

- `part = "header"` - Headers contain only character values

- `part = "footer"` - Footers contain only character values

- `part = "all"` - Header/footer are character-only while body has
  original data types

This restriction exists because formula selectors evaluate conditions
using the actual data types from your dataset (numeric, logical, etc.).
Headers and footers store only character representations of values, so
conditional expressions like `i = ~ price < 330` cannot be evaluated on
them.

## Advanced Programming with Selectors

Function
[`nrow_part()`](https://davidgohel.github.io/flextable/dev/reference/nrow_part.md)
returns the number of lines in a part.

    # Format the last row differently
    ft <- flextable(iris[48:52,])
    ft <- bold(ft, i = nrow_part(ft, part = "body"))

    # Add footnote to last row
    ft <- footnote(
      ft,
      i = nrow_part(ft, part = "body"), j = 1:4,
      value = as_paragraph("Calculated mean")
    )
    ft

Function
[`ncol_keys()`](https://davidgohel.github.io/flextable/dev/reference/ncol_keys.md)
returns the number of columns.

    # Get column count
    ncol_keys(ft)

    # Useful for programmatic selection
    ncols <- ncol_keys(ft)
    ft <- bg(ft, j = rep(c(TRUE, FALSE), length.out = ncols), bg = "#f0f0f0")
    ft
