# Render flextable with 'knitr'

Function used to render flextable in knitr/rmarkdown documents.

You should not call this method directly. This function is used by the
knitr package to automatically display a flextable in an "R Markdown"
document from a chunk. However, it is recommended to read its
documentation in order to get familiar with the different options
available.

R Markdown outputs can be :

- HTML

- 'Microsoft Word'

- 'Microsoft PowerPoint'

- PDF

![](figures/fig_formats.png)

Table captioning is a flextable feature compatible with R Markdown
documents. The feature is available for HTML, PDF and Word documents.
Compatibility with the "bookdown" package is also ensured, including the
ability to produce captions so that they can be used in
cross-referencing.

For Word, it's recommanded to work with package 'officedown' that
supports all features of flextable.

## Usage

``` r
# S3 method for class 'flextable'
knit_print(x, ...)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- ...:

  unused.

## Note

Supported formats require some minimum
[pandoc](https://pandoc.org/installing.html) versions:

|                   |                            |
|-------------------|----------------------------|
| **Output format** | **pandoc minimal version** |
| HTML              | \>= 1.12                   |
| Word (docx)       | \>= 2.0                    |
| PowerPoint (pptx) | \>= 2.4                    |
| PDF               | \>= 1.12                   |

If the output format is not HTML, Word, or PDF (e.g., `rtf_document`,
`github_document`, `beamer_presentation`), an image will be generated
instead.

## Chunk options

Some features, often specific to an output format, are available to help
you configure some global settings relatve to the table output. knitr's
chunk options are to be used to change the default settings:

- HTML, PDF and Word:

  - `ft.align`: flextable alignment, supported values are 'left',
    'center' and 'right'. Its default value is 'center'.

- HTML only:

  - `ft.htmlscroll`, can be `TRUE` or `FALSE` (default) to enable
    horizontal scrolling. Use
    [`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md)
    for more options about scrolling.

- Word only:

  - `ft.split` Word option 'Allow row to break across pages' can be
    activated when TRUE (default value).

  - `ft.keepnext` defunct in favor of
    [`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)

- PDF only:

  - `ft.tabcolsep` space between the text and the left/right border of
    its containing cell, the default value is 0 points.

  - `ft.arraystretch` height of each row relative to its default height,
    the default value is 1.5.

  - `ft.latex.float` type of floating placement in the document, one of:

    - 'none' (the default value), table is placed after the preceding
      paragraph.

    - 'float', table can float to a place in the text where it fits best

    - 'wrap-r', wrap text around the table positioned to the right side
      of the text

    - 'wrap-l', wrap text around the table positioned to the left side
      of the text

    - 'wrap-i', wrap text around the table positioned inside edge-near
      the binding

    - 'wrap-o', wrap text around the table positioned outside edge-far
      from the binding

- PowerPoint only:

  - `ft.left`, `ft.top` Position should be defined with these options.
    Theses are the top left coordinates in inches of the placeholder
    that will contain the table. Their default values are 1 and 2
    inches.

If some values are to be used all the time in the same document, it is
recommended to set these values in a 'knitr r chunk' by using function
`knitr::opts_chunk$set(ft.split=FALSE, ...)`.

## Table caption

Captions can be defined in two ways.

The first is with the
[`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md)
function. If it is used, the other method will be ignored. The second
method is by using knitr chunk option `tab.cap`.

    set_caption(x, caption = "my caption")

If `set_caption` function is not used, caption identifier will be read
from knitr's chunk option `tab.id`. Note that in a bookdown and when not
using
[`officedown::rdocx_document()`](https://davidgohel.github.io/officedown/reference/rdocx_document.html),
the usual numbering feature of bookdown is used.

`tab.id='my_id'`.

Some options are available to customise captions for any output:

|                                                  |                |           |
|--------------------------------------------------|----------------|-----------|
| **label**                                        | **name**       | **value** |
| Word stylename to use for table captions.        | tab.cap.style  | NULL      |
| caption id/bookmark                              | tab.id         | NULL      |
| caption                                          | tab.cap        | NULL      |
| display table caption on top of the table or not | tab.topcaption | TRUE      |
| caption table sequence identifier.               | tab.lp         | "tab:"    |

Word output when
[`officedown::rdocx_document()`](https://davidgohel.github.io/officedown/reference/rdocx_document.html)
is used is coming with more options such as ability to choose the prefix
for numbering chunk for example. The table below expose these options:

|                                                         |                 |                           |
|---------------------------------------------------------|-----------------|---------------------------|
| **label**                                               | **name**        | **value**                 |
| prefix for numbering chunk (default to "Table ").       | tab.cap.pre     | Table                     |
| suffix for numbering chunk (default to ": ").           | tab.cap.sep     | " :"                      |
| title number depth                                      | tab.cap.tnd     | 0                         |
| caption prefix formatting properties                    | tab.cap.fp_text | fp_text_lite(bold = TRUE) |
| separator to use between title number and table number. | tab.cap.tns     | "-"                       |

## HTML output

HTML output is using shadow dom to encapsule the table into an isolated
part of the page so that no clash happens with styles.

## PDF output

Some features are not implemented in PDF due to technical infeasibility.
These are the padding, line_spacing and height properties. Note also
justified text is not supported and is transformed to left.

It is recommended to set theses values in a 'knitr r chunk' so that they
are permanent all along the document:
`knitr::opts_chunk$set(ft.tabcolsep=0, ft.latex.float = "none")`.

See
[`add_latex_dep()`](https://davidgohel.github.io/flextable/dev/reference/add_latex_dep.md)
if caching flextable results in 'R Markdown' documents.

## PowerPoint output

Auto-adjust Layout is not available for PowerPoint, PowerPoint only
support fixed layout. It's then often necessary to call function
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md)
so that the columns' widths are adjusted if user does not provide the
withs.

Images cannot be integrated into tables with the PowerPoint format.

## See also

[`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md),
[`htmltools_value()`](https://davidgohel.github.io/flextable/dev/reference/htmltools_value.md),
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
if (FALSE) { # \dontrun{
library(rmarkdown)
if (pandoc_available() &&
  pandoc_version() > numeric_version("2")) {
  demo_loop <- system.file(
    package = "flextable",
    "examples/rmd",
    "demo.Rmd"
  )
  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy(demo_loop, to = rmd_file, overwrite = TRUE)
  render(
    input = rmd_file, output_format = "html_document",
    output_file = "demo.html"
  )
}
} # }
```
