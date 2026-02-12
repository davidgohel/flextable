# Add a flextable into a PowerPoint slide

Add a flextable in a PowerPoint document object produced by
[`officer::read_pptx()`](https://davidgohel.github.io/officer/reference/read_pptx.html).

This function will create a native PowerPoint table from the flextable
and the result can be eventually edited.

## Usage

``` r
# S3 method for class 'flextable'
ph_with(x, value, location, ...)
```

## Arguments

- x:

  a pptx device

- value:

  flextable object

- location:

  a location for a placeholder. See
  [`officer::ph_location_type()`](https://davidgohel.github.io/officer/reference/ph_location_type.html)
  for example.

- ...:

  unused arguments.

## Note

The width and height of the table can not be set with `location`. Use
functions
[`width()`](https://davidgohel.github.io/flextable/reference/width.md),
[`height()`](https://davidgohel.github.io/flextable/reference/height.md),
[`autofit()`](https://davidgohel.github.io/flextable/reference/autofit.md)
and
[`dim_pretty()`](https://davidgohel.github.io/flextable/reference/dim_pretty.md)
instead. The overall size is resulting from cells, paragraphs and text
properties (i.e. padding, font size, border widths).

## caption

Captions are not printed in PowerPoint slides.

While captions are useful for document formats like Word, RTF, HTML, or
PDF, they aren't directly supported in PowerPoint slides. Unlike
documents with a defined layout, PowerPoint slides lack a structured
document flow. They don't function like HTML documents or paginated
formats (RTF, Word, PDF). This makes it technically challenging to
determine the ideal placement for a caption within a slide.
Additionally, including a caption within the table itself isn't
feasible.

## Examples

``` r
library(officer)

ft <- flextable(head(iris))

doc <- read_pptx()
doc <- add_slide(doc, "Title and Content", "Office Theme")
doc <- ph_with(doc, ft, location = ph_location_left())

fileout <- tempfile(fileext = ".pptx")
print(doc, target = fileout)
```
