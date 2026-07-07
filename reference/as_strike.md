# Strikethrough chunk

The function is producing a chunk with strikethrough font.

It is used to add it to the content of a cell of the flextable with the
functions
[`compose()`](https://davidgohel.github.io/flextable/reference/compose.md),
[`append_chunks()`](https://davidgohel.github.io/flextable/reference/append_chunks.md)
or
[`prepend_chunks()`](https://davidgohel.github.io/flextable/reference/prepend_chunks.md).

## Usage

``` r
as_strike(x)
```

## Arguments

- x:

  value, if a chunk, the chunk will be updated

## See also

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/reference/as_chunk.md),
[`as_equation()`](https://davidgohel.github.io/flextable/reference/as_equation.md),
[`as_highlight()`](https://davidgohel.github.io/flextable/reference/as_highlight.md),
[`as_i()`](https://davidgohel.github.io/flextable/reference/as_i.md),
[`as_image()`](https://davidgohel.github.io/flextable/reference/as_image.md),
[`as_qmd()`](https://davidgohel.github.io/flextable/reference/as_qmd.md),
[`as_sub()`](https://davidgohel.github.io/flextable/reference/as_sub.md),
[`as_sup()`](https://davidgohel.github.io/flextable/reference/as_sup.md),
[`as_word_field()`](https://davidgohel.github.io/flextable/reference/as_word_field.md),
[`colorize()`](https://davidgohel.github.io/flextable/reference/colorize.md),
[`gg_chunk()`](https://davidgohel.github.io/flextable/reference/gg_chunk.md),
[`grid_chunk()`](https://davidgohel.github.io/flextable/reference/grid_chunk.md),
[`hyperlink_text()`](https://davidgohel.github.io/flextable/reference/hyperlink_text.md),
[`linerange()`](https://davidgohel.github.io/flextable/reference/linerange.md),
[`minibar()`](https://davidgohel.github.io/flextable/reference/minibar.md),
[`plot_chunk()`](https://davidgohel.github.io/flextable/reference/plot_chunk.md)

## Examples

``` r
ft <- flextable(head(iris),
  col_keys = c("Sepal.Length", "dummy")
)

ft <- compose(ft,
  j = "dummy",
  value = as_paragraph(
    as_strike(Sepal.Length)
  )
)

ft


.cl-3b7a4750{}.cl-3b727e08{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-3b727e12{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:line-through;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-3b756154{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-3b756168{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-3b7585c6{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3b7585d0{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3b7585da{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3b7585db{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3b7585e4{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3b7585e5{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
