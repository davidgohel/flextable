# Rotate cell text

It can be useful to change the text direction when table headers are
large. For example, header labels can be rendered as "tbrl" (top to
bottom and right to left), corresponding to a 90-degree rotation, or
"btlr", corresponding to a 270-degree rotation. This function changes
cell text direction. By default, it is "lrtb", which means from left to
right and top to bottom.

'Word' and 'PowerPoint' do not handle automatic height with rotated
headers. Therefore, you need to set header heights (with the
[`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md)
function) and set the rule to "exact" for row heights (with the
[`hrule()`](https://davidgohel.github.io/flextable/dev/reference/hrule.md)
function); otherwise, Word and PowerPoint outputs will have insufficient
height to properly display the text.

flextable does not rotate text by arbitrary angles. It only rotates by
right angles (90-degree increments). This choice ensures consistent
rendering across Word, PowerPoint (limited to angles 0, 270, and 90),
HTML, and PDF.

## Usage

``` r
rotate(x, i = NULL, j = NULL, rotation, align = NULL, part = "body")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- rotation:

  one of "lrtb", "tbrl", "btlr".

- align:

  vertical alignment of paragraph within cell, one of "center" or "top"
  or "bottom".

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## Details

When the
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md)
function is used, rotation will be ignored. In that case, use
[dim_pretty](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md)
and
[width](https://davidgohel.github.io/flextable/dev/reference/width.md)
instead of
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md).

## See also

Other sugar functions for table style:
[`align()`](https://davidgohel.github.io/flextable/dev/reference/align.md),
[`bg()`](https://davidgohel.github.io/flextable/dev/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/dev/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/dev/reference/color.md),
[`empty_blanks()`](https://davidgohel.github.io/flextable/dev/reference/empty_blanks.md),
[`font()`](https://davidgohel.github.io/flextable/dev/reference/font.md),
[`fontsize()`](https://davidgohel.github.io/flextable/dev/reference/fontsize.md),
[`highlight()`](https://davidgohel.github.io/flextable/dev/reference/highlight.md),
[`italic()`](https://davidgohel.github.io/flextable/dev/reference/italic.md),
[`keep_with_next()`](https://davidgohel.github.io/flextable/dev/reference/keep_with_next.md),
[`line_spacing()`](https://davidgohel.github.io/flextable/dev/reference/line_spacing.md),
[`padding()`](https://davidgohel.github.io/flextable/dev/reference/padding.md),
[`style()`](https://davidgohel.github.io/flextable/dev/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/dev/reference/valign.md)

## Examples

``` r
library(flextable)

ft_1 <- flextable(head(iris))

ft_1 <- rotate(ft_1, j = 1:4, align = "bottom", rotation = "tbrl", part = "header")
ft_1 <- rotate(ft_1, j = 5, align = "bottom", rotation = "btlr", part = "header")

# if output is docx or pptx, think about (1) set header heights
# and (2) set rule "exact" for rows heights because Word
# and PowerPoint don't handle auto height with rotated headers
ft_1 <- height(ft_1, height = 1.2, part = "header")
ft_1 <- hrule(ft_1, i = 1, rule = "exact", part = "header")

ft_1


.cl-3372f4bc{}.cl-336c5ff8{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-336f2b2a{margin:0;text-align:right;margin-left:auto;writing-mode: vertical-rl;-ms-writing-mode:tb-rl;-webkit-writing-mode:vertical-rl;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-336f2b34{margin:0;text-align:left;margin-right:auto;writing-mode: vertical-rl;transform: rotate(180deg);-ms-writing-mode:bt-lr;-webkit-writing-mode:vertical-rl;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-336f2b35{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-336f2b3e{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-336f4ede{width:0.75in;height:1.2in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-336f4ee8{width:0.75in;height:1.2in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-336f4ef2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-336f4ef3{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-336f4efc{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-336f4efd{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```

Sepal.Width

Petal.Length

Petal.Width

Species

5.1

3.5

1.4

0.2

setosa

4.9

3.0

1.4

0.2

setosa

4.7

3.2

1.3

0.2

setosa

4.6

3.1

1.5

0.2

setosa

5.0

3.6

1.4

0.2

setosa

5.4

3.9

1.7

0.4

setosa

dat \<- [data.frame](https://rdrr.io/r/base/data.frame.html)( a =
[c](https://rdrr.io/r/base/c.html)("left-top", "left-middle",
"left-bottom"), b = [c](https://rdrr.io/r/base/c.html)("center-top",
"center-middle", "center-bottom"), c =
[c](https://rdrr.io/r/base/c.html)("right-top", "right-middle",
"right-bottom") ) ft_2 \<-
[flextable](https://davidgohel.github.io/flextable/dev/reference/flextable.md)(dat)
ft_2 \<-
[theme_box](https://davidgohel.github.io/flextable/dev/reference/theme_box.md)(ft_2)
ft_2 \<-
[height_all](https://davidgohel.github.io/flextable/dev/reference/height.md)(x
= ft_2, height = 1.3, part = "body") ft_2 \<-
[hrule](https://davidgohel.github.io/flextable/dev/reference/hrule.md)(ft_2,
rule = "exact") ft_2 \<- rotate(ft_2, rotation = "tbrl") ft_2 \<-
[width](https://davidgohel.github.io/flextable/dev/reference/width.md)(ft_2,
width = 1.3) ft_2 \<-
[align](https://davidgohel.github.io/flextable/dev/reference/align.md)(ft_2,
j = 1, align = "left") ft_2 \<-
[align](https://davidgohel.github.io/flextable/dev/reference/align.md)(ft_2,
j = 2, align = "center") ft_2 \<-
[align](https://davidgohel.github.io/flextable/dev/reference/align.md)(ft_2,
j = 3, align = "right") ft_2 \<-
[valign](https://davidgohel.github.io/flextable/dev/reference/valign.md)(ft_2,
i = 1, valign = "top") ft_2 \<-
[valign](https://davidgohel.github.io/flextable/dev/reference/valign.md)(ft_2,
i = 2, valign = "center") ft_2 \<-
[valign](https://davidgohel.github.io/flextable/dev/reference/valign.md)(ft_2,
i = 3, valign = "bottom") ft_2

| a           | b             | c            |
|-------------|---------------|--------------|
| left-top    | center-top    | right-top    |
| left-middle | center-middle | right-middle |
| left-bottom | center-bottom | right-bottom |
