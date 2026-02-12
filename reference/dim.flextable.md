# Get column widths and row heights of a flextable

returns widths and heights for each table columns and rows. Values are
expressed in inches.

## Usage

``` r
# S3 method for class 'flextable'
dim(x)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

## See also

Other functions for flextable size management:
[`autofit()`](https://davidgohel.github.io/flextable/reference/autofit.md),
[`dim_pretty()`](https://davidgohel.github.io/flextable/reference/dim_pretty.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/reference/fit_to_width.md),
[`flextable_dim()`](https://davidgohel.github.io/flextable/reference/flextable_dim.md),
[`height()`](https://davidgohel.github.io/flextable/reference/height.md),
[`hrule()`](https://davidgohel.github.io/flextable/reference/hrule.md),
[`ncol_keys()`](https://davidgohel.github.io/flextable/reference/ncol_keys.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/reference/nrow_part.md),
[`width()`](https://davidgohel.github.io/flextable/reference/width.md)

## Examples

``` r
ftab <- flextable(head(iris))
dim(ftab)
#> $widths
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width      Species 
#>         0.75         0.75         0.75         0.75         0.75 
#> 
#> $heights
#> [1] 0.25 0.25 0.25 0.25 0.25 0.25 0.25
#> 
```
