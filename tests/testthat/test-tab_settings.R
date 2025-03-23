test_that("tab_settings works", {
  z <- data.frame(
    Statistic = c("Median (Q1 ; Q3)", "Min ; Max"),
    Value = c(
      "\t999.99\t(99.9 ; 99.9)",
      "\t9.99\t(9999.9 ; 99.9)"
    )
  )

  ts <- fp_tabs(
    fp_tab(pos = 0.4, style = "decimal"),
    fp_tab(pos = 1.4, style = "decimal")
  )

  ft <- flextable(z) |>
    tab_settings(i = 1, j = 2, value = ts) |>
    width(width = c(1.5, 2))


  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = ft)
  doc <- print(doc, target = docx_file)

  main_folder <- file.path(getwd(), "docx_folder")
  unpack_folder(file = docx_file, folder = main_folder)

  doc_file <- file.path(main_folder, "/word/document.xml")
  doc <- read_xml(doc_file)

  tabnode <- xml_find_first(doc, "w:body/w:tbl/w:tr[3]/w:tc[2]/w:p/w:pPr/w:tabs")
  expect_true(inherits(tabnode, "xml_missing"))

  tabnode <- xml_find_first(doc, "w:body/w:tbl/w:tr[2]/w:tc[2]/w:p/w:pPr/w:tabs")

  expect_false(inherits(tabnode, "xml_missing"))
  tab1 <- xml_child(tabnode, "w:tab[1]")
  tab2 <- xml_child(tabnode, "w:tab[2]")

  expect_equal(
    xml_attr(tab1, "val"),
    "decimal"
  )
  expect_equal(
    xml_attr(tab1, "pos"),
    "576"
  )
  expect_equal(
    xml_attr(tab2, "val"),
    "decimal"
  )
  expect_equal(
    xml_attr(tab2, "pos"),
    "2016"
  )

  unlink(main_folder, recursive = TRUE, force = TRUE)
})
