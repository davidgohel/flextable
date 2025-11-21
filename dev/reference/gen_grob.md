# Convert a flextable to a grid grob object

It uses Grid Graphics (package `grid`) to Convert a flextable into a
grob object with scaling and text wrapping capabilities.

This method can be used to insert a flextable inside a `ggplot2` plot,
it can also be used with package 'patchwork' or 'cowplot' to combine
ggplots and flextables into the same graphic.

User can vary the size of the elements according to the size of the
graphic window. The text behavior is controllable, user can decide to
make the paragraphs (texts and images) distribute themselves correctly
in the available space of the cell. It is possible to define resizing
options, for example by using only the width, or by distributing the
content so that it occupies the whole graphic space. It is also possible
to freeze or not the size of the columns.

It is not recommended to use this function for large tables because the
calculations can be long.

Limitations: equations (see
[`as_equation()`](https://davidgohel.github.io/flextable/dev/reference/as_equation.md))
and hyperlinks (see
[`officer::hyperlink_ftext()`](https://davidgohel.github.io/officer/reference/hyperlink_ftext.html))
will not be displayed.

'ragg' or 'svglite' or 'ggiraph' graphical device drivers should be used
to ensure a correct rendering.

## Usage

``` r
gen_grob(
  x,
  ...,
  fit = c("auto", "width", "fixed"),
  scaling = c("min", "full", "fixed"),
  wrapping = TRUE,
  autowidths = TRUE,
  just = NULL
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- ...:

  Reserved for extra arguments

- fit:

  Determines the fitting/scaling of the grob on its parent viewport. One
  of `auto`, `width`, `fixed`, `TRUE`, `FALSE`:

  - `auto` or `TRUE` (default): The grob is resized to fit in the parent
    viewport. The table row heights and column widths are resized
    proportionally.

  - `width`: The grob is resized horizontally to fit the width of the
    parent viewport. The column widths are resized proportionally. The
    row heights are unaffected and the table height may be smaller or
    larger than the height of the parent viewport.

  - `fixed` or `FALSE`: The grob will have fixed dimensions, as
    determined by the column widths and the row heights.

- scaling:

  Determines the scaling of the table contents. One of `min`, `full`,
  `fixed`, `TRUE`, `FALSE`:

  - `min` or `TRUE` (default): When the parent viewport is smaller than
    the necessary, the various content sizes (text font size, line width
    and image dimensions) will decrease accordingly so that the content
    can still fit. When the parent viewport is larger than the
    necessary, the content sizes will remain the same, they will not
    increase.

  - `full`: Same as `min`, except that the content sizes are scaled
    fully, they will increase or decrease, according to the size of the
    drawing surface.

  - `fixed` or `FALSE`: The content sizes will not be scaled.

- wrapping:

  Determines the soft wrapping (line breaking) method for the table cell
  contents. One of `TRUE`, `FALSE`:

  - `TRUE`: Text content may wrap into separate lines at normal word
    break points (such as a space or tab character between two words) or
    at newline characters anywhere in the text content. If a word does
    not fit in the available cell width, then the text content may wrap
    at any character. Non-text content (such as images) is also wrapped
    into new lines, according to the available cell width.

  - `FALSE`: Text content may wrap only with a newline character.
    Non-text content is not wrapped.

  Superscript and subscript chunks do not wrap. Newline and tab
  characters are removed from these chunk types.

- autowidths:

  If `TRUE` (default) the column widths are adjusted in order to fit the
  contents of the cells (taking into account the `wrapping` setting).

- just:

  Justification of viewport layout, same as `just` argument in
  [`grid::grid.layout()`](https://rdrr.io/r/grid/grid.layout.html). When
  set to `NULL` (default), it is determined according to the `fit`
  argument.

## Value

a grob (gTree) object made with package `grid`

## size

The size of the flextable can be known by using the method
[dim](https://davidgohel.github.io/flextable/dev/reference/dim.flextableGrob.md)
on the grob.

## caption

It's important to note that captions are not part of the table itself.
This means when exporting a table to PNG or SVG formats (image formats),
the caption won't be included. Captions are intended for document
outputs like Word, HTML, or PDF, where tables are embedded within the
document itself.

## See also

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md),
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
library(ragg)
library(gdtools)
register_liberationsans()
#> [1] TRUE

set_flextable_defaults(font.family = "Liberation Sans")

ft <- flextable(head(mtcars))

gr <- gen_grob(ft)

png_f_1 <- tempfile(fileext = ".png")
ragg::agg_png(
  filename = png_f_1, width = 4, height = 2,
  units = "in", res = 150)
plot(gr)
dev.off()
#> agg_record_738606595 
#>                    2 

png_f_2 <- tempfile(fileext = ".png")
# get the size
dims <- dim(gr)
dims
#> $width
#> [1] 8.25
#> 
#> $height
#> [1] 1.777778
#> 
ragg::agg_png(
  filename = png_f_2, width = dims$width + .1,
  height = dims$height + .1, units = "in", res = 150
)
plot(gr)
dev.off()
#> agg_record_738606595 
#>                    2 


if (require("ggplot2")) {
  png_f_3 <- tempfile(fileext = ".png")
  z <- summarizor(iris, by = "Species")
  ft <- as_flextable(z, spread_first_col = TRUE)
  ft <- color(ft, color = "gray", part = "all")
  gg <- ggplot(data = iris, aes(Sepal.Length, Petal.Width)) +
    annotation_custom(
      gen_grob(ft, scaling = "full"),
      xmin  = 4.5, xmax = 7.5, ymin = 0.25, ymax = 2.25) +
    geom_point() +
    theme_minimal()
  ragg::agg_png(
    filename = png_f_3, width = 7,
    height = 7, units = "in", res = 150
  )
  print(gg)
  dev.off()
}
#> Loading required package: ggplot2
#> agg_record_738606595 
#>                    2 

```
