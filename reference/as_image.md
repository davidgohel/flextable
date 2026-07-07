# Image chunk

The function lets add images within flextable objects with functions:

- [`compose()`](https://davidgohel.github.io/flextable/reference/compose.md)
  and
  [`as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.md),

- [`append_chunks()`](https://davidgohel.github.io/flextable/reference/append_chunks.md),

- [`prepend_chunks()`](https://davidgohel.github.io/flextable/reference/prepend_chunks.md)
  ![as_image
  illustration](https://www.ardata.fr/img/flextable-imgs/flextable-006.png)

## Usage

``` r
as_image(
  src,
  width = NULL,
  height = NULL,
  unit = "in",
  guess_size = TRUE,
  alt = "",
  ...
)
```

## Arguments

- src:

  image filename

- width, height:

  size of the image file. It can be ignored if parameter
  `guess_size=TRUE`, see parameter `guess_size`.

- unit:

  unit for width and height, one of "in", "cm", "mm".

- guess_size:

  If package 'magick' is installed, this option can be used (set it to
  `TRUE` and don't provide values for paramters `width` and `height`).
  When the flextable will be printed, the images will be read and width
  and height will be guessed. This should be avoid if possible as it can
  be an extensive task when several images.

- alt:

  alternative text for the image (used for accessibility)

- ...:

  unused argument

## Note

This chunk option requires package officedown in a R Markdown context
with Word output format. With Quarto (`format: docx`) or
[`rmarkdown::word_document()`](https://pkgs.rstudio.com/rmarkdown/reference/word_document.html),
the resulting file must be repaired with
[`repair_docx()`](https://davidgohel.github.io/flextable/reference/repair_docx.md).

PowerPoint cannot mix images and text in a paragraph, images are removed
when outputing to PowerPoint format.

## See also

[`compose()`](https://davidgohel.github.io/flextable/reference/compose.md),
[`as_paragraph()`](https://davidgohel.github.io/flextable/reference/as_paragraph.md)

Other chunk elements for paragraph:
[`as_b()`](https://davidgohel.github.io/flextable/reference/as_b.md),
[`as_bracket()`](https://davidgohel.github.io/flextable/reference/as_bracket.md),
[`as_chunk()`](https://davidgohel.github.io/flextable/reference/as_chunk.md),
[`as_equation()`](https://davidgohel.github.io/flextable/reference/as_equation.md),
[`as_highlight()`](https://davidgohel.github.io/flextable/reference/as_highlight.md),
[`as_i()`](https://davidgohel.github.io/flextable/reference/as_i.md),
[`as_qmd()`](https://davidgohel.github.io/flextable/reference/as_qmd.md),
[`as_strike()`](https://davidgohel.github.io/flextable/reference/as_strike.md),
[`as_sub()`](https://davidgohel.github.io/flextable/reference/as_sub.md),
[`as_sup()`](https://davidgohel.github.io/flextable/reference/as_sup.md),
[`as_word_field()`](https://davidgohel.github.io/flextable/reference/as_word_field.md),
[`colorize()`](https://davidgohel.github.io/flextable/reference/colorize.md),
[`gg_chunk()`](https://davidgohel.github.io/flextable/reference/gg_chunk.md),
[`grid_chunk()`](https://davidgohel.github.io/flextable/reference/grid_chunk.md),
[`hyperlink_text()`](https://davidgohel.github.io/flextable/reference/hyperlink_text.md),
[`linerange()`](https://davidgohel.github.io/flextable/reference/linerange.md),
[`minibar()`](https://davidgohel.github.io/flextable/reference/minibar.md),
[`plot_chunk()`](https://davidgohel.github.io/flextable/reference/plot_chunk.md)

## Examples

``` r
img.file <- file.path(
  R.home("doc"),
  "html", "logo.jpg"
)
if (require("magick")) {
  myft <- flextable(head(iris))
  myft <- compose(myft,
    i = 1:3, j = 1,
    value = as_paragraph(
      as_image(src = img.file),
      " ",
      as_chunk(Sepal.Length,
        props = fp_text_default(color = "red")
      )
    ),
    part = "body"
  )
  ft <- autofit(myft)
  ft
}
#> Loading required package: magick
#> Linking to ImageMagick 6.9.12.98
#> Enabled features: fontconfig, freetype, fftw, heic, lcms, pango, raw, webp, x11
#> Disabled features: cairo, ghostscript, rsvg


.cl-3a4581d8{}.cl-3a3e219a{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-3a3e21ae{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(255, 0, 0, 1.00);background-color:transparent;}.cl-3a41584c{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-3a415860{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-3a417cdc{width:1.966in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417ce6{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417ce7{width:1.245in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417cf0{width:1.163in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417cf1{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417cfa{width:1.966in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417cfb{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d04{width:1.245in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d05{width:1.163in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d0e{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d0f{width:1.966in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d18{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d19{width:1.245in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d22{width:1.163in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d23{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d2c{width:1.966in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d2d{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d36{width:1.245in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d40{width:1.163in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-3a417d4a{width:1.674in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Sepal.Length
```
