# Transform a 'tables::tabular' object into a flextable

Produce a flextable from a 'tabular' object produced with function
[`tables::tabular()`](https://dmurdoch.github.io/tables/reference/tabular.html).

When `as_flextable.tabular=TRUE`, the first column is used as row
separator acting as a row title. It can be formated with arguments
`fp_p` (the formatting properties of the paragraph) and `row_title` that
specifies the content and eventually formattings of the content.

Two hidden columns can be used for conditional formatting after the
creation of the flextable (use only when `spread_first_col=TRUE`):

- The column `.row_title` that contains the title label

- The column `.type` that can contain the following values:

  - "one_row": Indicates that there is only one row for this group. In
    this case, the row is not expanded with a title above.

  - "list_title": Indicates a row that serves as a title for the data
    that are displayed after it.

  - "list_data": Indicates rows that follow a title and contain data to
    be displayed.

The result is paginated (see
[`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)).

## Usage

``` r
# S3 method for class 'tabular'
as_flextable(
  x,
  spread_first_col = FALSE,
  fp_p = fp_par(text.align = "center", padding.top = 4),
  row_title = as_paragraph(as_chunk(.row_title)),
  add_tab = FALSE,
  ...
)
```

## Arguments

- x:

  object produced by
  [`tables::tabular()`](https://dmurdoch.github.io/tables/reference/tabular.html).

- spread_first_col:

  if TRUE, first row is spread as a new line separator instead of being
  a column. This helps to reduce the width and allows for clear
  divisions.

- fp_p:

  paragraph formatting properties associated with row titles, see
  [`officer::fp_par()`](https://davidgohel.github.io/officer/reference/fp_par.html).

- row_title:

  a call to
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md) -
  it will be applied to the row titles if any when
  `spread_first_col=TRUE`.

- add_tab:

  adds a tab in front of "list_data" label lines (located in column
  `.type`).

- ...:

  unused argument

## See also

Other as_flextable methods:
[`as_flextable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md),
[`as_flextable.compact_summary()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.compact_summary.md),
[`as_flextable.data.frame()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.data.frame.md),
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
[`as_flextable.tabulator()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabulator.md),
[`as_flextable.xtable()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.xtable.md),
[`compact_summary()`](https://davidgohel.github.io/flextable/dev/reference/compact_summary.md)

## Examples

``` r
if (require("tables")) {
  set.seed(42)
  genders <- c("Male", "Female")
  status <- c("low", "medium", "high")
  Sex <- factor(sample(genders, 100, rep = TRUE))
  Status <- factor(sample(status, 100, rep = TRUE))
  z <- rnorm(100) + 5
  fmt <- function(x) {
    s <- format(x, digits = 2)
    even <- ((1:length(s)) %% 2) == 0
    s[even] <- sprintf("(%s)", s[even])
    s
  }
  tab <- tabular(
    Justify(c) * Heading() * z *
      Sex * Heading(Statistic) *
      Format(fmt()) *
      (mean + sd) ~ Status
  )
  as_flextable(tab)
}
#> Loading required package: tables


.cl-8456a418{}.cl-84502c96{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-8452efbc{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-8452efd0{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-8452efda{margin:0;text-align:center;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-8453132a{width:0.746in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-84531334{width:0.804in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-84531335{width:0.894in;background-color:transparent;vertical-align: bottom;border-bottom: 0 solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-8453133e{width:0.746in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-8453133f{width:0.804in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-84531348{width:0.894in;background-color:transparent;vertical-align: bottom;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-84531349{width:0.746in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-84531352{width:0.804in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-84531353{width:0.894in;background-color:transparent;vertical-align: top;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-8453135c{width:0.746in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-8453135d{width:0.804in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-84531366{width:0.894in;background-color:transparent;vertical-align: top;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Sex
```

Statistic

Status

high

low

medium

Female

mean

4.57

4.73

5.09

sd

(1.04)

(0.92)

(0.66)

Male

mean

4.58

4.40

5.64

sd

(0.83)

(0.82)

(1.11)

if
([require](https://rdrr.io/r/base/library.html)(["tables"](https://dmurdoch.github.io/tables/)))
{ tab \<-
[tabular](https://dmurdoch.github.io/tables/reference/tabular.html)(
(Species + 1) ~ (n = 1) +
[Format](https://dmurdoch.github.io/tables/reference/Format.html)(digits
= 2) \* (Sepal.Length + Sepal.Width) \* (mean + sd), data = iris )
[as_flextable](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)(tab)
}

| Species    |     | Sepal.Length |      | Sepal.Width |      |
|------------|-----|--------------|------|-------------|------|
|            | n   | mean         | sd   | mean        | sd   |
| setosa     | 50  | 5.01         | 0.35 | 3.43        | 0.38 |
| versicolor | 50  | 5.94         | 0.52 | 2.77        | 0.31 |
| virginica  | 50  | 6.59         | 0.64 | 2.97        | 0.32 |
| All        | 150 | 5.84         | 0.83 | 3.06        | 0.44 |

if
([require](https://rdrr.io/r/base/library.html)(["tables"](https://dmurdoch.github.io/tables/)))
{ x \<-
[tabular](https://dmurdoch.github.io/tables/reference/tabular.html)(([Factor](https://dmurdoch.github.io/tables/reference/RowFactor.html)(gear,
"Gears") + 1) \* ((n = 1) +
[Percent](https://dmurdoch.github.io/tables/reference/Percent.html)()  +
(RowPct =
[Percent](https://dmurdoch.github.io/tables/reference/Percent.html)("row"))
 + (ColPct =
[Percent](https://dmurdoch.github.io/tables/reference/Percent.html)("col")))
~
([Factor](https://dmurdoch.github.io/tables/reference/RowFactor.html)(carb,
"Carburetors") + 1) \*
[Format](https://dmurdoch.github.io/tables/reference/Format.html)(digits
= 1), data = mtcars) ft \<-
[as_flextable](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)(
x, spread_first_col = TRUE, row_title =
[as_paragraph](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)(
[colorize](https://davidgohel.github.io/flextable/dev/reference/colorize.md)("Gears:
", color = "#666666"),
[colorize](https://davidgohel.github.io/flextable/dev/reference/colorize.md)([as_b](https://davidgohel.github.io/flextable/dev/reference/as_b.md)(.row_title),
color = "red") ) ) ft }

|            | Carburetors |     |     |     |     |     |     |
|------------|-------------|-----|-----|-----|-----|-----|-----|
|            | 1           | 2   | 3   | 4   | 6   | 8   | All |
| Gears: 3   |             |     |     |     |     |     |     |
| n          | 3           | 4   | 3   | 5   | 0   | 0   | 15  |
| Percent    | 9           | 12  | 9   | 16  | 0   | 0   | 47  |
| RowPct     | 20          | 27  | 20  | 33  | 0   | 0   | 100 |
| ColPct     | 43          | 40  | 100 | 50  | 0   | 0   | 47  |
| Gears: 4   |             |     |     |     |     |     |     |
| n          | 4           | 4   | 0   | 4   | 0   | 0   | 12  |
| Percent    | 12          | 12  | 0   | 12  | 0   | 0   | 38  |
| RowPct     | 33          | 33  | 0   | 33  | 0   | 0   | 100 |
| ColPct     | 57          | 40  | 0   | 40  | 0   | 0   | 38  |
| Gears: 5   |             |     |     |     |     |     |     |
| n          | 0           | 2   | 0   | 1   | 1   | 1   | 5   |
| Percent    | 0           | 6   | 0   | 3   | 3   | 3   | 16  |
| RowPct     | 0           | 40  | 0   | 20  | 20  | 20  | 100 |
| ColPct     | 0           | 20  | 0   | 10  | 100 | 100 | 16  |
| Gears: All |             |     |     |     |     |     |     |
| n          | 7           | 10  | 3   | 10  | 1   | 1   | 32  |
| Percent    | 22          | 31  | 9   | 31  | 3   | 3   | 100 |
| RowPct     | 22          | 31  | 9   | 31  | 3   | 3   | 100 |
| ColPct     | 100         | 100 | 100 | 100 | 100 | 100 | 100 |

if
([require](https://rdrr.io/r/base/library.html)(["tables"](https://dmurdoch.github.io/tables/)))
{ tab \<-
[tabular](https://dmurdoch.github.io/tables/reference/tabular.html)(
(mean + mean) \* (Sepal.Length + Sepal.Width) ~ 1, data = iris )
[as_flextable](https://davidgohel.github.io/flextable/dev/reference/as_flextable.md)(tab)
}

|      |              | All   |
|------|--------------|-------|
| mean | Sepal.Length | 5.843 |
|      | Sepal.Width  | 3.057 |
| mean | Sepal.Length | 5.843 |
|      | Sepal.Width  | 3.057 |
