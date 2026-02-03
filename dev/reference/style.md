# Set flextable default styles

Modify flextable text, paragraph, and cell default formatting
properties. This allows you to specify a set of formatting properties
for a selection instead of using multiple functions (e.g., `bold`,
`italic`, `bg`) that must all be applied to the same selection of rows
and columns.

## Usage

``` r
style(
  x,
  i = NULL,
  j = NULL,
  pr_t = NULL,
  pr_p = NULL,
  pr_c = NULL,
  part = "body"
)
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

- pr_t:

  object(s) of class `fp_text`, result of
  [`officer::fp_text()`](https://davidgohel.github.io/officer/reference/fp_text.html)
  or
  [`officer::fp_text_lite()`](https://davidgohel.github.io/officer/reference/fp_text.html)

- pr_p:

  object(s) of class `fp_par`, result of
  [`officer::fp_par()`](https://davidgohel.github.io/officer/reference/fp_par.html)
  or
  [`officer::fp_par_lite()`](https://davidgohel.github.io/officer/reference/fp_par.html)

- pr_c:

  object(s) of class `fp_cell`, result of
  [`officer::fp_cell()`](https://davidgohel.github.io/officer/reference/fp_cell.html)

- part:

  part selector, see section *Part selection with the `part` parameter*
  in
  \<[`Selectors in flextable`](https://davidgohel.github.io/flextable/dev/reference/flextable_selectors.md)\>.
  Value 'all' can be used.

## Examples

``` r
library(officer)
def_cell <- fp_cell(border = fp_border(color = "wheat"))

def_par <- fp_par(text.align = "center")

ft <- flextable(head(mtcars))

ft <- style(ft, pr_c = def_cell, pr_p = def_par, part = "all")
ft <- style(ft, ~ drat > 3.5, ~ vs + am + gear + carb,
  pr_t = fp_text(color = "red", italic = TRUE)
)

ft


.cl-e1bfa084{}.cl-e1b92f10{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-e1b92f1a{font-family:'Arial';font-size:10pt;font-weight:normal;font-style:italic;text-decoration:none;color:rgba(255, 0, 0, 1.00);background-color:transparent;}.cl-e1bbd6ac{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:0;padding-top:0;padding-left:0;padding-right:0;line-height: 1;background-color:transparent;}.cl-e1bbf6fa{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1pt solid rgba(245, 222, 179, 1.00);border-top: 1pt solid rgba(245, 222, 179, 1.00);border-left: 1pt solid rgba(245, 222, 179, 1.00);border-right: 1pt solid rgba(245, 222, 179, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


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
