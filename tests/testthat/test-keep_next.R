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

test_that("paginate with default init uses flextable defaults", {
  init_flextable_defaults()
  ft <- flextable(head(iris, 10))

  ft_paged <- paginate(ft, hdr_ftr = FALSE)
  par_data <- information_data_paragraph(ft_paged)
  default_kwn <- get_flextable_defaults()$keep_with_next
  expect_true(
    all(par_data$keep_with_next == default_kwn)
  )
})

test_that("paginate hdr_ftr binds header and footer to body", {
  dat <- data.frame(a = 1:3, b = 4:6)
  ft <- flextable(dat)
  ft <- add_footer_lines(ft, values = "a footer note")

  ft_paged <- paginate(ft, init = FALSE, hdr_ftr = TRUE)
  par_data <- information_data_paragraph(ft_paged)

  # header rows should all have keep_with_next = TRUE
  header_kwn <- par_data$keep_with_next[par_data$.part == "header"]
  expect_true(all(header_kwn))

  # last body row should have keep_with_next = TRUE (bound to footer)
  body_kwn <- par_data$keep_with_next[par_data$.part == "body"]
  body_nrow <- nrow_part(ft_paged, "body")
  last_body_col_count <- sum(
    par_data$.part == "body" &
      par_data$.row_id == body_nrow
  )
  last_body_kwn <- tail(body_kwn, last_body_col_count)
  expect_true(all(last_body_kwn))

  # footer: all TRUE except last row
  footer_kwn <- par_data[par_data$.part == "footer", ]
  footer_nrow <- nrow_part(ft_paged, "footer")
  kwn_not_last <- footer_kwn$keep_with_next[
    footer_kwn$.row_id < footer_nrow
  ]
  expect_true(all(kwn_not_last))
  kwn_last <- footer_kwn$keep_with_next[
    footer_kwn$.row_id == footer_nrow
  ]
  expect_true(all(!kwn_last))
})

test_that("paginate hdr_ftr FALSE does not alter header/footer binding", {
  dat <- data.frame(a = 1:3, b = 4:6)
  ft <- flextable(dat)
  ft <- add_footer_lines(ft, values = "a footer note")

  ft_paged <- paginate(ft, init = FALSE, hdr_ftr = FALSE)
  par_data <- information_data_paragraph(ft_paged)

  # with init=FALSE and hdr_ftr=FALSE, all keep_with_next should be FALSE
  expect_true(all(!par_data$keep_with_next))
})

test_that("paginate with group_def nonempty", {
  dat <- data.frame(
    grp = c("A", "", "", "B", "", "C"),
    val = 1:6,
    stringsAsFactors = FALSE
  )
  ft <- flextable(dat)

  ft_paged <- paginate(
    ft, init = FALSE, hdr_ftr = FALSE,
    group = "grp", group_def = "nonempty"
  )
  par_data <- information_data_paragraph(ft_paged)
  body_data <- par_data[par_data$.part == "body", ]

  # check keep_with_next per row (same for all columns in a row)
  kwn_by_row <- tapply(body_data$keep_with_next, body_data$.row_id, unique)

  # Groups: rows 1-3 (A), rows 4-5 (B), row 6 (C)
  # Last row of each group should have keep_with_next = FALSE
  # Row 3 (last of group A) -> FALSE
  # Row 5 (last of group B) -> FALSE
  # Row 6 (last of group C) -> FALSE
  # Rows 1, 2, 4 -> TRUE
  expect_true(kwn_by_row[["1"]])
  expect_true(kwn_by_row[["2"]])
  expect_false(kwn_by_row[["3"]])
  expect_true(kwn_by_row[["4"]])
  expect_false(kwn_by_row[["5"]])
  expect_false(kwn_by_row[["6"]])
})

test_that("paginate nonempty errors on missing group column", {
  dat <- data.frame(a = 1:3, b = 4:6)
  ft <- flextable(dat)
  expect_error(
    paginate(ft, group = "nonexistent", group_def = "nonempty"),
    "could not find"
  )
})

test_that("paginate with group_def rle", {
  dat <- data.frame(
    grp = c("A", "A", "A", "B", "B", "C"),
    val = 1:6,
    stringsAsFactors = FALSE
  )
  ft <- flextable(dat)

  ft_paged <- paginate(
    ft, init = FALSE, hdr_ftr = FALSE,
    group = "grp", group_def = "rle"
  )
  par_data <- information_data_paragraph(ft_paged)
  body_data <- par_data[par_data$.part == "body", ]

  kwn_by_row <- tapply(
    body_data$keep_with_next,
    body_data$.row_id, unique
  )

  # Groups: rows 1-3 (A), rows 4-5 (B), row 6 (C)
  # Last row of each group -> FALSE, others -> TRUE
  expect_true(kwn_by_row[["1"]])
  expect_true(kwn_by_row[["2"]])
  expect_false(kwn_by_row[["3"]])
  expect_true(kwn_by_row[["4"]])
  expect_false(kwn_by_row[["5"]])
  expect_false(kwn_by_row[["6"]])
})

test_that("paginate rle errors on missing group column", {
  dat <- data.frame(a = 1:3, b = 4:6)
  ft <- flextable(dat)
  expect_error(
    paginate(ft, group = "nonexistent", group_def = "rle"),
    "could not find"
  )
})

test_that("paginate rle with empty body returns unchanged", {
  dat <- data.frame(a = character(0), b = numeric(0))
  ft <- flextable(dat)
  ft_paged <- paginate(ft, group = "a", group_def = "rle")
  expect_equal(nrow_part(ft_paged, "body"), 0L)
})

test_that("paginate nonempty with empty body returns unchanged", {
  dat <- data.frame(a = character(0), b = numeric(0))
  ft <- flextable(dat)
  ft_paged <- paginate(
    ft, group = "a", group_def = "nonempty"
  )
  expect_equal(nrow_part(ft_paged, "body"), 0L)
})

init_flextable_defaults()
