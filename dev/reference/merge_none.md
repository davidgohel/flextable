# Delete flextable merging information

Delete all merging information from a flextable.

## Usage

``` r
merge_none(x, part = "all")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## See also

Other flextable merging function:
[`merge_at()`](https://davidgohel.github.io/flextable/dev/reference/merge_at.md),
[`merge_h()`](https://davidgohel.github.io/flextable/dev/reference/merge_h.md),
[`merge_h_range()`](https://davidgohel.github.io/flextable/dev/reference/merge_h_range.md),
[`merge_v()`](https://davidgohel.github.io/flextable/dev/reference/merge_v.md)

## Examples

``` r
typology <- data.frame(
  col_keys = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species"),
  what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
  measure = c("Length", "Width", "Length", "Width", "Species"),
  stringsAsFactors = FALSE
)

ft <- flextable(head(iris))
ft <- set_header_df(ft, mapping = typology, key = "col_keys")
ft <- merge_v(ft, j = c("Species"))

ft <- theme_tron_legacy(merge_none(ft))
ft


.cl-0bd78eea{}.cl-0bd0b5fc{font-family:'Liberation Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(223, 116, 12, 1.00);background-color:transparent;}.cl-0bd0b606{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 230, 77, 1.00);background-color:transparent;}.cl-0bd39394{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-0bd393a8{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-0bd3b63a{width:0.75in;background-color:rgba(12, 20, 31, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(111, 195, 223, 1.00);border-top: 0.75pt solid rgba(111, 195, 223, 1.00);border-left: 0.75pt solid rgba(111, 195, 223, 1.00);border-right: 0.75pt solid rgba(111, 195, 223, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0bd3b644{width:0.75in;background-color:rgba(12, 20, 31, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(111, 195, 223, 1.00);border-top: 0.75pt solid rgba(111, 195, 223, 1.00);border-left: 0.75pt solid rgba(111, 195, 223, 1.00);border-right: 0.75pt solid rgba(111, 195, 223, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0bd3b64e{width:0.75in;background-color:rgba(12, 20, 31, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(111, 195, 223, 1.00);border-top: 0.75pt solid rgba(111, 195, 223, 1.00);border-left: 0.75pt solid rgba(111, 195, 223, 1.00);border-right: 0.75pt solid rgba(111, 195, 223, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-0bd3b64f{width:0.75in;background-color:rgba(12, 20, 31, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(111, 195, 223, 1.00);border-top: 0.75pt solid rgba(111, 195, 223, 1.00);border-left: 0.75pt solid rgba(111, 195, 223, 1.00);border-right: 0.75pt solid rgba(111, 195, 223, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Sepal
```

Sepal

Petal

Petal

Species

Length

Width

Length

Width

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
