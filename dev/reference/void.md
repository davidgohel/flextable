# Clear the displayed content of selected columns

`void()` replaces the visible text of the selected columns with an empty
string. The columns themselves (and their headers) remain in the table,
but the cell values are no longer displayed.

This is useful when a column should stay in the layout (e.g. to preserve
its width or to keep its header label) but its body values should be
hidden, for instance after using
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md)
to build a richer display in a neighbouring column that already
incorporates those values.

The underlying dataset is not modified; only the displayed content is
affected. To remove a column entirely, use the `col_keys` argument of
[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md)
instead.

## Usage

``` r
void(x, j = NULL, part = "body")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- j:

  column selector, see section *Column selection with the `j` parameter*
  in
  \<[`flextable column selection`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## Examples

``` r
ftab <- flextable(head(mtcars))
ftab <- void(ftab, ~ vs + am + gear + carb)
ftab


.cl-39bb62d4{}.cl-39b4058e{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-39b7159e{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-39b73a4c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-39b73a56{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-39b73a57{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


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

160

110

3.90

2.620

16.46

21.0

6

160

110

3.90

2.875

17.02

22.8

4

108

93

3.85

2.320

18.61

21.4

6

258

110

3.08

3.215

19.44

18.7

8

360

175

3.15

3.440

17.02

18.1

6

225

105

2.76

3.460

20.22
