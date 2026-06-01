# Surround cells with borders

`surround()` draws borders around specific cells, highlighting them
individually.

To set borders for the whole table, use
[`border_outer()`](https://davidgohel.github.io/flextable/reference/border_outer.md),
[`border_inner_h()`](https://davidgohel.github.io/flextable/reference/border_inner_h.md)
and
[`border_inner_v()`](https://davidgohel.github.io/flextable/reference/border_inner_v.md).

All the following functions also support the row and column selector `i`
and `j`:

- [`hline()`](https://davidgohel.github.io/flextable/reference/hline.md):
  set bottom borders (inner horizontal)

- [`vline()`](https://davidgohel.github.io/flextable/reference/vline.md):
  set right borders (inner vertical)

- [`hline_top()`](https://davidgohel.github.io/flextable/reference/hline_top.md):
  set the top border (outer horizontal)

- [`vline_left()`](https://davidgohel.github.io/flextable/reference/vline_left.md):
  set the left border (outer vertical)

## Usage

``` r
surround(
  x,
  i = NULL,
  j = NULL,
  border = NULL,
  border.top = NULL,
  border.bottom = NULL,
  border.left = NULL,
  border.right = NULL,
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

- border:

  border (shortcut for top, bottom, left and right)

- border.top:

  border top

- border.bottom:

  border bottom

- border.left:

  border left

- border.right:

  border right

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## See also

Other borders management:
[`border_inner()`](https://davidgohel.github.io/flextable/reference/border_inner.md),
[`border_inner_h()`](https://davidgohel.github.io/flextable/reference/border_inner_h.md),
[`border_inner_v()`](https://davidgohel.github.io/flextable/reference/border_inner_v.md),
[`border_outer()`](https://davidgohel.github.io/flextable/reference/border_outer.md),
[`border_remove()`](https://davidgohel.github.io/flextable/reference/border_remove.md),
[`hline()`](https://davidgohel.github.io/flextable/reference/hline.md),
[`hline_bottom()`](https://davidgohel.github.io/flextable/reference/hline_bottom.md),
[`hline_top()`](https://davidgohel.github.io/flextable/reference/hline_top.md),
[`vline()`](https://davidgohel.github.io/flextable/reference/vline.md),
[`vline_left()`](https://davidgohel.github.io/flextable/reference/vline_left.md),
[`vline_right()`](https://davidgohel.github.io/flextable/reference/vline_right.md)

## Examples

``` r
library(officer)
library(flextable)

# cell to highlight
vary_i <- 1:3
vary_j <- 1:3

std_border <- fp_border(color = "orange")

ft <- flextable(head(iris))
ft <- border_remove(x = ft)
ft <- border_outer(x = ft, border = std_border)

for (id in seq_along(vary_i)) {
  ft <- bg(
    x = ft,
    i = vary_i[id],
    j = vary_j[id], bg = "yellow"
  )
  ft <- surround(
    x = ft,
    i = vary_i[id],
    j = vary_j[id],
    border.left = std_border,
    border.right = std_border,
    part = "body"
  )
}

ft <- autofit(ft)
ft


.cl-61236ae8{}.cl-611b7aea{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-611ecb46{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-611ecb5a{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-611ef288{width:1.287in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef292{width:1.205in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef29c{width:1.245in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2a6{width:1.163in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2a7{width:0.873in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2b0{width:1.287in;background-color:rgba(255, 255, 0, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2ba{width:1.205in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2bb{width:1.245in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2c4{width:1.163in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2c5{width:0.873in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2ce{width:1.287in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2d8{width:1.205in;background-color:rgba(255, 255, 0, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2e2{width:1.245in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2e3{width:1.287in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2ec{width:1.205in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2f6{width:1.245in;background-color:rgba(255, 255, 0, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef2f7{width:1.163in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef300{width:1.205in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef30a{width:1.287in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef314{width:1.205in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef315{width:1.245in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef31e{width:1.163in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-611ef328{width:0.873in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
