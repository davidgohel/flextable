# Set the bottom border of a table part

`hline_bottom()` draws a horizontal line at the **very bottom** of a
table part. It does not accept a row selector `i` because it always
targets the last row.

Unlike
[`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md),
which adds inner lines below arbitrary rows, `hline_bottom()` is meant
for the outer bottom edge of a part.

## Usage

``` r
hline_bottom(x, j = NULL, border = NULL, part = "body")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`flextable column selection`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

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
[`hline_top()`](https://davidgohel.github.io/flextable/dev/reference/hline_top.md),
[`surround()`](https://davidgohel.github.io/flextable/dev/reference/surround.md),
[`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md),
[`vline_left()`](https://davidgohel.github.io/flextable/dev/reference/vline_left.md),
[`vline_right()`](https://davidgohel.github.io/flextable/dev/reference/vline_right.md)

## Examples

``` r
library(officer)
big_border <- fp_border(color = "orange", width = 3)

ft <- flextable(head(iris))
ft <- border_remove(x = ft)

# add a thick line at the bottom of the body
ft <- hline_bottom(ft, part = "body", border = big_border)
ft


.cl-0825a462{}.cl-081f3c94{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-0821fcf4{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-0821fd08{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-08221f68{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-08221f7c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-08221f86{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 3pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-08221f87{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 3pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


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
