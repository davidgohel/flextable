# Add flextable into a Word document

Add a flextable into a Word document created with 'officer'.

## Usage

``` r
body_add_flextable(
  x,
  value,
  align = NULL,
  pos = "after",
  split = NULL,
  topcaption = TRUE,
  keepnext = NULL
)
```

## Arguments

- x:

  an rdocx object

- value:

  `flextable` object

- align:

  left, center (default) or right. The `align` parameter is still
  supported for the time being, but we recommend using
  `set_flextable_defaults(table_align = "center")` instead that will set
  this default alignment for all flextables during the R session, or to
  define alignement for each table with
  `set_table_properties(align = "center")`.

- pos:

  where to add the flextable relative to the cursor, one of "after",
  "before", "on" (end of line).

- split:

  set to TRUE if you want to activate Word option 'Allow row to break
  across pages'. This argument is still supported for the time being,
  but we recommend using `set_flextable_defaults(split = TRUE)` instead
  that will set this as default setting for all flextables during the R
  session, or to define alignement for each table with
  [`set_table_properties()`](https://davidgohel.github.io/flextable/dev/reference/set_table_properties.md)
  with argument `opts_word=list(split = TRUE)` instead.

- topcaption:

  if TRUE caption is added before the table, if FALSE, caption is added
  after the table.

- keepnext:

  Defunct in favor of
  [`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md).
  The default value used for `keep_with_next` is set with
  `set_flextable_defaults(keep_with_next = TRUE)`.

## Details

Use the
[`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)
function to define whether the table should be displayed on one or more
pages, and whether the header should be displayed with the first lines
of the table body on the same page.

Use the
[`set_caption()`](https://davidgohel.github.io/flextable/dev/reference/set_caption.md)
function to define formatted captions (with
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md))
or simple captions (with a string). `topcaption` can be used to insert
the caption before the table (default) or after the table (use `FALSE`).

## See also

[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md),
[`save_as_docx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_docx.md)

Other functions for officer integration:
[`body_replace_flextable_at_bkm()`](https://davidgohel.github.io/flextable/dev/reference/body_replace_flextable_at_bkm.md),
[`ph_with.flextable()`](https://davidgohel.github.io/flextable/dev/reference/ph_with.flextable.md),
[`rtf_add.flextable()`](https://davidgohel.github.io/flextable/dev/reference/rtf_add.flextable.md)

## Examples

``` r
library(officer)

# define global settings
set_flextable_defaults(
  split = TRUE,
  table_align = "center",
  table.layout = "autofit"
)

# produce 3 flextable
ft_1 <- flextable(head(airquality, n = 20))
ft_1 <- color(ft_1, i = ~ Temp > 70, color = "red", j = "Temp")
ft_1 <- highlight(ft_1, i = ~ Wind < 8, color = "yellow", j = "Wind")
ft_1 <- set_caption(
  x = ft_1,
  autonum = run_autonum(seq_id = "tab"),
  caption = "Daily air quality measurements"
)
ft_1 <- paginate(ft_1, init = TRUE, hdr_ftr = TRUE)

ft_2 <- proc_freq(mtcars, "vs", "gear")
ft_2 <- set_caption(
  x = ft_2,
  autonum = run_autonum(seq_id = "tab", bkm = "mtcars"),
  caption = as_paragraph(
    as_b("mtcars"), " ",
    colorize("table", color = "orange")
  ),
  fp_p = fp_par(keep_with_next = TRUE)
)
ft_2 <- paginate(ft_2, init = TRUE, hdr_ftr = TRUE)

ft_3 <- summarizor(iris, by = "Species")
ft_3 <- as_flextable(ft_3, spread_first_col = TRUE)
ft_3 <- set_caption(
  x = ft_3,
  autonum = run_autonum(seq_id = "tab"),
  caption = "iris summary"
)
ft_3 <- paginate(ft_3, init = TRUE, hdr_ftr = TRUE)

# add the 3 flextable in a new Word document
doc <- read_docx()
doc <- body_add_flextable(doc, value = ft_1)
doc <- body_add_par(doc, value = "")
doc <- body_add_flextable(doc, value = ft_2)
doc <- body_add_par(doc, value = "")
doc <- body_add_flextable(doc, value = ft_3)

fileout <- tempfile(fileext = ".docx")
print(doc, target = fileout)
```
