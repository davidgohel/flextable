# Get cell-level information from a flextable

This function takes a flextable object and returns a data.frame
containing information about each cell within the flextable. The
data.frame includes details about formatting properties and position
within the row and column.

## Usage

``` r
information_data_cell(x)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

## Value

a data.frame containing information about cells:

- formatting properties,

- part (`.part`), row (`.row_id`) and column (`.col_id`).

## don't use this

These data structures should not be used, as they represent an
interpretation of the underlying data structures, which may evolve over
time.

**They are exported to enable two packages that exploit these structures
to make a transition, and should not remain available for long.**

## See also

Other information data functions:
[`information_data_chunk()`](https://davidgohel.github.io/flextable/reference/information_data_chunk.md),
[`information_data_paragraph()`](https://davidgohel.github.io/flextable/reference/information_data_paragraph.md)

## Examples

``` r
ft <- as_flextable(iris)
x <- information_data_cell(ft)
head(x)
#>    .part .row_id      .col_id vertical.align width height margin.bottom
#> 1 header       1 Sepal.Length         center    NA     NA             0
#> 2 header       1  Sepal.Width         center    NA     NA             0
#> 3 header       1 Petal.Length         center    NA     NA             0
#> 4 header       1  Petal.Width         center    NA     NA             0
#> 5 header       1      Species         center    NA     NA             0
#> 6 header       2 Sepal.Length         center    NA     NA             0
#>   margin.top margin.left margin.right border.width.bottom border.width.top
#> 1          0           0            0                 0.0              1.5
#> 2          0           0            0                 0.0              1.5
#> 3          0           0            0                 0.0              1.5
#> 4          0           0            0                 0.0              1.5
#> 5          0           0            0                 0.0              1.5
#> 6          0           0            0                 1.5              0.0
#>   border.width.left border.width.right border.color.bottom border.color.top
#> 1                 0                  0             #666666          #666666
#> 2                 0                  0             #666666          #666666
#> 3                 0                  0             #666666          #666666
#> 4                 0                  0             #666666          #666666
#> 5                 0                  0             #666666          #666666
#> 6                 0                  0             #666666          #666666
#>   border.color.left border.color.right border.style.bottom border.style.top
#> 1             black              black               solid            solid
#> 2             black              black               solid            solid
#> 3             black              black               solid            solid
#> 4             black              black               solid            solid
#> 5             black              black               solid            solid
#> 6             black              black               solid            solid
#>   border.style.left border.style.right text.direction background.color hrule
#> 1             solid              solid           lrtb      transparent  auto
#> 2             solid              solid           lrtb      transparent  auto
#> 3             solid              solid           lrtb      transparent  auto
#> 4             solid              solid           lrtb      transparent  auto
#> 5             solid              solid           lrtb      transparent  auto
#> 6             solid              solid           lrtb      transparent  auto
```
