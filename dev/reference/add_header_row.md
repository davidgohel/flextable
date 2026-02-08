# Add header labels

Add a row of new columns labels in header part. Labels can be spanned
along multiple columns, as merged cells.

Labels are associated with a number of columns to merge that default to
one if not specified. In this case, you have to make sure that the
number of labels is equal to the number of columns displayed.

The function can add only one single row by call.

Labels can also be formatted with
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md).

## Usage

``` r
add_header_row(x, top = TRUE, values = character(0), colwidths = integer(0))
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- top:

  should the row be inserted at the top or the bottom. Default to TRUE.

- values:

  values to add, a character vector (as header rows contains only
  character values/columns), a list or a call to
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md).

- colwidths:

  the number of columns used for each label

## See also

[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md),
[`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md)

Other functions for row and column operations in a flextable:
[`add_body()`](https://davidgohel.github.io/flextable/dev/reference/add_body.md),
[`add_body_row()`](https://davidgohel.github.io/flextable/dev/reference/add_body_row.md),
[`add_footer()`](https://davidgohel.github.io/flextable/dev/reference/add_footer.md),
[`add_footer_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_lines.md),
[`add_footer_row()`](https://davidgohel.github.io/flextable/dev/reference/add_footer_row.md),
[`add_header()`](https://davidgohel.github.io/flextable/dev/reference/add_header.md),
[`add_header_lines()`](https://davidgohel.github.io/flextable/dev/reference/add_header_lines.md),
[`delete_columns()`](https://davidgohel.github.io/flextable/dev/reference/delete_columns.md),
[`delete_part()`](https://davidgohel.github.io/flextable/dev/reference/delete_part.md),
[`separate_header()`](https://davidgohel.github.io/flextable/dev/reference/separate_header.md),
[`set_header_footer_df`](https://davidgohel.github.io/flextable/dev/reference/set_header_footer_df.md),
[`set_header_labels()`](https://davidgohel.github.io/flextable/dev/reference/set_header_labels.md)

## Examples

``` r
library(flextable)

ft01 <- fp_text_default(color = "red")
ft02 <- fp_text_default(color = "orange")

pars <- as_paragraph(
  as_chunk(c("(1)", "(2)"), props = ft02), " ",
  as_chunk(c(
    "My tailor is rich",
    "My baker is rich"
  ), props = ft01)
)

ft_1 <- flextable(head(mtcars))
ft_1 <- add_header_row(ft_1,
  values = pars,
  colwidths = c(5, 6), top = FALSE
)
ft_1 <- add_header_row(ft_1,
  values = pars,
  colwidths = c(3, 8), top = TRUE
)
ft_1


.cl-fb8a440e{}.cl-fb832872{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 165, 0, 1.00);background-color:transparent;}.cl-fb832886{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-fb832890{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 0, 0, 1.00);background-color:transparent;}.cl-fb861b2c{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-fb8641ec{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-fb8641f6{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-fb8641f7{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



(1) My tailor is rich
```

(2) My baker is rich

mpg

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

(1) My tailor is rich

(2) My baker is rich

21.0

6

160

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

160

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

108

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

258

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

360

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

225

105

2.76

3.460

20.22

1

0

3

1

ft_2 \<-
[flextable](https://davidgohel.github.io/flextable/dev/reference/flextable.md)([head](https://rdrr.io/r/utils/head.html)(airquality))
ft_2 \<- add_header_row(ft_2, values =
[c](https://rdrr.io/r/base/c.html)("Measure", "Time"), colwidths =
[c](https://rdrr.io/r/base/c.html)(4, 2), top = TRUE ) ft_2 \<-
[theme_box](https://davidgohel.github.io/flextable/dev/reference/theme_box.md)(ft_2)
ft_2

| Measure |         |      |      | Time  |     |
|---------|---------|------|------|-------|-----|
| Ozone   | Solar.R | Wind | Temp | Month | Day |
| 41      | 190     | 7.4  | 67   | 5     | 1   |
| 36      | 118     | 8.0  | 72   | 5     | 2   |
| 12      | 149     | 12.6 | 74   | 5     | 3   |
| 18      | 313     | 11.5 | 62   | 5     | 4   |
|         |         | 14.3 | 56   | 5     | 5   |
| 28      |         | 14.9 | 66   | 5     | 6   |
