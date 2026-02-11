# Modify flextable defaults formatting properties

The current formatting properties (see
[`get_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/get_flextable_defaults.md))
are automatically applied to every flextable you produce. Use
`set_flextable_defaults()` to override them. Use
`init_flextable_defaults()` to re-init all values with the package
defaults.

## Usage

``` r
set_flextable_defaults(
  font.family = NULL,
  font.size = NULL,
  font.color = NULL,
  text.align = NULL,
  padding = NULL,
  padding.bottom = NULL,
  padding.top = NULL,
  padding.left = NULL,
  padding.right = NULL,
  border.color = NULL,
  border.width = NULL,
  background.color = NULL,
  line_spacing = NULL,
  table.layout = NULL,
  cs.family = NULL,
  eastasia.family = NULL,
  hansi.family = NULL,
  decimal.mark = NULL,
  big.mark = NULL,
  digits = NULL,
  pct_digits = NULL,
  na_str = NULL,
  nan_str = NULL,
  fmt_date = NULL,
  fmt_datetime = NULL,
  extra_css = NULL,
  scroll = NULL,
  table_align = "center",
  split = NULL,
  keep_with_next = NULL,
  tabcolsep = NULL,
  arraystretch = NULL,
  float = NULL,
  fonts_ignore = NULL,
  theme_fun = NULL,
  post_process_all = NULL,
  post_process_pdf = NULL,
  post_process_docx = NULL,
  post_process_html = NULL,
  post_process_pptx = NULL,
  ...
)

init_flextable_defaults()
```

## Arguments

- font.family:

  single character value. When format is Word, it specifies the font to
  be used to format characters in the Unicode range (U+0000-U+007F). If
  you want to use non ascii characters in Word, you should also set
  `hansi.family` to the same family name.

- font.size:

  font size (in point) - 0 or positive integer value.

- font.color:

  font color - a single character value specifying a valid color (e.g.
  "#000000" or "black").

- text.align:

  text alignment - a single character value, expected value is one of
  'left', 'right', 'center', 'justify'.

- padding:

  padding (shortcut for top, bottom, left and right padding)

- padding.bottom, padding.top, padding.left, padding.right:

  paragraph paddings - 0 or positive integer value.

- border.color:

  border color - single character value (e.g. "#000000" or "black").

- border.width:

  border width in points.

- background.color:

  cell background color - a single character value specifying a valid
  color (e.g. "#000000" or "black").

- line_spacing:

  space between lines of text, 1 is single line spacing, 2 is double
  line spacing.

- table.layout:

  'autofit' or 'fixed' algorithm. Default to 'autofit'.

- cs.family:

  optional and only for Word. Font to be used to format characters in a
  complex script Unicode range. For example, Arabic text might be
  displayed using the "Arial Unicode MS" font.

- eastasia.family:

  optional and only for Word. Font to be used to format characters in an
  East Asian Unicode range. For example, Japanese text might be
  displayed using the "MS Mincho" font.

- hansi.family:

  optional and only for Word. Font to be used to format characters in a
  Unicode range which does not fall into one of the other categories.

- decimal.mark, big.mark, na_str, nan_str:

  [formatC](https://rdrr.io/r/base/formatc.html) arguments used by
  [`colformat_num()`](https://davidgohel.github.io/flextable/dev/reference/colformat_num.md),
  [`colformat_double()`](https://davidgohel.github.io/flextable/dev/reference/colformat_double.md),
  and
  [`colformat_int()`](https://davidgohel.github.io/flextable/dev/reference/colformat_int.md).

- digits:

  [formatC](https://rdrr.io/r/base/formatc.html) argument used by
  [`colformat_double()`](https://davidgohel.github.io/flextable/dev/reference/colformat_double.md).

- pct_digits:

  number of digits for percentages.

- fmt_date, fmt_datetime:

  formats for date and datetime columns as documented in
  [`strptime()`](https://rdrr.io/r/base/strptime.html). Default to
  '%Y-%m-%d' and '%Y-%m-%d %H:%M:%S'.

- extra_css:

  css instructions to be integrated with the table.

- scroll:

  NULL or a list if you want to add a scroll-box. See **scroll** element
  of argument `opts_html` in function
  [`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md).

- table_align:

  default flextable alignment, supported values are 'left', 'center' and
  'right'.

- split:

  Word option 'Allow row to break across pages' can be activated when
  TRUE.

- keep_with_next:

  default initialization value used by the
  [`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)
  function corresponding to the Word option "keep rows together" that
  will be defined in the array.

- tabcolsep:

  space between the text and the left/right border of its containing
  cell.

- arraystretch:

  height of each row relative to its default height, the default value
  is 1.5.

- float:

  type of floating placement in the PDF document, one of:

  - 'none' (the default value), table is placed after the preceding
    paragraph.

  - 'float', table can float to a place in the text where it fits best

  - 'wrap-r', wrap text around the table positioned to the right side of
    the text

  - 'wrap-l', wrap text around the table positioned to the left side of
    the text

  - 'wrap-i', wrap text around the table positioned inside edge-near the
    binding

  - 'wrap-o', wrap text around the table positioned outside edge-far
    from the binding

- fonts_ignore:

  if TRUE, pdf-engine pdflatex can be used instead of xelatex or
  lualatex. If pdflatex is used, fonts will be ignored because they are
  not supported by pdflatex, whereas with the xelatex and lualatex
  engines they are.

- theme_fun:

  a single character value (the name of the theme function to be
  applied) or a theme function (input is a flextable, output is a
  flextable).

- post_process_all:

  Post-processing function that will allow you to customize the the
  table. It will be executed before call to post_process_pdf(),
  post_process_docx(), post_process_html(), post_process_pptx().

- post_process_pdf, post_process_docx, post_process_html,
  post_process_pptx:

  Post-processing functions that will allow you to customize the display
  by output type (pdf, html, docx, pptx). They are executed just before
  printing the table.

- ...:

  unused or deprecated arguments

## Value

a list containing previous default values.

## See also

Other functions related to themes:
[`get_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/get_flextable_defaults.md),
[`theme_alafoli()`](https://davidgohel.github.io/flextable/dev/reference/theme_alafoli.md),
[`theme_apa()`](https://davidgohel.github.io/flextable/dev/reference/theme_apa.md),
[`theme_booktabs()`](https://davidgohel.github.io/flextable/dev/reference/theme_booktabs.md),
[`theme_borderless()`](https://davidgohel.github.io/flextable/dev/reference/theme_borderless.md),
[`theme_box()`](https://davidgohel.github.io/flextable/dev/reference/theme_box.md),
[`theme_tron()`](https://davidgohel.github.io/flextable/dev/reference/theme_tron.md),
[`theme_tron_legacy()`](https://davidgohel.github.io/flextable/dev/reference/theme_tron_legacy.md),
[`theme_vader()`](https://davidgohel.github.io/flextable/dev/reference/theme_vader.md),
[`theme_vanilla()`](https://davidgohel.github.io/flextable/dev/reference/theme_vanilla.md),
[`theme_zebra()`](https://davidgohel.github.io/flextable/dev/reference/theme_zebra.md)

## Examples

``` r
ft_1 <- qflextable(head(airquality))
ft_1


.cl-377de814{}.cl-37770ae4{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-3779f31c{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-377a16e4{width:0.77in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a16ee{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a16f8{width:0.673in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1702{width:0.718in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1703{width:0.764in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a170c{width:0.587in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a170d{width:0.77in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1716{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1717{width:0.673in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1720{width:0.718in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1721{width:0.764in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1722{width:0.587in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a172a{width:0.77in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a172b{width:0.829in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1734{width:0.673in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a1735{width:0.718in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a173e{width:0.764in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-377a173f{width:0.587in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Ozone
```

Solar.R

Wind

Temp

Month

Day

41

190

7.4

67

5

1

36

118

8.0

72

5

2

12

149

12.6

74

5

3

18

313

11.5

62

5

4

14.3

56

5

5

28

14.9

66

5

6

old \<- set_flextable_defaults( font.color = "#AA8855", border.color =
"#8855AA" ) ft_2 \<-
[qflextable](https://davidgohel.github.io/flextable/dev/reference/flextable.md)([head](https://rdrr.io/r/utils/head.html)(airquality))
ft_2

| Ozone | Solar.R | Wind | Temp | Month | Day |
|-------|---------|------|------|-------|-----|
| 41    | 190     | 7.4  | 67   | 5     | 1   |
| 36    | 118     | 8.0  | 72   | 5     | 2   |
| 12    | 149     | 12.6 | 74   | 5     | 3   |
| 18    | 313     | 11.5 | 62   | 5     | 4   |
|       |         | 14.3 | 56   | 5     | 5   |
| 28    |         | 14.9 | 66   | 5     | 6   |

[do.call](https://rdrr.io/r/base/do.call.html)(set_flextable_defaults,
old)
