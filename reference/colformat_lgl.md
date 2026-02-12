# Format logical cells

Format logical cells in a flextable.

## Usage

``` r
colformat_lgl(
  x,
  i = NULL,
  j = NULL,
  true = "true",
  false = "false",
  na_str = get_flextable_defaults()$na_str,
  nan_str = get_flextable_defaults()$nan_str,
  prefix = "",
  suffix = ""
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.

- false, true:

  string to be used for logical

- na_str, nan_str:

  string to be used for NA and NaN values

- prefix, suffix:

  string to be used as prefix or suffix

## See also

Other cells formatters:
[`colformat_char()`](https://davidgohel.github.io/flextable/reference/colformat_char.md),
[`colformat_date()`](https://davidgohel.github.io/flextable/reference/colformat_date.md),
[`colformat_datetime()`](https://davidgohel.github.io/flextable/reference/colformat_datetime.md),
[`colformat_double()`](https://davidgohel.github.io/flextable/reference/colformat_double.md),
[`colformat_image()`](https://davidgohel.github.io/flextable/reference/colformat_image.md),
[`colformat_int()`](https://davidgohel.github.io/flextable/reference/colformat_int.md),
[`colformat_num()`](https://davidgohel.github.io/flextable/reference/colformat_num.md),
[`set_formatter()`](https://davidgohel.github.io/flextable/reference/set_formatter.md)

## Examples

``` r
dat <- data.frame(a = c(TRUE, FALSE), b = c(FALSE, TRUE))

z <- flextable(dat)
z <- colformat_lgl(x = z, j = c("a", "b"))
autofit(z)


.cl-16f4d2ea{}.cl-16ee9a2e{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-16f14c42{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-16f16c4a{width:0.649in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-16f16c54{width:0.649in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-16f16c5e{width:0.649in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


a
```

b

true

false

false

true
