context("captions")

library(utils)
library(xml2)
library(officer)
library(rmarkdown)

rmd_str <- c("```{r setup, include=FALSE}", "knitr::opts_chunk$set(echo=FALSE)",
"```", "", "```{r libs}", "library(flextable)", "```", "", "Table \\@ref(tab:table1).",
"", "```{r table1, tab.cap=\"a table caption\", tab.cap.style=\"Table Caption\"}",
"df <- head(iris)", "ft <- flextable(df)", "ft", "```", "", "Table \\@ref(tab:table2).",
"", "```{r table2}", "ft <- set_caption(", "  x = ft, ", "  caption =\"a table caption\", ",
"  style = \"Table Caption\")", "ft", "```", "")
rmd_file <- tempfile(fileext = ".Rmd")
writeLines(rmd_str, rmd_file)

test_that("word_document2 captions", {
  skip_if_not_installed("bookdown")
  skip_if_not(pandoc_version() >= numeric_version("2"))

  template <- tempfile(fileext = ".docx")
  print(read_docx(), target = template)

  render(rmd_file, output_format = bookdown::word_document2(reference_docx=template),
         output_file = "caption.docx", quiet = TRUE)
  dir_xml <- tempfile(pattern = "xml_tmp")
  officer::unpack_folder(file.path(dirname(rmd_file), "caption.docx"), dir_xml)

  xml_file <- file.path(dir_xml, "/word/document.xml" )
  x <- read_xml(xml_file)

  xml_captions <- xml_find_all(x, "/w:document/w:body/w:tbl/preceding-sibling::*[1]")
  caption <- xml_captions[[1]]
  pstyle <- xml_child(caption, "w:pPr/w:pStyle")
  expect_equal(xml_attr(pstyle, "val"), "TableCaption")
  txt <- xml_child(caption, "w:r/w:t")
  expect_equal(xml_text(txt), "Table 1: a table caption")

  caption <- xml_captions[[2]]
  pstyle <- xml_child(caption, "w:pPr/w:pStyle")
  expect_equal(xml_attr(pstyle, "val"), "TableCaption")
  txt <- xml_child(caption, "w:r/w:t")
  expect_equal(xml_text(txt), "Table 2: a table caption")
})

