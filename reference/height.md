# Set flextable rows height

control rows height for a part of the flextable when the line height
adjustment is "atleast" or "exact" (see
[`hrule()`](https://davidgohel.github.io/flextable/reference/hrule.md)).

## Usage

``` r
height(x, i = NULL, height, part = "body", unit = "in")

height_all(x, height, part = "all", unit = "in")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.

- height:

  height in inches

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.
  Value 'all' is not allowed by the function.

- unit:

  unit for height, one of "in", "cm", "mm".

## Note

This function has no effect when the rule for line height is set to
"auto" (see
[`hrule()`](https://davidgohel.github.io/flextable/reference/hrule.md)),
which is the default case, except with PowerPoint which does not support
this automatic line height adjustment feature.

## height_all

`height_all` is a convenient function for setting the same height to all
rows (selected with argument `part`).

## See also

Other functions for flextable size management:
[`autofit()`](https://davidgohel.github.io/flextable/reference/autofit.md),
[`dim.flextable()`](https://davidgohel.github.io/flextable/reference/dim.flextable.md),
[`dim_pretty()`](https://davidgohel.github.io/flextable/reference/dim_pretty.md),
[`fit_columns()`](https://davidgohel.github.io/flextable/reference/fit_columns.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/reference/fit_to_width.md),
[`flextable_dim()`](https://davidgohel.github.io/flextable/reference/flextable_dim.md),
[`hrule()`](https://davidgohel.github.io/flextable/reference/hrule.md),
[`ncol_keys()`](https://davidgohel.github.io/flextable/reference/ncol_keys.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/reference/nrow_part.md),
[`set_table_properties()`](https://davidgohel.github.io/flextable/reference/set_table_properties.md),
[`width()`](https://davidgohel.github.io/flextable/reference/width.md)

## Examples

``` r
ft_1 <- flextable(head(iris))
ft_1 <- height(ft_1, height = .5)
ft_1 <- hrule(ft_1, rule = "exact")
ft_1


.cl-4d796b8c{}.cl-4d72a57c{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-4d7584e0{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-4d7584f4{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-4d75a600{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4d75a60a{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4d75a614{width:0.75in;height:0.5in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4d75a615{width:0.75in;height:0.5in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4d75a616{width:0.75in;height:0.5in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-4d75a61e{width:0.75in;height:0.5in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
