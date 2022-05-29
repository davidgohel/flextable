context("check rotations")

library(officer)
library(xml2)


dat <- data.frame(
  a = c("left-top", "left-middle", "left-bottom"),
  b = c("center-top", "center-middle", "center-bottom"),
  c = c("right-top", "right-middle", "right-bottom"))

ft_1 <- flextable(dat)
ft_1 <- theme_box(ft_1)
ft_1 <- height_all(x=ft_1, height = 1.3)
ft_1 <- hrule(ft_1, rule = "exact")
ft_1 <- rotate(ft_1, rotation = "tbrl")
ft_1 <- delete_part(ft_1)

ft_1 <- align(ft_1, j = 1, align = "left")
ft_1 <- align(ft_1, j = 2, align = "center")
ft_1 <- align(ft_1, j = 3, align = "right")

ft_1 <- valign(ft_1, i = 1, valign = "top")
ft_1 <- valign(ft_1, i = 2, valign = "center")
ft_1 <- valign(ft_1, i = 3, valign = "bottom")


test_that("docx rotations", {

  tmp_docx <- tempfile(fileext = ".docx")
  save_as_docx(ft_1, path = tmp_docx)

  doc <- read_docx(tmp_docx)

  docx <- docx_body_xml(doc)
  valign_val <- xml_find_all(docx, "w:body/w:tbl/w:tr/w:tc/w:tcPr/w:vAlign")
  valign_val <- xml_attr(valign_val, "val")

  text_direction_val <- xml_find_all(docx, "w:body/w:tbl/w:tr/w:tc/w:tcPr/w:textDirection")
  text_direction_val <- xml_attr(text_direction_val, "val")

  align_val <- xml_find_all(docx, "w:body/w:tbl/w:tr/w:tc/w:p/w:pPr/w:jc")
  align_val <- xml_attr(align_val, "val")

  align <- c("left", "center", "right")
  valign <- c("bottom", "center", "top")

  expect_equal(valign_val, rep(valign, 3))
  expect_equal(text_direction_val, rep("tbRl", 9))
  expect_equal(align_val, rep(align, each = 3))
})

test_that("pptx rotations", {
  tmp_pptx <- tempfile(fileext = ".pptx")
  save_as_pptx(ft_1, path = tmp_pptx)

  x <- read_pptx(tmp_pptx)
  slide <- x$slide$get_slide(x$cursor)

  doc <- slide$get()

  cell_prs <- xml_find_all(doc, "//a:tbl/a:tr/a:tc/a:tcPr")
  par_prs <- xml_find_all(doc, "//a:tbl/a:tr/a:tc/a:txBody/a:p/a:pPr")

  text_direction_val <- xml_attr(cell_prs, "vert")
  valign_val <- xml_attr(cell_prs, "anchor")
  align_val <- xml_attr(par_prs, "algn")

  align <- c("l", "ctr", "r")
  valign <- c("b", "ctr", "t")

  expect_equal(valign_val, rep(valign, 3))
  expect_equal(text_direction_val, rep("vert", 9))
  expect_equal(align_val, rep(align, each = 3))
})

