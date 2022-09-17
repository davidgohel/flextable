context("check hyperlink")

library(xml2)
library(officer)

data <- data.frame(
  code = c("X01", "X02"),
  name = c("X Number 1", "X Number 2"),
  stringsAsFactors = FALSE
)
url_base <- "https://example.com?/path&project=%s"
ft <- flextable(data)
ft <- mk_par(
  x = ft,
  j = ~code,
  value = as_paragraph(
    hyperlink_text(code, url = sprintf(url_base, code))
  )
)


test_that("URL are preserved in docx", {
  outfile <- tempfile(fileext = ".docx")
  save_as_docx(ft, path = outfile)
  doc <- read_docx(path = outfile)
  body <- docx_body_xml(doc)
  rid <- xml_attr(xml_find_all(body, "//w:hyperlink"), "id")
  rels <- doc$doc_obj$rel_df()
  urls <- rels[rels$id %in% rid, "target"]
  expect_equivalent(urls, sprintf(url_base, data$code))
})

test_that("URL are preserved in pptx", {
  outfile <- tempfile(fileext = ".pptx")
  save_as_pptx(ft, path = outfile)
  doc <- read_pptx(path = outfile)
  xml_slide <- doc$slide$get_slide(1)$get()
  rid <- xml_attr(xml_find_all(xml_slide, "//a:hlinkClick"), "id")
  rels <- doc$slide$get_slide(1)$rel_df()
  urls <- rels[rels$id %in% rid, "target"]
  expect_equivalent(urls, sprintf(url_base, data$code))
})

test_that("URL are preserved in html", {
  str_ <- flextable:::gen_raw_html(ft)
  str_ <- gsub("<style>(.*)</style>", "", str_)
  str_ <- gsub("<script>(.*)</script>", "", str_)
  str_ <- gsub("<template id=\"[0-9a-z\\-]+\">", "", str_)
  str_ <- gsub("</div></template(.*)", "", str_)
  doc <- read_html(str_)
  urls <- xml_attr(xml_find_all(doc, "//a"), "href")
  expect_equivalent(urls, sprintf(url_base, data$code))
})
