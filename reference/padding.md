# Set paragraph paddings

Change the padding of selected rows and columns of a flextable.

## Usage

``` r
padding(
  x,
  i = NULL,
  j = NULL,
  padding = NULL,
  padding.top = NULL,
  padding.bottom = NULL,
  padding.left = NULL,
  padding.right = NULL,
  part = "body"
)
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

- padding:

  padding (shortcut for top, bottom, left and right), unit is pts
  (points).

- padding.top:

  padding top, unit is pts (points).

- padding.bottom:

  padding bottom, unit is pts (points).

- padding.left:

  padding left, unit is pts (points).

- padding.right:

  padding right, unit is pts (points).

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## Note

In PDF output, only `padding.left` and `padding.right` are supported.
`padding.top` and `padding.bottom` are ignored due to LaTeX limitations.
Global horizontal spacing can also be set with
`set_table_properties(opts_pdf = list(tabcolsep = 1))`.

## See also

Other formatting shortcuts:
[`align()`](https://davidgohel.github.io/flextable/reference/align.md),
[`bg()`](https://davidgohel.github.io/flextable/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/reference/color.md),
[`empty_blanks()`](https://davidgohel.github.io/flextable/reference/empty_blanks.md),
[`font()`](https://davidgohel.github.io/flextable/reference/font.md),
[`fontsize()`](https://davidgohel.github.io/flextable/reference/fontsize.md),
[`highlight()`](https://davidgohel.github.io/flextable/reference/highlight.md),
[`indentation()`](https://davidgohel.github.io/flextable/reference/indentation.md),
[`italic()`](https://davidgohel.github.io/flextable/reference/italic.md),
[`keep_with_next()`](https://davidgohel.github.io/flextable/reference/keep_with_next.md),
[`line_spacing()`](https://davidgohel.github.io/flextable/reference/line_spacing.md),
[`rotate()`](https://davidgohel.github.io/flextable/reference/rotate.md),
[`style()`](https://davidgohel.github.io/flextable/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/reference/valign.md)

## Examples

``` r
ft_1 <- flextable(head(iris))
ft_1 <- theme_vader(ft_1)
ft_1 <- padding(ft_1, padding.top = 4, part = "all")
ft_1 <- padding(ft_1, j = 1, padding.right = 40)
ft_1 <- padding(ft_1, i = 3, padding.top = 40)
ft_1 <- padding(ft_1, padding.top = 10, part = "header")
ft_1 <- padding(ft_1, padding.bottom = 10, part = "header")
ft_1 <- autofit(ft_1)
ft_1


.cl-5350c75a{}.cl-5349bece{font-family:'Liberation Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(223, 223, 223, 1.00);background-color:transparent;}.cl-5349bee2{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(223, 223, 223, 1.00);background-color:transparent;}.cl-534cc31c{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:10pt;padding-top:10pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-534cc330{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:10pt;padding-top:10pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-534cc33a{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:4pt;padding-left:5pt;padding-right:40pt;line-height: 1;background-color:transparent;}.cl-534cc344{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:4pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-534cc34e{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:4pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-534cc34f{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:40pt;padding-left:5pt;padding-right:40pt;line-height: 1;background-color:transparent;}.cl-534cc350{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:40pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-534cc358{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:40pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-534ce8a6{width:1.244in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8ba{width:1.159in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8c4{width:1.202in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8c5{width:1.117in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8ce{width:0.863in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8cf{width:1.244in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8d8{width:1.159in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8d9{width:1.202in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8e2{width:1.117in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8ec{width:0.863in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce8f6{width:1.244in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce900{width:1.159in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce901{width:1.202in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce90a{width:1.117in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-534ce914{width:0.863in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
