test_that("shortcut functions", {
  ft <- flextable(head(mtcars, n = 2))

  ft <- bg(x = ft, bg = "red", j = 1, part = "all")
  ft <- bold(x = ft, bold = TRUE, j = 2, part = "all")
  ft <- fontsize(x = ft, size = 9, j = 3, part = "all")
  ft <- italic(x = ft, italic = TRUE, j = 4, part = "all")
  ft <- color(x = ft, color = "gray", j = 5, part = "all")
  ft <- padding(x = ft, padding = 5, j = 6, part = "all")
  ft <- align(x = ft, align = "left", j = 7, part = "all")
  ft <- border(x = ft, border = fp_border(color = "orange"), j = 8, part = "all")

  docx_file <- tempfile(fileext = ".docx")

  doc <- read_docx()
  doc <- body_add_flextable(doc, value = ft)
  doc <- print(doc, target = docx_file)

  main_folder <- file.path(getwd(), "docx_folder")
  unpack_folder(file = docx_file, folder = main_folder)

  doc_file <- file.path(main_folder, "/word/document.xml")
  doc <- read_xml(doc_file)

  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[1]/w:tcPr/w:shd")
  expect_equal(xml_attr(nodes, "fill"), c("FF0000", "FF0000", "FF0000"))

  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[2]/w:p/w:r/w:rPr/w:b")
  expect_length(nodes, 3)

  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[3]/w:p/w:r/w:rPr/w:sz")
  expect_equal(xml_attr(nodes, "val"), c("18", "18", "18"))

  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[4]/w:p/w:r/w:rPr/w:i")
  expect_length(nodes, 3)

  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[5]/w:p/w:r/w:rPr/w:color")
  expect_equal(xml_attr(nodes, "val"), c("BEBEBE", "BEBEBE", "BEBEBE"))

  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[6]/w:p/w:pPr/w:spacing")
  expect_equal(xml_attr(nodes, "after"), rep("100", 3))
  expect_equal(xml_attr(nodes, "before"), rep("100", 3))
  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[6]/w:p/w:pPr/w:ind")
  expect_equal(xml_attr(nodes, "left"), rep("100", 3))
  expect_equal(xml_attr(nodes, "right"), rep("100", 3))

  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[7]/w:p/w:pPr/w:jc")
  expect_equal(xml_attr(nodes, "val"), rep("left", 3))

  nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc[8]/w:tcPr/w:tcBorders/*")
  expect_true(all(xml_attr(nodes, "color") == "FFA500"))

  unlink(main_folder, recursive = TRUE, force = TRUE)
})

tab <- data.frame(x = c("Row1", "Row2"), y = c(1, 2))

ft <- flextable(tab)
ft <- border_remove(ft)
ft <- hline(ft, i = 1:2, j = 2, part = "body")
ft <- delete_part(ft, part = "header")

test_that("borders with office docs are sanitized", {
  docx_file <- tempfile(fileext = ".docx")
  pptx_file <- tempfile(fileext = ".pptx")
  save_as_docx(ft, path = docx_file)
  save_as_pptx(ft, path = pptx_file)

  docx <- read_docx(docx_file)
  doc <- docx_body_xml(docx)

  top_nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc/w:tcPr/w:tcBorders/w:top")
  bot_nodes <- xml_find_all(doc, "w:body/w:tbl/w:tr/w:tc/w:tcPr/w:tcBorders/w:bottom")
  expect_equal(xml_attr(top_nodes, "color"), c("000000", "000000", "000000", "666666"))
  expect_equal(xml_attr(bot_nodes, "color"), c("000000", "666666", "000000", "666666"))

  pptx <- read_pptx(pptx_file)
  slide <- pptx$slide$get_slide(1)$get()

  top_nodes <- xml_find_all(slide, "//a:tbl/a:tr/a:tc/a:tcPr/a:lnT")
  bot_nodes <- xml_find_all(slide, "//a:tbl/a:tr/a:tc/a:tcPr/a:lnB")
  expect_equal(xml_attr(top_nodes, "w"), c("0", "0", "0", "12700"))
  expect_equal(xml_attr(bot_nodes, "w"), c("0", "12700", "0", "12700"))
})

test_that("align() accepts default align argument when columns is not a multiple of 4", {
  ft <- flextable(head(mtcars, n = 2)[, 1:6])
  ft1 <- align(ft, part = "all")
  expect_equal(
    rep("left", 18),
    information_data_paragraph(ft1)$text.align
  )
})

test_that("align() accepts combinations of align arguments.", {
  ft <- flextable(head(mtcars, n = 2)[, 1:6])

  # All columns right-aligned
  ft2 <- align(ft, align = "right", part = "all")
  expect_equal(
    rep("right", 18),
    information_data_paragraph(ft2)$text.align
  )

  # Custom alignment for each column
  custom_alignment <- c("left", "right", "left", "center", "center", "right")
  ft3 <- align(ft, align = custom_alignment, part = "all")
  expect_equal(
    rep(custom_alignment, 3),
    information_data_paragraph(ft3)$text.align
  )

  # Custom alignment for only columns 3 and 5 in body only
  custom_alignment <- c("center", "left")
  ft4 <- align(ft, j = c("disp", "drat"), align = custom_alignment, part = "body")
  subdat <- information_data_paragraph(ft4)
  subdat <- subdat[subdat$.col_id %in% c("disp", "drat"),]
  subdat <- subdat[subdat$.part %in% c("body"),]
  expect_equal(
    rep(custom_alignment, 2),
    subdat$text.align
  )

  # Custom alignment for only columns 3 and 5 in body only (using default body arg)
  ft4b <- align(ft, j = c("disp", "drat"), align = custom_alignment)
  subdat <- information_data_paragraph(ft4b)
  subdat <- subdat[subdat$.col_id %in% c("disp", "drat"),]
  subdat <- subdat[subdat$.part %in% c("body"),]
  expect_equal(
    rep(custom_alignment, 2),
    subdat$text.align
  )

  # Center alignment for only columns 3 and 5
  ft5 <- align(ft, j = c("disp", "drat"), align = "center", part = "all")
  subdat <- information_data_paragraph(ft5)
  subdat <- subdat[subdat$.col_id %in% c("disp", "drat"),]
  expect_equal(
    rep("center", 6),
    subdat$text.align
  )

  # Alternate left and center alignment across columns 1-4 for header only
  ft6 <- align(ft, j = 1:4, align = c("left", "center"), part = "header")
  subdat <- information_data_paragraph(ft6)
  subdat <- subdat[subdat$.part %in% c("header"),]
  expect_equal(
    c(rep(c("left", "center"), 2), "right", "right"),
    subdat$text.align
  )
})

test_that("align() will error if invalid align and part arguments are supplied", {
  ft <- flextable(head(mtcars, n = 2)[, 1:6])

  # Invalid "part" argument
  expect_error(align(ft, align = c("left", "center", "right"), part = "everything"))

  # Invalid "align" argument
  expect_error(align(ft, align = "top"))

  # Invalid "align" argument mixed in with valid arguments throws warning
  expect_error(align(ft, align = c("top", "left")), "Invalid `align` argument")
})
