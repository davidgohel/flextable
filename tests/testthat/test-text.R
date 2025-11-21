ft1 <- flextable(data.frame(a = "1 < 3", stringsAsFactors = FALSE))

get_xml_doc <- function(tab, main_folder = "docx_folder") {
  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = tab)
  print(doc, target = docx_file)

  main_folder <- file.path(getwd(), main_folder)
  unlink(main_folder, recursive = TRUE, force = TRUE)

  unpack_folder(file = docx_file, folder = main_folder)
  doc_file <- file.path(main_folder, "/word/document.xml")
  read_xml(doc_file)
}

get_xml_ppt <- function(tab, main_folder = "pptx_folder") {
  pptx_file <- tempfile(fileext = ".pptx")
  doc <- read_pptx()
  doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
  doc <- ph_with(doc, tab, location = ph_location_type(type = "body"))
  print(doc, target = pptx_file)

  main_folder <- file.path(getwd(), main_folder)
  unlink(main_folder, recursive = TRUE, force = TRUE)
  unpack_folder(file = pptx_file, folder = main_folder)
  doc_file <- file.path(main_folder, "/ppt/slides/slide1.xml")
  read_xml(doc_file)
}

test_that("docx - string are html encoded", {
  main_folder <- "docx_folder"

  doc <- get_xml_doc(tab = ft1, main_folder = main_folder)
  text_ <- xml_text(xml_find_first(doc, "w:body/w:tbl[1]/w:tr[2]/w:tc/w:p/w:r/w:t"))
  expect_equal(text_, c("1 < 3"))

  unlink(main_folder, recursive = TRUE, force = TRUE)
})

test_that("pptx - string are html encoded", {
  main_folder <- "pptx_folder"

  doc <- get_xml_ppt(tab = ft1, main_folder = main_folder)
  text_ <- xml_text(xml_find_first(doc, "//a:tbl/a:tr[2]/a:tc/a:txBody/a:p/a:r/a:t"))
  expect_equal(text_, c("1 < 3"))


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
  expect_equal(text_, c("1 < 3"))
})
test_that("utf8 is preserved", {
  ft <- flextable(data.frame(a = c("\U2265 4.7")))
  str_ <- flextable:::gen_raw_html(ft)
  str_ <- gsub("<style>(.*)</style>", "", str_)
  str_ <- gsub("<script>(.*)</script>", "", str_)
  str_ <- gsub("<template id=\"[0-9a-z\\-]+\">", "", str_)
  str_ <- gsub("</div></template(.*)", "", str_)
  doc <- read_xml(str_)
  text_ <- xml_text(xml_find_first(doc, "//tbody/tr/td/p/span"))
  expect_equal(text_, c("\U2265 4.7"))
})

test_that("NA managment", {
  x <- data.frame(zz = c("a", NA_character_), stringsAsFactors = FALSE)
  ft1 <- flextable(x)

  str_ <- flextable:::gen_raw_html(ft1)
  str_ <- paste0("<div>", str_, "</div>")
  doc <- read_xml(str_)
  text_ <- xml_text(xml_find_all(doc, "//table/tbody/tr/td/p"))
  expect_equal(text_, c("a", ""))
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

  chunks_txt <- information_data_chunk(z)$txt

  expect_equal(
    chunks_txt,
    c(
      "this", "<br>", "is", "<br>", "it",
      "<br>", "<tab>", "This", "<br>",
      "is", "<br>", "it", "<br>", "this",
      "<tab>", "is", "<tab>", "it", "<br>",
      "thatsit", "<br>"
    )
  )
})

test_that("word superscript and subscript", {
  ft <- flextable(data.frame(a = ""), col_keys = c("dummy"))
  ft <- delete_part(ft, part = "header")


  ft <- compose(ft,
    i = 1, j = "dummy", part = "body",
    value = as_paragraph(
      as_sub("Sepal.Length")
    )
  )
  runs <- information_data_chunk(ft)
  expect_equal(runs$vertical.align[1], "subscript")
  openxml <- flextable:::runs_as_wml(ft, txt_data = runs)$run_openxml
  expect_match(openxml, "<w:vertAlign w:val=\"subscript\"/>", fixed = TRUE)

  ft <- compose(ft,
    i = 1, j = "dummy", part = "body",
    value = as_paragraph(
      as_sup("Sepal.Length")
    )
  )
  runs <- information_data_chunk(ft)
  expect_equal(runs$vertical.align[1], "superscript")
  openxml <- flextable:::runs_as_wml(ft, txt_data = runs)$run_openxml
  expect_match(openxml, "<w:vertAlign w:val=\"superscript\"/>", fixed = TRUE)
})

