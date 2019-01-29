context("check cells text")

library(xml2)
library(officer)

ft1 <- flextable(data.frame(a="1 < 3", stringsAsFactors = FALSE))

get_xml_doc <- function(tab, main_folder = "docx_folder") {
  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = tab)
  print(doc, target = docx_file)

  main_folder <- file.path(getwd(), main_folder )
  unlink(main_folder, recursive = TRUE, force = TRUE)

  unpack_folder(file = docx_file, folder = main_folder)
  doc_file <- file.path(main_folder, "/word/document.xml" )
  read_xml( doc_file )
}

get_xml_ppt <- function(tab, main_folder = "pptx_folder") {
  pptx_file <- tempfile(fileext = ".pptx")
  doc <- read_pptx()
  doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
  doc <- ph_with_flextable(doc, tab)
  print(doc, target = pptx_file)

  main_folder <- file.path(getwd(), main_folder )
  unlink(main_folder, recursive = TRUE, force = TRUE)
  unpack_folder(file = pptx_file, folder = main_folder)
  doc_file <- file.path(main_folder, "/ppt/slides/slide1.xml" )
  read_xml( doc_file )
}

test_that("docx - string are html encoded", {
  main_folder <- "docx_folder"

  doc <- get_xml_doc( tab = ft1, main_folder = main_folder )
  text_ <- xml_text(xml_find_first(doc, "w:body/w:tbl[1]/w:tr[2]/w:tc/w:p/w:r/w:t"))
  expect_equal(text_, c("1 < 3") )

  unlink(main_folder, recursive = TRUE, force = TRUE)
})

test_that("pptx - string are html encoded", {

  main_folder <- "pptx_folder"

  doc <- get_xml_ppt( tab = ft1, main_folder = main_folder )
  text_ <- xml_text(xml_find_first(doc, "//a:tbl/a:tr[2]/a:tc/a:txBody/a:p/a:r/a:t"))
  expect_equal(text_, c("1 < 3") )


  unlink(main_folder, recursive = TRUE, force = TRUE)
})

test_that("html - string are html encoded", {

  str_ <- flextable:::html_str.flextable(ft1)
  doc <- read_xml(str_)
  text_ <- xml_text(xml_find_first(doc, "//tbody/tr/td/p/span"))
  expect_equal(text_, c("1 < 3") )
})

test_that("NA managment", {

  x <- data.frame(zz = c("a", NA_character_), stringsAsFactors = FALSE)
  ft1 <- flextable(x)

  str_ <- flextable:::html_str.flextable(ft1)
  doc <- read_xml(str_)
  text_ <- xml_text(xml_find_all(doc, "tbody/tr/td/p"))
  expect_equal(text_, c("a", "") )
})
