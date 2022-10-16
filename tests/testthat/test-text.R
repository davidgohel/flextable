context("check cells text")

library(xml2)
library(officer)

ft1 <- flextable(data.frame(a="1 < 3", stringsAsFactors = FALSE))

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

test_that("docx - string are html encoded", {
  main_folder <- "docx_folder"

  doc <- get_xml_doc( tab = ft1, main_folder = main_folder )
  text_ <- xml_text(xml_find_first(doc, "w:body/w:tbl[1]/w:tr[2]/w:tc/w:p/w:r/w:t"))
  expect_equal(text_, c("1 < 3") )

  unlink(main_folder, recursive = TRUE, force = TRUE)
})

test_that("pptx - string are html encoded", {

  main_folder <- "pptx_folder"

  doc <- get_xml_ppt( tab = ft1, main_folder = main_folder )
  text_ <- xml_text(xml_find_first(doc, "//a:tbl/a:tr[2]/a:tc/a:txBody/a:p/a:r/a:t"))
  expect_equal(text_, c("1 < 3") )


  unlink(main_folder, recursive = TRUE, force = TRUE)
})

test_that("html - string are html encoded", {

  str_ <- flextable:::gen_raw_html(ft1)
  str_ <- gsub("<style>(.*)</style>", "", str_)
  str_ <- gsub("<script>(.*)</script>", "", str_)
  str_ <- gsub("<template id=\"[0-9a-z\\-]+\">", "", str_)
  str_ <- gsub("</div></template(.*)", "", str_)
  doc <- read_xml(str_)
  text_ <- xml_text(xml_find_first(doc, "//tbody/tr/td/p/span"))
  expect_equal(text_, c("1 < 3") )
})
test_that("utf8 is preserved", {
  ft <- flextable(data.frame(a = c('\U2265 4.7')))
  str_ <- flextable:::gen_raw_html(ft)
  str_ <- gsub("<style>(.*)</style>", "", str_)
  str_ <- gsub("<script>(.*)</script>", "", str_)
  str_ <- gsub("<template id=\"[0-9a-z\\-]+\">", "", str_)
  str_ <- gsub("</div></template(.*)", "", str_)
  doc <- read_xml(str_)
  text_ <- xml_text(xml_find_first(doc, "//tbody/tr/td/p/span"))
  expect_equal(text_, c("\U2265 4.7") )
})

test_that("NA managment", {

  x <- data.frame(zz = c("a", NA_character_), stringsAsFactors = FALSE)
  ft1 <- flextable(x)

  str_ <- flextable:::gen_raw_html(ft1)
  str_ <- gsub("<style>(.*)</style>", "", str_)
  str_ <- gsub("<script>(.*)</script>", "", str_)
  str_ <- gsub("<template id=\"[0-9a-z\\-]+\">", "", str_)
  str_ <- gsub("</template(.*)", "", str_)
  doc <- read_xml(str_)
  text_ <- xml_text(xml_find_all(doc, "//table/tbody/tr/td/p"))
  expect_equal(text_, c("a", "") )
})

test_that("newlines and tabulations expand correctly", {
  z <- flextable(data.frame(a = c("")))
  z <- compose(
    x = z, i = 1, j = 1,
    value = as_paragraph(
      "this\nis\nit",
      "\n\t", "This", "\n",
      "is", "\n", "it", "\n",
      "this\tis\tit\nthatsit\n"
    )
  )
  z <- delete_part(z, part = "header")

  chunks_txt <- flextable:::fortify_run(z)$txt

  expect_equal(
    chunks_txt,
    c("this", "<br>", "is", "<br>", "it",
      "<br>", "<tab>", "This", "<br>",
      "is", "<br>", "it", "<br>", "this",
      "<tab>", "is", "<tab>", "it", "<br>",
      "thatsit", "<br>")
  )
})

test_that("word superscript and subscript", {
  ft <- flextable( data.frame(a = ""), col_keys = c("dummy") )
  ft <- delete_part(ft, part = "header")


  ft <- compose(ft, i = 1, j = "dummy", part = "body",
              value = as_paragraph(
                as_sub("Sepal.Length")
              ) )
  runs <- flextable:::fortify_run(ft)
  expect_equal(runs$vertical.align[1], "subscript")
  openxml <- flextable:::runs_as_wml(ft, txt_data = runs)$run_openxml
  expect_match(openxml, "<w:vertAlign w:val=\"subscript\"/>", fixed = TRUE)

  ft <- compose(ft, i = 1, j = "dummy", part = "body",
              value = as_paragraph(
                as_sup("Sepal.Length")
              ) )
  runs <- flextable:::fortify_run(ft)
  expect_equal(runs$vertical.align[1], "superscript")
  openxml <- flextable:::runs_as_wml(ft, txt_data = runs)$run_openxml
  expect_match(openxml, "<w:vertAlign w:val=\"superscript\"/>", fixed = TRUE)
})
