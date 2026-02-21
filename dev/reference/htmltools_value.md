# Convert a flextable to an HTML object

get a
[`htmltools::div()`](https://rstudio.github.io/htmltools/reference/builder.html)
from a flextable object. This can be used in a shiny application. For an
output within "R Markdown" document, use
[knit_print.flextable](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md).

## Usage

``` r
htmltools_value(
  x,
  ft.align = NULL,
  ft.shadow = NULL,
  extra_dependencies = NULL
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- ft.align:

  flextable alignment, supported values are 'left', 'center' and
  'right'.

- ft.shadow:

  deprecated.

- extra_dependencies:

  a list of HTML dependencies to add in the HTML output.

## Value

an object marked as
[htmltools::HTML](https://rstudio.github.io/htmltools/reference/HTML.html)
ready to be used within a call to `shiny::renderUI` for example.

## See also

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md),
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
htmltools_value(flextable(iris[1:5, ]))
#> <style></style>
#> <div class="tabwid"><style>.cl-916d4198{}.cl-916601a8{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-91693814{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-9169381e{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-91695c04{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-91695c0e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-91695c18{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-91695c22{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-91695c23{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-91695c2c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-916d4198'><thead><tr style="overflow-wrap:break-word;"><th class="cl-91695c04"><p class="cl-91693814"><span class="cl-916601a8">Sepal.Length</span></p></th><th class="cl-91695c04"><p class="cl-91693814"><span class="cl-916601a8">Sepal.Width</span></p></th><th class="cl-91695c04"><p class="cl-91693814"><span class="cl-916601a8">Petal.Length</span></p></th><th class="cl-91695c04"><p class="cl-91693814"><span class="cl-916601a8">Petal.Width</span></p></th><th class="cl-91695c0e"><p class="cl-9169381e"><span class="cl-916601a8">Species</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">5.1</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">3.5</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">1.4</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">0.2</span></p></td><td class="cl-91695c22"><p class="cl-9169381e"><span class="cl-916601a8">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">4.9</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">3.0</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">1.4</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">0.2</span></p></td><td class="cl-91695c22"><p class="cl-9169381e"><span class="cl-916601a8">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">4.7</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">3.2</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">1.3</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">0.2</span></p></td><td class="cl-91695c22"><p class="cl-9169381e"><span class="cl-916601a8">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">4.6</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">3.1</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">1.5</span></p></td><td class="cl-91695c18"><p class="cl-91693814"><span class="cl-916601a8">0.2</span></p></td><td class="cl-91695c22"><p class="cl-9169381e"><span class="cl-916601a8">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-91695c23"><p class="cl-91693814"><span class="cl-916601a8">5.0</span></p></td><td class="cl-91695c23"><p class="cl-91693814"><span class="cl-916601a8">3.6</span></p></td><td class="cl-91695c23"><p class="cl-91693814"><span class="cl-916601a8">1.4</span></p></td><td class="cl-91695c23"><p class="cl-91693814"><span class="cl-916601a8">0.2</span></p></td><td class="cl-91695c2c"><p class="cl-9169381e"><span class="cl-916601a8">setosa</span></p></td></tr></tbody></table></div>
```
