# Create a chunk representation suitable for flextable

This function is to be used by external packages that want to provide an
object that can be inserted as a chunk object in paragraphs of a
flextable object.

## Usage

``` r
chunk_dataframe(...)
```

## Arguments

- ...:

  values to set.

## Value

a data.frame with an additional class "chunk" that makes it suitable for
beeing used in
[`as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.md)

## text pattern with default values

    chunk_dataframe(txt = c("any text", "other text"))

## text pattern with bold set to TRUE

    chunk_dataframe(
      txt = c("any text", "other text"),
      bold = c(TRUE, TRUE))

## text pattern with control over all formatting properties

    chunk_dataframe(
      txt = c("any text", "other text"),
      font.size = c(12, 10),
      italic = c(FALSE, TRUE),
      bold = c(FALSE, TRUE),
      underlined = c(FALSE, TRUE),
      strike = c(FALSE, TRUE),
      color = c("black", "red"),
      shading.color = c("transparent", "yellow"),
      font.family = c("Arial", "Arial"),
      hansi.family = c("Arial", "Arial"),
      eastasia.family = c("Arial", "Arial"),
      cs.family = c("Arial", "Arial"),
      vertical.align = c("top", "bottom") )

## text with url pattern

    chunk_dataframe(
      txt = c("any text", "other text"),
      url = rep("https://www.google.fr", 2),
      font.size = c(12, 10),
      italic = c(FALSE, TRUE),
      bold = c(FALSE, TRUE),
      underlined = c(FALSE, TRUE),
      strike = c(FALSE, TRUE),
      color = c("black", "red"),
      shading.color = c("transparent", "yellow"),
      font.family = c("Arial", "Arial"),
      hansi.family = c("Arial", "Arial"),
      eastasia.family = c("Arial", "Arial"),
      cs.family = c("Arial", "Arial"),
      vertical.align = c("top", "bottom") )

## images pattern

    chunk_dataframe(width = width, height = height, img_data = files )
