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
rmd_str <-
  c("---",
    "title: flextable",
    "---", rmd_str)
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

  style_nodes <- xml_find_all(x, "/w:document/w:body/w:tbl/preceding-sibling::*[1]/w:pPr/w:pStyle[@w:val='TableCaption']")
  expect_length(style_nodes, 2)
  txt_nodes <- xml_find_all(x, "/w:document/w:body/w:tbl/preceding-sibling::*[1]/w:r/w:t")
  expect_equal(
    sum(xml_text(txt_nodes) %in% "a table caption"),
    2
  )
})

test_that("html_document2 captions", {
  skip_if_not_installed("bookdown")
  skip_if_not(pandoc_version() >= numeric_version("2"))

  render(rmd_file, output_format = bookdown::html_document2(),
         output_file = "caption.html", quiet = TRUE)

  doc <- read_html(file.path(dirname(rmd_file), "caption.html"))
  captions_ids <- xml_find_all(doc, "//table/caption/span")
  expect_equal(xml_attr(captions_ids, "id"), c("tab:table1", "tab:table2"))
  txt <- gsub("[\n\r]+", "", xml_text(xml_find_all(doc, "//table/caption")))
  expect_equal(txt, c("Table 1: a table caption", "Table 2: a table caption"))
})

rmd_str <-
  c("```{r include=FALSE}", "knitr::opts_chunk$set(echo=FALSE)",
    "library(flextable)", "```", "", "```{r tab.id=\"table1\", tab.cap=\"a table caption\", tab.cap.style=\"Table Caption\"}",
    "df <- head(airquality)", "ft <- flextable(df)", "ft", "```",
    "", "```{r table2}", "library(officer)", "autonum <- run_autonum(seq_id = \"tab\", bkm = \"mtcars\")",
    "ft <- set_caption(ft, caption =\"a table caption\", autonum = autonum, style = \"Table Caption\")",
    "ft", "```")
rmd_str <-
  c("---",
    "title: flextable",
    "---", rmd_str)
rmd_file <- tempfile(fileext = ".Rmd")
writeLines(rmd_str, rmd_file)

test_that("word_document captions", {
  skip_if_not(pandoc_version() >= numeric_version("2"))

  template <- tempfile(fileext = ".docx")
  print(read_docx(), target = template)

  render(rmd_file, output_format = rmarkdown::word_document(reference_docx=template),
         output_file = "caption.docx", quiet = TRUE)
  dir_xml <- tempfile(pattern = "xml_tmp")
  officer::unpack_folder(file.path(dirname(rmd_file), "caption.docx"), dir_xml)

  xml_file <- file.path(dir_xml, "/word/document.xml" )
  x <- read_xml(xml_file)


  xml_find_all(x, "/w:document/w:body/w:tbl/preceding-sibling::w:p[1]/w:bookmarkStart[@w:name='table1']")
  bookmarks <- xml_find_all(x, "/w:document/w:body/w:tbl/preceding-sibling::w:p[1]/w:bookmarkStart")
  expect_length(bookmarks, 2)
  expect_equal(xml_attr(bookmarks, "name"), c("table1", "mtcars"))
  wordfields <- xml_find_all(x, "/w:document/w:body/w:tbl/preceding-sibling::w:p[1]/w:r/w:instrText")
  expect_equal(xml_text(wordfields), c("SEQ tab \\* Arabic", "SEQ tab \\* Arabic"))
})

test_that("html_document captions", {
  skip_if_not(pandoc_version() >= numeric_version("2"))

  render(rmd_file, output_format = "rmarkdown::html_document",
         output_file = "caption.html", quiet = TRUE)
  doc <- read_html(file.path(dirname(rmd_file), "caption.html"))
  captions <- xml_find_all(doc, "//table/caption")
  expect_equal(
    sum(xml_text(captions) %in% "a table caption"),
    2
  )
})

