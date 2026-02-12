# Get HTML code as a string

Generate HTML code of corresponding flextable as an HTML table or an
HTML image.

## Usage

``` r
# S3 method for class 'flextable'
to_html(x, type = c("table", "img"), ...)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- type:

  output type. one of "table" or "img".

- ...:

  unused

## Value

If `type='img'`, the result will be a string containing HTML code of an
image tag, otherwise, the result will be a string containing HTML code
of a table tag.

## See also

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/reference/gen_grob.md),
[`htmltools_value()`](https://davidgohel.github.io/flextable/reference/htmltools_value.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/reference/knit_print.flextable.md),
[`plot.flextable()`](https://davidgohel.github.io/flextable/reference/plot.flextable.md),
[`print.flextable()`](https://davidgohel.github.io/flextable/reference/print.flextable.md),
[`save_as_docx()`](https://davidgohel.github.io/flextable/reference/save_as_docx.md),
[`save_as_html()`](https://davidgohel.github.io/flextable/reference/save_as_html.md),
[`save_as_image()`](https://davidgohel.github.io/flextable/reference/save_as_image.md),
[`save_as_pptx()`](https://davidgohel.github.io/flextable/reference/save_as_pptx.md),
[`save_as_rtf()`](https://davidgohel.github.io/flextable/reference/save_as_rtf.md),
[`wrap_flextable()`](https://davidgohel.github.io/flextable/reference/wrap_flextable.md)

## Examples

``` r
library(officer)
library(flextable)
x <- to_html(as_flextable(cars))
```
