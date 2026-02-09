# Set flextable caption

Set caption value in a flextable. The function can also be used to
define formattings that will be applied if possible to Word and HTML
outputs.

- The caption will be associated with a paragraph style when the output
  is Word. It can also be numbered as a auto-numbered Word computed
  value.

- The PowerPoint format ignores captions. PowerPoint documents are not
  structured and do not behave as HTML documents and paginated documents
  (word, pdf), and it's not possible to know where we should create a
  shape to contain the caption (technically it can't be in the
  PowerPoint shape containing the table).

When working with 'R Markdown' or 'Quarto', the caption settings defined
with `set_caption()` will be prioritized over knitr chunk options.

Caption value can be a single string or the result to a call to
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md).
With the latter, the caption is made of formatted chunks whereas with
the former, caption will not be associated with any formatting.

## Usage

``` r
set_caption(
  x,
  caption = NULL,
  autonum = NULL,
  word_stylename = "Table Caption",
  style = word_stylename,
  fp_p = fp_par(padding = 3),
  align_with_table = TRUE,
  html_classes = NULL,
  html_escape = TRUE
)
```

## Arguments

- x:

  a 'flextable' object, see
  [flextable-package](https://davidgohel.github.io/flextable/dev/reference/flextable-package.md)
  to learn how to create 'flextable' object.

- caption:

  caption value. The caption can be either a string either a call to
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md).
  In the latter case, users are free to format the caption with colors,
  italic fonts, also mixed with images or equations. Note that Quarto
  does not allow the use of this feature.

  Caption as a string does not support 'Markdown' syntax. If you want to
  add a bold text in the caption, use
  `as_paragraph('a ', as_b('bold'), ' text')` when providing caption.

