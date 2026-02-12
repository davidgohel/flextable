# Transform and summarise a 'data.frame' into a flextable Simple summary of a data.frame as a flextable

It displays the first rows and shows the column types. If there is only
one row, a simplified vertical table is produced.

## Usage

``` r
# S3 method for class 'data.frame'
as_flextable(
  x,
  max_row = 10,
  split_colnames = FALSE,
  short_strings = FALSE,
  short_size = 35,
  short_suffix = "...",
  do_autofit = TRUE,
  show_coltype = TRUE,
  color_coltype = "#999999",
  ...
)
```

## Arguments

- x:

  a data.frame

- max_row:

  The number of rows to print. Default to 10.

- split_colnames:

  Should the column names be split (with non alpha-numeric characters).
  Default to FALSE.

- short_strings:

  Should the character column be shorten. Default to FALSE.

- short_size:

  Maximum length of character column if `short_strings` is TRUE. Default
  to 35.

- short_suffix:

  Suffix to add when character values are shorten. Default to "...".

- do_autofit:

  Use
  [`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md)
  before rendering the table. Default to TRUE.

- show_coltype:

  Show column types. Default to TRUE.

- color_coltype:

  Color to use for column types. Default to "#999999".

- ...:

  unused arguments

## See also

Other as_flextable methods:
[`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md),
[`as_flextable.compact_summary()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.compact_summary.md),
[`as_flextable.gam()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.gam.md),
[`as_flextable.glm()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.glm.md),
[`as_flextable.grouped_data()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.grouped_data.md),
[`as_flextable.htest()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.htest.md),
[`as_flextable.kmeans()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.kmeans.md),
[`as_flextable.lm()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.lm.md),
[`as_flextable.merMod()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.merMod.md),
[`as_flextable.pam()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.pam.md),
[`as_flextable.summarizor()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.summarizor.md),
[`as_flextable.table()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.table.md),
[`as_flextable.tabular()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabular.md),
[`as_flextable.tabulator()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabulator.md),
[`as_flextable.xtable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.xtable.md),
[`compact_summary()`](https://davidgohel.github.io/flextable/dev/reference/compact_summary.md)

## Examples

``` r
as_flextable(mtcars)


.cl-ce4b12d4{}.cl-ce428f92{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-ce428fa6{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(153, 153, 153, 1.00);background-color:transparent;}.cl-ce468fde{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-ce468ff2{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-ce46b360{width:0.911in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ce46b36a{width:0.911in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ce46b36b{width:0.911in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ce46b374{width:0.911in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-ce46b375{width:0.911in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



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

numeric

numeric

numeric

numeric

numeric

numeric

numeric

numeric

numeric

numeric

numeric

21.0

6

160.0

110

3.9

2.6

16.5

0

1

4

4

21.0

6

160.0

110

3.9

2.9

17.0

0

1

4

4

22.8

4

108.0

93

3.9

2.3

18.6

1

1

4

1

21.4

6

258.0

110

3.1

3.2

19.4

1

0

3

1

18.7

8

360.0

175

3.1

3.4

17.0

0

0

3

2

18.1

6

225.0

105

2.8

3.5

20.2

1

0

3

1

14.3

8

360.0

245

3.2

3.6

15.8

0

0

3

4

24.4

4

146.7

62

3.7

3.2

20.0

1

0

4

2

22.8

4

140.8

95

3.9

3.1

22.9

1

0

4

2

19.2

6

167.6

123

3.9

3.4

18.3

1

0

4

4

n: 32
