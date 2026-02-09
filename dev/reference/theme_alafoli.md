# Apply alafoli theme

Apply alafoli theme

## Usage

``` r
theme_alafoli(x)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

## behavior

Theme functions are not like 'ggplot2' themes. They are applied to the
existing table **immediately**. If you add a row in the footer, the new
row is not formatted with the theme. The theme function applies the
theme only to existing elements when the function is called.

That is why theme functions should be applied after all elements of the
table have been added (mainly additionnal header or footer rows).

If you want to automatically apply a theme function to each flextable,
you can use the `theme_fun` argument of
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md);
be aware that this theme function is applied as the last instruction
when calling
[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md) -
so if you add headers or footers to the array, they will not be
formatted with the theme.

You can also use the `post_process_html` argument of
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
(or `post_process_pdf`, `post_process_docx`, `post_process_pptx`) to
specify a theme to be applied systematically before the
[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md)
is printed; in this case, don't forget to take care that the theme
doesn't override any formatting done before the print statement.

## See also

Other functions related to themes:
[`get_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/get_flextable_defaults.md),
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md),
[`theme_apa()`](https://davidgohel.github.io/flextable/dev/reference/theme_apa.md),
[`theme_booktabs()`](https://davidgohel.github.io/flextable/dev/reference/theme_booktabs.md),
[`theme_borderless()`](https://davidgohel.github.io/flextable/dev/reference/theme_borderless.md),
[`theme_box()`](https://davidgohel.github.io/flextable/dev/reference/theme_box.md),
[`theme_tron()`](https://davidgohel.github.io/flextable/dev/reference/theme_tron.md),
[`theme_tron_legacy()`](https://davidgohel.github.io/flextable/dev/reference/theme_tron_legacy.md),
[`theme_vader()`](https://davidgohel.github.io/flextable/dev/reference/theme_vader.md),
[`theme_vanilla()`](https://davidgohel.github.io/flextable/dev/reference/theme_vanilla.md),
[`theme_zebra()`](https://davidgohel.github.io/flextable/dev/reference/theme_zebra.md)

## Examples

``` r
ft <- flextable(head(airquality))
ft <- theme_alafoli(ft)
ft


.cl-c3ba1e78{}.cl-c3b1e9b0{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(102, 102, 102, 1.00);background-color:transparent;}.cl-c3b62430{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:3pt;padding-right:3pt;line-height: 1;background-color:transparent;}.cl-c3b646f4{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-c3b646fe{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Ozone
```

Solar.R

Wind

Temp

Month

Day

41

190

7.4

67

5

1

36

118

8.0

72

5

2

12

149

12.6

74

5

3

18

313

11.5

62

5

4

14.3

56

5

5

28

14.9

66

5

6
