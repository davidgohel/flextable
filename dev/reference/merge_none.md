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

Other cell merging functions:
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


.cl-c72fd966{}.cl-c7296356{font-family:'Liberation Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(223, 116, 12, 1.00);background-color:transparent;}.cl-c729636a{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 230, 77, 1.00);background-color:transparent;}.cl-c72c1c68{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c72c1c7c{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-c72c3c34{width:0.75in;background-color:rgba(12, 20, 31, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(111, 195, 223, 1.00);border-top: 0.75pt solid rgba(111, 195, 223, 1.00);border-left: 0.75pt solid rgba(111, 195, 223, 1.00);border-right: 0.75pt solid rgba(111, 195, 223, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c72c3c3e{width:0.75in;background-color:rgba(12, 20, 31, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(111, 195, 223, 1.00);border-top: 0.75pt solid rgba(111, 195, 223, 1.00);border-left: 0.75pt solid rgba(111, 195, 223, 1.00);border-right: 0.75pt solid rgba(111, 195, 223, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c72c3c3f{width:0.75in;background-color:rgba(12, 20, 31, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(111, 195, 223, 1.00);border-top: 0.75pt solid rgba(111, 195, 223, 1.00);border-left: 0.75pt solid rgba(111, 195, 223, 1.00);border-right: 0.75pt solid rgba(111, 195, 223, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c72c3c52{width:0.75in;background-color:rgba(12, 20, 31, 1.00);vertical-align: middle;border-bottom: 0.75pt solid rgba(111, 195, 223, 1.00);border-top: 0.75pt solid rgba(111, 195, 223, 1.00);border-left: 0.75pt solid rgba(111, 195, 223, 1.00);border-right: 0.75pt solid rgba(111, 195, 223, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Sepal
```
