# Get widths and heights of flextable

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
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

## See also

Other functions for flextable size management:
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md),
[`dim_pretty()`](https://davidgohel.github.io/flextable/dev/reference/dim_pretty.md),
[`fit_to_width()`](https://davidgohel.github.io/flextable/dev/reference/fit_to_width.md),
[`flextable_dim()`](https://davidgohel.github.io/flextable/dev/reference/flextable_dim.md),
[`height()`](https://davidgohel.github.io/flextable/dev/reference/height.md),
[`hrule()`](https://davidgohel.github.io/flextable/dev/reference/hrule.md),
[`ncol_keys()`](https://davidgohel.github.io/flextable/dev/reference/ncol_keys.md),
[`nrow_part()`](https://davidgohel.github.io/flextable/dev/reference/nrow_part.md),
[`width()`](https://davidgohel.github.io/flextable/dev/reference/width.md)

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
