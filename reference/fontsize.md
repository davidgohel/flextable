# Set font size

Change the font size of selected rows and columns of a flextable.

## Usage

``` r
fontsize(x, i = NULL, j = NULL, size = 11, part = "body")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.

- size:

  integer value (points)

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## See also

Other formatting shortcuts:
[`align()`](https://davidgohel.github.io/flextable/reference/align.md),
[`bg()`](https://davidgohel.github.io/flextable/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/reference/color.md),
[`empty_blanks()`](https://davidgohel.github.io/flextable/reference/empty_blanks.md),
[`font()`](https://davidgohel.github.io/flextable/reference/font.md),
[`highlight()`](https://davidgohel.github.io/flextable/reference/highlight.md),
[`italic()`](https://davidgohel.github.io/flextable/reference/italic.md),
[`keep_with_next()`](https://davidgohel.github.io/flextable/reference/keep_with_next.md),
[`line_spacing()`](https://davidgohel.github.io/flextable/reference/line_spacing.md),
[`padding()`](https://davidgohel.github.io/flextable/reference/padding.md),
[`rotate()`](https://davidgohel.github.io/flextable/reference/rotate.md),
[`style()`](https://davidgohel.github.io/flextable/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/reference/valign.md)

## Examples

``` r
ft <- flextable(head(iris))
ft <- fontsize(ft, size = 14, part = "header")
ft <- fontsize(ft, size = 14, j = 2)
ft <- fontsize(ft, size = 7, j = 3)
ft


.cl-4a84554a{}.cl-4a7d9282{font-family:'DejaVu Sans';font-size:14pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-4a7d9296{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-4a7d92a0{font-family:'DejaVu Sans';font-size:7pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-4a80597c{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-4a805990{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-4a807a10{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4a807a24{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4a807a25{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4a807a2e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4a807a38{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4a807a39{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
