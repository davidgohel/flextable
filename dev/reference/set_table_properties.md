# Global table properties

Set table layout and table width. Default to fixed algorithm.

If layout is fixed, column widths will be used to display the table;
`width` is ignored.

If layout is autofit, column widths will not be used; table width is
used (as a percentage).

## Usage

``` r
set_table_properties(
  x,
  layout = "fixed",
  width = 0,
  align = NULL,
  opts_html = list(),
  opts_word = list(),
  opts_pdf = list(),
  word_title = NULL,
  word_description = NULL
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- layout:

  'autofit' or 'fixed' algorithm. Default to 'fixed'.

- width:

  The parameter has a different effect depending on the output format.
  Users should consider it as a minimum width. In HTML, it is the
  minimum width of the space that the table should occupy. In Word, it
  is a preferred size and Word may decide not to strictly stick to it.
  It has no effect on PowerPoint and PDF output. Its default value is 0,
  as an effect, it only use necessary width to display all content. It
  is not used by the PDF output.

- align:

  alignment in document (only Word, HTML and PDF), supported values are
  'left', 'center' and 'right'.

- opts_html:

  html options as a list. Supported elements are:

  - 'extra_css': extra css instructions to be integrated with the HTML
    code of the table.

  - 'scroll': NULL or a list if you want to add a scroll-box.

    - Use an empty list to add an horizontal scroll. The with is fixed,
      corresponding to the container's width.

    - If the list has a value named `height` it will be used as height
      and the scroll will happen also vertically. The height will be in
      pixel if numeric, if a string it should be a valid css measure.

    - If the list has a value named `freeze_first_column` set to `TRUE`,
      the first column is set as a *sticky* column.

    - If the list has a value named `add_css` it will be used as extra
      css to add, .i.e: `border:1px solid red;`.

  - 'extra_class': extra classes to add in the table tag

- opts_word:

  Word options as a list. Supported elements are:

  - 'split': Word option 'Allow row to break across pages' can be
    activated when TRUE.

  - 'keep_with_next': Word option 'keep rows together' is activated when
    TRUE. It avoids page break within tables. This is handy for small
    tables, i.e. less than a page height.

  - 'repeat_headers': Word option 'Repeat as header row' is activated
    and associated to header rows when TRUE.

- opts_pdf:

  PDF options as a list. Supported elements are:

  - 'tabcolsep': space between the text and the left/right border of its
    containing cell.

  - 'arraystretch': height of each row relative to its default height,
    the default value is 1.5.

  - 'float': type of floating placement in the PDF document, one of:

    - 'none' (the default value), table is placed after the preceding
      paragraph.

    - 'float', table can float to a place in the text where it fits best

    - 'wrap-r', wrap text around the table positioned to the right side
      of the text

    - 'wrap-l', wrap text around the table positioned to the left side
      of the text

    - 'wrap-i', wrap text around the table positioned inside edge-near
      the binding

    - 'wrap-o', wrap text around the table positioned outside edge-far
      from the binding

  - 'fonts_ignore': if TRUE, pdf-engine 'pdflatex' can be used instead
    of 'xelatex' or 'lualatex.' If pdflatex is used, fonts will be
    ignored because they are not supported by pdflatex, whereas with the
    xelatex and lualatex engines they are.

  - 'caption_repeat': a boolean that indicates if the caption should be
    repeated along pages. Its default value is `TRUE`.

  - 'footer_repeat': a boolean that indicates if the footer should be
    repeated along pages. Its default value is `TRUE`.

  - 'default_line_color': default line color, restored globally after
    the flextable is produced.

- word_title:

  alternative text for Word table (used as title of the table)

- word_description:

  alternative text for Word table (used as description of the table)

## Note

PowerPoint output ignore 'autofit layout'.

## See also

[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md),
[`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md),
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md)

## Examples

``` r
library(flextable)
ft_1 <- flextable(head(cars))
ft_1 <- autofit(ft_1)
ft_2 <- set_table_properties(ft_1, width = .5, layout = "autofit")
ft_2


.cl-5fffbc8a{table-layout:auto;width:50%;}.cl-5ff91402{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-5ffbec68{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-5ffc0fa4{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5ffc0fae{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5ffc0fb8{background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5ffc0fb9{background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5ffc0fc2{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5ffc0fc3{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


speed
```

dist

4

2

4

10

7

4

7

22

8

16

9

10

