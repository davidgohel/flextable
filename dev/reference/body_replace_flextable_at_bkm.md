# Add flextable at bookmark location in a Word document

Use this function if you want to replace a paragraph containing a
bookmark with a flextable. As a side effect, the bookmark will be lost.

## Usage

``` r
body_replace_flextable_at_bkm(
  x,
  bookmark,
  value,
  align = "center",
  split = FALSE
)
```

## Arguments

- x:

  an rdocx object

- bookmark:

  bookmark id

- value:

  `flextable` object

- align:

  left, center (default) or right.

- split:

  set to TRUE if you want to activate Word option 'Allow row to break
  across pages'.

## See also

Other functions for officer integration:
[`body_add_flextable()`](https://davidgohel.github.io/flextable/dev/reference/body_add_flextable.md),
[`ph_with.flextable()`](https://davidgohel.github.io/flextable/dev/reference/ph_with.flextable.md),
[`rtf_add.flextable()`](https://davidgohel.github.io/flextable/dev/reference/rtf_add.flextable.md)
