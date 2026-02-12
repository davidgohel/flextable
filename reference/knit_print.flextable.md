# Render flextable in knitr documents

This function is called automatically by knitr to display a flextable in
R Markdown and Quarto documents. You do not need to call it directly.

Supported output formats: HTML, Word (docx), PDF and PowerPoint (pptx).
For other formats (e.g., `github_document`, `beamer_presentation`), the
table is rendered as a PNG image.

## Usage

``` r
# S3 method for class 'flextable'
knit_print(x, ...)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- ...:

  unused.

## Getting started

No special setup is needed: place a flextable object in a code chunk and
it will be rendered in the output document.

Add a caption with
[`set_caption()`](https://davidgohel.github.io/flextable/reference/set_caption.md):

    ft <- set_caption(ft, caption = "My table caption")

In Quarto documents, use chunk options `tbl-cap` and `label` instead:

    ```{r}
    #| label: tbl-mytable
    #| tbl-cap: "My table caption"
    ft
    ```

## Captions

**Recommended method:** use
[`set_caption()`](https://davidgohel.github.io/flextable/reference/set_caption.md)
to define the caption directly on the flextable object. When
[`set_caption()`](https://davidgohel.github.io/flextable/reference/set_caption.md)
is used, chunk options related to captions are ignored.

**Alternative (R Markdown only):** use knitr chunk options `tab.cap` and
`tab.id`:

|                             |                  |             |
|-----------------------------|------------------|-------------|
| **Description**             | **Chunk option** | **Default** |
| Caption text                | tab.cap          | NULL        |
| Caption id/bookmark         | tab.id           | NULL        |
| Caption on top of the table | tab.topcaption   | TRUE        |
| Caption sequence identifier | tab.lp           | "tab:"      |
| Word style for captions     | tab.cap.style    | NULL        |

**Bookdown:** cross-references use the pattern `\@ref(tab:chunk_label)`.
The usual bookdown numbering applies.

**Quarto:** cross-references use `@tbl-chunk_label`. To embed
cross-references or other Quarto markdown inside flextable cells, use
[`as_qmd()`](https://davidgohel.github.io/flextable/reference/as_qmd.md)
with the `flextable-qmd` extension (see
[`use_flextable_qmd()`](https://davidgohel.github.io/flextable/reference/use_flextable_qmd.md)).

## Chunk options

Use `knitr::opts_chunk$set(...)` to set defaults for the whole document.

**All formats:**

- `ft.align`: table alignment, one of `'left'`, `'center'` (default) or
  `'right'`.

**HTML:**

- `ft.htmlscroll`: `TRUE` or `FALSE` (default) to enable horizontal
  scrolling. See
  [`set_table_properties()`](https://davidgohel.github.io/flextable/reference/set_table_properties.md)
  for finer control.

**Word:**

- `ft.split`: allow rows to break across pages (`TRUE` by default).

**PDF:**

- `ft.tabcolsep`: space between text and cell borders (default 0 pt).

- `ft.arraystretch`: row height multiplier (default 1.5).

- `ft.latex.float`: floating placement. One of `'none'` (default),
  `'float'`, `'wrap-r'`, `'wrap-l'`, `'wrap-i'`, `'wrap-o'`.

**PowerPoint:**

- `ft.left`, `ft.top`: top-left coordinates of the table placeholder in
  inches (defaults: 1 and 2).

## Word with officedown

When using
[`officedown::rdocx_document()`](https://davidgohel.github.io/officedown/reference/rdocx_document.html),
additional caption options are available:

|                                       |                  |                           |
|---------------------------------------|------------------|---------------------------|
| **Description**                       | **Chunk option** | **Default**               |
| Numbering prefix                      | tab.cap.pre      | "Table "                  |
| Numbering suffix                      | tab.cap.sep      | ": "                      |
| Title number depth                    | tab.cap.tnd      | 0                         |
| Caption prefix formatting             | tab.cap.fp_text  | `fp_text_lite(bold=TRUE)` |
| Title number / table number separator | tab.cap.tns      | "-"                       |

## Quarto

flextable works natively in Quarto documents for HTML, PDF and Word.

The `flextable-qmd` Lua filter extension enables Quarto markdown inside
flextable cells: cross-references (`@tbl-xxx`, `@fig-xxx`), bold/italic,
links, math, inline code and shortcodes. See
[`as_qmd()`](https://davidgohel.github.io/flextable/reference/as_qmd.md)
and
[`use_flextable_qmd()`](https://davidgohel.github.io/flextable/reference/use_flextable_qmd.md)
for setup instructions.

## PDF limitations

The following properties are not supported in PDF output: padding,
`line_spacing` and row `height`. Justified text is converted to
left-aligned.

To use system fonts, set `latex_engine: xelatex` in the YAML header (the
default `pdflatex` engine does not support them).

See
[`add_latex_dep()`](https://davidgohel.github.io/flextable/reference/add_latex_dep.md)
when caching flextable results.

## PowerPoint limitations

PowerPoint only supports fixed table layout. Use
[`autofit()`](https://davidgohel.github.io/flextable/reference/autofit.md)
to adjust column widths. Images inside table cells are not supported
(this is a PowerPoint limitation).

## HTML note

HTML output uses Shadow DOM to isolate table styles from the rest of the
page.

## See also

[`set_caption()`](https://davidgohel.github.io/flextable/reference/set_caption.md),
[`as_qmd()`](https://davidgohel.github.io/flextable/reference/as_qmd.md),
[`use_flextable_qmd()`](https://davidgohel.github.io/flextable/reference/use_flextable_qmd.md),
[`paginate()`](https://davidgohel.github.io/flextable/reference/paginate.md)

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/reference/df_printer.md),
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/reference/gen_grob.md),
[`htmltools_value()`](https://davidgohel.github.io/flextable/reference/htmltools_value.md),
[`plot.flextable()`](https://davidgohel.github.io/flextable/reference/plot.flextable.md),
[`print.flextable()`](https://davidgohel.github.io/flextable/reference/print.flextable.md),
[`save_as_docx()`](https://davidgohel.github.io/flextable/reference/save_as_docx.md),
[`save_as_html()`](https://davidgohel.github.io/flextable/reference/save_as_html.md),
[`save_as_image()`](https://davidgohel.github.io/flextable/reference/save_as_image.md),
[`save_as_pptx()`](https://davidgohel.github.io/flextable/reference/save_as_pptx.md),
[`save_as_rtf()`](https://davidgohel.github.io/flextable/reference/save_as_rtf.md),
[`to_html.flextable()`](https://davidgohel.github.io/flextable/reference/to_html.flextable.md),
[`wrap_flextable()`](https://davidgohel.github.io/flextable/reference/wrap_flextable.md)

## Examples

``` r
if (FALSE) { # \dontrun{
library(rmarkdown)
if (pandoc_available() &&
  pandoc_version() > numeric_version("2")) {
  demo_loop <- system.file(
    package = "flextable",
    "examples/rmd",
    "demo.Rmd"
  )
  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy(demo_loop, to = rmd_file, overwrite = TRUE)
  render(
    input = rmd_file, output_format = "html_document",
    output_file = "demo.html"
  )
}
} # }
```
