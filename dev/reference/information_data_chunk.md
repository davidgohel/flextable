# Get chunk-level content information from a flextable

This function takes a flextable object and returns a data.frame
containing information about each text chunk within the flextable. The
data.frame includes details such as the text content, formatting
properties, position within the paragraph, paragraph row, and column.

## Usage

``` r
information_data_chunk(x, expand_special_chars = TRUE)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

## Value

a data.frame containing information about chunks:

- text chunk (column `txt`) and other content (`url` for the linked url,
  `eq_data` for content of type 'equation', `word_field_data` for
  content of type 'word_field' and `img_data` for content of type
  'image'),

- formatting properties,

- part (`.part`), position within the paragraph (`.chunk_index`), row
  (`.row_id`) and column (`.col_id`).

## don't use this

These data structures should not be used, as they represent an
interpretation of the underlying data structures, which may evolve over
time.

**They are exported to enable two packages that exploit these structures
to make a transition, and should not remain available for long.**

## See also

Other table data extraction:
[`information_data_cell()`](https://davidgohel.github.io/flextable/dev/reference/information_data_cell.md),
[`information_data_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/information_data_paragraph.md)

## Examples

``` r
ft <- as_flextable(iris)
x <- information_data_chunk(ft)
head(x)
#>    .part .row_id      .col_id .chunk_index          txt font.size italic  bold
#> 1 header       1 Sepal.Length            1 Sepal.Length        11  FALSE FALSE
#> 2 header       1  Sepal.Width            1  Sepal.Width        11  FALSE FALSE
#> 3 header       1 Petal.Length            1 Petal.Length        11  FALSE FALSE
#> 4 header       1  Petal.Width            1  Petal.Width        11  FALSE FALSE
#> 5 header       1      Species            1      Species        11  FALSE FALSE
#> 6 header       2 Sepal.Length            1      numeric        11  FALSE FALSE
#>   underlined strike   color shading.color     font.family hansi.family
#> 1      FALSE  FALSE   black   transparent Liberation Sans  DejaVu Sans
#> 2      FALSE  FALSE   black   transparent Liberation Sans  DejaVu Sans
#> 3      FALSE  FALSE   black   transparent Liberation Sans  DejaVu Sans
#> 4      FALSE  FALSE   black   transparent Liberation Sans  DejaVu Sans
#> 5      FALSE  FALSE   black   transparent Liberation Sans  DejaVu Sans
#> 6      FALSE  FALSE #999999   transparent Liberation Sans  DejaVu Sans
#>   eastasia.family   cs.family vertical.align width height  url eq_data
#> 1     DejaVu Sans DejaVu Sans       baseline    NA     NA <NA>    <NA>
#> 2     DejaVu Sans DejaVu Sans       baseline    NA     NA <NA>    <NA>
#> 3     DejaVu Sans DejaVu Sans       baseline    NA     NA <NA>    <NA>
#> 4     DejaVu Sans DejaVu Sans       baseline    NA     NA <NA>    <NA>
#> 5     DejaVu Sans DejaVu Sans       baseline    NA     NA <NA>    <NA>
#> 6     DejaVu Sans DejaVu Sans       baseline    NA     NA <NA>    <NA>
#>   word_field_data qmd_data img_data
#> 1            <NA>     <NA>     NULL
#> 2            <NA>     <NA>     NULL
#> 3            <NA>     <NA>     NULL
#> 4            <NA>     <NA>     NULL
#> 5            <NA>     <NA>     NULL
#> 6            <NA>     <NA>     NULL
```
