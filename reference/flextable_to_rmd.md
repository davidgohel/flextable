# Print a flextable inside knitr loops and conditionals

Print flextable in R Markdown or Quarto documents within `for` loop or
`if` statement.

The function is particularly useful when you want to generate flextable
in a loop from a R Markdown document.

Inside R Markdown document, chunk option `results` must be set to
'asis'.

See
[knit_print.flextable](https://davidgohel.github.io/flextable/reference/knit_print.flextable.md)
for more details.

## Usage

``` r
flextable_to_rmd(x, ...)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- ...:

  unused argument

## See also

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/reference/df_printer.md),
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
[`to_html.flextable()`](https://davidgohel.github.io/flextable/reference/to_html.flextable.md),
[`wrap_flextable()`](https://davidgohel.github.io/flextable/reference/wrap_flextable.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(rmarkdown)
if (pandoc_available() &&
  pandoc_version() > numeric_version("2")) {
  demo_loop <- system.file(
    package = "flextable",
    "examples/rmd",
    "loop_with_flextable.Rmd"
  )
  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy(demo_loop, to = rmd_file, overwrite = TRUE)
  render(
    input = rmd_file, output_format = "html_document",
    output_file = "loop_with_flextable.html"
  )
}
} # }
```
