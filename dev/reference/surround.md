# Set borders for a selection of cells

Highlight specific cells with borders.

To set borders for the whole table, use
[`border_outer()`](https://davidgohel.github.io/flextable/dev/reference/border_outer.md),
[`border_inner_h()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_h.md)
and
[`border_inner_v()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_v.md).

All the following functions also support the row and column selector `i`
and `j`:

- [`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md):
  set bottom borders (inner horizontal)

- [`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md):
  set right borders (inner vertical)

- [`hline_top()`](https://davidgohel.github.io/flextable/dev/reference/hline_top.md):
  set the top border (outer horizontal)

- [`vline_left()`](https://davidgohel.github.io/flextable/dev/reference/vline_left.md):
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
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`flextable column selection`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

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
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## See also

Other borders management:
[`border_inner()`](https://davidgohel.github.io/flextable/dev/reference/border_inner.md),
[`border_inner_h()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_h.md),
[`border_inner_v()`](https://davidgohel.github.io/flextable/dev/reference/border_inner_v.md),
[`border_outer()`](https://davidgohel.github.io/flextable/dev/reference/border_outer.md),
[`border_remove()`](https://davidgohel.github.io/flextable/dev/reference/border_remove.md),
[`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md),
[`hline_bottom()`](https://davidgohel.github.io/flextable/dev/reference/hline_bottom.md),
[`hline_top()`](https://davidgohel.github.io/flextable/dev/reference/hline_top.md),
[`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md),
[`vline_left()`](https://davidgohel.github.io/flextable/dev/reference/vline_left.md),
[`vline_right()`](https://davidgohel.github.io/flextable/dev/reference/vline_right.md)

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


.cl-c96686b8{}.cl-c95fef38{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-c962a214{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c962a21e{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c962c3f2{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c488{width:1.202in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c492{width:1.237in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c493{width:1.155in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c49c{width:0.873in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 1pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4a6{width:1.285in;background-color:rgba(255, 255, 0, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4a7{width:1.202in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4b0{width:1.237in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4b1{width:1.155in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4ba{width:0.873in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4bb{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4bc{width:1.202in;background-color:rgba(255, 255, 0, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4bd{width:1.237in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4c4{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4c5{width:1.202in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4ce{width:1.237in;background-color:rgba(255, 255, 0, 1.00);vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4cf{width:1.155in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4d8{width:1.202in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4d9{width:1.285in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4da{width:1.202in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4e2{width:1.237in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4e3{width:1.155in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c962c4ec{width:0.873in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


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

\# \# render \# print(ft, preview = "pptx") \# print(ft, preview =
"docx") \# print(ft, preview = "pdf") \# print(ft, preview = "html")
