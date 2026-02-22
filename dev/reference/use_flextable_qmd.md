# Install the flextable-qmd Quarto extension

Copies the `flextable-qmd` Quarto extension (bundled with flextable)
into the `_extensions/` directory of a Quarto project. The extension
provides Lua filters that resolve Quarto markdown content produced by
[`as_qmd()`](https://davidgohel.github.io/flextable/dev/reference/as_qmd.md)
inside flextable cells for HTML, PDF and Word (docx) output formats.

After installation, add the filter to your document or project YAML:

    filters:
      - flextable-qmd

For Word (docx) output with labelled flextable chunks (e.g.
`#| label: tbl-xxx`), add the post-render filter to remove the wrapper
table Quarto creates around the flextable:

    filters:
      - flextable-qmd
      - at: post-render
        path: _extensions/flextable-qmd/unwrap-float.lua

## Usage

``` r
use_flextable_qmd(path = ".", quiet = FALSE)
```

## Arguments

- path:

  Path to the Quarto project root. Defaults to the current working
  directory.

- quiet:

  If `TRUE`, suppress informational messages.

## Value

The path to the installed extension (invisibly).

## See also

[`as_qmd()`](https://davidgohel.github.io/flextable/dev/reference/as_qmd.md)
for creating Quarto markdown chunks,
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)
for rendering options in knitr documents.

Other flextable configuration:
[`add_latex_dep()`](https://davidgohel.github.io/flextable/dev/reference/add_latex_dep.md),
[`use_df_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_df_printer.md),
[`use_model_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_model_printer.md)

## Examples

``` r
if (FALSE) { # \dontrun{
use_flextable_qmd()
} # }
```
