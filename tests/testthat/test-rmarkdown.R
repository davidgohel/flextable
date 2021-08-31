context(paste("check rmarkdown with pandoc", as.character(rmarkdown::pandoc_version()) ))

rmd_file <- tempfile(fileext = ".Rmd")
cat("
---
title: test
---

```{r tab.lp='table:', tab.cap='caption', tab.id='tab1'}
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

  skip_if_not(rmarkdown::pandoc_available("1.12.3"))

  if (rmarkdown::pandoc_version() >= 2){
    docx <- rmarkdown::render(rmd_file, output_format = "word_document", output_file = docx_file, quiet = TRUE)
    expect_equal(basename(docx), basename(docx_file) )
  } else {
    expect_error({out <- rmarkdown::render(rmd_file, output_format = "word_document", output_file = docx_file, quiet = TRUE)},
                 regexp = "2.0 required for flextable rendering in docx")
  }
})

test_that("tab.lp is updated in HTML", {

  skip_if_not(rmarkdown::pandoc_available("1.12.3"))
  skip_if_not(rmarkdown::pandoc_version() >= 2)

  html <- rmarkdown::render(rmd_file, output_format = "bookdown::html_document2", output_file = html_file, quiet = TRUE)

  doc <- read_html(html)
  elt <- xml_find_first(doc, "body/div/template/div/table/caption")
  expect_true(grepl("(#table:tab1)caption", xml_text(elt), fixed = TRUE))
})

