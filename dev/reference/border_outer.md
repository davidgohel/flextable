# Set outer borders

The function is applying a border to outer cells of one or all parts of
a flextable.

## Usage

``` r
border_outer(x, border = NULL, part = "all")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- border:

  border properties defined by a call to
  [`officer::fp_border()`](https://davidgohel.github.io/officer/reference/fp_border.html)

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## See also

Other borders management:
[`border_inner()`](https://davidgohel.github.io/flextable/dev/reference/border_inner.md),
[`border_inner_h()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_h.md),
[`border_inner_v()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_v.md),
[`border_remove()`](https://davidgohel.github.io/flextable/dev/reference/border_remove.md),
[`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md),
[`hline_bottom()`](https://davidgohel.github.io/flextable/dev/reference/hline_bottom.md),
[`hline_top()`](https://davidgohel.github.io/flextable/dev/reference/hline_top.md),
[`surround()`](https://davidgohel.github.io/flextable/dev/reference/surround.md),
[`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md),
[`vline_left()`](https://davidgohel.github.io/flextable/dev/reference/vline_left.md),
[`vline_right()`](https://davidgohel.github.io/flextable/dev/reference/vline_right.md)

## Examples

``` r
library(officer)
big_border <- fp_border(color = "red", width = 2)

dat <- iris[c(1:5, 51:55, 101:105), ]
ft <- flextable(dat)
ft <- border_remove(x = ft)

# add outer borders
ft <- border_outer(ft, part = "all", border = big_border)
ft


.cl-b5ca7ed8{}.cl-b5c3c2a0{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-b5c67cc0{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-b5c67cd4{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-b5c69cbe{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 2pt solid rgba(255, 0, 0, 1.00);border-top: 2pt solid rgba(255, 0, 0, 1.00);border-left: 2pt solid rgba(255, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b5c69cc8{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 2pt solid rgba(255, 0, 0, 1.00);border-top: 2pt solid rgba(255, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b5c69cc9{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 2pt solid rgba(255, 0, 0, 1.00);border-top: 2pt solid rgba(255, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 2pt solid rgba(255, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b5c69cd2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 2pt solid rgba(255, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b5c69cdc{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b5c69ce6{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 2pt solid rgba(255, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b5c69cf0{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 2pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 2pt solid rgba(255, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b5c69cf1{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 2pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b5c69cfa{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 2pt solid rgba(255, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 2pt solid rgba(255, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
