library(rmarkdown)
library(xml2)
library(officer)

testthat::test_that("HTML cross-references are not OK when not using bookdown", {
  skip_if_not(pandoc_version() >= numeric_version("2"))

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("test-captions-rmd.Rmd", rmd_file)

  baseout <- "caption-tests"
  file_out <- paste0(baseout, "-rmd.html")

  render(rmd_file,
         output_format = rmarkdown::html_document(),
         output_file = file_out,
         quiet = TRUE)
  xml_doc <- read_html(file.path(dirname(rmd_file), file_out))
  crossref_chunk <- xml_find_first(xml_doc, "//a[@href='#tab:id1']")
  expect_true(inherits(crossref_chunk, "xml_missing"))

  body <- xml_find_first(xml_doc, "//*[id='tab:id1']")
  id_chunk <- xml_find_first(xml_doc, "//table/caption/p/span[@id='tab:id1']")
  expect_true(inherits(id_chunk, "xml_missing"))

  captions <- xml_find_all(xml_doc, "//table/caption/p")
  expect_true(all(!grepl("Table [0-9]+:" , xml_text(captions))))
})

testthat::test_that("HTML cross-references are OK when using bookdown", {
  skip_if_not(pandoc_version() >= numeric_version("2"))

  testthat::skip_if_not_installed("bookdown")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("test-captions-rmd.Rmd", rmd_file)

  baseout <- "caption-tests"
  file_out <- paste0(baseout, "-bookdown-rmd.html")

  render(rmd_file,
         output_format = bookdown::html_document2(keep_md = FALSE),
         output_file = file_out,
         quiet = TRUE)
  xml_doc <- read_html(file.path(dirname(rmd_file), file_out))
  crossref_chunk <- xml_find_first(xml_doc, "//a[@href='#tab:id1']")
  expect_false(inherits(crossref_chunk, "xml_missing"))

  body <- xml_find_first(xml_doc, "//*[id='tab:id1']")
  id_chunk <- xml_find_first(xml_doc, "//table/caption/p/span[@id='tab:id1']")
  expect_false(inherits(id_chunk, "xml_missing"))

  caption <- xml_find_first(xml_doc, "//table/caption/p[span/@id='tab:id1']")
  expect_true(grepl("Table 2:" , xml_text(caption)))
})


testthat::test_that("DOCX cross-references are OK when using bookdown", {
  skip_if_not(pandoc_version() >= numeric_version("2"))

  testthat::skip_if_not_installed("bookdown")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("test-captions-rmd.Rmd", rmd_file)

  baseout <- "caption-tests"
  file_out <- paste0(baseout, "-bookdown-rmd.docx")

  render(rmd_file,
         output_format = bookdown::word_document2(keep_md = FALSE),
         output_file = file_out,
         quiet = TRUE)

  doc <- read_docx(file.path(dirname(rmd_file), file_out))

  caption_node <- xml_find_first(docx_body_xml(doc),
                                 xpath = "/w:document/w:body/w:tbl[2]/preceding-sibling::*[1]")
  expect_true(grepl("Table 2", xml_text(caption_node), fixed = TRUE))

  crossref_node <- xml_find_first(docx_body_xml(doc), "/w:document/w:body/w:p[2]")
  expect_equal("Cross-reference is there: 2", xml_text(crossref_node))
})


testthat::test_that("DOCX bookmark is OK when not using bookdown", {
  skip_if_not(pandoc_version() >= numeric_version("2"))

  testthat::skip_if_not_installed("bookdown")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("test-captions-rmd.Rmd", rmd_file)

  baseout <- "caption-tests"
  file_out <- paste0(baseout, "-rmd.docx")

  render(rmd_file,
         output_format = word_document(keep_md = FALSE),
         output_file = file_out,
         quiet = TRUE)

  doc <- read_docx(file.path(dirname(rmd_file), file_out))

  caption_node <- xml_find_first(
    x = docx_body_xml(doc),
    xpath = "/w:document/w:body/w:tbl[2]/preceding-sibling::*[1]")

  expect_true(grepl("Table SEQ tab \\* Arabic", xml_text(caption_node), fixed = TRUE))
})


test_that("PDF cross-references are OK when using bookdown", {
  skip_if_not(pandoc_version() >= numeric_version("2"))
  skip_if_not_installed("bookdown")
  skip_if_not_installed("pdftools")

  require("pdftools")

  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("test-captions-rmd.Rmd", rmd_file)

  baseout <- "caption-tests"
  file_out <- paste0(baseout, "-bookdown-rmd.pdf")

  render(rmd_file,
         output_format = bookdown::pdf_document2(keep_md = FALSE),
         output_file = file_out,
         quiet = TRUE)

  doc <- pdf_text(file.path(dirname(rmd_file), file_out))
  txtfile <- tempfile()
  cat(paste0(doc, collapse = "\n"), file = txtfile)
  doc <- readLines(txtfile)

  expect_true(any(grepl("Cross-reference is there: 2", doc, fixed = TRUE)))
})

