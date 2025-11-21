# Save flextable objects in an 'HTML' file

save a flextable in an 'HTML' file. This function is useful to save the
flextable in 'HTML' file without using R Markdown (it is highly
recommanded to use R Markdown instead).

## Usage

``` r
save_as_html(..., values = NULL, path, lang = "en", title = "&#32;")
```

## Arguments

- ...:

  flextable objects, objects, possibly named. If named objects, names
  are used as titles.

- values:

  a list (possibly named), each element is a flextable object. If named
  objects, names are used as titles. If provided, argument `...` will be
  ignored.

- path:

  HTML file to be created

- lang:

  language of the document using IETF language tags

- title:

  page title

## Value

a string containing the full name of the generated file

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
[`save_as_image()`](https://davidgohel.github.io/flextable/dev/reference/save_as_image.md),
[`save_as_pptx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_pptx.md),
[`save_as_rtf()`](https://davidgohel.github.io/flextable/dev/reference/save_as_rtf.md),
[`to_html.flextable()`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md)

## Examples

``` r
ft1 <- flextable(head(iris))
tf1 <- tempfile(fileext = ".html")
if (rmarkdown::pandoc_available()) {
  save_as_html(ft1, path = tf1)
  # browseURL(tf1)
}

ft2 <- flextable(head(mtcars))
tf2 <- tempfile(fileext = ".html")
if (rmarkdown::pandoc_available()) {
  save_as_html(
    `iris table` = ft1,
    `mtcars table` = ft2,
    path = tf2,
    title = "rhoooo"
  )
  # browseURL(tf2)
}
```
