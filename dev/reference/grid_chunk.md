# Grid Graphics chunk

This function is used to insert grid objects into flextable with
functions:

- [`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md)
  and
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md),

- [`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md),

- [`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md).

## Usage

``` r
grid_chunk(value, width = 1, height = 0.2, unit = "in", res = 300)
```

## Arguments

- value:

  grid objects, stored in a list column; or a list of grid objects.

- width, height:

  size of the resulting png file

- unit:

  unit for width and height, one of "in", "cm", "mm".

- res:

  resolution of the png image in ppi

## Note

This chunk option requires package officedown in a R Markdown context
with Word output format.

PowerPoint cannot mix images and text in a paragraph, images are removed
when outputing to PowerPoint format.

## See also

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/dev/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`as_equation()`](https://davidgohel.github.io/flextable/dev/reference/as_equation.md),
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
[`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md),
[`linerange()`](https://davidgohel.github.io/flextable/dev/reference/linerange.md),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md),
[`plot_chunk()`](https://davidgohel.github.io/flextable/dev/reference/plot_chunk.md)

## Examples

``` r
library(flextable)
ft_1 <- flextable(head(cars))
if (require("grid")) {
  ft_1 <- prepend_chunks(
    x = ft_1, i = 2, j = 2,
    grid_chunk(
      list(
        circleGrob(gp = gpar(
          fill = "#ec11c2",
          col = "transparent"
        ))
      ),
      width = .15, height = .15
    )
  )
}
#> Loading required package: grid
ft_1


.cl-27c9a746{}.cl-27c329e8{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-27c619f0{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-27c63a02{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-27c63a0c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-27c63a16{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


speed
```

dist

4

2

4

![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAC0AAAAtCAYAAAA6GuKaAAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAC4jAAAuIwF4pT92AAADh0lEQVRYhdWZP2wbVRzHP793Z5ho6rOTlBpVSMDYlilDSTAWIEUdUkQ2JkCiUyuYYKqqbnQsKUuQgIUxiLIUIdSojVVEJqBsFAmVuGoS+xwXltR378dQu3IS+/wnti/+bO/d79197unp9O59hX1STN3OEIZTCFOITqG8sKdI+AuVVZRVdeWX8eL0/f08U3oZtJnOP2OC8H0VOQe82MMt7orqVes6X44Xp//tdnBX0n4yf0yx5xXOAoe6fVgTHgosCmbBK0/f63RQR9KKGt/Lf6SqnwKJnhVbUxXhE8+fuSKIbVfcVnp94qdJU33qa4HZ/vi1RtHrYdV998h/r2xE1UVKF8duvY7IN4hO9lcvApV11L6TrmRvtCppKb1x+OarRuRH4OmByEWzbbFvTpRfW2l2sam0n7x53CIrwNhA1aLZMoQzXjn3x+4Le6T9ZP6Yxf4MHB2KWiRaMDindn9ZzI4Sll3Ffs+BEAaQjBJeU5bdxt4d0qWke1bh5HDFolHk5VLS+aCx78nyqBy67VWd4E/AG7pZe0qulZcOV2bK0DDTVbd6kYMpDJAKHC7WGwJQ8pafU3X+Bpy4rDogFAmfT/m5tcczbc08B1sYwFHrvg315SFmPladDhHReQDZGF8+YgLnPj1uU4eMholHzxoJzBlGQxhATDXxlhE4EbdJNwjmuAHJxC3SHZoxiI6WtJIx6IjNtJAxQDpujy5JG6AYt0WXFA2ihbgtukIpGFRGS1ooGBixmUYKRuH3uDW6QbF3jLr2GqBxy3SI2kT1OzOxmXsgSD5um04QWJnceGP98dZU7VLMPh2hKktQ308buwSEcQp1QCgm+BZq0ik/t4bo5/E6tUHkasrPrUHDj20iSFwC/Nikoim5IZfqjSfSYw9P+SAX4nFqy4X68QHsOqxJlYNFgd+G79QaQX9NlcMvGvvMzoJcIJg5YF+ZSP/QguCcEXJBY6/ZXeaVp+8ZdBaoDM2tOVsGO9ss1tgjDeCVs3es6hywPXC15mxb7FyzY15oIQ0wsZW9hdXTqKwPzq0pD7B6utWBOkRIA6Qr2RtBYE4o/NB/t70oej2oOiejogvoKt1a+VCVywwq3VI+9rZmPutLutVILUc8V8sR+xFtVAQWEV1I+dl/Oh3Uc2Irgb6H6Hl6TGxRWVBXvhp4YtuMzXT+qAS2lo0zhTZ5CeEuSi0bN6v7zcb/Bwv5PGTqM/++AAAAAElFTkSuQmCC)10

7

4

7

22

8

16

9

10
