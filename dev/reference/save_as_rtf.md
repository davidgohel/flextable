# Save flextable objects in an 'RTF' file

sugar function to save flextable objects in an 'RTF' file.

## Usage

``` r
save_as_rtf(..., values = NULL, path, pr_section = NULL)
```

## Arguments

- ...:

  flextable objects, objects, possibly named. If named objects, names
  are used as titles.

- values:

  a list (possibly named), each element is a flextable object. If named
  objects, names are used as titles. If provided, argument `...` will be
  ignored.

- path:

  Word file to be created

- pr_section:

  a
  [officer::prop_section](https://davidgohel.github.io/officer/reference/prop_section.html)
  object that can be used to define page layout such as orientation,
  width and height.

## Value

a string containing the full name of the generated file

## See also

[`paginate()`](https://davidgohel.github.io/flextable/dev/reference/paginate.md)

Other flextable print function:
[`df_printer()`](https://davidgohel.github.io/flextable/dev/reference/df_printer.md),
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
[`to_html.flextable()`](https://davidgohel.github.io/flextable/dev/reference/to_html.flextable.md)

## Examples

``` r
tf <- tempfile(fileext = ".rtf")

library(officer)
ft1 <- flextable(head(iris))
save_as_rtf(ft1, path = tf)


ft2 <- flextable(head(mtcars))
sect_properties <- prop_section(
  page_size = page_size(
    orient = "landscape",
    width = 8.3, height = 11.7
  ),
  type = "continuous",
  page_margins = page_mar(),
  header_default = block_list(
    fpar(ftext("text for default page header")),
    qflextable(data.frame(a = 1L))
  )
)
tf <- tempfile(fileext = ".rtf")
save_as_rtf(
  `iris table` = ft1, `mtcars table` = ft2,
  path = tf, pr_section = sect_properties
)
```
