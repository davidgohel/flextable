# Create border formatting with flextable defaults

Create a
[`officer::fp_border()`](https://davidgohel.github.io/officer/reference/fp_border.html)
object whose unspecified arguments inherit from
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
(border color, width).

Use `fp_border_default()` instead of
[`officer::fp_border()`](https://davidgohel.github.io/officer/reference/fp_border.html)
so that borders automatically match the table's default style.

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

Other default formatting properties:
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


.cl-87d54d32{}.cl-87cd828c{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-87cd82a0{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-87d0ec7e{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-87d1158c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 165, 0, 1.00);border-top: 1.5pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-87d11596{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 165, 0, 1.00);border-top: 1.5pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-87d115a0{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-87d115a1{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(255, 165, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 1pt solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-87d115aa{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(255, 165, 0, 1.00);border-top: 0.75pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-87d115b4{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(255, 165, 0, 1.00);border-top: 0.75pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-87d115b5{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 165, 0, 1.00);border-top: 0.75pt solid rgba(255, 165, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 1pt solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-87d115be{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(255, 165, 0, 1.00);border-top: 0.75pt solid rgba(255, 165, 0, 1.00);border-left: 1pt solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(255, 165, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


speed
```
