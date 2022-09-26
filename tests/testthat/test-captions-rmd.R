context("check captions")

library(rmarkdown)
library(xml2)
library(officer)
init_flextable_defaults()

rmd_file_0 <- "rmd/captions.Rmd"
if (!file.exists(rmd_file_0)) {#just for dev purpose
  rmd_file_0 <- "tests/testthat/rmd/captions.Rmd"
}
rmd_file <- tempfile(fileext = ".Rmd")
file.copy(rmd_file_0, rmd_file, overwrite = TRUE)

html_file <- gsub("\\.Rmd$", ".html", rmd_file)
docx_file <- gsub("\\.Rmd$", ".docx", rmd_file)
pdf_file <- gsub("\\.Rmd$", ".pdf", rmd_file)

source("zzzzz.R")

testthat::test_that("with html_document", {
  skip_if_not(rmarkdown::pandoc_available())
  skip_if_not(pandoc_version() >= numeric_version("2"))
  unlink(html_file, force = TRUE)
  render(rmd_file,
         output_format = rmarkdown::html_document(),
         output_file = html_file,
         envir = new.env(),
         quiet = TRUE)

  xml_doc <- get_html_xml(html_file)

  # id is there, caption is the one of set_caption, no numbering
  caption_id2 <- xml_find_first(xml_doc, "//table/caption[@id='id2']")
  expect_true(grepl("text-align:center;", xml_attr(caption_id2, "style")))
  expect_equal(xml_text(caption_id2), "azerty querty")

  # first_chunk has an defined class
  first_chunk_class <- xml_attr(xml_child(caption_id2, 1), "class")
  expect_true(grepl("^cl\\-", first_chunk_class))
  expect_true(any(grepl(first_chunk_class, xml_text(xml_find_all(xml_doc, "//style")))))

  crossref_chunk <- xml_find_first(xml_doc, "//a[@href='#tab:id1']")
  expect_true(inherits(crossref_chunk, "xml_missing"))

  body <- xml_find_first(xml_doc, "//*[id='tab:id1']")
  id_chunk <- xml_find_first(xml_doc, "//table/caption/p/span[@id='tab:id1']")
  expect_true(inherits(id_chunk, "xml_missing"))

  captions <- xml_find_all(xml_doc, "//table/caption/p")
  expect_true(all(!grepl("Table [0-9]+:" , xml_text(captions))))
})

testthat::test_that("with html_document2", {
  skip_if_not(rmarkdown::pandoc_available())
  skip_if_not(pandoc_version() >= numeric_version("2"))
  testthat::skip_if_not_installed("bookdown")

  unlink(html_file, force = TRUE)
  render(rmd_file,
         output_format = bookdown::html_document2(keep_md = FALSE),
         output_file = html_file,
         envir = new.env(),
         quiet = TRUE)

  xml_doc <- get_html_xml(html_file)

  # id is there, caption is the one of set_caption, numbering
  caption_id2 <- xml_find_first(xml_doc, "//table/caption/span[@id='tab:id2']")
  expect_true(grepl("text-align:center;", xml_attr(xml_parent(caption_id2), "style")))
  expect_true(grepl("Table [0-9]+\\: azerty querty", xml_text(xml_parent(caption_id2))))

  # first_chunk has an defined class
  first_chunk_class <- xml_attr(xml_siblings(caption_id2), "class")
  expect_true(all(grepl("^cl\\-", first_chunk_class)))

  crossref_chunk <- xml_find_first(xml_doc, "//a[@href='#tab:id1']")
  expect_false(inherits(crossref_chunk, "xml_missing"))

  id_chunk <- xml_find_first(xml_doc, "//caption/span[@id='tab:id1']")
  expect_false(inherits(id_chunk, "xml_missing"))

  caption <- xml_find_first(xml_doc, "//caption[span/@id='tab:id1']")
  expect_true(grepl("Table 2:" , xml_text(caption)))
})

testthat::test_that("with word_document", {
  skip_if_not(rmarkdown::pandoc_available())
  skip_if_not(pandoc_version() >= numeric_version("2"))
  skip_if(pandoc_version() == numeric_version("2.9.2.1"))

  unlink(docx_file, force = TRUE)
  render(rmd_file,
         output_format = rmarkdown::word_document(keep_md = FALSE),
         output_file = docx_file,
         envir = new.env(),
         quiet = TRUE)

  doc <- get_docx_xml(docx_file)

  caption_node <- xml_find_first(doc,
                                 xpath = "/w:document/w:body/w:tbl[4]/preceding-sibling::*[1]")
  expect_false(grepl("Table [1-5]+", xml_text(caption_node), fixed = TRUE))

  style_nodes <- xml_find_all(doc, "//w:pStyle[@w:val='TableCaption']")
  expect_length(style_nodes, 4)
  expect_true(all(xml_attr(style_nodes, "val") %in% "TableCaption"))
  txt_nodes <- xml_parent(xml_parent(style_nodes))
  expect_true(
    all(!grepl("^Table [1-5]+\\:", xml_text(txt_nodes)))
  )

  bookmarks <- xml_find_all(doc, "//w:tbl/preceding-sibling::w:p[1]/w:bookmarkStart")
  expect_length(bookmarks, 0)
})

