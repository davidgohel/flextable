# Wrap a flextable for use with patchwork

This function wraps a flextable as a patchwork-compliant patch, similar
to what
[`patchwork::wrap_table()`](https://patchwork.data-imaginist.com/reference/wrap_table.html)
does for gt tables. It allows flextable objects to be combined with
ggplot2 plots in a patchwork layout, with optional alignment of table
headers and body with plot panel areas.

Note this is experimental and may change in the future.

## Usage

``` r
wrap_flextable(
  x,
  panel = c("body", "full", "rows", "cols"),
  space = c("free", "free_x", "free_y", "fixed"),
  n_row_headers = 0L
)
```

## Arguments

- x:

  A flextable object.

- panel:

  What portion of the table should be aligned with the panel region?
  `"body"` means that header and footer will be placed outside the panel
  region. `"full"` means that the whole table will be placed inside the
  panel region. `"rows"` keeps all rows inside the panel but is
  otherwise equivalent to `"body"`. `"cols"` places all columns within
  the panel region but keeps column headers on top.

- space:

  How should the dimension of the table influence the final composition?
  `"fixed"` means that the table width and height will set the
  dimensions of the area it occupies. `"free"` means the table
  dimensions will not influence the sizing. `"free_x"` and `"free_y"`
  allow freeing either direction.

- n_row_headers:

  Number of leading columns to treat as row headers. These columns will
  be placed outside the panel region and will not participate in
  alignment with the plot axes.

## Value

A patchwork-compliant object that can be combined with ggplot2 plots
using `+`, `|`, or `/` operators.

## See also

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md),
[`htmltools_value()`](https://davidgohel.github.io/flextable/dev/reference/htmltools_value.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md),
[`plot.flextable()`](https://davidgohel.github.io/flextable/dev/reference/plot.flextable.md),
[`print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/print.flextable.md),
[`save_as_docx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_docx.md),
[`save_as_html()`](https://davidgohel.github.io/flextable/dev/reference/save_as_html.md),
[`save_as_image()`](https://davidgohel.github.io/flextable/dev/reference/save_as_image.md),
[`save_as_pptx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_pptx.md),
[`save_as_rtf()`](https://davidgohel.github.io/flextable/dev/reference/save_as_rtf.md),
[`to_html.flextable()`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md)

## Examples

``` r
library(gdtools)
register_liberationsans()
#> [1] TRUE
set_flextable_defaults(
  font.family = "Liberation Sans",
  font.size = 7,
  padding = 4,
  big.mark = ""
)

if (require("patchwork") && require("ggplot2")) {
  ft <- flextable(head(iris))
  ft <- autofit(ft)
  p <- ggplot(iris, aes(Sepal.Length, Sepal.Width)) +
    geom_point()

  tf <- tempfile(fileext = ".png")
  ragg::agg_png(
    filename = tf, width = 8,
    height = 7, units = "in", res = 150
  )
  # Place side by side
  print(p | wrap_flextable(ft))
  dev.off()

  tf <- tempfile(fileext = ".png")
  ragg::agg_png(
    filename = tf, width = 8,
    height = 7, units = "in", res = 150
  )
  # Stack vertically
  print(p / wrap_flextable(ft))
  dev.off()

  tf <- tempfile(fileext = ".png")
  ragg::agg_png(
    filename = tf, width = 8,
    height = 7, units = "in", res = 150
  )
  # Use + operator (also works directly: p + ft)
  print(p + wrap_flextable(ft))
  dev.off()

  # does not work perfectly if below the boxplot
  p <- ggplot(diamonds, aes(color, x)) +
    geom_boxplot(position = position_dodge(width = 1))

  ft <- summarizor(diamonds[c("color", "cut", "carat")], by = c("color"))
  ft <- as_flextable(
      ft,
      sep_w = 0.0,
      spread_first_col = TRUE
    )
  ft <- delete_part(ft, "header")

  ptch <- p / wrap_flextable(
    x = ft,
    panel = "body",
    space = "fixed",
    n_row_headers = 1
  )

  tf <- tempfile(fileext = ".png")
  ragg::agg_png(
    filename = tf, width = 8,
    height = 7, units = "in", res = 150
  )
  print(ptch)
  dev.off()



  # This one works well - horizontally
  p <- ggplot(diamonds) +
    geom_bar(aes(y = cut)) +
    scale_y_discrete(name = NULL, guide = "none")

  cts <- data.frame(
    cut = ordered(
      c("Fair", "Good", "Very Good", "Premium", "Ideal"),
      levels = c("Fair", "Good", "Very Good", "Premium", "Ideal")
    ),
    n = c(1610L, 4906L, 12082L, 13791L, 21551L)
  )

  ft_tab <- flextable(cts)
  ft_tab <- autofit(ft_tab)

  ptch <- wrap_flextable(ft_tab, space = "fixed") + p

  tf <- tempfile(fileext = ".png")
  ragg::agg_png(
    filename = tf, width = 6,
    height = 2, units = "in", res = 150
  )
  print(ptch)
  dev.off()
  init_flextable_defaults()
}
#> Loading required package: patchwork
```
