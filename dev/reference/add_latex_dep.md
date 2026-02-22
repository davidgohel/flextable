# Add latex dependencies

Manually add flextable latex dependencies to the knitr session via
[`knitr::knit_meta_add()`](https://rdrr.io/pkg/knitr/man/knit_meta.html).

When enabling caching in 'R Markdown' documents for PDF output, the
flextable cached result is used directly. Call `add_latex_dep()` in a
non cached chunk so that flextable latex dependencies are added to knitr
metadata.

## Usage

``` r
add_latex_dep(float = FALSE, wrapfig = FALSE)
```

## Arguments

- float:

  load package 'float'

- wrapfig:

  load package 'wrapfig'

## See also

[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)

Other flextable configuration:
[`use_df_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_df_printer.md),
[`use_flextable_qmd()`](https://davidgohel.github.io/flextable/dev/reference/use_flextable_qmd.md),
[`use_model_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_model_printer.md)

## Examples

``` r
add_latex_dep()
```
