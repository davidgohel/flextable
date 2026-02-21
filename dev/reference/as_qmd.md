# Quarto inline markdown chunk

`as_qmd()` creates a chunk for inline Quarto markdown content
(text-level) that fits within a table cell paragraph. This enables
cross-references (`@fig-xxx`, `@tbl-xxx`), links, bold/italic, math,
inline code, shortcodes and other inline Quarto markdown features inside
flextable cells.

It is not designed for block-level elements such as headings, bullet
lists or fenced code blocks.

The chunk is used with
[`compose()`](https://davidgohel.github.io/flextable/dev/reference/compose.md),
[`append_chunks()`](https://davidgohel.github.io/flextable/dev/reference/append_chunks.md)
or
[`prepend_chunks()`](https://davidgohel.github.io/flextable/dev/reference/prepend_chunks.md).
It requires the `flextable-qmd` Lua filter extension (see
[`use_flextable_qmd()`](https://davidgohel.github.io/flextable/dev/reference/use_flextable_qmd.md))
and works with HTML, PDF and Word (docx) Quarto output formats.

## Usage

``` r
as_qmd(x, display = x)
```

## Arguments

- x:

  character vector of Quarto markdown content.

- display:

  character vector of display text used as fallback when the Lua filter
  is not active. Defaults to `x`.

## Setup

1.  Install the extension once per project:

    flextable::use_flextable_qmd()

1.  Add the filter to your Quarto document YAML. For HTML and PDF, a
    single line is enough:

    filters:
      - flextable-qmd

For Word (docx), an additional post-render filter removes the wrapper
table that Quarto adds around labelled flextables:

    filters:
      - flextable-qmd
      - at: post-render
        path: _extensions/flextable-qmd/unwrap-float.lua

## Supported markdown

- Cross-references: `@fig-xxx`, `@tbl-xxx`

- Bold / italic: `**bold**`, `*italic*`

- Inline code: `` `code` ``

- Links: `[text](url)` (internal and external)

- Math: `$\\alpha + \\beta$`

- Shortcodes and other Quarto markdown constructs

## Limitations

Each table cell in a flextable contains a single paragraph built from
inline chunks (see
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)).
There is no mechanism to insert block-level structures (multiple
paragraphs, lists, headings, fenced code blocks, callouts, etc.) inside
a cell. Because `as_qmd()` produces one of these inline chunks, only
inline markdown is supported.

## See also

[`use_flextable_qmd()`](https://davidgohel.github.io/flextable/dev/reference/use_flextable_qmd.md)
to install the Lua filter extension,
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)
for rendering options in knitr documents.

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/dev/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/dev/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md),
[`as_equation()`](https://davidgohel.github.io/flextable/dev/reference/as_equation.md),
[`as_highlight()`](https://davidgohel.github.io/flextable/dev/reference/as_highlight.md),
[`as_i()`](https://davidgohel.github.io/flextable/dev/reference/as_i.md),
[`as_image()`](https://davidgohel.github.io/flextable/dev/reference/as_image.md),
[`as_strike()`](https://davidgohel.github.io/flextable/dev/reference/as_strike.md),
[`as_sub()`](https://davidgohel.github.io/flextable/dev/reference/as_sub.md),
[`as_sup()`](https://davidgohel.github.io/flextable/dev/reference/as_sup.md),
[`as_word_field()`](https://davidgohel.github.io/flextable/dev/reference/as_word_field.md),
[`colorize()`](https://davidgohel.github.io/flextable/dev/reference/colorize.md),
[`gg_chunk()`](https://davidgohel.github.io/flextable/dev/reference/gg_chunk.md),
[`grid_chunk()`](https://davidgohel.github.io/flextable/dev/reference/grid_chunk.md),
[`hyperlink_text()`](https://davidgohel.github.io/flextable/dev/reference/hyperlink_text.md),
[`linerange()`](https://davidgohel.github.io/flextable/dev/reference/linerange.md),
[`minibar()`](https://davidgohel.github.io/flextable/dev/reference/minibar.md),
[`plot_chunk()`](https://davidgohel.github.io/flextable/dev/reference/plot_chunk.md)

## Examples

``` r
library(flextable)

dat <- data.frame(
  label = c("Bold", "Link", "Code"),
  content = c(
    "This is **bold** text",
    "Visit [Quarto](https://quarto.org)",
    "Use `print()` here"
  )
)
ft <- flextable(dat)
ft <- mk_par(ft, j = "content",
  value = as_paragraph(as_qmd(content)))
ft


.cl-17cb3062{}.cl-17c4cdd0{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-17c79e52{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-17c7bf04{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-17c7bf0e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-17c7bf18{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


label
```

content

Bold

This is \*\*bold\*\* text

Link

Visit \[Quarto\](https://quarto.org)

Code

Use \`print()\` here