test_that("highlight", {
  ft <- flextable(data.frame(test = "test"))
  ft <- add_footer_lines(ft, values = "test")
  ft <- mk_par(ft,
    j = "test", part = "body",
    value = as_paragraph(
      as_highlight(test, color = "yellow")
    )
  )
  ft <- mk_par(ft,
    j = "test", part = "header",
    value = as_paragraph(
      as_highlight(test, color = "red")
    )
  )
  ft <- mk_par(ft,
    j = "test", part = "footer",
    value = as_paragraph(
      as_highlight(test, color = "purple")
    )
  )

  runs <- information_data_chunk(ft)
  expect_equal(runs$shading.color, c("red", "yellow", "purple"))

  openxml <- flextable:::runs_as_wml(ft, txt_data = runs)$run_openxml
  expect_match(openxml[1], "<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"FF0000\"/>", fixed = TRUE)
  expect_match(openxml[2], "<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"FFFF00\"/>", fixed = TRUE)
  expect_match(openxml[3], "<w:shd w:val=\"clear\" w:color=\"auto\" w:fill=\"A020F0\"/>", fixed = TRUE)

  openxml <- flextable:::runs_as_pml(ft)$par_nodes_str
  expect_match(openxml[1], "<a:highlight><a:srgbClr val=\"FF0000\">", fixed = TRUE)
  expect_match(openxml[2], "<a:highlight><a:srgbClr val=\"FFFF00\">", fixed = TRUE)
  expect_match(openxml[3], "<a:highlight><a:srgbClr val=\"A020F0\">", fixed = TRUE)

  html_info <- flextable:::runs_as_html(ft)
  css <- attr(html_info, "css")
  expect_match(css, "background-color:rgba(255, 0, 0, 1.00);}", fixed = TRUE)
  expect_match(css, "background-color:rgba(255, 255, 0, 1.00);}", fixed = TRUE)
  expect_match(css, "background-color:rgba(160, 32, 240, 1.00);}", fixed = TRUE)

  latex_str <- flextable:::runs_as_latex(ft)$txt
  expect_match(latex_str[1], "\\colorbox[HTML]{FF0000}", fixed = TRUE)
  expect_match(latex_str[2], "\\colorbox[HTML]{FFFF00}", fixed = TRUE)
  expect_match(latex_str[3], "\\colorbox[HTML]{A020F0}", fixed = TRUE)

  rtf_str <- flextable:::runs_as_rtf(ft)$txt
  expect_match(rtf_str[1], "%ftshading:red%", fixed = TRUE)
  expect_match(rtf_str[2], "%ftshading:yellow%", fixed = TRUE)
  expect_match(rtf_str[3], "%ftshading:purple%", fixed = TRUE)
})

test_that("as_bracket", {
  ft <- flextable(head(iris), col_keys = c("Species", "what"))
  ft <- mk_par(ft,
    j = "what", part = "body",
    value = as_paragraph(
      as_bracket(Sepal.Length, Sepal.Width, sep = "-")
    )
  )

  runs <- information_data_chunk(ft)
  runs <- runs[runs$.part %in% "body", ]
  expect_equal(
    runs$txt,
    c(
      "setosa", "(5.1-3.5)", "setosa", "(4.9-3)", "setosa",
      "(4.7-3.2)", "setosa", "(4.6-3.1)", "setosa", "(5-3.6)",
      "setosa", "(5.4-3.9)"
    )
  )
})

