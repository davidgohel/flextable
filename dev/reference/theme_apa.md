# Apply APA theme

Apply theme APA (the stylistic style of the American Psychological
Association) to a flextable

## Usage

``` r
theme_apa(x, ...)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- ...:

  unused

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
[`theme_alafoli()`](https://davidgohel.github.io/flextable/dev/reference/theme_alafoli.md),
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
ft <- flextable(head(mtcars * 22.22))
ft <- theme_apa(ft)
ft


.cl-3bbad736{}.cl-3bb441dc{font-family:'Times New Roman';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-3bb6fcc4{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 2;background-color:transparent;}.cl-3bb71f92{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(0, 0, 0, 1.00);border-top: 0.75pt solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3bb71f9c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3bb71fa6{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


mpg
```

cyl

disp

hp

drat

wt

qsec

vs

am

gear

carb

466.62

133.32

3,555.20

2,444.20

86.66

58.22

365.74

0.00

22.22

88.88

88.88

466.62

133.32

3,555.20

2,444.20

86.66

63.88

378.18

0.00

22.22

88.88

88.88

506.62

88.88

2,399.76

2,066.46

85.55

51.55

413.51

22.22

22.22

88.88

22.22

475.51

133.32

5,732.76

2,444.20

68.44

71.44

431.96

22.22

0.00

66.66

22.22

415.51

177.76

7,999.20

3,888.50

69.99

76.44

378.18

0.00

0.00

66.66

44.44

402.18

133.32

4,999.50

2,333.10

61.33

76.88

449.29

22.22

0.00

66.66

22.22
