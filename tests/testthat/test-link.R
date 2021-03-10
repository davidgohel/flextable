context("check cells text")

library(xml2)
library(officer)

data <- data.frame(
  code = c("X01", "X02"),
  name = c("X Number 1", "X Number 2"),
  stringsAsFactors = FALSE)
url_base <- "https://example.com?/path&project=%s"
ft <- flextable(data)
ft <- flextable::compose(ft,
                         j = ~ code,
                         value = as_paragraph(
                           hyperlink_text(code, url = sprintf(url_base, code))
                         )
)

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
  doc <- ph_with(doc, tab, location = ph_location_type(type = "body"))
  print(doc, target = pptx_file)

  main_folder <- file.path(getwd(), main_folder )
  unlink(main_folder, recursive = TRUE, force = TRUE)
  unpack_folder(file = pptx_file, folder = main_folder)
  doc_file <- file.path(main_folder, "/ppt/slides/slide1.xml" )
  read_xml( doc_file )
}

test_that("docx - url encoding", {
  main_folder <- "docx_folder"

  doc <- get_xml_doc( tab = ft, main_folder = main_folder )
  rid <- xml_attr(xml_find_all(doc, "//w:hyperlink"), "id")
  rels <- read_xml(file.path(main_folder, "word", "_rels", "document.xml.rels"))
  urls <- sapply(rid, function(id, x){
    z <- xml_find_first(x, sprintf("//*[@Id='%s']", id))
    xml_attr(z, "Target")
  }, rels)

  expect_equivalent(urls, c("https%3A//example.com%3F/path%26project%3DX01",
                       "https%3A//example.com%3F/path%26project%3DX02" )
               )

  unlink(main_folder, recursive = TRUE, force = TRUE)
})

test_that("pptx - url encoding", {

  main_folder <- "pptx_folder"

  doc <- get_xml_ppt( tab = ft, main_folder = main_folder )
  rid <- xml_attr(xml_find_all(doc, "//a:hlinkClick"), "id")
  rels <- read_xml(file.path(main_folder, "ppt/slides/_rels/slide1.xml.rels"))
  urls <- sapply(rid, function(id, x){
    z <- xml_find_first(x, sprintf("//*[@Id='%s']", id))
    xml_attr(z, "Target")
  }, rels)

  expect_equivalent(urls, c("https%3A//example.com%3F/path%26project%3DX01",
                       "https%3A//example.com%3F/path%26project%3DX02" )
  )


  unlink(main_folder, recursive = TRUE, force = TRUE)
})

test_that("html - url encoding", {

  str_ <- flextable:::html_str(ft)
  str_ <- gsub("<style>(.*)</style>", "", str_)
  str_ <- gsub("<script>(.*)</script>", "", str_)
  str_ <- gsub("<template id=\"[0-9a-z\\-]+\">", "", str_)
  str_ <- gsub("</div></template(.*)", "", str_)
  doc <- read_html(str_)
  urls <- xml_attr(xml_find_all(doc, "//a"), "href")
  expect_equivalent(urls, sprintf(url_base, data$code) )
})
