context("captions")

library(utils)
library(xml2)
library(officer)
library(rmarkdown)

rmd_str <- c("---", "output:", "  bookdown::word_document2:", "    keep_md: true",
  "---", "", "```{r setup, include=FALSE}", "knitr::opts_chunk$set(echo=FALSE)",
  "```", "", "```{r libs}", "library(flextable)", "```", "", "Table \\@ref(tab:table1).",
  "", "```{r table1, tab.cap=\"a table caption\", tab.cap.style=\"Table Caption\"}",
  "df <- head(iris)", "ft <- flextable(df)", "ft", "```", "", "Table \\@ref(tab:table2).",
  "", "```{r table2}", "ft <- set_caption(", "  x = ft, ", "  caption =\"a table caption\", ",
  "  style = \"Table Caption\")", "ft", "```", "")
rmd_file <- tempfile(fileext = ".Rmd")
writeLines(rmd_str, rmd_file)

test_that("row height is valid", {
  render(rmd_file, output_file = "caption.docx", quiet = TRUE)
  dir_xml <- tempfile(pattern = "xml_tmp")
  officer::unpack_folder(file.path(dirname(rmd_file), "caption.docx"), dir_xml)

  xml_file <- file.path(dir_xml, "/word/document.xml" )
  x <- read_xml(xml_file)
  caption1 <- xml_find_first(x, "//w:p[2]")
  ref_1 <- list(pPr = list(pStyle = structure(list(), val = "TableCaption")),
                r = list(t = structure(list("Table 1: a table caption"), space = "preserve")))
  expect_equal(as_list(caption1), ref_1)

  caption2 <- xml_find_first(x, "//w:p[4]")
  ref_2 <- list(pPr = list(pStyle = structure(list(), val = "TableCaption")),
                r = list(t = structure(list("Table 2: a table caption"), space = "preserve")))
  expect_equal(as_list(caption2), ref_2)
})

