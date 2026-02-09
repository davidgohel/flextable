# Set Word 'Keep with next' instructions

The 'Keep with next' functionality in 'Word', applied to the rows of a
table, ensures that rows with that attribute stay together and do not
break across multiple pages.

This function provides better control of page breaks than the global
`keep_with_next` parameter.

## Usage

``` r
keep_with_next(x, i = NULL, value = TRUE, part = "body")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- value:

  TRUE or FALSE. When applied to a group, all rows except the last one
  should be flagged with the 'Keep with next' attribute.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' is not allowed by the function.

## See also

[`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)

Other sugar functions for table style:
[`align()`](https://davidgohel.github.io/flextable/dev/reference/align.md),
[`bg()`](https://davidgohel.github.io/flextable/dev/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/dev/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/dev/reference/color.md),
[`empty_blanks()`](https://davidgohel.github.io/flextable/dev/reference/empty_blanks.md),
[`font()`](https://davidgohel.github.io/flextable/dev/reference/font.md),
[`fontsize()`](https://davidgohel.github.io/flextable/dev/reference/fontsize.md),
[`highlight()`](https://davidgohel.github.io/flextable/dev/reference/highlight.md),
[`italic()`](https://davidgohel.github.io/flextable/dev/reference/italic.md),
[`line_spacing()`](https://davidgohel.github.io/flextable/dev/reference/line_spacing.md),
[`padding()`](https://davidgohel.github.io/flextable/dev/reference/padding.md),
[`rotate()`](https://davidgohel.github.io/flextable/dev/reference/rotate.md),
[`style()`](https://davidgohel.github.io/flextable/dev/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/dev/reference/valign.md)

## Examples

``` r
library(flextable)
dat <- iris[c(1:25, 51:75, 101:125), ]
ft <- qflextable(dat)
ft <- keep_with_next(
  x = ft,
  i = c(1:24, 26:49, 51:74),
  value = TRUE
)

save_as_docx(ft, path = tempfile(fileext = ".docx"))
```
