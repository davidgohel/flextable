# Plot a flextable

plots a flextable as a grid grob object and display the result in a new
graphics window. 'ragg' or 'svglite' or 'ggiraph' graphical device
drivers should be used to ensure a correct rendering.

## Usage

``` r
# S3 method for class 'flextable'
plot(x, ...)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- ...:

  additional arguments passed to
  [`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md).

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
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md),
[`htmltools_value()`](https://davidgohel.github.io/flextable/dev/reference/htmltools_value.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md),
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
library(gdtools)
library(ragg)
register_liberationsans()
#> [1] TRUE
set_flextable_defaults(font.family = "Liberation Sans")
ftab <- as_flextable(cars)

plot(ftab)
```
