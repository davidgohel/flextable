# internal utils for roxygen tags reuse

internal utils for roxygen tags reuse

## Note

This chunk option requires package officedown in a R Markdown context
with Word output format. With Quarto (`format: docx`) or
[`rmarkdown::word_document()`](https://pkgs.rstudio.com/rmarkdown/reference/word_document.html),
the resulting file must be repaired with
[`repair_docx()`](https://davidgohel.github.io/flextable/dev/reference/repair_docx.md).

PowerPoint cannot mix images and text in a paragraph, images are removed
when outputing to PowerPoint format.
