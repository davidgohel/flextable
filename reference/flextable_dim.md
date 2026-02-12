# Get overall width and height of a flextable

Returns the width, height and aspect ratio of a flextable in a named
list. The aspect ratio is the ratio corresponding to `height/width`.

Names of the list are `widths`, `heights` and `aspect_ratio`.

## Usage

``` r
flextable_dim(x, unit = "in")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- unit:

  unit for returned values, one of "in", "cm", "mm".

## See also

Other functions for flextable size management:
[`autofit()`](https://davidgohel.github.io/flextable/reference/autofit.md),
[`dim.flextable()`](https://davidgohel.github.io/flextable/reference/dim.flextable.md),
[`dim_pretty()`](https://davidgohel.github.io/flextable/reference/dim_pretty.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/reference/fit_to_width.md),
[`height()`](https://davidgohel.github.io/flextable/reference/height.md),
[`hrule()`](https://davidgohel.github.io/flextable/reference/hrule.md),
[`ncol_keys()`](https://davidgohel.github.io/flextable/reference/ncol_keys.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/reference/nrow_part.md),
[`width()`](https://davidgohel.github.io/flextable/reference/width.md)

## Examples

``` r
ftab <- flextable(head(iris))
flextable_dim(ftab)
#> $widths
#> [1] 3.75
#> 
#> $heights
#> [1] 1.75
#> 
#> $aspect_ratio
#> [1] 0.4666667
#> 
ftab <- autofit(ftab)
flextable_dim(ftab)
#> $widths
#> [1] 5.774125
#> 
#> $heights
#> [1] 2.837469
#> 
#> $aspect_ratio
#> [1] 0.4914111
#> 
```
