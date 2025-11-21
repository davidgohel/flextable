# set model automatic printing as a flextable

Define
[`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)
as print method in an R Markdown document for models of class:

- lm

- glm

- models from package 'lme' and 'lme4'

- htest (t.test, chisq.test, ...)

- gam

- kmeans and pam

In a setup run chunk:

    flextable::use_model_printer()

## Usage

``` r
use_model_printer()
```

## See also

[`use_df_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_df_printer.md),
[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md)
