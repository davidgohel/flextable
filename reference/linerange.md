# Mini linerange chunk

This function is used to insert lineranges into flextable with
functions:

- [`compose()`](https://davidgohel.github.io/flextable/reference/compose.md)
  and
  [`as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.md),

- [`append_chunks()`](https://davidgohel.github.io/flextable/reference/append_chunks.md),

- [`prepend_chunks()`](https://davidgohel.github.io/flextable/reference/prepend_chunks.md).

## Usage

``` r
linerange(
  value,
  min = NULL,
  max = NULL,
  rangecol = "#CCCCCC",
  stickcol = "#FF0000",
  bg = "transparent",
  width = 1,
  height = 0.2,
  raster_width = 30,
  unit = "in",
  alt = ""
)
```

## Arguments

- value:

  values containing the bar size

- min:

  min bar size. Default min of value

- max:

  max bar size. Default max of value

- rangecol:

  bar color

- stickcol:

  jauge color

- bg:

  background color

- width, height:

  size of the resulting png file in inches

- raster_width:

  number of pixels used as width when interpolating value.

- unit:

  unit for width and height, one of "in", "cm", "mm".

- alt:

  alternative text for the image (used for accessibility)

## Note

This chunk option requires package officedown in a R Markdown context
with Word output format.

PowerPoint cannot mix images and text in a paragraph, images are removed
when outputing to PowerPoint format.

## See also

[`compose()`](https://davidgohel.github.io/flextable/reference/compose.md),
[`as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.md)

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/reference/as_chunk.md),
[`as_equation()`](https://davidgohel.github.io/flextable/reference/as_equation.md),
[`as_highlight()`](https://davidgohel.github.io/flextable/reference/as_highlight.md),
[`as_i()`](https://davidgohel.github.io/flextable/reference/as_i.md),
[`as_image()`](https://davidgohel.github.io/flextable/reference/as_image.md),
[`as_qmd()`](https://davidgohel.github.io/flextable/reference/as_qmd.md),
[`as_strike()`](https://davidgohel.github.io/flextable/reference/as_strike.md),
[`as_sub()`](https://davidgohel.github.io/flextable/reference/as_sub.md),
[`as_sup()`](https://davidgohel.github.io/flextable/reference/as_sup.md),
[`as_word_field()`](https://davidgohel.github.io/flextable/reference/as_word_field.md),
[`colorize()`](https://davidgohel.github.io/flextable/reference/colorize.md),
[`gg_chunk()`](https://davidgohel.github.io/flextable/reference/gg_chunk.md),
[`grid_chunk()`](https://davidgohel.github.io/flextable/reference/grid_chunk.md),
[`hyperlink_text()`](https://davidgohel.github.io/flextable/reference/hyperlink_text.md),
[`minibar()`](https://davidgohel.github.io/flextable/reference/minibar.md),
[`plot_chunk()`](https://davidgohel.github.io/flextable/reference/plot_chunk.md)

## Examples

``` r
myft <- flextable(head(iris, n = 10))

myft <- compose(myft,
  j = 1,
  value = as_paragraph(
    linerange(value = Sepal.Length)
  ),
  part = "body"
)

autofit(myft)


.cl-517270b2{}.cl-5169a0ae{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-516e9190{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-516e919a{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-516eb18e{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-516eb198{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-516eb199{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-516eb1a2{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-516eb1ac{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-516eb1ad{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-516eb1b6{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-516eb1c0{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
