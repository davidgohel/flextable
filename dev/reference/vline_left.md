# Set the left border of the table

`vline_left()` draws a vertical line along the **left edge** of the
table by setting the left border of the first column. It does not accept
a column selector `j` because it always targets column 1.

An optional row selector `i` lets you restrict the line to specific rows
(e.g. only the body, or only certain rows).

Unlike
[`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md),
which adds inner lines to the right of arbitrary columns, `vline_left()`
is meant for the outer left edge of the table.

## Usage

``` r
vline_left(x, i = NULL, border = NULL, part = "all")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

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
[`border_outer()`](https://davidgohel.github.io/flextable/dev/reference/border_outer.md),
[`border_remove()`](https://davidgohel.github.io/flextable/dev/reference/border_remove.md),
[`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md),
[`hline_bottom()`](https://davidgohel.github.io/flextable/dev/reference/hline_bottom.md),
[`hline_top()`](https://davidgohel.github.io/flextable/dev/reference/hline_top.md),
[`surround()`](https://davidgohel.github.io/flextable/dev/reference/surround.md),
[`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md),
[`vline_right()`](https://davidgohel.github.io/flextable/dev/reference/vline_right.md)

## Examples

``` r
library(officer)
std_border <- fp_border(color = "orange")

ft <- flextable(head(iris))
ft <- border_remove(x = ft)

# add a border on the left edge of the table
ft <- vline_left(ft, border = std_border)
ft


.cl-1b87b234{}.cl-1b814fb6{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-1b840c24{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1b840c2e{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1b842fe2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(255, 165, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1b842fec{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1b842fed{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


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
