# Replace the entire header or footer from a data frame

Replace all header or footer rows using a mapping data frame. Unlike
[`set_header_labels()`](https://davidgohel.github.io/flextable/reference/set_header_labels.md)
which only renames the bottom header row, this function rebuilds the
entire header (or footer) structure.

The data.frame must contain a column whose values match flextable
`col_keys` argument, this column will be used as join key. The other
columns will be displayed as header or footer rows. The leftmost column
is used as the top header/footer row and the rightmost column is used as
the bottom header/footer row.

## Usage

``` r
set_header_df(x, mapping = NULL, key = "col_keys")

set_footer_df(x, mapping = NULL, key = "col_keys")
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- mapping:

  a `data.frame` specyfing for each colname content of the column.

- key:

  column to use as key when joigning data_mapping.

## See also

Other functions for row and column operations in a flextable:
[`add_body()`](https://davidgohel.github.io/flextable/reference/add_body.md),
[`add_body_row()`](https://davidgohel.github.io/flextable/reference/add_body_row.md),
[`add_footer()`](https://davidgohel.github.io/flextable/reference/add_footer.md),
[`add_footer_lines()`](https://davidgohel.github.io/flextable/reference/add_footer_lines.md),
[`add_footer_row()`](https://davidgohel.github.io/flextable/reference/add_footer_row.md),
[`add_header()`](https://davidgohel.github.io/flextable/reference/add_header.md),
[`add_header_lines()`](https://davidgohel.github.io/flextable/reference/add_header_lines.md),
[`add_header_row()`](https://davidgohel.github.io/flextable/reference/add_header_row.md),
[`delete_columns()`](https://davidgohel.github.io/flextable/reference/delete_columns.md),
[`delete_part()`](https://davidgohel.github.io/flextable/reference/delete_part.md),
[`separate_header()`](https://davidgohel.github.io/flextable/reference/separate_header.md),
[`set_header_labels()`](https://davidgohel.github.io/flextable/reference/set_header_labels.md)

## Examples

``` r
typology <- data.frame(
  col_keys = c(
    "Sepal.Length", "Sepal.Width", "Petal.Length",
    "Petal.Width", "Species"
  ),
  what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
  measure = c("Length", "Width", "Length", "Width", "Species"),
  stringsAsFactors = FALSE
)

ft_1 <- flextable(head(iris))
ft_1 <- set_header_df(ft_1, mapping = typology, key = "col_keys")
ft_1 <- merge_h(ft_1, part = "header")
ft_1 <- merge_v(ft_1, j = "Species", part = "header")
ft_1 <- theme_vanilla(ft_1)
ft_1 <- fix_border_issues(ft_1)
ft_1


.cl-2e7bcb26{}.cl-2e747858{font-family:'DejaVu Sans';font-size:11pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-2e74786c{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-2e773818{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2e773822{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-2e782c14{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c15{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c1e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c1f{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c20{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c28{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c29{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c2a{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c2b{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-2e782c32{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0.75pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}



Sepal
```

Petal

Species

Length

Width

Length

Width

5.1

3.5

1.4

0.2

setosa

4.9

3.0

1.4

0.2

setosa

4.7

3.2

1.3

0.2

setosa

4.6

3.1

1.5

0.2

setosa

5.0

3.6

1.4

0.2

setosa

5.4

3.9

1.7

0.4

setosa

typology \<- [data.frame](https://rdrr.io/r/base/data.frame.html)(
col_keys = [c](https://rdrr.io/r/base/c.html)( "Sepal.Length",
"Sepal.Width", "Petal.Length", "Petal.Width", "Species" ), unit =
[c](https://rdrr.io/r/base/c.html)("(cm)", "(cm)", "(cm)", "(cm)", ""),
stringsAsFactors = FALSE ) ft_2 \<- set_footer_df(ft_1, mapping =
typology, key = "col_keys") ft_2 \<-
[italic](https://davidgohel.github.io/flextable/reference/italic.md)(ft_2,
italic = TRUE, part = "footer") ft_2 \<-
[theme_booktabs](https://davidgohel.github.io/flextable/reference/theme_booktabs.md)(ft_2)
ft_2 \<-
[fix_border_issues](https://davidgohel.github.io/flextable/reference/fix_border_issues.md)(ft_2)
ft_2

| Sepal  |       | Petal  |       | Species |
|--------|-------|--------|-------|---------|
| Length | Width | Length | Width |         |
| 5.1    | 3.5   | 1.4    | 0.2   | setosa  |
| 4.9    | 3.0   | 1.4    | 0.2   | setosa  |
| 4.7    | 3.2   | 1.3    | 0.2   | setosa  |
| 4.6    | 3.1   | 1.5    | 0.2   | setosa  |
| 5.0    | 3.6   | 1.4    | 0.2   | setosa  |
| 5.4    | 3.9   | 1.7    | 0.4   | setosa  |
| (cm)   | (cm)  | (cm)   | (cm)  |         |
