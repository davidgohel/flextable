# Text formatting properties

Create a
[`officer::fp_text()`](https://davidgohel.github.io/officer/reference/fp_text.html)
object that uses defaut values defined in the flextable it applies to.

`fp_text_default()` is a handy function that will allow you to specify
certain formatting values to be applied to a piece of text, the
formatting values that are not specified will simply be the existing
formatting values.

For example, if you set the text in the cell to red previously, using
the code `fp_text_default(bold = TRUE)`, the formatting will be 'bold'
but it will also be 'red'.

On the other hand, the
[`fp_text()`](https://davidgohel.github.io/officer/reference/fp_text.html)
function forces you to specify all the parameters, so we strongly
recommend working with `fp_text_default()` which was created to replace
the use of the former.

See also
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
to modify flextable defaults formatting properties.

## Usage

``` r
fp_text_default(
  color = flextable_global$defaults$font.color,
  font.size = flextable_global$defaults$font.size,
  bold = FALSE,
  italic = FALSE,
  underlined = FALSE,
  strike = FALSE,
  font.family = flextable_global$defaults$font.family,
  cs.family = NULL,
  eastasia.family = NULL,
  hansi.family = NULL,
  vertical.align = "baseline",
  shading.color = "transparent"
)
```

## Arguments

- color:

  font color - a single character value specifying a valid color (e.g.
  "#000000" or "black").

- font.size:

  font size (in point) - 0 or positive integer value.

- bold:

  is bold

- italic:

  is italic

- underlined:

  is underlined

- strike:

  is strikethrough

- font.family:

  single character value. Specifies the font to be used to format
  characters in the Unicode range (U+0000-U+007F).

- cs.family:

  optional font to be used to format characters in a complex script
  Unicode range. For example, Arabic text might be displayed using the
  "Arial Unicode MS" font.

- eastasia.family:

  optional font to be used to format characters in an East Asian Unicode
  range. For example, Japanese text might be displayed using the "MS
  Mincho" font.

- hansi.family:

  optional. Specifies the font to be used to format characters in a
  Unicode range which does not fall into one of the other categories.

- vertical.align:

  single character value specifying font vertical alignments. Expected
  value is one of the following : default `'baseline'` or `'subscript'`
  or `'superscript'`

- shading.color:

  shading color - a single character value specifying a valid color
  (e.g. "#000000" or "black").

## See also

[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md),
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md)

Other functions for defining formatting properties:
[`fp_border_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_border_default.md)

## Examples

``` r
library(flextable)

set_flextable_defaults(
  font.size = 11, font.color = "#303030",
  padding = 3, table.layout = "autofit"
)
z <- flextable(head(cars))

z <- compose(
  x = z,
  i = ~ speed < 6,
  j = "speed",
  value = as_paragraph(
    as_chunk("slow... ", props = fp_text_default(color = "red")),
    as_chunk(speed, props = fp_text_default(italic = TRUE))
  )
)
z


.cl-329b138e{table-layout:auto;}.cl-3294864a{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(48, 48, 48, 1.00);background-color:transparent;}.cl-3294865e{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 0, 0, 1.00);background-color:transparent;}.cl-32948668{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:italic;text-decoration:none;color:rgba(48, 48, 48, 1.00);background-color:transparent;}.cl-32974cd6{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:3pt;padding-right:3pt;line-height: 1;background-color:transparent;}.cl-329771ac{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-329771b6{background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-329771c0{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


speed
```

dist

slow... 4.0

2

slow... 4.0

10

7

4

7

22

8

16

9

10

[init_flextable_defaults](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)()
