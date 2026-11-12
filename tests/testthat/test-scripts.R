# Superscripts and subscripts drawn as Word draws them with Arial and
# Liberation Sans: 65% of the font size, baseline shifted by 0.34 (up) or
# 0.07 (down) of the font size.

scripts_ft <- function(size = 12) {
  ft <- flextable(data.frame(a = ""))
  ft <- mk_par(
    ft,
    j = "a",
    value = as_paragraph("H", as_sub("2"), "O m", as_sup("3"))
  )
  ft <- delete_part(ft, "header")
  fontsize(ft, size = size, part = "all")
}

# text grobs placed by gen_grob(), in the order of the chunks
placed_texts <- function(ft) {
  find_text <- function(x) {
    out <- if (inherits(x, "text")) list(x) else list()
    kids <- c(if (inherits(x, "gTree")) x$children, x$ftgrobs)
    for (k in kids) out <- c(out, find_text(k))
    out
  }
  ragg::agg_png(tempfile(fileext = ".png"), width = 3, height = 2, units = "in", res = 72)
  on.exit(grDevices::dev.off())
  grid::grid.newpage()
  tx <- find_text(grid::makeContent(gen_grob(ft, fit = "fixed")))
  tx <- Filter(function(z) grid::unitType(z$y) == "inches", tx)
  data.frame(
    label = vapply(tx, function(z) z$label, ""),
    size = vapply(tx, function(z) z$gp$fontsize, 0),
    y = vapply(tx, function(z) grid::convertY(z$y, "bigpts", valueOnly = TRUE), 0)
  )
}

test_that("gen_grob() draws scripts at 65% with a shifted baseline", {
  skip_if_not_installed("ragg")
  tx <- placed_texts(scripts_ft(12))
  expect_equal(tx$label, c("H", "2", "O m", "3"))
  expect_equal(tx$size, c(12, 12 * 0.65, 12, 12 * 0.65))
  y <- tx$y
  expect_equal(y[2] - y[1], -0.07 * 12, tolerance = 1e-6)
  expect_equal(y[4] - y[1], 0.34 * 12, tolerance = 1e-6)
})

test_that("HTML scripts are sized and shifted from the font size of the text", {
  for (size in c(8, 24)) {
    html <- gen_raw_html(scripts_ft(size))
    shifts <- regmatches(html, gregexpr("vertical-align:-?[0-9.]+pt;", html))[[1]]
    expect_equal(
      shifts,
      sprintf("vertical-align:%.2fpt;", c(-0.07, 0.34) * size)
    )
    # 65% of the font size, as in Word
    script_styles <- regmatches(html, gregexpr("\\{[^}]*vertical-align:-?[0-9.]+pt;\\}", html))[[1]]
    expect_length(script_styles, 2L)
    expect_true(all(grepl(
      sprintf("font-size:%spt;", format_double(size * 0.65, digits = 1)),
      script_styles,
      fixed = TRUE
    )))
  }
})
