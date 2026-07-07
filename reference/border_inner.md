# Set all inner borders

The function is applying a vertical and horizontal borders to inner
content of one or all parts of a flextable.

## Usage

``` r
border_inner(x, border = NULL, part = "all")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- border:

  border properties defined by a call to
  [`officer::fp_border()`](https://davidgohel.github.io/officer/reference/fp_border.html)

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## See also

Other borders management:
[`border_inner_h()`](https://davidgohel.github.io/flextable/reference/border_inner_h.md),
[`border_inner_v()`](https://davidgohel.github.io/flextable/reference/border_inner_v.md),
[`border_outer()`](https://davidgohel.github.io/flextable/reference/border_outer.md),
[`border_remove()`](https://davidgohel.github.io/flextable/reference/border_remove.md),
[`hline()`](https://davidgohel.github.io/flextable/reference/hline.md),
[`hline_bottom()`](https://davidgohel.github.io/flextable/reference/hline_bottom.md),
[`hline_top()`](https://davidgohel.github.io/flextable/reference/hline_top.md),
[`surround()`](https://davidgohel.github.io/flextable/reference/surround.md),
[`vline()`](https://davidgohel.github.io/flextable/reference/vline.md),
[`vline_left()`](https://davidgohel.github.io/flextable/reference/vline_left.md),
[`vline_right()`](https://davidgohel.github.io/flextable/reference/vline_right.md)

## Examples

``` r
library(officer)
std_border <- fp_border(color = "orange", width = 1)

dat <- iris[c(1:5, 51:55, 101:105), ]
ft <- flextable(dat)
ft <- border_remove(x = ft)

# add inner vertical borders
ft <- border_inner(ft, border = std_border)
ft


.cl-3ebb12aa{}.cl-3eb328e2{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-3eb6b96c{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-3eb6b980{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-3eb6dff0{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e004{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e005{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e00e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e00f{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e018{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e019{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e022{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e02c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e02d{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e02e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3eb6e036{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
