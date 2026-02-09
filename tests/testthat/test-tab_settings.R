init_flextable_defaults()

ft <- flextable(head(iris, 2))

# --- set_table_properties validation ---

test_that("set_table_properties rejects invalid layout", {
  expect_error(set_table_properties(ft, layout = "bogus"), "layout")
})

test_that("set_table_properties rejects invalid width", {
  expect_error(set_table_properties(ft, width = "a"), "width")
  expect_error(set_table_properties(ft, width = 1.5), "width")
})

test_that("set_table_properties validates word_title and word_description", {
  expect_error(
    set_table_properties(ft, word_title = 123),
    "is.character"
  )
  expect_error(
    set_table_properties(ft, word_title = "Title"),
    "is.character"
  )
  expect_no_error(
    set_table_properties(ft, word_title = "Title", word_description = "Desc")
  )
})

# --- opts_ft_html validation ---

test_that("opts_ft_html rejects invalid extra_css", {
  expect_error(
    set_table_properties(ft, opts_html = list(extra_css = 123)),
    "extra_css"
  )
  expect_error(
    set_table_properties(ft, opts_html = list(extra_css = c("a", "b"))),
    "extra_css"
  )
})

test_that("opts_ft_html rejects invalid scroll", {
  expect_error(
    set_table_properties(ft, opts_html = list(scroll = "yes")),
    "scroll"
  )
  expect_no_error(
    set_table_properties(ft, opts_html = list(scroll = NULL))
  )
  expect_no_error(
    set_table_properties(ft, opts_html = list(scroll = list(height = "300px")))
  )
})

# --- opts_ft_word validation ---

test_that("opts_ft_word rejects invalid split", {
  expect_error(
    set_table_properties(ft, opts_word = list(split = "yes")),
    "split"
  )
  expect_error(
    set_table_properties(ft, opts_word = list(split = c(TRUE, FALSE))),
    "split"
  )
})

test_that("opts_ft_word rejects invalid keep_with_next", {
  expect_error(
    set_table_properties(ft, opts_word = list(keep_with_next = 1)),
    "keep_with_next"
  )
})

test_that("opts_ft_word rejects invalid repeat_headers", {
  expect_error(
    set_table_properties(ft, opts_word = list(repeat_headers = "yes")),
    "repeat_headers"
  )
})

test_that("opts_ft_word accepts valid values", {
  ft2 <- set_table_properties(ft, opts_word = list(
    split = TRUE, keep_with_next = FALSE, repeat_headers = TRUE
  ))
  expect_true(ft2$properties$opts_word$split)
  expect_false(ft2$properties$opts_word$keep_with_next)
  expect_true(ft2$properties$opts_word$repeat_headers)
})

# --- opts_ft_pdf validation ---

test_that("opts_ft_pdf rejects invalid fonts_ignore", {
  expect_error(
    set_table_properties(ft, opts_pdf = list(fonts_ignore = "yes")),
    "fonts_ignore"
  )
  expect_error(
    set_table_properties(ft, opts_pdf = list(fonts_ignore = c(TRUE, FALSE))),
    "fonts_ignore"
  )
})

test_that("opts_ft_pdf rejects invalid tabcolsep", {
  expect_error(
    set_table_properties(ft, opts_pdf = list(tabcolsep = "big")),
    "tabcolsep"
  )
  expect_error(
    set_table_properties(ft, opts_pdf = list(tabcolsep = -1)),
    "tabcolsep"
  )
})

test_that("opts_ft_pdf rejects invalid arraystretch", {
  expect_error(
    set_table_properties(ft, opts_pdf = list(arraystretch = "big")),
    "arraystretch"
  )
  expect_error(
    set_table_properties(ft, opts_pdf = list(arraystretch = -0.5)),
    "arraystretch"
  )
})

test_that("opts_ft_pdf rejects invalid float", {
  expect_error(
    set_table_properties(ft, opts_pdf = list(float = "top")),
    "float"
  )
  expect_error(
    set_table_properties(ft, opts_pdf = list(float = 1)),
    "float"
  )
})

test_that("opts_ft_pdf rejects invalid caption_repeat", {
  expect_error(
    set_table_properties(ft, opts_pdf = list(caption_repeat = "yes")),
    "logical"
  )
})

test_that("opts_ft_pdf accepts all valid float values", {
  for (fval in c("none", "float", "wrap-r", "wrap-l", "wrap-i", "wrap-o")) {
    ft2 <- set_table_properties(ft, opts_pdf = list(float = fval))
    expect_equal(ft2$properties$opts_pdf$float, fval)
  }
})

test_that("opts_ft_pdf accepts valid combinations", {
  ft2 <- set_table_properties(ft, opts_pdf = list(
    tabcolsep = 4, arraystretch = 2, float = "float",
    fonts_ignore = TRUE, caption_repeat = FALSE, footer_repeat = TRUE
  ))
  expect_equal(ft2$properties$opts_pdf$tabcolsep, 4)
  expect_equal(ft2$properties$opts_pdf$arraystretch, 2)
  expect_equal(ft2$properties$opts_pdf$float, "float")
  expect_true(ft2$properties$opts_pdf$fonts_ignore)
  expect_false(ft2$properties$opts_pdf$caption_repeat)
  expect_true(ft2$properties$opts_pdf$footer_repeat)
})

# --- tab_settings ---

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

  ft <- flextable(z)
  ft <- tab_settings(ft, i = 1, j = 2, value = ts)
  ft <- width(ft, width = c(1.5, 2))


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
