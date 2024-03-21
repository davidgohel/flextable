context("df_printer and utilities")

test_that("use_model_printer and use_df_printer works", {
  rmd_file <- tempfile(fileext = ".Rmd")
  file.copy("rmd/use-printer.Rmd", rmd_file)
  outfile <- tempfile(fileext = ".html")
  rmarkdown::render(rmd_file,
         output_file = outfile, output_format = "html_document",
         envir = new.env(), quiet = TRUE
  )

  doc <- read_html(outfile)
  table_nodes <- xml_find_all(doc, "body//*/table")
  testthat::expect_length(table_nodes, n = 3)

  # check last table that should be a summary table
  table_node_3 <- table_nodes[[3]]
  expect_length(xml_children(xml_child(table_node_3, search = "/thead")), 2)
  expect_length(xml_children(xml_child(table_node_3, search = "/tbody")), 10)

  tfoot_content <- xml_child(table_node_3, search = "/tfoot")
  expect_length(xml_children(tfoot_content), 1)
  expect_equal(xml_text(tfoot_content), "n: 153")

  # check first table and last column should have stars
  first_tr <- xml_find_first(doc, "//table/tbody/tr")
  expect_length(xml_children(first_tr), 6)
  expect_equal(xml_text(xml_child(first_tr, 6)), "***")

  # check second table has 5 columns
  first_tr <- xml_find_first(doc, "//*[@id='no-stars']//table/tbody/tr")
  expect_length(xml_children(first_tr), 5)
})
