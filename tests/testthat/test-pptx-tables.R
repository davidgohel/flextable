context("ppt table structure")

library(utils)
library(xml2)
library(officer)

test_that("row height is valid", {
  ft <- flextable( head( iris) )
  pptx_file <- "test.pptx"
  doc <- read_pptx()
  doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
  doc <- ph_with(doc, value = ft, location = ph_location_type(type = "body"))
  doc <- print(doc, target = pptx_file)

  main_folder <- file.path(getwd(), "pptx_folder" )
  unzip(pptx_file, exdir = main_folder)

  slide_file <- file.path(main_folder, "/ppt/slides/slide1.xml" )
  doc <- read_xml( slide_file )

  nodes <- xml_find_all(doc, "//p:graphicFrame/a:graphic/a:graphicData/a:tbl/a:tr")
  h_values <- sapply( nodes, xml_attr, attr="h")
  h_values <- as.integer(h_values)
  expect_true( all( is.finite( h_values ) ) )
  expect_true( all( h_values > 0 ) )

  unlink(main_folder, recursive = TRUE, force = TRUE)
  unlink(pptx_file, force = TRUE)
})


test_that("location is correct", {
  ft <- flextable( head( iris) )
  pptx_file <- tempfile(fileext = ".pptx")
  doc <- read_pptx()
  doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
  doc <- ph_with(doc, value = ft, location = ph_location(left = 0, top = 0))
  doc <- print(doc, target = pptx_file)

  main_folder <- file.path(getwd(), "pptx_folder" )
  unpack_folder(file = pptx_file, folder = main_folder)

  slide_file <- file.path(main_folder, "/ppt/slides/slide1.xml" )
  doc <- read_xml( slide_file )

  node <- xml_find_first(doc, "//p:graphicFrame/p:xfrm/a:off")
  expect_equal( xml_attr(node, "x"), "0" )
  expect_equal( xml_attr(node, "y"), "0" )

  unlink(main_folder, recursive = TRUE, force = TRUE)
})

