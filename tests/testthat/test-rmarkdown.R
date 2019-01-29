context(paste("check rmarkdown with pandoc", as.character(rmarkdown::pandoc_version()) ))

rmd_file <- tempfile(fileext = ".Rmd")
cat("
---
title: test
---

```{r}
library(flextable)
knitr::opts_chunk$set(echo = TRUE)
rt <- flextable(head(mtcars))
rt <- theme_booktabs(rt)
rt <- autofit(rt)
rt
```
", file = rmd_file )
docx_file <- gsub("\\.Rmd$", ".docx", rmd_file )
html_file <- gsub("\\.Rmd$", ".html", rmd_file )

test_that("html output", {
  testthat::skip_if_not(rmarkdown::pandoc_available("1.12.3"))
  html <- rmarkdown::render(rmd_file, output_format = "html_document", output_file = html_file, quiet = TRUE)
  expect_equal(basename(html), basename(html_file) )
})

test_that("docx output", {

  skip_if_not(Sys.which('pandoc') != "")
  skip_if_not(Sys.which('pandoc-citeproc') != "")
  skip_if_not(rmarkdown::pandoc_available("1.12.3"))

  if (rmarkdown::pandoc_version() >= 2){
    docx <- rmarkdown::render(rmd_file, output_format = "word_document", output_file = docx_file, quiet = TRUE)
    expect_equal(basename(docx), basename(docx_file) )
  } else {
    expect_error({out <- rmarkdown::render(rmd_file, output_format = "word_document", output_file = docx_file, quiet = TRUE)},
                 regexp = "2.0 required for flextable rendering in docx")
  }
})

