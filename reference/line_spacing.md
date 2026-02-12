# Set line spacing

Change the line spacing of selected rows and columns of a flextable.

## Usage

``` r
line_spacing(x, i = NULL, j = NULL, space = 1, part = "body")
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

- space:

  space between lines of text; 1 is single line spacing, 2 is double
  line spacing.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## See also

Other sugar functions for table style:
[`align()`](https://davidgohel.github.io/flextable/reference/align.md),
[`bg()`](https://davidgohel.github.io/flextable/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/reference/color.md),
[`empty_blanks()`](https://davidgohel.github.io/flextable/reference/empty_blanks.md),
[`font()`](https://davidgohel.github.io/flextable/reference/font.md),
[`fontsize()`](https://davidgohel.github.io/flextable/reference/fontsize.md),
[`highlight()`](https://davidgohel.github.io/flextable/reference/highlight.md),
[`italic()`](https://davidgohel.github.io/flextable/reference/italic.md),
[`keep_with_next()`](https://davidgohel.github.io/flextable/reference/keep_with_next.md),
[`padding()`](https://davidgohel.github.io/flextable/reference/padding.md),
[`rotate()`](https://davidgohel.github.io/flextable/reference/rotate.md),
[`style()`](https://davidgohel.github.io/flextable/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/reference/valign.md)

## Examples

``` r
ft <- flextable(head(mtcars)[, 3:6])
ft <- line_spacing(ft, space = 1.6, part = "all")
ft <- set_table_properties(ft, layout = "autofit")
ft


.cl-2421192e{table-layout:auto;}.cl-241aac9c{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-241d7486{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1.6;background-color:transparent;}.cl-241d9646{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-241d9650{background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-241d9651{background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


disp
```

hp

drat

wt

160

110

3.90

2.620

160

110

3.90

2.875

108

93

3.85

2.320

258

110

3.08

3.215

360

175

3.15

3.440

225

105

2.76

3.460
