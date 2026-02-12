# Calculate optimal column widths and row heights

return minimum estimated widths and heights for each table columns and
rows in inches.

## Usage

``` r
dim_pretty(x, part = "all", unit = "in", hspans = "none")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

- unit:

  unit for returned values, one of "in", "cm", "mm".

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
[`autofit()`](https://davidgohel.github.io/flextable/reference/autofit.md),
[`dim.flextable()`](https://davidgohel.github.io/flextable/reference/dim.flextable.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/reference/fit_to_width.md),
[`flextable_dim()`](https://davidgohel.github.io/flextable/reference/flextable_dim.md),
[`height()`](https://davidgohel.github.io/flextable/reference/height.md),
[`hrule()`](https://davidgohel.github.io/flextable/reference/hrule.md),
[`ncol_keys()`](https://davidgohel.github.io/flextable/reference/ncol_keys.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/reference/nrow_part.md),
[`width()`](https://davidgohel.github.io/flextable/reference/width.md)

## Examples

``` r
ftab <- flextable(head(mtcars))
dim_pretty(ftab)
#> $widths
#>  [1] 0.5279654 0.4020431 0.5011845 0.4767908 0.5253545 0.6225563 0.6225563
#>  [8] 0.3551952 0.4276304 0.5325905 0.5225943
#> 
#> $heights
#> [1] 0.3330395 0.3007383 0.3007383 0.3007383 0.3007383 0.3007383 0.3007383
#> 
```