test_that("as_equation", {
  skip_if_not_installed("equatags")

  eqs <- c(
    "(ax^2 + bx + c = 0)",
    "a \\ne 0",
    "x = {-b \\pm \\sqrt{b^2-4ac} \\over 2a}"
  )
  df <- data.frame(formula = eqs)

  ft <- flextable(df)
  ft <- mk_par(ft,
    j = "formula", part = "body",
    value = as_paragraph(as_equation(formula, width = 2, height = .5))
  )

  runs <- information_data_chunk(ft)
  openxml <- flextable:::runs_as_wml(ft, txt_data = runs)$run_openxml
  expect_match(openxml[2], "</m:oMath>", fixed = TRUE)
  expect_match(openxml[3], "</m:oMath>", fixed = TRUE)
  expect_match(openxml[4], "</m:oMath>", fixed = TRUE)


  openxml <- flextable:::runs_as_pml(ft)$par_nodes_str
  expect_match(openxml[2], "</m:oMath>", fixed = TRUE)
  expect_match(openxml[3], "</m:oMath>", fixed = TRUE)
  expect_match(openxml[4], "</m:oMath>", fixed = TRUE)

  latex_str <- flextable:::runs_as_latex(ft)$txt
  expect_match(latex_str[2], eqs[1], fixed = TRUE)
  expect_match(latex_str[3], eqs[2], fixed = TRUE)
  expect_match(latex_str[4], eqs[3], fixed = TRUE)

  runs <- information_data_chunk(ft)
  html_str <- flextable:::runs_as_html(ft)$span_tag
  expect_match(html_str[2], "<span class=\"katex\">", fixed = TRUE)
  expect_match(html_str[3], "<span class=\"katex\">", fixed = TRUE)
  expect_match(html_str[4], "<span class=\"katex\">", fixed = TRUE)
})

test_that("as_word_field", {

  ft <- flextable(head(cars))
  ft <- add_footer_lines(ft, "temp text")
  ft <- compose(
    x = ft, part = "footer", i = 1, j = 1,
    as_paragraph(
      as_word_field(x = "Page", width = .05)
    )
  )

  runs <- information_data_chunk(ft)
  wml_str <- flextable:::runs_as_wml(ft)
  wml_str <- wml_str[wml_str$.part %in% "footer",]$run_openxml[1]
  expect_match(wml_str, "<w:instrText xml:space=\"preserve\" w:dirty=\"true\">Page</w:instrText>", fixed = TRUE)
})

test_that("strike", {
  ft <- flextable(data.frame(test = "test"))
  ft <- add_footer_lines(ft, values = "test")
  ft <- mk_par(ft,
    j = "test", part = "body",
    value = as_paragraph(
      as_strike(test)
    )
  )
  ft <- mk_par(ft,
    j = "test", part = "header",
    value = as_paragraph(
      as_strike(test)
    )
  )
  ft <- mk_par(ft,
    j = "test", part = "footer",
    value = as_paragraph(
      as_strike(test)
    )
  )

  runs <- information_data_chunk(ft)
  expect_equal(runs$strike, c(TRUE, TRUE, TRUE))

  openxml <- flextable:::runs_as_wml(ft, txt_data = runs)$run_openxml
  expect_match(openxml[1], "<w:strike w:val=\"true\"", fixed = TRUE)
  expect_match(openxml[2], "<w:strike w:val=\"true\"", fixed = TRUE)
  expect_match(openxml[3], "<w:strike w:val=\"true\"", fixed = TRUE)

  openxml <- flextable:::runs_as_pml(ft)$par_nodes_str
  expect_match(openxml[1], "strike=\"sngStrike\"", fixed = TRUE)
  expect_match(openxml[2], "strike=\"sngStrike\"", fixed = TRUE)
  expect_match(openxml[3], "strike=\"sngStrike\"", fixed = TRUE)

  html_info <- flextable:::runs_as_html(ft)
  css <- attr(html_info, "css")
  expect_match(css, "text-decoration:line-through;", fixed = TRUE)

  latex_str <- flextable:::runs_as_latex(ft)$txt
  expect_match(latex_str[1], "\\sout{", fixed = TRUE)
  expect_match(latex_str[2], "\\sout{", fixed = TRUE)
  expect_match(latex_str[3], "\\sout{", fixed = TRUE)

  rtf_str <- flextable:::runs_as_rtf(ft)$txt
  expect_match(rtf_str[1], "\\strike", fixed = TRUE)
  expect_match(rtf_str[2], "\\strike", fixed = TRUE)
  expect_match(rtf_str[3], "\\strike", fixed = TRUE)
})
