# Merge flextable cells vertically

Merge flextable cells vertically when consecutive cells have identical
values. Text of formatted values are used to compare values if
available.

Two options are available, either a column-by-column algorithm or an
algorithm where the combinations of these columns are used once for all
target columns.

## Usage

``` r
merge_v(x, j = NULL, target = NULL, part = "body", combine = FALSE)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- target:

  columns names where cells have to be merged.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' is not allowed by the function.

- combine:

  If the value is TRUE, the columns defined by `j` will be combined into
  a single column/value and the consecutive values of this result will
  be used. Otherwise, the columns are inspected one by one to perform
  cell merges.

## See also

Other flextable merging function:
[`merge_at()`](https://davidgohel.github.io/flextable/dev/reference/merge_at.md),
[`merge_h()`](https://davidgohel.github.io/flextable/dev/reference/merge_h.md),
[`merge_h_range()`](https://davidgohel.github.io/flextable/dev/reference/merge_h_range.md),
[`merge_none()`](https://davidgohel.github.io/flextable/dev/reference/merge_none.md)

## Examples

``` r
ft_merge <- flextable(mtcars)
ft_merge <- merge_v(ft_merge, j = c("gear", "carb"))
ft_merge


.cl-2ec23f5e{}.cl-2e8a2dd0{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-2e8d8106{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2e8da4e2{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e8da4ec{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e8da4f6{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


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

22.8

4

108.0

93

3.85

2.320

18.61

1

1

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

18.7

8

360.0

175

3.15

3.440

17.02

0

0

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

17.8

6

167.6

123

3.92

3.440

18.90

1

0

16.4

8

275.8

180

3.07

4.070

17.40

0

0

3

3

17.3

8

275.8

180

3.07

3.730

17.60

0

0

15.2

8

275.8

180

3.07

3.780

18.00

0

0

10.4

8

472.0

205

2.93

5.250

17.98

0

0

4

10.4

8

460.0

215

3.00

5.424

17.82

0

0

14.7

8

440.0

230

3.23

5.345

17.42

0

0

32.4

4

78.7

66

4.08

2.200

19.47

1

1

4

1

30.4

4

75.7

52

4.93

1.615

18.52

1

1

2

33.9

4

71.1

65

4.22

1.835

19.90

1

1

1

21.5

4

120.1

97

3.70

2.465

20.01

1

0

3

15.5

8

318.0

150

2.76

3.520

16.87

0

0

2

15.2

8

304.0

150

3.15

3.435

17.30

0

0

13.3

8

350.0

245

3.73

3.840

15.41

0

0

4

19.2

8

400.0

175

3.08

3.845

17.05

0

0

2

27.3

4

79.0

66

4.08

1.935

18.90

1

1

4

1

26.0

4

120.3

91

4.43

2.140

16.70

0

1

5

2

30.4

4

95.1

113

3.77

1.513

16.90

1

1

15.8

8

351.0

264

4.22

3.170

14.50

0

1

4

19.7

6

145.0

175

3.62

2.770

15.50

0

1

6

15.0

8

301.0

335

3.54

3.570

14.60

0

1

8

21.4

4

121.0

109

4.11

2.780

18.60

1

1

4

2

data_ex \<-
[structure](https://rdrr.io/r/base/structure.html)([list](https://rdrr.io/r/base/list.html)(srdr_id
= [c](https://rdrr.io/r/base/c.html)( "175124", "175124", "172525",
"172525", "172545", "172545", "172609", "172609", "172609" ), substances
= [c](https://rdrr.io/r/base/c.html)( "alcohol", "alcohol", "alcohol",
"alcohol", "cannabis", "cannabis", "alcohol\n cannabis\n other drugs",
"alcohol\n cannabis\n other drugs", "alcohol\n cannabis\n other drugs"
), full_name = [c](https://rdrr.io/r/base/c.html)( "TAU", "MI", "TAU",
"MI (parent)", "TAU", "MI", "TAU", "MI", "MI" ), article_arm_name =
[c](https://rdrr.io/r/base/c.html)( "Control", "WISEteens", "Treatment
as usual", "Brief MI (b-MI)", "Assessed control", "Intervention",
"Control", "Computer BI", "Therapist BI" )), row.names =
[c](https://rdrr.io/r/base/c.html)( NA, -9L ), class =
[c](https://rdrr.io/r/base/c.html)("tbl_df", "tbl", "data.frame")) ft_1
\<-
[flextable](https://davidgohel.github.io/flextable/dev/reference/flextable.md)(data_ex)
ft_1 \<-
[theme_box](https://davidgohel.github.io/flextable/dev/reference/theme_box.md)(ft_1)
ft_2 \<- merge_v(ft_1, j = "srdr_id", target =
[c](https://rdrr.io/r/base/c.html)("srdr_id", "substances") ) ft_2

[TABLE]
