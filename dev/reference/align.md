# Set text alignment

Change the text alignment of selected rows and columns of a flextable.

## Usage

``` r
align(
  x,
  i = NULL,
  j = NULL,
  align = "left",
  part = c("body", "header", "footer", "all")
)

align_text_col(x, align = "left", header = TRUE, footer = TRUE)

align_nottext_col(x, align = "right", header = TRUE, footer = TRUE)
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

- align:

  text alignment - a single character value, or a vector of character
  values equal in length to the number of columns selected by `j`.
  Expected values must be from the set ('left', 'right', 'center', or
  'justify').

  If the number of columns is a multiple of the length of the `align`
  parameter, then the values in `align` will be recycled across the
  remaining columns.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

- header:

  should the header be aligned with the body

- footer:

  should the footer be aligned with the body

## See also

Other formatting shortcuts:
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
[`rotate()`](https://davidgohel.github.io/flextable/dev/reference/rotate.md),
[`style()`](https://davidgohel.github.io/flextable/dev/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/dev/reference/valign.md)

## Examples

``` r
# Table of 6 columns
ft_car <- flextable(head(mtcars)[, 2:7])

# All 6 columns right aligned
align(ft_car, align = "right", part = "all")


.cl-c7103766{}.cl-c70939ca{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-c70c33d2{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c70c574a{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c70c575e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c70c575f{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


cyl
```
