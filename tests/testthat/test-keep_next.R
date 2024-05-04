init_flextable_defaults()

iris_sum <- summarizor(iris, by = "Species")
ft_1 <- as_flextable(iris_sum, sep_w = 0)
ft_1 <- set_caption(ft_1, "a caption")

test_that("docx-keep-with-next", {

  tmp_file <- tempfile(fileext = ".docx")
  docx <- read_docx()
  docx <- body_add_flextable(docx, ft_1)
  for(i in 1:10) {
    docx <- body_add_par(docx, value = "")
  }
  ft_1 <- paginate(ft_1, init = TRUE, hdr_ftr = TRUE)
  docx <- body_add_flextable(docx, ft_1)
  print(docx, target = tmp_file)

  doc <- read_docx(path = tmp_file)
  body_xml <- docx_body_xml(doc)

  expect_length(
    xml_find_all(body_xml, "//w:tbl[1]/w:tr/w:tc/w:p/w:pPr/w:keepNext"),
    n = 0
  )

  expect_length(
    xml_find_all(body_xml, "//w:tbl[2]/w:tr/w:tc/w:p/w:pPr/w:keepNext"),
    n = 65
  )

})

init_flextable_defaults()
