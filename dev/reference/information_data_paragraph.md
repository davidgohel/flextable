# Get paragraph-level information from a flextable

This function takes a flextable object and returns a data.frame
containing information about each paragraph within the flextable. The
data.frame includes details about formatting properties and position
within the row and column.

## Usage

``` r
information_data_paragraph(x)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

## Value

a data.frame containing information about paragraphs:

- formatting properties,

- part (`.part`), row (`.row_id`) and column (`.col_id`).

## don't use this

These data structures should not be used, as they represent an
interpretation of the underlying data structures, which may evolve over
time.

**They are exported to enable two packages that exploit these structures
to make a transition, and should not remain available for long.**

## See also

Other table data extraction:
[`information_data_cell()`](https://davidgohel.github.io/flextable/dev/reference/information_data_cell.md),
[`information_data_chunk()`](https://davidgohel.github.io/flextable/dev/reference/information_data_chunk.md)

## Examples

``` r
ft <- as_flextable(iris)
x <- information_data_paragraph(ft)
head(x)
#>    .part .row_id      .col_id text.align padding.bottom padding.top
#> 1 header       1 Sepal.Length      right              5           5
#> 2 header       1  Sepal.Width      right              5           5
#> 3 header       1 Petal.Length      right              5           5
#> 4 header       1  Petal.Width      right              5           5
#> 5 header       1      Species       left              5           5
#> 6 header       2 Sepal.Length      right              5           5
#>   padding.left padding.right line_spacing border.width.bottom border.width.top
#> 1            5             5            1                   0                0
#> 2            5             5            1                   0                0
#> 3            5             5            1                   0                0
#> 4            5             5            1                   0                0
#> 5            5             5            1                   0                0
#> 6            5             5            1                   0                0
#>   border.width.left border.width.right border.color.bottom border.color.top
#> 1                 0                  0               black            black
#> 2                 0                  0               black            black
#> 3                 0                  0               black            black
#> 4                 0                  0               black            black
#> 5                 0                  0               black            black
#> 6                 0                  0               black            black
#>   border.color.left border.color.right border.style.bottom border.style.top
#> 1             black              black               solid            solid
#> 2             black              black               solid            solid
#> 3             black              black               solid            solid
#> 4             black              black               solid            solid
#> 5             black              black               solid            solid
#> 6             black              black               solid            solid
#>   border.style.left border.style.right shading.color keep_with_next word_style
#> 1             solid              solid   transparent          FALSE     Normal
#> 2             solid              solid   transparent          FALSE     Normal
#> 3             solid              solid   transparent          FALSE     Normal
#> 4             solid              solid   transparent          FALSE     Normal
#> 5             solid              solid   transparent          FALSE     Normal
#> 6             solid              solid   transparent          FALSE     Normal
#>   tabs
#> 1 <NA>
#> 2 <NA>
#> 3 <NA>
#> 4 <NA>
#> 5 <NA>
#> 6 <NA>
```
