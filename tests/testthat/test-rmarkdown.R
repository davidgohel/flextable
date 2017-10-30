context("check rmarkdown")

library(xml2)
library(officer)

rmd_file <- tempfile(fileext = ".Rmd")
cat("
---
title: test
---

```{r}
library(flextable)
knitr::opts_chunk$set(echo = TRUE)
knit_print.flextable = render_flextable
rt <- regulartable(head(mtcars))
rt <- theme_booktabs(rt)
rt <- autofit(rt)
rt
```
", file = rmd_file )
docx_file <- gsub("\\.Rmd$", ".docx", rmd_file )
html_file <- gsub("\\.Rmd$", ".html", rmd_file )

test_that("html output", {

  if (requireNamespace("knitr", quietly = TRUE) &&
      requireNamespace("rmarkdown", quietly = TRUE)){
    if (rmarkdown::pandoc_version() >= 2){
      docx <- rmarkdown::render(rmd_file, output_format = "word_document", output_file = docx_file, quiet = TRUE)
      expect_equal(basename(docx), basename(docx_file) )
    } else if (rmarkdown::pandoc_version() < 2){
      expect_error(rmarkdown::render(rmd_file, output_format = "word_document", output_file = docx_file, quiet = TRUE))
    }
    html <- rmarkdown::render(rmd_file, output_format = "html_document", output_file = html_file, quiet = TRUE)
    expect_equal(basename(html), basename(html_file) )
  }

})
