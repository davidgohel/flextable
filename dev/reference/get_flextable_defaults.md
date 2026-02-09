# Get flextable defaults formatting properties

The current formatting properties are automatically applied to every
flextable you produce. These default values are returned by this
function.

## Usage

``` r
get_flextable_defaults()
```

## Value

a list containing default values.

## See also

Other functions related to themes:
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md),
[`theme_alafoli()`](https://davidgohel.github.io/flextable/dev/reference/theme_alafoli.md),
[`theme_apa()`](https://davidgohel.github.io/flextable/dev/reference/theme_apa.md),
[`theme_booktabs()`](https://davidgohel.github.io/flextable/dev/reference/theme_booktabs.md),
[`theme_borderless()`](https://davidgohel.github.io/flextable/dev/reference/theme_borderless.md),
[`theme_box()`](https://davidgohel.github.io/flextable/dev/reference/theme_box.md),
[`theme_tron()`](https://davidgohel.github.io/flextable/dev/reference/theme_tron.md),
[`theme_tron_legacy()`](https://davidgohel.github.io/flextable/dev/reference/theme_tron_legacy.md),
[`theme_vader()`](https://davidgohel.github.io/flextable/dev/reference/theme_vader.md),
[`theme_vanilla()`](https://davidgohel.github.io/flextable/dev/reference/theme_vanilla.md),
[`theme_zebra()`](https://davidgohel.github.io/flextable/dev/reference/theme_zebra.md)

## Examples

``` r
get_flextable_defaults()
#> ## style properties
#>            property           value
#> 1       font.family Liberation Sans
#> 2      hansi.family     DejaVu Sans
#> 3   eastasia.family     DejaVu Sans
#> 4         cs.family     DejaVu Sans
#> 5         font.size              11
#> 6        font.color           black
#> 7        text.align            left
#> 8    padding.bottom               5
#> 9       padding.top               5
#> 10     padding.left               5
#> 11    padding.right               5
#> 12     line_spacing               1
#> 13     border.color         #666666
#> 14     border.width            0.75
#> 15 background.color     transparent
#> 
#> ## cell content settings
#>       property             value
#> 1 decimal.mark                 .
#> 2     big.mark                 ,
#> 3       digits                 1
#> 4   pct_digits                 1
#> 5       na_str                  
#> 6      nan_str                  
#> 7     fmt_date          %Y-%m-%d
#> 8 fmt_datetime %Y-%m-%d %H:%M:%S
#> 
#> ## table.layout is: fixed 
#> ## default theme is: theme_booktabs 
```
