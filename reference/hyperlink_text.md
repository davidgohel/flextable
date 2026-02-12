# Hyperlink chunk

The function lets add hyperlinks within flextable objects.

It is used to add it to the content of a cell of the flextable with the
functions
[`compose()`](https://davidgohel.github.io/flextable/reference/compose.md),
[`append_chunks()`](https://davidgohel.github.io/flextable/reference/append_chunks.md)
or
[`prepend_chunks()`](https://davidgohel.github.io/flextable/reference/prepend_chunks.md).

URL are not encoded, they are preserved 'as is'.

## Usage

``` r
hyperlink_text(x, props = NULL, formatter = format_fun, url, ...)
```

## Arguments

- x:

  text or any element that can be formatted as text with function
  provided in argument `formatter`.

- props:

  an
  [`fp_text_default()`](https://davidgohel.github.io/flextable/reference/fp_text_default.md)
  or
  [`officer::fp_text()`](https://davidgohel.github.io/officer/reference/fp_text.html)
  object to be used to format the text. If not specified, it will be the
  default value corresponding to the cell.

- formatter:

  a function that will format x as a character vector.

- url:

  url to be used

- ...:

  additional arguments for `formatter` function.

## Note

This chunk option requires package officedown in a R Markdown context
with Word output format.

## See also

[`compose()`](https://davidgohel.github.io/flextable/reference/compose.md)

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/reference/as_chunk.md),
[`as_equation()`](https://davidgohel.github.io/flextable/reference/as_equation.md),
[`as_highlight()`](https://davidgohel.github.io/flextable/reference/as_highlight.md),
[`as_i()`](https://davidgohel.github.io/flextable/reference/as_i.md),
[`as_image()`](https://davidgohel.github.io/flextable/reference/as_image.md),
[`as_qmd()`](https://davidgohel.github.io/flextable/reference/as_qmd.md),
[`as_strike()`](https://davidgohel.github.io/flextable/reference/as_strike.md),
[`as_sub()`](https://davidgohel.github.io/flextable/reference/as_sub.md),
[`as_sup()`](https://davidgohel.github.io/flextable/reference/as_sup.md),
[`as_word_field()`](https://davidgohel.github.io/flextable/reference/as_word_field.md),
[`colorize()`](https://davidgohel.github.io/flextable/reference/colorize.md),
[`gg_chunk()`](https://davidgohel.github.io/flextable/reference/gg_chunk.md),
[`grid_chunk()`](https://davidgohel.github.io/flextable/reference/grid_chunk.md),
[`linerange()`](https://davidgohel.github.io/flextable/reference/linerange.md),
[`minibar()`](https://davidgohel.github.io/flextable/reference/minibar.md),
[`plot_chunk()`](https://davidgohel.github.io/flextable/reference/plot_chunk.md)

## Examples

``` r
dat <- data.frame(
  col = "Google it",
  href = "https://www.google.fr/search?source=hp&q=flextable+R+package",
  stringsAsFactors = FALSE
)

ftab <- flextable(dat)
ftab <- compose(
  x = ftab, j = "col",
  value = as_paragraph(
    "This is a link: ",
    hyperlink_text(x = col, url = href)
  )
)
ftab


.cl-219a70c4{}.cl-2193ff0a{font-family:'Liberation Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-2196e59e{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-21970786{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-21970787{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


col
```

href

This is a link: [Google
it](https://www.google.fr/search?source=hp&q=flextable+R+package)

https://www.google.fr/search?source=hp&q=flextable+R+package
