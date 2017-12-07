context(paste("check rmarkdown with pandoc", as.character(rmarkdown::pandoc_version()) ))

rmd_file <- tempfile(fileext = ".Rmd")
cat("
---
title: test
---

```{r}
library(flextable)
knitr::opts_chunk$set(echo = TRUE)
rt <- regulartable(head(mtcars))
rt <- theme_booktabs(rt)
rt <- autofit(rt)
rt
```
", file = rmd_file )
docx_file <- gsub("\\.Rmd$", ".docx", rmd_file )
html_file <- gsub("\\.Rmd$", ".html", rmd_file )

test_that("html output", {
  html <- rmarkdown::render(rmd_file, output_format = "html_document", output_file = html_file, quiet = TRUE)
  expect_equal(basename(html), basename(html_file) )
})

test_that("docx output", {
  if (rmarkdown::pandoc_version() >= 2){
    docx <- rmarkdown::render(rmd_file, output_format = "word_document", output_file = docx_file, quiet = TRUE)
    expect_equal(basename(docx), basename(docx_file) )
  } else {
    expect_error({out <- rmarkdown::render(rmd_file, output_format = "word_document", output_file = docx_file, quiet = TRUE)},
                 regexp = "2.0 required for flextable rendering in docx")
  }
})

