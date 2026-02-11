# Format count as '(N=XX)' for column headers

Format counts as `\n(N=XX)` for appending sample sizes to column titles.

## Usage

``` r
fmt_header_n(n, newline = TRUE)
```

## Arguments

- n:

  count values

- newline:

  indicates to prefix the text with a new line (sof return).

## See also

[`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md),
[`mk_par()`](https://davidgohel.github.io/flextable/dev/reference/compose.md)

Other text formatter functions:
[`fmt_2stats()`](https://davidgohel.github.io/flextable/dev/reference/fmt_2stats.md),
[`fmt_avg_dev()`](https://davidgohel.github.io/flextable/dev/reference/fmt_avg_dev.md),
[`fmt_dbl()`](https://davidgohel.github.io/flextable/dev/reference/fmt_dbl.md),
[`fmt_int()`](https://davidgohel.github.io/flextable/dev/reference/fmt_int.md),
[`fmt_n_percent()`](https://davidgohel.github.io/flextable/dev/reference/fmt_n_percent.md),
[`fmt_pct()`](https://davidgohel.github.io/flextable/dev/reference/fmt_pct.md),
[`fmt_signif_after_zeros()`](https://davidgohel.github.io/flextable/dev/reference/fmt_signif_after_zeros.md)

## Examples

``` r
library(flextable)

df <- data.frame(zz = 1)

ft_1 <- flextable(df)
ft_1 <- append_chunks(
  x = ft_1, j = 1, part = "header",
  value = as_chunk(fmt_header_n(200))
)
ft_1 <- autofit(ft_1)
ft_1


.cl-25f361fa{}.cl-25ed3d66{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-25efe8d6{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-25f008d4{width:0.938in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-25f008de{width:0.938in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

zz
(N=200)
```

1
