# Save flextable objects in a 'PowerPoint' file

sugar function to save flextable objects in an PowerPoint file.

This feature is available to simplify the work of users by avoiding the
need to use the 'officer' package. If it doesn't suit your needs, then
use the API offered by 'officer' which allows simple and complicated
things.

## Usage

``` r
save_as_pptx(..., values = NULL, path)
```

## Arguments

- ...:

  flextable objects, objects, possibly named. If named objects, names
  are used as slide titles.

- values:

  a list (possibly named), each element is a flextable object. If named
  objects, names are used as slide titles. If provided, argument `...`
  will be ignored.

- path:

  PowerPoint file to be created

## Value

a string containing the full name of the generated file

## Note

The PowerPoint format ignores captions (see
[`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md)).

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
[`save_as_rtf()`](https://davidgohel.github.io/flextable/dev/reference/save_as_rtf.md),
[`to_html.flextable()`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md)

## Examples

``` r
ft1 <- flextable(head(iris))
tf <- tempfile(fileext = ".pptx")
save_as_pptx(ft1, path = tf)

ft2 <- flextable(head(mtcars))
tf <- tempfile(fileext = ".pptx")
save_as_pptx(`iris table` = ft1, `mtcars table` = ft2, path = tf)
```
