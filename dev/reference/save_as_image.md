# Save a flextable in a 'png' or 'svg' file

Save a flextable as a png or svg image. This function uses R graphic
system to create an image from the flextable, allowing for high-quality
image output. See
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
for more options.

## Usage

``` r
save_as_image(x, path, expand = 10, res = 200, ...)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- path:

  image file to be created. It should end with '.png' or '.svg'.

- expand:

  space in pixels to add around the table.

- res:

  The resolution of the device

- ...:

  unused arguments

## Value

a string containing the full name of the generated file

## caption

It's important to note that captions are not part of the table itself.
This means when exporting a table to PNG or SVG formats (image formats),
the caption won't be included. Captions are intended for document
outputs like Word, HTML, or PDF, where tables are embedded within the
document itself.

## See also

Other functions for flextable output and export:
[`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md),
[`htmltools_value()`](https://davidgohel.github.io/flextable/dev/reference/htmltools_value.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md),
[`plot.flextable()`](https://davidgohel.github.io/flextable/dev/reference/plot.flextable.md),
[`print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/print.flextable.md),
[`save_as_docx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_docx.md),
[`save_as_html()`](https://davidgohel.github.io/flextable/dev/reference/save_as_html.md),
[`save_as_pptx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_pptx.md),
[`save_as_rtf()`](https://davidgohel.github.io/flextable/dev/reference/save_as_rtf.md),
[`to_html.flextable()`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md),
[`wrap_flextable()`](https://davidgohel.github.io/flextable/dev/reference/wrap_flextable.md)

## Examples

``` r
library(gdtools)
register_liberationsans()
#> [1] TRUE
set_flextable_defaults(font.family = "Liberation Sans")

ft <- flextable(head(mtcars))
ft <- autofit(ft)
tf <- tempfile(fileext = ".png")
save_as_image(x = ft, path = tf)
#> [1] "/tmp/Rtmp83fftt/file252746d09975.png"

init_flextable_defaults()
```
