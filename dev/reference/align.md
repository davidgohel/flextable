# Set text alignment

Change the text alignment of selected rows and columns of a flextable.

## Usage

``` r
align(
  x,
  i = NULL,
  j = NULL,
  align = "left",
  part = c("body", "header", "footer", "all")
)

align_text_col(x, align = "left", header = TRUE, footer = TRUE)

align_nottext_col(x, align = "right", header = TRUE, footer = TRUE)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- i:

  row selector, see section *Row selection with the `i` parameter* in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`flextable column selection`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- align:

  text alignment - a single character value, or a vector of character
  values equal in length to the number of columns selected by `j`.
  Expected values must be from the set ('left', 'right', 'center', or
  'justify').

  If the number of columns is a multiple of the length of the `align`
  parameter, then the values in `align` will be recycled across the
  remaining columns.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

- header:

  should the header be aligned with the body

- footer:

  should the footer be aligned with the body

## See also

Other sugar functions for table style:
[`bg()`](https://davidgohel.github.io/flextable/dev/reference/bg.md),
[`bold()`](https://davidgohel.github.io/flextable/dev/reference/bold.md),
[`color()`](https://davidgohel.github.io/flextable/dev/reference/color.md),
[`empty_blanks()`](https://davidgohel.github.io/flextable/dev/reference/empty_blanks.md),
[`font()`](https://davidgohel.github.io/flextable/dev/reference/font.md),
[`fontsize()`](https://davidgohel.github.io/flextable/dev/reference/fontsize.md),
[`highlight()`](https://davidgohel.github.io/flextable/dev/reference/highlight.md),
[`italic()`](https://davidgohel.github.io/flextable/dev/reference/italic.md),
[`keep_with_next()`](https://davidgohel.github.io/flextable/dev/reference/keep_with_next.md),
[`line_spacing()`](https://davidgohel.github.io/flextable/dev/reference/line_spacing.md),
[`padding()`](https://davidgohel.github.io/flextable/dev/reference/padding.md),
[`rotate()`](https://davidgohel.github.io/flextable/dev/reference/rotate.md),
[`tab_settings()`](https://davidgohel.github.io/flextable/dev/reference/tab_settings.md),
[`valign()`](https://davidgohel.github.io/flextable/dev/reference/valign.md)

## Examples

``` r
# Table of 6 columns
ft_car <- flextable(head(mtcars)[, 2:7])

# All 6 columns right aligned
align(ft_car, align = "right", part = "all")


