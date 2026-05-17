# Set table layout and width properties

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
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)

Other functions for flextable size management:
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md),
[`dim.flextable()`](https://davidgohel.github.io/flextable/dev/reference/dim.flextable.md),
[`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md),
[`fit_columns()`](https://davidgohel.github.io/flextable/dev/reference/fit_columns.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/dev/reference/fit_to_width.md),
[`flextable_dim()`](https://davidgohel.github.io/flextable/dev/reference/flextable_dim.md),
[`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md),
[`hrule()`](https://davidgohel.github.io/flextable/dev/reference/hrule.md),
[`ncol_keys()`](https://davidgohel.github.io/flextable/dev/reference/ncol_keys.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/dev/reference/nrow_part.md),
[`width()`](https://davidgohel.github.io/flextable/dev/reference/width.md)

## Examples

``` r
library(flextable)
ft_1 <- flextable(head(cars))
ft_1 <- autofit(ft_1)
ft_2 <- set_table_properties(ft_1, width = .5, layout = "autofit")
ft_2


.cl-d11074fe{table-layout:auto;width:50%;}.cl-d109aaac{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-d10ccb92{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-d10cecb2{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-d10cecbc{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-d10cecc6{background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-d10cecc7{background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-d10cecd0{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-d10cecd1{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


speed
```
