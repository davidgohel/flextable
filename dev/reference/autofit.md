# Adjust columns to their content size

Compute and apply the minimum widths and heights needed to display each
cell's content on a single line, with an optional extra margin (`add_w`,
`add_h`).

This function sizes columns to fit their content. It does not constrain
the table to a given total width. To enforce a maximum width, use
[`fit_columns()`](https://davidgohel.github.io/flextable/dev/reference/fit_columns.md)
(wraps text) or
[`fit_to_width()`](https://davidgohel.github.io/flextable/dev/reference/fit_to_width.md)
(shrinks font size).

Note that this function is not related to 'Microsoft Word' *Autofit*
feature.

There is an alternative to fixed-width layouts that works well with HTML
and Word output that can be set with
`set_table_properties(layout = "autofit")`, see
[`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md).

## Usage

``` r
autofit(
  x,
  add_w = 0.1,
  add_h = 0.1,
  part = c("body", "header"),
  unit = "in",
  hspans = "none"
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- add_w:

  extra width to add in inches

- add_h:

  extra height to add in inches

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

- unit:

  unit for add_h and add_w, one of "in", "cm", "mm".

- hspans:

  specifies how cells that are horizontally are included in the
  calculation. It must be one of the following values "none", "divided"
  or "included". If "none", widths of horizontally spanned cells is set
  to 0 (then do not affect the widths); if "divided", widths of
  horizontally spanned cells is divided by the number of spanned cells;
  if "included", all widths (included horizontally spanned cells) will
  be used in the calculation.

## See also

Other functions for flextable size management:
[`dim.flextable()`](https://davidgohel.github.io/flextable/dev/reference/dim.flextable.md),
[`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md),
[`fit_columns()`](https://davidgohel.github.io/flextable/dev/reference/fit_columns.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/dev/reference/fit_to_width.md),
[`flextable_dim()`](https://davidgohel.github.io/flextable/dev/reference/flextable_dim.md),
[`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md),
[`hrule()`](https://davidgohel.github.io/flextable/dev/reference/hrule.md),
[`ncol_keys()`](https://davidgohel.github.io/flextable/dev/reference/ncol_keys.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/dev/reference/nrow_part.md),
[`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md),
[`width()`](https://davidgohel.github.io/flextable/dev/reference/width.md)

## Examples

``` r
ft_1 <- flextable(head(mtcars))
ft_1


.cl-b34b4278{}.cl-b3439d8e{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-b3466564{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-b346872e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b3468738{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-b3468739{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


mpg
```
