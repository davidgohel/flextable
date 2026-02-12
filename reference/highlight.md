# Set text highlight color

Change the text highlight color of selected rows and columns of a
flextable. A function can be used instead of fixed colors.

When `color` is a function, it is possible to color cells based on
values located in other columns; using hidden columns (those not used by
argument `colkeys`) is a common use case. The argument `source` must be
used to define the columns to be used for the color definition, and the
argument `j` must be used to define where to apply the colors and only
accepts values from `colkeys`.

## Usage

``` r
highlight(x, i = NULL, j = NULL, color = "yellow", part = "body", source = j)
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

- color:

  color to use as text highlighting color. If a function, the function
  must return a character vector of colors.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

- source:

  if color is a function, source specifies the dataset column to be used
  as an argument to `color`. This is only useful when j is colored with
  values contained in other columns.

## See also

Other sugar functions for table style:
[`align()`](https://davidgohel.github.io/flextable/reference/align.md),
[`bg()`](https://davidgohel.github.io/flextable/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/reference/color.md),
[`empty_blanks()`](https://davidgohel.github.io/flextable/reference/empty_blanks.md),
[`font()`](https://davidgohel.github.io/flextable/reference/font.md),
[`fontsize()`](https://davidgohel.github.io/flextable/reference/fontsize.md),
[`italic()`](https://davidgohel.github.io/flextable/reference/italic.md),
[`keep_with_next()`](https://davidgohel.github.io/flextable/reference/keep_with_next.md),
[`line_spacing()`](https://davidgohel.github.io/flextable/reference/line_spacing.md),
[`padding()`](https://davidgohel.github.io/flextable/reference/padding.md),
[`rotate()`](https://davidgohel.github.io/flextable/reference/rotate.md),
[`style()`](https://davidgohel.github.io/flextable/reference/style.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/reference/valign.md)

## Examples

``` r
my_color_fun <- function(x) {
  out <- rep("yellow", length(x))
  out[x < quantile(x, .75)] <- "pink"
  out[x < quantile(x, .50)] <- "wheat"
  out[x < quantile(x, .25)] <- "gray90"
  out
}
ft <- flextable(head(mtcars, n = 10))
ft <- highlight(ft, j = "disp", i = ~ disp > 200, color = "yellow")
ft <- highlight(ft, j = ~ drat + wt + qsec, color = my_color_fun)
ft


.cl-208f8ab6{}.cl-20884bf2{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-20884c06{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:rgba(255, 255, 0, 1.00);}.cl-20884c07{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:rgba(229, 229, 229, 1.00);}.cl-20884c10{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:rgba(245, 222, 179, 1.00);}.cl-20884c11{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:rgba(255, 192, 203, 1.00);}.cl-208b5202{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-208b7318{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-208b7322{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-208b732c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


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

21.0

6

160.0

110

3.90

2.620

16.46

0

1

4

4

21.0

6

160.0

110

3.90

2.875

17.02

0

1

4

4

22.8

4

108.0

93

3.85

2.320

18.61

1

1

4

1

21.4

6

258.0

110

3.08

3.215

19.44

1

0

3

1

18.7

8

360.0

175

3.15

3.440

17.02

0

0

3

2

18.1

6

225.0

105

2.76

3.460

20.22

1

0

3

1

14.3

8

360.0

245

3.21

3.570

15.84

0

0

3

4

24.4

4

146.7

62

3.69

3.190

20.00

1

0

4

2

22.8

4

140.8

95

3.92

3.150

22.90

1

0

4

2

19.2

6

167.6

123

3.92

3.440

18.30

1

0

4

4
