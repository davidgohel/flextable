test_that("gen_grob() lines are spaced as in Word", {
  skip_if_not_installed("gdtools", minimum_version = "0.6.0")
  dat <- data.table::data.table(
    txt = c("Hxg", "Hxg"),
    font.family = "sans",
    font.size = 12,
    bold = FALSE,
    italic = FALSE,
    is_text = TRUE,
    is_superscript = FALSE,
    is_subscript = FALSE,
    line_spacing = c(1, 2)
  )
  m <- flextable:::calc_grid_text_metrics(dat)
  ref <- gdtools::font_line_metrics("sans", fontsize = 12)
  # single spacing: the line metrics of the font
  expect_equal(m$ascent[1], ref$ascent)
  expect_equal(m$descent[1], ref$descent)
  # double spacing: the added space is below the line
  expect_equal(m$ascent[2], ref$ascent)
  expect_equal(m$height[2], 2 * ref$line_height)
})

test_that("gen_grob() borders take space as in Word", {
  gdtools::font_set_liberation()
  row_heights <- function(ft) gen_grob(ft, fit = "fixed")$ftpar$heights
  ft <- flextable(data.frame(a = "Hxg", b = "x"))
  ft <- border_remove(ft)
  plain <- row_heights(ft)
  thick <- hline_bottom(ft, part = "header", border = officer::fp_border(width = 3))
  # a horizontal border adds its width to the row carrying it
  expect_equal(row_heights(thick), plain + c(3, 0) / 72)
})

test_that("gen_grob() centers contents between asymmetric paddings", {
  gdtools::font_set_liberation()
  ft <- flextable(data.frame(a = "Hxg"))
  ft <- border_remove(ft)
  ft <- padding(ft, padding.top = 20, padding.bottom = 0, part = "all")
  dat <- flextable:::get_grid_data(ft, autowidths = TRUE, wrapping = FALSE)
  dat <- flextable:::grid_data_add_cell_info(dat, ft)
  dat <- flextable:::grid_data_add_par_info(dat, ft)
  vp <- dat$contents_vp[[2]]
  # center of the area between the paddings: 10 points under the center
  expect_equal(grid::convertY(vp$y - grid::unit(0.5, "npc"), "bigpts", valueOnly = TRUE), -10)
})

test_that("HTML lines are spaced as in Word", {
  gdtools::font_set_liberation()
  ft <- flextable(data.frame(a = c("x", "y")))
  ft <- font(ft, fontname = "Liberation Sans", part = "all")
  ft <- fontsize(ft, size = 12, part = "all")
  ft <- line_spacing(ft, i = 2, space = 1.5, part = "body")
  html <- flextable:::gen_raw_html(ft)
  # Liberation Sans: line height of 1.15 em (2355 / 2048)
  expect_match(html, "line-height: 1.15", fixed = TRUE)
  expect_match(html, "line-height: 1.725", fixed = TRUE)
  # the space added by the line spacing 1.5 is moved below the lines:
  # 0.5 * 1.15 * 12 / 2 = 3.45 points
  expect_match(html, "margin-top:-3.5pt;margin-bottom:3.5pt;", fixed = TRUE)
})

test_that("dim_pretty() heights use the line height of the fonts", {
  gdtools::font_set_liberation()
  ft <- flextable(data.frame(a = c("x", "y")))
  ft <- font(ft, fontname = "Liberation Sans", part = "all")
  ft <- fontsize(ft, size = 12, part = "all")
  ft <- border_remove(ft)
  ft <- padding(ft, padding = 0, part = "all")
  ft <- line_spacing(ft, i = 2, space = 2, part = "body")
  lh <- gdtools::font_line_metrics("Liberation Sans", fontsize = 12)$line_height
  expect_equal(dim_pretty(ft)$heights, c(lh, lh, 2 * lh))
})

test_that("PowerPoint line spacing is scaled to space lines as in Word", {
  gdtools::font_set_liberation()
  ft <- flextable(data.frame(a = c("x", "y")))
  ft <- font(ft, fontname = "Liberation Sans", part = "all")
  ft <- line_spacing(ft, i = 2, space = 2, part = "body")
  pml <- flextable:::gen_raw_pml(ft)
  # PowerPoint: 1.2 times the font size; Liberation Sans: 1.15 em
  expect_match(pml, "<a:spcPct val=\"95825\"/>", fixed = TRUE)
  expect_match(pml, "<a:spcPct val=\"191650\"/>", fixed = TRUE)
})

test_that("LaTeX paragraphs get the baselineskip of Word", {
  gdtools::font_set_liberation()
  ft <- flextable(data.frame(a = c("x", "y")))
  ft <- font(ft, fontname = "Liberation Sans", part = "all")
  ft <- fontsize(ft, size = 12, part = "all")
  ft <- line_spacing(ft, i = 2, space = 1.5, part = "body")
  latex <- flextable:::gen_raw_latex(ft)
  # set for the cell, outside the groups of the chunks
  expect_match(latex, "\\setlength{\\baselineskip}{13.8bp}", fixed = TRUE)
  expect_match(latex, "\\setlength{\\baselineskip}{20.7bp}", fixed = TRUE)
})
