# Number of columns

returns the number of columns displayed

## Usage

``` r
ncol_keys(x)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

## See also

Other functions for flextable size management:
[`autofit()`](https://davidgohel.github.io/flextable/reference/autofit.md),
[`dim.flextable()`](https://davidgohel.github.io/flextable/reference/dim.flextable.md),
[`dim_pretty()`](https://davidgohel.github.io/flextable/reference/dim_pretty.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/reference/fit_to_width.md),
[`flextable_dim()`](https://davidgohel.github.io/flextable/reference/flextable_dim.md),
[`height()`](https://davidgohel.github.io/flextable/reference/height.md),
[`hrule()`](https://davidgohel.github.io/flextable/reference/hrule.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/reference/nrow_part.md),
[`width()`](https://davidgohel.github.io/flextable/reference/width.md)

## Examples

``` r
library(flextable)
ft <- qflextable(head(cars))
ncol_keys(ft)
#> [1] 2
```