.cl-02653316{}.cl-025e5712{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-02614ef4{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-026172b2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-026172bc{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-026172bd{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


cyl
```

disp

hp

drat

wt

qsec

6

160

110

3.90

2.620

16.46

6

160

110

3.90

2.875

17.02

4

108

93

3.85

2.320

18.61

6

258

110

3.08

3.215

19.44

8

360

175

3.15

3.440

17.02

6

225

105

2.76

3.460

20.22

\# Manually specify alignment of each column align( ft_car, align =
[c](https://rdrr.io/r/base/c.html)("left", "right", "left", "center",
"center", "right"), part = "all" )

| cyl | disp | hp  | drat | wt    | qsec  |
|-----|------|-----|------|-------|-------|
| 6   | 160  | 110 | 3.90 | 2.620 | 16.46 |
| 6   | 160  | 110 | 3.90 | 2.875 | 17.02 |
| 4   | 108  | 93  | 3.85 | 2.320 | 18.61 |
| 6   | 258  | 110 | 3.08 | 3.215 | 19.44 |
| 8   | 360  | 175 | 3.15 | 3.440 | 17.02 |
| 6   | 225  | 105 | 2.76 | 3.460 | 20.22 |

\# Center-align column 2 and left-align column 5 align(ft_car, j =
[c](https://rdrr.io/r/base/c.html)(2, 5), align =
[c](https://rdrr.io/r/base/c.html)("center", "left"), part = "all")

| cyl | disp | hp  | drat | wt    | qsec  |
|-----|------|-----|------|-------|-------|
| 6   | 160  | 110 | 3.90 | 2.620 | 16.46 |
| 6   | 160  | 110 | 3.90 | 2.875 | 17.02 |
| 4   | 108  | 93  | 3.85 | 2.320 | 18.61 |
| 6   | 258  | 110 | 3.08 | 3.215 | 19.44 |
| 8   | 360  | 175 | 3.15 | 3.440 | 17.02 |
| 6   | 225  | 105 | 2.76 | 3.460 | 20.22 |

\# Alternate left and center alignment across columns 1-4 for header
only align(ft_car, j = 1:4, align =
[c](https://rdrr.io/r/base/c.html)("left", "center"), part = "header")

| cyl | disp | hp  | drat | wt    | qsec  |
|-----|------|-----|------|-------|-------|
| 6   | 160  | 110 | 3.90 | 2.620 | 16.46 |
| 6   | 160  | 110 | 3.90 | 2.875 | 17.02 |
| 4   | 108  | 93  | 3.85 | 2.320 | 18.61 |
| 6   | 258  | 110 | 3.08 | 3.215 | 19.44 |
| 8   | 360  | 175 | 3.15 | 3.440 | 17.02 |
| 6   | 225  | 105 | 2.76 | 3.460 | 20.22 |

ftab \<-
[flextable](https://davidgohel.github.io/flextable/dev/reference/flextable.md)(mtcars)
ftab \<- align_text_col(ftab, align = "left") ftab \<-
align_nottext_col(ftab, align = "right") ftab

| mpg  | cyl | disp  | hp  | drat | wt    | qsec  | vs  | am  | gear | carb |
|------|-----|-------|-----|------|-------|-------|-----|-----|------|------|
| 21.0 | 6   | 160.0 | 110 | 3.90 | 2.620 | 16.46 | 0   | 1   | 4    | 4    |
| 21.0 | 6   | 160.0 | 110 | 3.90 | 2.875 | 17.02 | 0   | 1   | 4    | 4    |
| 22.8 | 4   | 108.0 | 93  | 3.85 | 2.320 | 18.61 | 1   | 1   | 4    | 1    |
| 21.4 | 6   | 258.0 | 110 | 3.08 | 3.215 | 19.44 | 1   | 0   | 3    | 1    |
| 18.7 | 8   | 360.0 | 175 | 3.15 | 3.440 | 17.02 | 0   | 0   | 3    | 2    |
| 18.1 | 6   | 225.0 | 105 | 2.76 | 3.460 | 20.22 | 1   | 0   | 3    | 1    |
| 14.3 | 8   | 360.0 | 245 | 3.21 | 3.570 | 15.84 | 0   | 0   | 3    | 4    |
| 24.4 | 4   | 146.7 | 62  | 3.69 | 3.190 | 20.00 | 1   | 0   | 4    | 2    |
| 22.8 | 4   | 140.8 | 95  | 3.92 | 3.150 | 22.90 | 1   | 0   | 4    | 2    |
| 19.2 | 6   | 167.6 | 123 | 3.92 | 3.440 | 18.30 | 1   | 0   | 4    | 4    |
| 17.8 | 6   | 167.6 | 123 | 3.92 | 3.440 | 18.90 | 1   | 0   | 4    | 4    |
| 16.4 | 8   | 275.8 | 180 | 3.07 | 4.070 | 17.40 | 0   | 0   | 3    | 3    |
| 17.3 | 8   | 275.8 | 180 | 3.07 | 3.730 | 17.60 | 0   | 0   | 3    | 3    |
| 15.2 | 8   | 275.8 | 180 | 3.07 | 3.780 | 18.00 | 0   | 0   | 3    | 3    |
| 10.4 | 8   | 472.0 | 205 | 2.93 | 5.250 | 17.98 | 0   | 0   | 3    | 4    |
| 10.4 | 8   | 460.0 | 215 | 3.00 | 5.424 | 17.82 | 0   | 0   | 3    | 4    |
| 14.7 | 8   | 440.0 | 230 | 3.23 | 5.345 | 17.42 | 0   | 0   | 3    | 4    |
| 32.4 | 4   | 78.7  | 66  | 4.08 | 2.200 | 19.47 | 1   | 1   | 4    | 1    |
| 30.4 | 4   | 75.7  | 52  | 4.93 | 1.615 | 18.52 | 1   | 1   | 4    | 2    |
| 33.9 | 4   | 71.1  | 65  | 4.22 | 1.835 | 19.90 | 1   | 1   | 4    | 1    |
| 21.5 | 4   | 120.1 | 97  | 3.70 | 2.465 | 20.01 | 1   | 0   | 3    | 1    |
| 15.5 | 8   | 318.0 | 150 | 2.76 | 3.520 | 16.87 | 0   | 0   | 3    | 2    |
| 15.2 | 8   | 304.0 | 150 | 3.15 | 3.435 | 17.30 | 0   | 0   | 3    | 2    |
| 13.3 | 8   | 350.0 | 245 | 3.73 | 3.840 | 15.41 | 0   | 0   | 3    | 4    |
| 19.2 | 8   | 400.0 | 175 | 3.08 | 3.845 | 17.05 | 0   | 0   | 3    | 2    |
| 27.3 | 4   | 79.0  | 66  | 4.08 | 1.935 | 18.90 | 1   | 1   | 4    | 1    |
| 26.0 | 4   | 120.3 | 91  | 4.43 | 2.140 | 16.70 | 0   | 1   | 5    | 2    |
| 30.4 | 4   | 95.1  | 113 | 3.77 | 1.513 | 16.90 | 1   | 1   | 5    | 2    |
| 15.8 | 8   | 351.0 | 264 | 4.22 | 3.170 | 14.50 | 0   | 1   | 5    | 4    |
| 19.7 | 6   | 145.0 | 175 | 3.62 | 2.770 | 15.50 | 0   | 1   | 5    | 6    |
| 15.0 | 8   | 301.0 | 335 | 3.54 | 3.570 | 14.60 | 0   | 1   | 5    | 8    |
| 21.4 | 4   | 121.0 | 109 | 4.11 | 2.780 | 18.60 | 1   | 1   | 4    | 2    |
