# Format mean and standard deviation as text

Format means and standard deviations as `mean (sd)`.

## Usage

``` r
fmt_avg_dev(avg, dev, digit1 = 1, digit2 = 1)
```

## Arguments

- avg, dev:

  mean and sd values

- digit1, digit2:

  number of digits to show when printing 'mean' and 'sd'.

## See also

[`tabulator()`](https://davidgohel.github.io/flextable/reference/tabulator.md),
[`mk_par()`](https://davidgohel.github.io/flextable/reference/compose.md)

Other text formatter functions:
[`fmt_2stats()`](https://davidgohel.github.io/flextable/reference/fmt_2stats.md),
[`fmt_dbl()`](https://davidgohel.github.io/flextable/reference/fmt_dbl.md),
[`fmt_header_n()`](https://davidgohel.github.io/flextable/reference/fmt_header_n.md),
[`fmt_int()`](https://davidgohel.github.io/flextable/reference/fmt_int.md),
[`fmt_n_percent()`](https://davidgohel.github.io/flextable/reference/fmt_n_percent.md),
[`fmt_pct()`](https://davidgohel.github.io/flextable/reference/fmt_pct.md),
[`fmt_signif_after_zeros()`](https://davidgohel.github.io/flextable/reference/fmt_signif_after_zeros.md)

## Examples

``` r
library(flextable)

df <- data.frame(avg = 1:3 * 3, sd = 1:3)

ft_1 <- flextable(df, col_keys = "avg")
ft_1 <- mk_par(
  x = ft_1, j = 1, part = "body",
  value = as_paragraph(fmt_avg_dev(avg = avg, dev = sd))
)
ft_1 <- autofit(ft_1)
ft_1


.cl-1c7782da{}.cl-1c6fbed8{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-1c7282c6{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-1c72a42c{width:0.939in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1c72a436{width:0.939in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-1c72a440{width:0.939in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

avg
```

3.0 (1.0)

6.0 (2.0)

9.0 (3.0)
