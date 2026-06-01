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
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

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
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## Note

In PDF output, only `padding.left` and `padding.right` are supported.
`padding.top` and `padding.bottom` are ignored due to LaTeX limitations.
Global horizontal spacing can also be set with
`set_table_properties(opts_pdf = list(tabcolsep = 1))`.

## See also

Other formatting shortcuts:
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
[`rotate()`](https://davidgohel.github.io/flextable/dev/reference/rotate.md),
[`style()`](https://davidgohel.github.io/flextable/dev/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/dev/reference/valign.md)

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


.cl-bca8a4c8{}.cl-bca10cae{font-family:'Liberation Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(223, 223, 223, 1.00);background-color:transparent;}.cl-bca10cc2{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(223, 223, 223, 1.00);background-color:transparent;}.cl-bca46886{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:10pt;padding-top:10pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-bca468a4{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:10pt;padding-top:10pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-bca468a5{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:4pt;padding-left:5pt;padding-right:40pt;line-height: 1;background-color:transparent;}.cl-bca468ae{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:4pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-bca468af{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:4pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-bca468b8{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:40pt;padding-left:5pt;padding-right:40pt;line-height: 1;background-color:transparent;}.cl-bca468b9{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:40pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-bca468c2{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:40pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-bca49266{width:1.244in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca49270{width:1.159in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca49271{width:1.202in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca4927a{width:1.117in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca4927b{width:0.863in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca49284{width:1.244in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca4928e{width:1.159in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca4928f{width:1.202in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca49298{width:1.117in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca49299{width:0.863in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca492a2{width:1.244in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca492a3{width:1.159in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca492ac{width:1.202in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca492ad{width:1.117in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bca492ae{width:0.863in;background-color:rgba(36, 36, 36, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
