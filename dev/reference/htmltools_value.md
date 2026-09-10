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

Other functions for flextable output and export:
[`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md),
[`plot.flextable()`](https://davidgohel.github.io/flextable/dev/reference/plot.flextable.md),
[`print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/print.flextable.md),
[`repair_docx()`](https://davidgohel.github.io/flextable/dev/reference/repair_docx.md),
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
#> <div class="tabwid"><style>.cl-d8bad469{}.cl-58d9c9bd{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-a1958ec5{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-6477613b{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-8e0ee45a{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-150da73b{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-a18b2e34{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1c23095b{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c9ec629b{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-45102fc2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-d8bad469'><thead><tr style="overflow-wrap:break-word;"><th class="cl-8e0ee45a"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">Sepal.Length</span></p></th><th class="cl-8e0ee45a"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">Sepal.Width</span></p></th><th class="cl-8e0ee45a"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">Petal.Length</span></p></th><th class="cl-8e0ee45a"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">Petal.Width</span></p></th><th class="cl-150da73b"><p class="cl-6477613b"><span class="cl-58d9c9bd">Species</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">5.1</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">3.5</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">1.4</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">0.2</span></p></td><td class="cl-1c23095b"><p class="cl-6477613b"><span class="cl-58d9c9bd">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">4.9</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">3.0</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">1.4</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">0.2</span></p></td><td class="cl-1c23095b"><p class="cl-6477613b"><span class="cl-58d9c9bd">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">4.7</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">3.2</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">1.3</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">0.2</span></p></td><td class="cl-1c23095b"><p class="cl-6477613b"><span class="cl-58d9c9bd">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">4.6</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">3.1</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">1.5</span></p></td><td class="cl-a18b2e34"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">0.2</span></p></td><td class="cl-1c23095b"><p class="cl-6477613b"><span class="cl-58d9c9bd">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-c9ec629b"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">5.0</span></p></td><td class="cl-c9ec629b"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">3.6</span></p></td><td class="cl-c9ec629b"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">1.4</span></p></td><td class="cl-c9ec629b"><p class="cl-a1958ec5"><span class="cl-58d9c9bd">0.2</span></p></td><td class="cl-45102fc2"><p class="cl-6477613b"><span class="cl-58d9c9bd">setosa</span></p></td></tr></tbody></table></div>
```
