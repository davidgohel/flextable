# flextable old functions

The function is maintained for compatibility with old codes mades by
users but be aware it produces the same exact object than
[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md).
This function should be deprecated then removed in the next versions.

## Usage

``` r
regulartable(data, col_keys = names(data), cwidth = 0.75, cheight = 0.25)
```

## Arguments

- data:

  dataset

- col_keys:

  columns names/keys to display. If some column names are not in the
  dataset, they will be added as blank columns by default.

- cwidth, cheight:

  initial width and height to use for cell sizes in inches.