testthat::test_that("with word_document2", {
  skip_if_not(rmarkdown::pandoc_available(version = ))
  skip_if_not(pandoc_version() > numeric_version("2.7.3"))
  testthat::skip_if_not_installed("bookdown")
  skip_if(pandoc_version() == numeric_version("2.9.2.1"))

  unlink(docx_file, force = TRUE)
  render(rmd_file,
         output_format = bookdown::word_document2(keep_md = FALSE),
         output_file = docx_file,
         envir = new.env(),
         quiet = TRUE)

  doc <- get_docx_xml(docx_file)

  caption_node <- xml_find_first(doc,
                                 xpath = "/w:document/w:body/w:tbl[2]/preceding-sibling::*[1]")
  expect_true(grepl("Table 2", xml_text(caption_node), fixed = TRUE))

  crossref_node <- xml_find_first(doc, "/w:document/w:body/w:p[2]")
  expect_equal("Cross-reference is there: 2", xml_text(crossref_node))

  style_nodes <- xml_find_all(doc, "//w:pStyle[@w:val='TableCaption']")
  expect_length(style_nodes, 4)
  expect_true(all(xml_attr(style_nodes, "val") %in% "TableCaption"))
  txt_nodes <- xml_parent(xml_parent(style_nodes))
  expect_true(
    all(
      grepl("^Table [1-4]+\\:", xml_text(txt_nodes))
    )
  )

  bookmarks <- xml_find_all(doc, "//w:tbl/preceding-sibling::w:p[1]/w:bookmarkStart")
  expect_length(bookmarks, 0)
})



testthat::test_that("word with officer", {

  unlink(docx_file, force = TRUE)
  ft <- flextable(head(cars))
  ft <- theme_vanilla(ft)
  ft <- autofit(ft)
  ft <- set_caption(
    x = ft,
    caption = as_paragraph(
      as_chunk("azerty ", props = fp_text_default(color = "cyan")),
      as_chunk("querty", props = fp_text_default(color = "orange"))
    ),
    autonum = run_autonum(seq_id = "tab", bkm = "id2"),
    fp_p = fp_par(
      padding = 10,
      border = fp_border_default(color = "red", width = 1))
  )
  doc <- get_docx_xml(ft)

  caption_node <- xml_find_first(doc,
                                 xpath = "/w:document/w:body/w:tbl/preceding-sibling::*[1]")
  expect_false(grepl("Table [1-5]+", xml_text(caption_node), fixed = TRUE))

  style_nodes <- xml_find_all(doc, "//w:pStyle[@w:val='TableCaption']")
  expect_length(style_nodes, 1)
  expect_true(all(xml_attr(style_nodes, "val") %in% "TableCaption"))
  bookmarks <- xml_find_all(doc, "//w:tbl/preceding-sibling::w:p[1]/w:bookmarkStart")
  expect_length(bookmarks, 1)
  expect_equal(xml_attr(bookmarks, "name"), "id2")
})


test_that("with pdf_document2", {
  skip_on_cran()
  skip_if_not(rmarkdown::pandoc_available())
  skip_if_not(pandoc_version() > numeric_version("2.7.3"))
  skip_if_not_installed("bookdown")
  skip_if_not_installed("pdftools")

  require("pdftools")
  sucess <- render_rmd(file = pdf_file, rmd_format = bookdown::pdf_document2(keep_md = FALSE))
  if (sucess) {
    doc <- get_pdf_text(pdf_file, extract_fun = pdftools::pdf_text)
    expect_true(any(grepl("Cross-reference is there: 2", doc, fixed = TRUE)))
  } else {
    testthat::expect_false(sucess)# only necessary to avoid a note
  }
})

test_that("Adds label for cross referencing with bookdown", {
  expect_identical(flextable:::ref_label(), "")
  knitr::opts_current$set(label = 'foo')
  expect_identical(flextable:::ref_label(), "(\\#tab:foo)")
})

init_flextable_defaults()