ft_3 \<- set_table_properties(ft_1, width = 1, layout = "autofit") \#
add scroll for HTML ----
[set.seed](https://rdrr.io/r/base/Random.html)(2) dat \<-
[lapply](https://rdrr.io/r/base/lapply.html)(1:14, function(x)
[rnorm](https://rdrr.io/r/stats/Normal.html)(n = 20)) dat \<-
[setNames](https://rdrr.io/r/stats/setNames.html)(dat,
[paste0](https://rdrr.io/r/base/paste.html)("colname", 1:14)) dat \<-
[as.data.frame](https://rdrr.io/r/base/as.data.frame.html)(dat) ft_4 \<-
[flextable](https://davidgohel.github.io/flextable/dev/reference/flextable.md)(dat)
ft_4 \<-
[colformat_double](https://davidgohel.github.io/flextable/dev/reference/colformat_double.md)(ft_4)
ft_4 \<-
[bg](https://davidgohel.github.io/flextable/dev/reference/bg.md)(ft_4, j
= 1, bg = "#DDDDDD", part = "all") ft_4 \<-
[bg](https://davidgohel.github.io/flextable/dev/reference/bg.md)(ft_4, i
= 1, bg = "#DDDDDD", part = "header") ft_4 \<-
[autofit](https://davidgohel.github.io/flextable/dev/reference/autofit.md)(ft_4)
ft_4 \<- set_table_properties( x = ft_4, opts_html =
[list](https://rdrr.io/r/base/list.html)( scroll =
[list](https://rdrr.io/r/base/list.html)( height = "500px",
freeze_first_column = TRUE ) ) ) ft_4

| colname1 | colname2 | colname3 | colname4 | colname5 | colname6 | colname7 | colname8 | colname9 | colname10 | colname11 | colname12 | colname13 | colname14 |
|----------|----------|----------|----------|----------|----------|----------|----------|----------|-----------|-----------|-----------|-----------|-----------|
| -0.9     | 2.1      | -0.4     | -1.8     | 1.0      | 1.1      | 1.2      | -0.6     | 0.4      | -1.0      | 0.3       | 0.4       | -0.1      | 1.3       |
| 0.2      | -1.2     | -2.0     | 2.0      | -1.7     | 0.3      | 0.1      | 0.4      | -0.6     | -1.3      | -1.0      | 0.7       | 2.9       | -0.1      |
| 1.6      | 1.6      | -0.8     | -0.7     | -0.5     | -0.3     | 1.7      | -0.8     | -0.3     | 0.4       | 2.9       | -0.8      | 1.2       | -0.3      |
| -1.1     | 2.0      | 1.9      | 0.2      | -1.4     | -0.7     | -0.4     | 0.1      | 0.4      | -1.1      | 0.2       | 1.9       | 0.5       | -1.9      |
| -0.1     | 0.0      | 0.6      | 0.5      | -2.2     | -0.9     | -1.0     | 0.7      | -1.3     | 0.5       | -1.0      | 0.1       | 0.8       | -0.6      |
| 0.1      | -2.5     | 2.0      | -0.8     | 1.8      | 2.0      | 0.5      | -0.7     | -0.9     | 1.2       | 0.4       | 0.5       | -0.6      | -1.4      |
| 0.7      | 0.5      | -0.3     | -2.0     | -0.7     | 0.9      | -0.7     | 0.7      | 2.1      | 0.0       | -0.1      | -0.1      | 0.1       | 1.9       |
| -0.2     | -0.6     | -0.1     | -0.5     | -0.3     | 2.0      | 0.6      | 0.5      | -2.1     | 0.5       | -0.4      | 0.9       | 0.3       | 0.5       |
| 2.0      | 0.8      | -0.2     | 0.1      | -0.4     | -0.4     | -1.7     | -0.8     | -1.2     | -0.7      | 0.6       | -0.4      | -0.5      | 0.5       |
| -0.1     | 0.3      | -1.2     | -0.9     | 0.4      | -0.4     | -1.7     | -1.0     | 1.0      | 0.5       | 0.2       | 2.3       | -0.5      | -0.0      |
| 0.4      | 0.7      | -0.8     | -0.9     | 1.6      | -1.0     | 0.7      | 1.0      | 1.1      | -1.3      | 1.0       | 1.6       | 0.5       | -2.7      |
| 1.0      | 0.3      | 2.1      | 0.3      | 1.7      | -0.3     | 0.3      | -0.2     | 0.8      | -0.1      | -0.5      | -2.0      | -0.4      | -0.0      |
| -0.4     | 1.1      | -0.6     | -0.1     | -1.2     | 0.5      | 0.9      | 0.7      | 0.1      | -1.3      | 1.8       | -0.6      | -0.2      | 0.0       |
| -1.0     | -0.3     | 1.3      | 0.4      | -1.4     | 1.4      | -2.0     | -0.8     | 0.3      | -0.3      | -1.4      | -0.0      | -0.3      | -1.2      |
| 1.8      | -0.8     | -1.0     | -0.1     | -1.5     | 0.6      | 1.2      | 1.3      | -0.9     | 1.1       | 0.1       | -1.7      | 0.8       | 0.3       |
| -2.3     | -0.6     | -2.0     | -0.9     | -1.3     | 0.5      | 1.2      | -1.3     | -0.7     | 0.7       | 0.5       | -1.1      | 0.5       | 1.6       |
| 0.9      | -1.7     | -0.3     | 1.3      | 2.0      | 1.2      | 1.0      | 0.8      | -0.3     | -0.4      | 1.2       | -0.6      | -0.3      | -0.0      |
| 0.0      | -0.9     | 0.9      | 0.8      | 0.0      | 1.1      | 0.8      | 0.5      | -0.9     | -0.8      | -1.3      | 0.5       | -0.3      | 1.0       |
| 1.0      | -0.6     | 1.1      | 1.1      | -0.8     | 0.1      | 2.1      | 0.3      | 0.8      | -0.9      | -1.1      | 0.1       | 1.0       | -0.4      |
| 0.4      | -0.2     | 1.7      | -1.4     | -0.6     | -0.8     | -1.5     | 0.7      | -1.6     | -0.7      | 1.7       | -0.6      | -0.2      | 0.1       |
