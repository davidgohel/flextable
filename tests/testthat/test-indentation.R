get_indent_ft <- function() {
  ft <- flextable(head(cars, 2))
  ft <- padding(ft, i = 1, j = 1, padding.left = 30, part = "header")
  ft <- indentation(ft, i = 1, j = 1, hanging = 20, part = "header")
  ft <- indentation(ft, i = 1, j = 2, first_line = 15, part = "header")
  ft
}

test_that("indentation() stores first_line and hanging", {
  ft <- get_indent_ft()
  dat <- information_data_paragraph(ft)
  header <- dat[dat$.part %in% "header", ]
  expect_equal(header$hanging[header$.col_id %in% "speed"], 20)
  expect_equal(header$first_line[header$.col_id %in% "dist"], 15)
  body <- dat[dat$.part %in% "body", ]
  expect_true(all(is.na(body$hanging)))
  expect_true(all(is.na(body$first_line)))

  expect_error(indentation(ft, hanging = "z"), "must be numeric")
  expect_error(indentation(iris), "supports only flextable")
})

test_that("indents can be set with style(pr_p = fp_par(...))", {
  ft <- flextable(head(cars, 2))
  ft <- style(
    ft,
    i = 1,
    j = 1,
    pr_p = officer::fp_par(padding.left = 30, hanging = 12),
    part = "header"
  )
  dat <- information_data_paragraph(ft)
  header <- dat[dat$.part %in% "header" & dat$.row_id %in% 1, ]
  expect_equal(header$hanging[header$.col_id %in% "speed"], 12)
})

test_that("indents in wml, pml and html", {
  ft <- get_indent_ft()

  wml <- flextable:::gen_raw_wml(ft)
  expect_match(wml, "w:hanging=\"400\"", fixed = TRUE)
  expect_match(wml, "w:firstLine=\"300\"", fixed = TRUE)

  pml <- flextable:::gen_raw_pml(ft)
  expect_match(pml, "indent=\"-254000\"", fixed = TRUE)
  expect_match(pml, "indent=\"190500\"", fixed = TRUE)

  html <- flextable:::gen_raw_html(ft)
  expect_match(html, "text-indent:-20pt;", fixed = TRUE)
  expect_match(html, "text-indent:15pt;", fixed = TRUE)

  html0 <- flextable:::gen_raw_html(flextable(head(cars, 2)))
  expect_no_match(html0, "text-indent", fixed = TRUE)
})

test_that("indents in rtf", {
  ft <- get_indent_ft()
  path <- tempfile(fileext = ".rtf")
  save_as_rtf(ft, path = path)
  rtf <- paste(readLines(path, warn = FALSE), collapse = "\n")
  expect_match(rtf, "\\fi-400", fixed = TRUE)
  expect_match(rtf, "\\fi300", fixed = TRUE)
})

test_that("indents in latex", {
  ft <- get_indent_ft()
  ltx <- paste(flextable:::gen_raw_latex(ft), collapse = "\n")
  # leftskip is reduced by the hanging value: 30 - 20
  expect_match(ltx, "\\advance\\leftskip by 10.0pt", fixed = TRUE)
  expect_match(ltx, "\\hangindent=20.0pt\\hangafter=1", fixed = TRUE)
  expect_match(ltx, "\\hspace*{15.0pt}", fixed = TRUE)

  ltx0 <- paste(
    flextable:::gen_raw_latex(flextable(head(cars, 2))),
    collapse = "\n"
  )
  expect_no_match(ltx0, "hangindent", fixed = TRUE)
})

test_that("indents in typst", {
  ft <- get_indent_ft()
  ty <- paste(flextable:::gen_raw_typst(ft), collapse = "\n")
  expect_match(ty, "#par(hanging-indent: 20pt)[", fixed = TRUE)
  expect_match(ty, "#h(15pt)", fixed = TRUE)
  # inset left is reduced by the hanging value: 30 - 20
  expect_match(ty, "inset: (left: 10pt", fixed = TRUE)

  ty0 <- paste(
    flextable:::gen_raw_typst(flextable(head(cars, 2))),
    collapse = "\n"
  )
  expect_no_match(ty0, "hanging-indent", fixed = TRUE)
})

test_that("indents in grid output", {
  skip_if_not_installed("gdtools")
  gdtools::font_set_liberation()

  ft <- flextable(data.frame(species = "x", island = "y"))
  ft <- mk_par(
    ft,
    part = "header",
    i = 1,
    j = "species",
    value = as_paragraph("species with a long trailing text that wraps")
  )
  ft <- padding(ft, i = 1, j = 1, padding.left = 30, part = "header")
  ft <- align(ft, align = "left", part = "all")
  ft <- width(ft, j = 1, width = 1.6)

  ft_hang <- indentation(ft, i = 1, j = 1, hanging = 24, part = "header")
  gr1 <- gen_grob(ft_hang, fit = "fixed")

  # first line has no indent column, continuation rows carry a leading
  # indent column of 24/72 in
  rows <- gr1$children[[1]]$children$contents$children
  expect_gt(length(rows), 1)
  first_widths <- as.numeric(rows[[1]]$vp$layout$widths)
  expect_false(isTRUE(all.equal(first_widths[1], 24 / 72)))
  for (row_id in seq_along(rows)[-1]) {
    widths <- as.numeric(rows[[row_id]]$vp$layout$widths)
    expect_equal(widths[1], 24 / 72, tolerance = 1e-6)
  }

  # first_line: only the first row is indented
  ft_first <- indentation(ft, i = 1, j = 1, first_line = 24, part = "header")
  gr2 <- gen_grob(ft_first, fit = "fixed")
  rows2 <- gr2$children[[1]]$children$contents$children
  expect_equal(
    as.numeric(rows2[[1]]$vp$layout$widths)[1],
    24 / 72,
    tolerance = 1e-6
  )
  widths2 <- as.numeric(rows2[[2]]$vp$layout$widths)
  expect_false(isTRUE(all.equal(widths2[1], 24 / 72)))
})
