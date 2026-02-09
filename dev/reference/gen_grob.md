# Render a flextable as a graphic object

`gen_grob()` converts a flextable into a Grid Graphics object (`grob`)
that can be drawn on any R graphic device. This is the function behind
[`save_as_image()`](https://davidgohel.github.io/flextable/dev/reference/save_as_image.md)
and the patchwork integration
([`wrap_flextable()`](https://davidgohel.github.io/flextable/dev/reference/wrap_flextable.md)).

Typical uses:

- embed a flextable in a `ggplot2` plot (via
  [`wrap_flextable()`](https://davidgohel.github.io/flextable/dev/reference/wrap_flextable.md)
  or cowplot)

- export a flextable as a PNG or SVG image (via
  [`save_as_image()`](https://davidgohel.github.io/flextable/dev/reference/save_as_image.md))

Text wrapping and scaling are supported. The `fit` argument controls how
the table adapts to the available space (fixed size, auto-fit width, or
fill the device).

Not recommended for very large tables because the grid calculations can
be slow.

Limitations: equations
([`as_equation()`](https://davidgohel.github.io/flextable/dev/reference/as_equation.md))
and hyperlinks
([`officer::hyperlink_ftext()`](https://davidgohel.github.io/officer/reference/hyperlink_ftext.html))
are not rendered.

Use a 'ragg', 'svglite' or 'ggiraph' device for correct rendering.

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
[`to_html.flextable()`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md),
[`wrap_flextable()`](https://davidgohel.github.io/flextable/dev/reference/wrap_flextable.md)

## Examples

``` r
library(ragg)
library(gdtools)
register_liberationsans()
#> [1] TRUE

set_flextable_defaults(font.family = "Liberation Sans")

ft <- flextable(head(mtcars))
gr <- gen_grob(ft)
plot(gr)
```