- autonum:

  an autonum representation. See
  [`officer::run_autonum()`](https://davidgohel.github.io/officer/reference/run_autonum.html).
  This has an effect only when the output is "Word" (in which case the
  object is used to define the Word auto-numbering), "html" and "pdf"
  (in which case only the bookmark identifier will be used). If used,
  the caption is preceded by an auto-number sequence.

- word_stylename, style:

  'Word' style name to associate with caption paragraph. These names are
  available with function
  [`officer::styles_info()`](https://davidgohel.github.io/officer/reference/styles_info.html)
  when output is Word. Argument `style` is deprecated in favor of
  `word_stylename`. If the caption is defined with
  [`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md),
  some of the formattings of the paragraph style will be replaced by the
  formattings associated with the chunks (such as the font).

- fp_p:

  paragraph formatting properties associated with the caption, see
  [`officer::fp_par()`](https://davidgohel.github.io/officer/reference/fp_par.html).
  It applies when possible, i.e. in HTML and 'Word' but not with
  bookdown.

- align_with_table:

  if TRUE, caption is aligned as the flextable, if FALSE, `fp_p` will
  not be updated and alignement is as defined with `fp_p`. It applies
  when possible, i.e. in HTML and 'Word' but not with bookdown.

- html_classes:

  css class(es) to apply to associate with caption paragraph when output
  is 'Word'.

- html_escape:

  should HTML entities be escaped so that it can be safely included as
  text or an attribute value within an HTML document.

## Details

The behavior of captions in the 'flextable' package varies depending on
the formats and technologies used.

The values set by the `set_caption()` function will be prioritized
whenever possible, including the caption ID and associated paragraph
style. However, it's important to note that the behavior may differ
across different tools. Here's what we have observed and attempted to
respect, but please inform us if you believe our observations are
incorrect:

- In Word and HTML documents created with 'rmarkdown'
  [`rmarkdown::word_document()`](https://pkgs.rstudio.com/rmarkdown/reference/word_document.html)
  and
  [`rmarkdown::html_document()`](https://pkgs.rstudio.com/rmarkdown/reference/html_document.html),
  numbered and cross-referenced captions are not typically expected.

- In PDF documents created with 'rmarkdown'
  [`rmarkdown::pdf_document()`](https://pkgs.rstudio.com/rmarkdown/reference/pdf_document.html),
  numbers are automatically added before the caption.

- In Word and HTML documents created with 'bookdown', numbered and
  cross-referenced captions are expected. 'bookdown' handles this
  functionality, but due to technical reasons, the caption should not be
  defined within an HTML or XML block. Therefore, when using
  'flextable', the ability to format the caption content is lost (this
  limitation does not apply to PDF documents).

- HTML and PDF documents created with Quarto handle captions and
  cross-references differently. Quarto replaces captions with 'tbl-cap'
  and 'label' values.

- Word documents created with Quarto present another specific case.
  Currently, Quarto does not inject captions using the 'tbl-cap' and
  label values. However, this is a temporary situation that is expected
  to change in the future. The 'flextable' package will adapt
  accordingly as Quarto evolves.

- When using the
  [`body_add_flextable()`](https://davidgohel.github.io/flextable/dev/reference/body_add_flextable.md)
  function, all the options specified with `set_caption()` will be
  enabled.

Using
[`body_add_flextable()`](https://davidgohel.github.io/flextable/dev/reference/body_add_flextable.md)
enable all options specified with `set_caption()`.

## R Markdown

flextable captions can be defined from R Markdown documents by using
`knitr::opts_chunk$set()`. User don't always have to call
`set_caption()` to set a caption, he can use knitr chunk options
instead. A typical call would be:

    ```{r}
    #| tab.id: bookmark_id
    #| tab.cap: caption text
    flextable(head(cars))
    ```

`tab.id` is the caption id or bookmark, `tab.cap` is the caption text.
There are many options that can replace `set_caption()` features. The
following knitr chunk options are available:

|                                                         |                 |                           |
|---------------------------------------------------------|-----------------|---------------------------|
| **label**                                               | **name**        | **value**                 |
| Word stylename to use for table captions.               | tab.cap.style   | NULL                      |
| caption id/bookmark                                     | tab.id          | NULL                      |
| caption                                                 | tab.cap         | NULL                      |
| display table caption on top of the table or not        | tab.topcaption  | TRUE                      |
| caption table sequence identifier.                      | tab.lp          | "tab:"                    |
| prefix for numbering chunk (default to "Table ").       | tab.cap.pre     | Table                     |
| suffix for numbering chunk (default to ": ").           | tab.cap.sep     | " :"                      |
| title number depth                                      | tab.cap.tnd     | 0                         |
| separator to use between title number and table number. | tab.cap.tns     | "-"                       |
| caption prefix formatting properties                    | tab.cap.fp_text | fp_text_lite(bold = TRUE) |

See
[knit_print.flextable](https://davidgohel.github.io/flextable/dev/reference/knit_print.flextable.md)
for more details.

## Formatting the caption

To create captions in R Markdown using the 'flextable' package and
'officer' package, you can utilize the
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)
function. This approach is recommended when your captions require
complex content, such as a combination of different text styles or the
inclusion of images and equations.

The caption is constructed as a paragraph consisting of multiple chunks.
Each chunk represents a specific portion of the caption with its desired
formatting, such as red bold text or Arial italic text.

By default, if no specific formatting is specified (using either "a
string" or `as_chunk("a string")`), the
[`fp_text_default()`](https://davidgohel.github.io/flextable/dev/reference/fp_text_default.md)
function sets the font settings for the caption, including the font
family, boldness, italics, color, etc. The default values can be
modified using the
[`set_flextable_defaults()`](https://davidgohel.github.io/flextable/dev/reference/set_flextable_defaults.md)
function. However, it is recommended to explicitly use
[`as_chunk()`](https://davidgohel.github.io/flextable/dev/reference/as_chunk.md)
to define the desired formatting.

It's important to note that the style properties of the caption will not
override the formatting of the individual elements within it. Therefore,
you need to explicitly specify the font to be used for the caption.

Here's an example of how to set a caption for a flextable in R Markdown
using the 'officer' package:

    library(flextable)
    library(officer)

    ftab <- flextable(head(cars)) %>%
      set_caption(
        as_paragraph(
          as_chunk("caption", props = fp_text_default(font.family = "Cambria"))
        ), word_stylename = "Table Caption"
      )

    print(ftab, preview = "docx")

In this example, the `set_caption()` function sets the caption for the
flextable. The caption is created using
[`as_paragraph()`](https://davidgohel.github.io/flextable/dev/reference/as_paragraph.md)
with a single chunk created using
`as_chunk("caption", props = fp_text_default(font.family = "Cambria"))`.
The `word_stylename` parameter is used to specify the table caption
style in the resulting Word document. Finally, the
[`print()`](https://rdrr.io/r/base/print.html) function generates the
flextable with the caption, and `preview = "docx"` displays a preview of
the resulting Word document.

## Using 'Quarto'

In 'Quarto', captions and cross-references are handled differently
compared to 'R Markdown', where flextable takes care of the job. In
Quarto, the responsibility for managing captions lies with the Quarto
framework itself. Consequently, the `set_caption()` function in
'flextable' is not as useful in a 'Quarto' document. The formatting and
numbering of captions are determined by Quarto rather than flextable.
Please refer to the Quarto documentation for more information on how to
work with captions in Quarto.

## See also

[`flextable()`](https://davidgohel.github.io/flextable/dev/reference/flextable.md)

## Examples

``` r
ftab <- flextable(head(iris))
ftab <- set_caption(ftab, "my caption")
ftab


.cl-30b898a0{}.cl-30b1feaa{font-family:'DejaVu Sans';font-size:11pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-30b4d166{margin:0;text-align:right;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-30b4d170{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:5pt;padding-top:5pt;padding-left:5pt;padding-right:5pt;line-height: 1;background-color:transparent;}.cl-30b4f218{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-30b4f222{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 1.5pt solid rgba(102, 102, 102, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-30b4f223{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-30b4f22c{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-30b4f22d{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-30b4f22e{width:0.75in;background-color:transparent;vertical-align: middle;border-bottom: 1.5pt solid rgba(102, 102, 102, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}

my caption

Sepal.Length
```

Sepal.Width

Petal.Length

Petal.Width

Species

5.1

3.5

1.4

0.2

setosa

4.9

3.0

1.4

0.2

setosa

4.7

3.2

1.3

0.2

setosa

4.6

3.1

1.5

0.2

setosa

5.0

3.6

1.4

0.2

setosa

5.4

3.9

1.7

0.4

setosa

[library](https://rdrr.io/r/base/library.html)([officer](https://ardata-fr.github.io/officeverse/))
autonum \<-
[run_autonum](https://davidgohel.github.io/officer/reference/run_autonum.html)(seq_id
= "tab", bkm = "mtcars") ftab \<-
[flextable](https://davidgohel.github.io/flextable/dev/reference/flextable.md)([head](https://rdrr.io/r/utils/head.html)(mtcars))
ftab \<- set_caption(ftab, caption = "mtcars data", autonum = autonum)
ftab

| mpg  | cyl | disp | hp  | drat | wt    | qsec  | vs  | am  | gear | carb |
|------|-----|------|-----|------|-------|-------|-----|-----|------|------|
| 21.0 | 6   | 160  | 110 | 3.90 | 2.620 | 16.46 | 0   | 1   | 4    | 4    |
| 21.0 | 6   | 160  | 110 | 3.90 | 2.875 | 17.02 | 0   | 1   | 4    | 4    |
| 22.8 | 4   | 108  | 93  | 3.85 | 2.320 | 18.61 | 1   | 1   | 4    | 1    |
| 21.4 | 6   | 258  | 110 | 3.08 | 3.215 | 19.44 | 1   | 0   | 3    | 1    |
| 18.7 | 8   | 360  | 175 | 3.15 | 3.440 | 17.02 | 0   | 0   | 3    | 2    |
| 18.1 | 6   | 225  | 105 | 2.76 | 3.460 | 20.22 | 1   | 0   | 3    | 1    |

mtcars data
