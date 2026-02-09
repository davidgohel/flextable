# Border formatting properties

Create a
[`officer::fp_border()`](https://davidgohel.github.io/officer/reference/fp_border.html)
object that uses defaut values defined in flextable defaults formatting
properties, i.e. default border color (see
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)).

## Usage

``` r
fp_border_default(
  color = flextable_global$defaults$border.color,
  style = "solid",
  width = flextable_global$defaults$border.width
)
```

## Arguments

- color:

  border color - single character value (e.g. "#000000" or "black")

- style:

  border style - single character value : See Details for supported
  border styles.

- width:

  border width - an integer value : 0\>= value

## See also

[`hline()`](https://davidgohel.github.io/flextable/dev/reference/hline.md),
[`vline()`](https://davidgohel.github.io/flextable/dev/reference/vline.md)

Other functions for defining formatting properties:
[`fp_text_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_text_default.md)

## Examples

``` r
library(flextable)

set_flextable_defaults(
  border.color = "orange"
)

z <- flextable(head(cars))
z <- theme_vanilla(z)
z <- vline(
  z,
  j = 1, part = "all",
  border = officer::fp_border()
)
z <- vline(
  z,
  j = 2, part = "all",
  border = fp_border_default()
)
z


.cl-32700e46{}.cl-32697d74{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-32697d7e{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-326c50b2{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-326c72c2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 165, 0, 1.00);border-top: 1.5pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-326c72cc{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 165, 0, 1.00);border-top: 1.5pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-326c72d6{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-326c72d7{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-326c72e0{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(255, 165, 0, 1.00);border-top: 0.75pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-326c72e1{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(255, 165, 0, 1.00);border-top: 0.75pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-326c72e2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 165, 0, 1.00);border-top: 0.75pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-326c72ea{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 165, 0, 1.00);border-top: 0.75pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


speed
```

dist

4

2

4

10

7

4

7

22

8

16

9

10

[init_flextable_defaults](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)()
