# Prevent page breaks inside a flextable

Prevents breaks between tables rows you want to stay together. This
feature only applies to Word and RTF output.

## Usage

``` r
paginate(
  x,
  init = NULL,
  hdr_ftr = TRUE,
  group = character(),
  group_def = c("rle", "nonempty")
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- init:

  init value for keep_with_next property, it default value is
  `get_flextable_defaults()$keep_with_next`.

- hdr_ftr:

  if TRUE (default), prevent breaks between table body and header and
  between table body and footer.

- group:

  name of a column to use for finding groups

- group_def:

  algorithm to be used to identify groups that should not be split into
  two pages, one of 'rle', 'nonempty':

  - 'rle': runs of equal values are used to define the groups, to be
    used with
    [`tabulator()`](https://davidgohel.github.io/flextable/dev/reference/tabulator.md).

  - 'nonempty': non empty value start a new group, to be used with
    [`as_flextable.tabular()`](https://davidgohel.github.io/flextable/dev/reference/as_flextable.tabular.md).

## Value

updated flextable object

## Details

The pagination of tables allows you to control their position in
relation to page breaks.

For small tables, a simple setting is usually used that indicates that
all rows should be displayed together:

    paginate(x, init = TRUE, hdr_ftr = TRUE)

For large tables, it is recommended to use a setting that indicates that
all rows of the header should be bound to the first row of the table to
avoid the case where the header is displayed alone at the bottom of the
page and then repeated on the next one:

    paginate(x, init = FALSE, hdr_ftr = TRUE)

For tables that present groups that you don't want to be presented on
two pages, you must use a parameterization involving the notion of group
and an algorithm for determining the groups.

    paginate(x, group = "grp", group_def = "rle")

## See also

[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)

## Examples

``` r
library(data.table)
library(flextable)

init_flextable_defaults()

multi_fun <- function(x) {
  list(mean = mean(x), sd = sd(x))
}

dat <- as.data.table(ggplot2::diamonds)
dat <- dat[clarity %in% c("I1", "SI1", "VS2")]

dat <- dat[, unlist(lapply(.SD, multi_fun),
  recursive = FALSE
),
.SDcols = c("z", "y"),
by = c("cut", "color", "clarity")
]

tab <- tabulator(
  x = dat, rows = c("cut", "color"),
  columns = "clarity",
  `z stats` = as_paragraph(as_chunk(fmt_avg_dev(z.mean, z.sd, digit2 = 2))),
  `y stats` = as_paragraph(as_chunk(fmt_avg_dev(y.mean, y.sd, digit2 = 2)))
)

ft_1 <- as_flextable(tab)
ft_1 <- autofit(x = ft_1, add_w = .05)
ft_1 <- paginate(ft_1, group = "cut", group_def = "rle")

save_as_docx(ft_1, path = tempfile(fileext = ".docx"))
save_as_rtf(ft_1, path = tempfile(fileext = ".rtf"))
```
