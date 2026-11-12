# Equation chunk

This function is used to insert equations into flextable.

It is used to add it to the content of a cell of the flextable with the
functions
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md)
or
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md).

To use this function, package 'equatags' is required.

## Usage

``` r
as_equation(x, width = NULL, height = NULL, unit = "in", props = NULL)
```

## Arguments

- x:

  values containing the 'MathJax' equations

- width, height:

  size of the resulting equation. When they are not provided (`NULL`,
  the default), the size is computed from the equation and the font size
  of the chunk with
  [`equatags::equation_size()`](https://rdrr.io/pkg/equatags/man/equation_size.html)
  (equatags \>= 0.4.0), so that
  [`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md),
  [`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md)
  and
  [`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
  know the size of the equation; with an older version of 'equatags', 1
  x 0.2 inch.

- unit:

  unit for width and height, one of "in", "cm", "mm".

- props:

  an
  [`fp_text_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_text_default.md)
  or
  [`officer::fp_text()`](https://davidgohel.github.io/officer/reference/fp_text.html)
  object to be used to format the text. If not specified, it will be the
  default value corresponding to the cell.

## Size and drawing of equations

The style of equations follows the rule of Word, in every output: an
equation is in display style (large fractions, limits above and below
sums and products) when its paragraph only contains equations, and in
inline style as soon as the paragraph contains something else, even a
space. HTML and LaTeX outputs use `\displaystyle` for the display style,
and the size and
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
use the same style.

The size computed by
[`equatags::equation_size()`](https://rdrr.io/pkg/equatags/man/equation_size.html)
is the one of the equation laid out with the math font 'STIX Two Math'.
Word and browsers display equations with their own math font, so the
displayed size may differ slightly. With
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md)
(R \>= 4.3), equations are drawn with
[`equatags::equation_grob()`](https://rdrr.io/pkg/equatags/man/equation_grob.html),
at their computed size.

## See also

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/dev/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`as_highlight()`](https://davidgohel.github.io/flextable/dev/reference/as_highlight.md),
[`as_i()`](https://davidgohel.github.io/flextable/dev/reference/as_i.md),
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md),
[`as_qmd()`](https://davidgohel.github.io/flextable/dev/reference/as_qmd.md),
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
  ft <- mk_par(
    x = ft, j = "formula",
    value = as_paragraph(as_equation(formula))
  )
  ft <- align(ft, align = "center", part = "all")
  ft <- autofit(ft)
  ft
}
#> Loading required package: equatags


.cl-d8bad469{}.cl-d8bad469 .katex{font-size:1em;}.cl-5430bca3{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-b21ffd22{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1.164;background-color:transparent;}.cl-510389b5{width:1.634in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4f45b1f4{width:1.634in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bede5773{width:1.634in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c18fbc80{width:1.634in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

formula
```
