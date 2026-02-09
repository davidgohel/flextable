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
#> <div class="tabwid"><style>.cl-2b8726d0{}.cl-2b80fd0a{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-2b8397ae{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2b8397b8{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2b83b978{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2b83b982{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2b83b98c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2b83b98d{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2b83b98e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2b83b996{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}</style><table data-quarto-disable-processing='true' class='cl-2b8726d0'><thead><tr style="overflow-wrap:break-word;"><th class="cl-2b83b978"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">Sepal.Length</span></p></th><th class="cl-2b83b978"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">Sepal.Width</span></p></th><th class="cl-2b83b978"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">Petal.Length</span></p></th><th class="cl-2b83b978"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">Petal.Width</span></p></th><th class="cl-2b83b982"><p class="cl-2b8397b8"><span class="cl-2b80fd0a">Species</span></p></th></tr></thead><tbody><tr style="overflow-wrap:break-word;"><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">5.1</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">3.5</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">1.4</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">0.2</span></p></td><td class="cl-2b83b98d"><p class="cl-2b8397b8"><span class="cl-2b80fd0a">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">4.9</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">3.0</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">1.4</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">0.2</span></p></td><td class="cl-2b83b98d"><p class="cl-2b8397b8"><span class="cl-2b80fd0a">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">4.7</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">3.2</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">1.3</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">0.2</span></p></td><td class="cl-2b83b98d"><p class="cl-2b8397b8"><span class="cl-2b80fd0a">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">4.6</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">3.1</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">1.5</span></p></td><td class="cl-2b83b98c"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">0.2</span></p></td><td class="cl-2b83b98d"><p class="cl-2b8397b8"><span class="cl-2b80fd0a">setosa</span></p></td></tr><tr style="overflow-wrap:break-word;"><td class="cl-2b83b98e"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">5.0</span></p></td><td class="cl-2b83b98e"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">3.6</span></p></td><td class="cl-2b83b98e"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">1.4</span></p></td><td class="cl-2b83b98e"><p class="cl-2b8397ae"><span class="cl-2b80fd0a">0.2</span></p></td><td class="cl-2b83b996"><p class="cl-2b8397b8"><span class="cl-2b80fd0a">setosa</span></p></td></tr></tbody></table></div>
```
