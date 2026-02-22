# data.frame automatic printing as a flextable

Create a summary from a data.frame as a flextable. This function is to
be used in an R Markdown document.

To use that function, you must declare it in the part `df_print` of the
'YAML' header of your R Markdown document:

    ---
    df_print: !expr function(x) flextable::df_printer(x)
    ---

We notice an unexpected behavior with bookdown. When using bookdown it
is necessary to use
[`use_df_printer()`](https://davidgohel.github.io/flextable/dev/reference/use_df_printer.md)
instead in a setup run chunk:

    use_df_printer()

## Usage

``` r
df_printer(dat, ...)
```

## Arguments

- dat:

  the data.frame

- ...:

  unused argument

## Details

'knitr' chunk options are available to customize the output:

- `ft_max_row`: The number of rows to print. Default to 10.

- `ft_split_colnames`: Should the column names be split (with non
  alpha-numeric characters). Default to FALSE.

- `ft_short_strings`: Should the character column be shorten. Default to
  FALSE.

- `ft_short_size`: Maximum length of character column if
  `ft_short_strings` is TRUE. Default to 35.

- `ft_short_suffix`: Suffix to add when character values are shorten.
  Default to "...".

- `ft_do_autofit`: Use autofit() before rendering the table. Default to
  TRUE.

- `ft_show_coltype`: Show column types. Default to TRUE.

- `ft_color_coltype`: Color to use for column types. Default to
  "#999999".

## See also

Other functions for flextable output and export:
[`flextable_to_rmd()`](https://davidgohel.github.io/flextable/dev/reference/flextable_to_rmd.md),
[`gen_grob()`](https://davidgohel.github.io/flextable/dev/reference/gen_grob.md),
[`htmltools_value()`](https://davidgohel.github.io/flextable/dev/reference/htmltools_value.md),
[`knit_print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md),
[`plot.flextable()`](https://davidgohel.github.io/flextable/dev/reference/plot.flextable.md),
[`print.flextable()`](https://davidgohel.github.io/flextable/dev/reference/print.flextable.md),
[`save_as_docx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_docx.md),
[`save_as_html()`](https://davidgohel.github.io/flextable/dev/reference/save_as_html.md),
[`save_as_image()`](https://davidgohel.github.io/flextable/dev/reference/save_as_image.md),
[`save_as_pptx()`](https://davidgohel.github.io/flextable/dev/reference/save_as_pptx.md),
[`save_as_rtf()`](https://davidgohel.github.io/flextable/dev/reference/save_as_rtf.md),
[`to_html.flextable()`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md),
[`wrap_flextable()`](https://davidgohel.github.io/flextable/dev/reference/wrap_flextable.md)

## Examples

``` r
df_printer(head(mtcars))
#> this function is to be used in a knitr context.
```
