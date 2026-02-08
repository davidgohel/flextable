# Get optimal width and height of a flextable grob

returns the optimal width and height for the grob, according to the grob
generation parameters.

## Usage

``` r
# S3 method for class 'flextableGrob'
dim(x)
```

## Arguments

- x:

  a flextableGrob object

## Value

a named list with two elements, `width` and `height`. Values are
expressed in inches.

## Examples

``` r
ftab <- flextable(head(iris))
gr <- gen_grob(ftab)
dim(gr)
#> $width
#> [1] 5.065769
#> 
#> $height
#> [1] 1.813395
#> 
```
