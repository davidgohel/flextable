# Create a flextable from a data frame

Create a flextable object with function `flextable`.

`flextable` are designed to make tabular reporting easier for R users.
Functions are available to let you format text, paragraphs and cells;
table cells can be merge vertically or horizontally, row headers can
easily be defined, rows heights and columns widths can be manually set
or automatically computed.

If working with 'R Markdown' documents, you should read about knitr
chunk options in
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)
and about setting default values with
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md).

## Usage

``` r
flextable(
  data,
  col_keys = names(data),
  cwidth = 0.75,
  cheight = 0.25,
  defaults = list(),
  theme_fun = theme_booktabs,
  use_labels = TRUE
)

qflextable(data)
```

## Arguments

- data:

  dataset

- col_keys:

  columns names/keys to display. If some column names are not in the
  dataset, they will be added as blank columns by default.

- cwidth, cheight:

  initial width and height to use for cell sizes in inches.

- defaults, theme_fun:

  deprecated, use
  [`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
  instead.

- use_labels:

  Logical; if TRUE, any column labels or value labels present in the
  dataset will be used for display purposes. Defaults to TRUE.

## Reuse frequently used parameters

Some default formatting properties are automatically applied to every
flextable you produce.

It is highly recommended to use this function because its use will
minimize the code. For example, instead of calling the
[`fontsize()`](https://davidgohel.github.io/flextable/dev/reference/fontsize.md)
function over and over again for each new flextable, set the font size
default value by calling (before creating the flextables)
`set_flextable_defaults(font.size = 11)`. This is also a simple way to
have homogeneous arrays and make the documents containing them easier to
read.

You can change these default values with function
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md).
You can reset them with function
[`init_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md).
You can access these values by calling
[`get_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/get_flextable_defaults.md).

## new lines and tabulations

The 'flextable' package will translate for you the new lines expressed
in the form `\n` and the tabs expressed in the form `\t`.

The new lines will be transformed into "soft-return", that is to say a
simple carriage return and not a new paragraph.

Tabs are different depending on the output format:

- HTML is using entity *em space*

- Word - a Word 'tab' element

- PowerPoint - a PowerPoint 'tab' element

- latex - tag "\quad "

## flextable parts

A `flextable` is made of 3 parts: header, body and footer.

Most functions have an argument named `part` that will be used to
specify what part of of the table should be modified.

## qflextable

`qflextable` is a convenient tool to produce quickly a flextable for
reporting where layout is fixed (see
[`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md))
and columns widths are adjusted with
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md).

## See also

[`style()`](https://davidgohel.github.io/flextable/dev/reference/style.md),
[`autofit()`](https://davidgohel.github.io/flextable/dev/reference/autofit.md),
[`theme_booktabs()`](https://davidgohel.github.io/flextable/dev/reference/theme_booktabs.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md),
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`footnote()`](https://davidgohel.github.io/flextable/dev/reference/footnote.md),
[`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md)

## Examples

``` r
ft <- flextable(head(mtcars))
ft


.cl-0180bed0{}.cl-017990a6{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-017cc30c{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-017ce8b4{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-017ce8be{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-017ce8bf{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


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
