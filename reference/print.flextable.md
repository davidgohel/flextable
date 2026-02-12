# Print a flextable

print a flextable object to format `html`, `docx`, `pptx` or as text
(not for display but for informative purpose). This function is to be
used in an interactive context.

## Usage

``` r
# S3 method for class 'flextable'
print(x, preview = "html", align = "center", ...)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- preview:

  preview type, one of c("html", "pptx", "docx", "rtf", "pdf, "log").
  When `"log"` is used, a description of the flextable is printed.

- align:

  left, center (default) or right. Only for docx/html/pdf.

- ...:

  arguments for 'pdf_document' call when preview is "pdf".

## Note

When argument `preview` is set to `"docx"` or `"pptx"`, an external
client linked to these formats (Office is installed) is used to edit a
document. The document is saved in the temporary directory of the R
session and will be removed when R session will be ended.

When argument `preview` is set to `"html"`, an external client linked to
these HTML format is used to display the table. If RStudio is used, the
Viewer is used to display the table.

Note also that a print method is used when flextable are used within R
markdown documents. See
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/reference/knit_print.flextable.md).

## See also

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/reference/gen_grob.md),
[`htmltools_value()`](https://davidgohel.github.io/flextable/reference/htmltools_value.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/reference/knit_print.flextable.md),
[`plot.flextable()`](https://davidgohel.github.io/flextable/reference/plot.flextable.md),
[`save_as_docx()`](https://davidgohel.github.io/flextable/reference/save_as_docx.md),
[`save_as_html()`](https://davidgohel.github.io/flextable/reference/save_as_html.md),
[`save_as_image()`](https://davidgohel.github.io/flextable/reference/save_as_image.md),
[`save_as_pptx()`](https://davidgohel.github.io/flextable/reference/save_as_pptx.md),
[`save_as_rtf()`](https://davidgohel.github.io/flextable/reference/save_as_rtf.md),
[`to_html.flextable()`](https://davidgohel.github.io/flextable/reference/to_html.flextable.md),
[`wrap_flextable()`](https://davidgohel.github.io/flextable/reference/wrap_flextable.md)
