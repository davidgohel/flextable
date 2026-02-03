# Split column names using a separator into multiple rows

This function is used to separate and place individual labels in their
own rows if your variable names contain multiple delimited labels.
![add_header
illustration](https://www.ardata.fr/img/flextable-imgs/flextable-016.png)

## Usage

``` r
separate_header(
  x,
  opts = c("span-top", "center-hspan", "bottom-vspan", "default-theme"),
  split = "[_\\.]",
  fixed = FALSE
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- opts:

  Optional treatments to apply to the resulting header part. This should
  be a character vector with support for multiple values.

  Supported values include:

  - "span-top": This operation spans empty cells with the first
    non-empty cell, applied column by column.

  - "center-hspan": Center the cells that are horizontally spanned.

  - "bottom-vspan": Aligns to the bottom the cells treated at the when
    "span-top" is applied.

  - "default-theme": Applies the theme set in
    `set_flextable_defaults(theme_fun = ...)` to the new header part.

- split:

  a regular expression (unless `fixed = TRUE`) to use for splitting.

- fixed:

  logical. If TRUE match `split` exactly, otherwise use regular
  expressions.

## See also

Other functions for row and column operations in a flextable:
[`add_body()`](https://davidgohel.github.io/flextable/dev/reference/add_body.md),
[`add_body_row()`](https://davidgohel.github.io/flextable/dev/reference/add_body_row.md),
[`add_footer()`](https://davidgohel.github.io/flextable/dev/reference/add_footer.md),
[`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md),
[`add_footer_row()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_row.md),
[`add_header()`](https://davidgohel.github.io/flextable/dev/reference/add_header.md),
[`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md),
[`add_header_row()`](https://davidgohel.github.io/flextable/dev/reference/add_header_row.md),
[`delete_columns()`](https://davidgohel.github.io/flextable/dev/reference/delete_columns.md),
[`delete_part()`](https://davidgohel.github.io/flextable/dev/reference/delete_part.md),
[`set_header_footer_df`](https://davidgohel.github.io/flextable/dev/reference/set_header_footer_df.md),
[`set_header_labels()`](https://davidgohel.github.io/flextable/dev/reference/set_header_labels.md)

## Examples

``` r
library(flextable)

x <- data.frame(
  Species = as.factor(c("setosa", "versicolor", "virginica")),
  Sepal.Length_mean = c(5.006, 5.936, 6.588),
  Sepal.Length_sd = c(0.35249, 0.51617, 0.63588),
  Sepal.Width_mean = c(3.428, 2.77, 2.974),
  Sepal.Width_sd = c(0.37906, 0.3138, 0.3225),
  Petal.Length_mean = c(1.462, 4.26, 5.552),
  Petal.Length_sd = c(0.17366, 0.46991, 0.55189),
  Petal.Width_mean = c(0.246, 1.326, 2.026),
  Petal.Width_sd = c(0.10539, 0.19775, 0.27465)
)

ft_1 <- flextable(x)
ft_1 <- colformat_double(ft_1, digits = 2)
ft_1 <- theme_box(ft_1)
ft_1 <- separate_header(
  x = ft_1,
  opts = c("span-top", "bottom-vspan")
)
ft_1


.cl-5be038c8{}.cl-5bd943e2{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-5bd943f6{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-5bdc2300{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-5bdc2314{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-5bdc231e{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-5bdc4826{width:0.75in;background-color:transparent;vertical-align: bottom;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5bdc4830{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5bdc4831{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5bdc483a{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-5bdc483b{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0.75pt solid rgba(102, 102, 102, 1.00);border-right: 0.75pt solid rgba(102, 102, 102, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Species
```

Sepal

Petal

Length

Width

Length

Width

mean

sd

mean

sd

mean

sd

mean

sd

setosa

5.01

0.35

3.43

0.38

1.46

0.17

0.25

0.11

versicolor

5.94

0.52

2.77

0.31

4.26

0.47

1.33

0.20

virginica

6.59

0.64

2.97

0.32

5.55

0.55

2.03

0.27
