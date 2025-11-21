# Equation chunk

This function is used to insert equations into flextable.

It is used to add it to the content of a cell of the flextable with the
functions
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md)
or
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md).

To use this function, package 'equatags' is required; also
`equatags::mathjax_install()` must be executed only once to install
necessary dependencies.

## Usage

``` r
as_equation(x, width = 1, height = 0.2, unit = "in", props = NULL)
```

## Arguments

- x:

  values containing the 'MathJax' equations

- width, height:

  size of the resulting equation

- unit:

  unit for width and height, one of "in", "cm", "mm".

- props:

  an
  [`fp_text_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_text_default.md)
  or
  [`officer::fp_text()`](https://davidgohel.github.io/officer/reference/fp_text.html)
  object to be used to format the text. If not specified, it will be the
  default value corresponding to the cell.

## See also

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/dev/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`as_highlight()`](https://davidgohel.github.io/flextable/dev/reference/as_highlight.md),
[`as_i()`](https://davidgohel.github.io/flextable/dev/reference/as_i.md),
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md),
[`as_strike()`](https://davidgohel.github.io/flextable/dev/reference/as_strike.md),
[`as_sub()`](https://davidgohel.github.io/flextable/dev/reference/as_sub.md),
[`as_sup()`](https://davidgohel.github.io/flextable/dev/reference/as_sup.md),
[`as_word_field()`](https://davidgohel.github.io/flextable/dev/reference/as_word_field.md),
[`colorize()`](https://davidgohel.github.io/flextable/dev/reference/colorize.md),
[`gg_chunk()`](https://davidgohel.github.io/flextable/dev/reference/gg_chunk.md),
[`grid_chunk()`](https://davidgohel.github.io/flextable/dev/reference/grid_chunk.md),
[`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md),
[`linerange()`](https://davidgohel.github.io/flextable/dev/reference/linerange.md),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md),
[`plot_chunk()`](https://davidgohel.github.io/flextable/dev/reference/plot_chunk.md)

## Examples

``` r
library(flextable)
if (require("equatags")) {
  eqs <- c(
    "(ax^2 + bx + c = 0)",
    "a \\ne 0",
    "x = {-b \\pm \\sqrt{b^2-4ac} \\over 2a}"
  )
  df <- data.frame(formula = eqs)
  df


  ft <- flextable(df)
  ft <- compose(
    x = ft, j = "formula",
    value = as_paragraph(as_equation(formula, width = 2, height = .5))
  )
  ft <- align(ft, align = "center", part = "all")
  ft <- width(ft, width = 2)
  ft
}
#> Loading required package: equatags


.cl-dfd5e35c{}.cl-dfccdc80{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-dfd1e004{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-dfd1f9d6{width:2in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-dfd1f9e0{width:2in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-dfd1f9e1{width:2in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

formula
```

$(ax^{2} + bx + c = 0)$(ax2+bx+c=0)

$a \neq 0$a=0

$x = \frac{- b \pm \sqrt{b^{2} - 4ac}}{2a}$x=2a−b±b2−4ac![](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MDBlbSIgaGVpZ2h0PSIxLjA4ZW0iIHZpZXdib3g9IjAgMCA0MDAwMDAgMTA4MCIgcHJlc2VydmVhc3BlY3RyYXRpbz0ieE1pbllNaW4gc2xpY2UiPjxwYXRoIGQ9Ik05NSw3MDIKYy0yLjcsMCwtNy4xNywtMi43LC0xMy41LC04Yy01LjgsLTUuMywtOS41LC0xMCwtOS41LC0xNApjMCwtMiwwLjMsLTMuMywxLC00YzEuMywtMi43LDIzLjgzLC0yMC43LDY3LjUsLTU0CmM0NC4yLC0zMy4zLDY1LjgsLTUwLjMsNjYuNSwtNTFjMS4zLC0xLjMsMywtMiw1LC0yYzQuNywwLDguNywzLjMsMTIsMTAKczE3MywzNzgsMTczLDM3OGMwLjcsMCwzNS4zLC03MSwxMDQsLTIxM2M2OC43LC0xNDIsMTM3LjUsLTI4NSwyMDYuNSwtNDI5CmM2OSwtMTQ0LDEwNC41LC0yMTcuNywxMDYuNSwtMjIxCmwwIC0wCmM1LjMsLTkuMywxMiwtMTQsMjAsLTE0Ckg0MDAwMDB2NDBIODQ1LjI3MjQKcy0yMjUuMjcyLDQ2NywtMjI1LjI3Miw0NjdzLTIzNSw0ODYsLTIzNSw0ODZjLTIuNyw0LjcsLTksNywtMTksNwpjLTYsMCwtMTAsLTEsLTEyLC0zcy0xOTQsLTQyMiwtMTk0LC00MjJzLTY1LDQ3LC02NSw0N3oKTTgzNCA4MGg0MDAwMDB2NDBoLTQwMDAwMHoiIC8+PC9zdmc+)​​
