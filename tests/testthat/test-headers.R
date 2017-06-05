context("check headers")

library(xml2)
library(officer)

test_that("set headers", {
  col_keys <- c("Species",
                "sep1", "Sepal.Length", "Sepal.Width",
                "sep2", "Petal.Length", "Petal.Width" )
  ft <- flextable( head( iris ), col_keys = col_keys)
  ft <- set_header_labels(ft, Sepal.Length = "Sepal length",
                            Sepal.Width = "Sepal width", Petal.Length = "Petal length",
                            Petal.Width = "Petal width" )

  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = ft)
  doc <- print(doc, target = docx_file)

  main_folder <- file.path(getwd(), "docx_folder" )
  unpack_folder(file = docx_file, folder = main_folder)

  doc_file <- file.path(main_folder, "/word/document.xml" )
  doc <- read_xml( doc_file )

  colnodes <- xml_find_all(doc, "w:body/w:tbl/w:tr[w:trPr/w:tblHeader]/w:tc")

  expect_equal(xml_text(colnodes),
               c("Species", "", "Sepal length", "Sepal width", "", "Petal length", "Petal width") )

  unlink(main_folder, recursive = TRUE, force = TRUE)
})
