# Insert group-label rows into a data frame

Repeated consecutive values of group columns will be used to define the
title of the groups and will be added as a row title.

## Usage

``` r
as_grouped_data(x, groups, columns = NULL, expand_single = TRUE)
```

## Arguments

- x:

  dataset

- groups:

  columns names to be used as row separators.

- columns:

  columns names to keep

- expand_single:

  if FALSE, groups with only one row will not be expanded with a title
  row. If TRUE (the default), single row groups and multi-row groups are
  all restructured.

## See also

[`as_flextable.grouped_data()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.grouped_data.md)

## Examples

``` r
# as_grouped_data -----
library(data.table)
CO2 <- CO2
setDT(CO2)
CO2$conc <- as.integer(CO2$conc)

data_co2 <- dcast(CO2, Treatment + conc ~ Type,
  value.var = "uptake", fun.aggregate = mean
)
data_co2
#> Key: <Treatment, conc>
#>      Treatment  conc   Quebec Mississippi
#>         <fctr> <int>    <num>       <num>
#>  1: nonchilled    95 15.26667    11.30000
#>  2: nonchilled   175 30.03333    20.20000
#>  3: nonchilled   250 37.40000    27.53333
#>  4: nonchilled   350 40.36667    29.90000
#>  5: nonchilled   500 39.60000    30.60000
#>  6: nonchilled   675 41.50000    30.53333
#>  7: nonchilled  1000 43.16667    31.60000
#>  8:    chilled    95 12.86667     9.60000
#>  9:    chilled   175 24.13333    14.76667
#> 10:    chilled   250 34.46667    16.10000
#> 11:    chilled   350 35.80000    16.60000
#> 12:    chilled   500 36.66667    16.63333
#> 13:    chilled   675 37.50000    18.26667
#> 14:    chilled  1000 40.83333    18.73333
data_co2 <- as_grouped_data(x = data_co2, groups = c("Treatment"))
data_co2
#>     Treatment conc   Quebec Mississippi
#> 1  nonchilled   NA       NA          NA
#> 2        <NA>   95 15.26667    11.30000
#> 3        <NA>  175 30.03333    20.20000
#> 4        <NA>  250 37.40000    27.53333
#> 5        <NA>  350 40.36667    29.90000
#> 6        <NA>  500 39.60000    30.60000
#> 7        <NA>  675 41.50000    30.53333
#> 8        <NA> 1000 43.16667    31.60000
#> 9     chilled   NA       NA          NA
#> 10       <NA>   95 12.86667     9.60000
#> 11       <NA>  175 24.13333    14.76667
#> 12       <NA>  250 34.46667    16.10000
#> 13       <NA>  350 35.80000    16.60000
#> 14       <NA>  500 36.66667    16.63333
#> 15       <NA>  675 37.50000    18.26667
#> 16       <NA> 1000 40.83333    18.73333
```
