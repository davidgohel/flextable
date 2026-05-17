# Build a paragraph from chunks

`as_paragraph()` assembles one or more chunks into a single paragraph
that defines the content of a flextable cell. Each cell in a flextable
contains exactly one paragraph; a paragraph is an ordered sequence of
chunks.

Chunks are the smallest content units and can be created with
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md)
(formatted text),
[`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md)
/
[`as_i()`](https://davidgohel.github.io/flextable/dev/reference/as_i.md)
(bold / italic shortcuts),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md)
(inline bar),
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md)
(image),
[`gg_chunk()`](https://davidgohel.github.io/flextable/dev/reference/gg_chunk.md)
(ggplot),
[`as_equation()`](https://davidgohel.github.io/flextable/dev/reference/as_equation.md)
(equation) or
[`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md)
(link). Plain character strings passed to `as_paragraph()` are
automatically converted to chunks via
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md).

The resulting paragraph is passed to the `value` argument of
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`mk_par()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md),
[`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md)
or
[`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md)
to set cell content.

## Usage

``` r
as_paragraph(..., list_values = NULL)
```

## Arguments

- ...:

  chunk elements that are defining the paragraph content. If a character
  is used, it is transformed to a chunk object with function
  [`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md).

- list_values:

  a list of chunk elements that are defining the paragraph content. If
  specified argument `...` is unused.

## See also

[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md),
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md),
[`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md)

Other functions to compose cell content:
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md),
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md),
[`labelizor()`](https://davidgohel.github.io/flextable/dev/reference/labelizor.md),
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md),
[`void()`](https://davidgohel.github.io/flextable/dev/reference/void.md)

## Examples

``` r
library(flextable)
ft <- flextable(airquality[sample.int(150, size = 10), ])
ft <- compose(ft,
  j = "Wind",
  value = as_paragraph(
    as_chunk(Wind, props = fp_text_default(color = "orange")),
    " ",
    minibar(value = Wind, max = max(airquality$Wind), barcol = "orange", bg = "black", height = .15)
  ),
  part = "body"
)
ft <- autofit(ft)
ft


.cl-b1f75286{}.cl-b1eefff0{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-b1eefffa{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 165, 0, 1.00);background-color:transparent;}.cl-b1f391fa{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-b1f3b1bc{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b1f3b1c6{width:1.577in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b1f3b1d0{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b1f3b1d1{width:1.577in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b1f3b1da{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b1f3b1db{width:1.577in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Ozone
```
