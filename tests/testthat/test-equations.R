equation_table <- function() {
  ft <- flextable(data.frame(eq = "\\frac{a}{b}"))
  # sizes given: no need of equatags to measure them
  mk_par(ft, j = "eq", value = as_paragraph(as_equation(eq, width = 1, height = 0.5)))
}

test_that("LaTeX equations use the display style", {
  str <- flextable:::gen_raw_latex(equation_table())
  expect_match(str, "$\\displaystyle \\frac{a}{b}$", fixed = TRUE)
})

test_that("HTML equations use the display style", {
  skip_if_not_installed("equatags")
  str <- flextable:::gen_raw_html(equation_table())
  # KaTeX keeps the source in an annotation
  expect_match(str, "\\displaystyle \\frac{a}{b}", fixed = TRUE)
})

test_that("Word and PowerPoint equations use the display style", {
  skip_if_not_installed("equatags")
  ft <- flextable(data.frame(eq = "\\sum_{i=1}^{n} x_i"))
  ft <- mk_par(ft, j = "eq", value = as_paragraph(as_equation(eq, width = 1, height = 0.5)))
  wml <- flextable:::gen_raw_wml(ft)
  expect_match(wml, "<m:limLoc m:val=\"undOvr\"/>", fixed = TRUE)
  pml <- flextable:::gen_raw_pml(ft)
  expect_match(pml, "<m:limLoc m:val=\"undOvr\"/>", fixed = TRUE)
})

test_that("computed sizes are the ones of the display style", {
  skip_if_not(flextable:::has_equation_size())
  ft <- flextable(data.frame(eq = "\\sum_{i=1}^{n} x_i"))
  ft <- mk_par(ft, j = "eq", value = as_paragraph(as_equation(eq)))
  dat <- flextable:::information_data_chunk(ft)
  dat <- dat[!is.na(dat$eq_data), ]
  s <- equatags::equation_size(dat$eq_data, size = dat$font.size, display = TRUE)
  expect_equal(dat$width, s$width)
  expect_equal(dat$height, s$height + s$depth)
})

test_that("equations are in display style only when alone in their paragraph", {
  ft <- flextable(data.frame(a = c("x", "y", "z"), b = 1:3))
  ft <- mk_par(ft, i = 1, j = "a", value = as_paragraph(as_equation("\\frac{a}{b}", width = 1, height = 0.5)))
  ft <- mk_par(ft, i = 2, j = "a", value = as_paragraph("eq ", as_equation("\\frac{a}{b}", width = 1, height = 0.5)))
  ft <- mk_par(ft, i = 3, j = "a", value = as_paragraph(
    as_equation("x", width = 1, height = 0.5),
    as_equation("y", width = 1, height = 0.5)
  ))
  dat <- flextable:::information_data_chunk(ft)
  eq <- dat[!is.na(dat$eq_data), ]
  expect_equal(eq$eq_display, c(TRUE, FALSE, TRUE, TRUE))
  # a space is enough to get the inline style
  ft <- mk_par(ft, i = 1, j = "a", value = as_paragraph(" ", as_equation("x", width = 1, height = 0.5)))
  dat <- flextable:::information_data_chunk(ft)
  expect_false(dat$eq_display[!is.na(dat$eq_data)][1])
})

test_that("LaTeX equations with text use the inline style", {
  ft <- flextable(data.frame(eq = "x"))
  ft <- mk_par(ft, j = "eq", value = as_paragraph("eq ", as_equation("\\frac{a}{b}", width = 1, height = 0.5)))
  str <- flextable:::gen_raw_latex(ft)
  expect_match(str, "$\\frac{a}{b}$", fixed = TRUE)
  expect_no_match(str, "displaystyle", fixed = TRUE)
})

test_that("Word equations alone in their paragraph keep the alignment of the paragraph", {
  skip_if_not_installed("equatags")
  ft <- flextable(data.frame(a = c("x", "y")))
  ft <- mk_par(ft, i = 1, j = "a", value = as_paragraph(as_equation("\\frac{a}{b}", width = 1, height = 0.5)))
  ft <- mk_par(ft, i = 2, j = "a", value = as_paragraph("eq ", as_equation("\\frac{a}{b}", width = 1, height = 0.5)))
  ft <- align(ft, align = "right", part = "all")
  wml <- flextable:::gen_raw_wml(ft)
  # one math paragraph, for the equation alone, right aligned
  expect_equal(lengths(regmatches(wml, gregexpr("</m:oMathPara>", wml, fixed = TRUE))), 1L)
  expect_match(wml, "<m:jc m:val=\"right\"/>", fixed = TRUE)
})

test_that("consecutive equations with the same format are one equation", {
  ft <- flextable(data.frame(a = c("x", "y")))
  ft <- mk_par(ft, i = 1, j = "a", value = as_paragraph(as_equation("a"), as_equation("b")))
  ft <- mk_par(ft, i = 2, j = "a", value = as_paragraph(
    as_equation("a"),
    as_equation("b", props = fp_text_default(color = "red"))
  ))
  dat <- flextable:::information_data_chunk(ft)
  dat <- dat[dat$.part == "body" & !is.na(dat$eq_data), ]
  expect_equal(dat$eq_data, c("a b", "a", "b"))
})

test_that("PowerPoint equations alone in their paragraph keep the alignment of the paragraph", {
  skip_if_not_installed("equatags")
  ft <- flextable(data.frame(a = c("x", "y")))
  ft <- mk_par(ft, i = 1, j = "a", value = as_paragraph(as_equation("\\frac{a}{b}", width = 1, height = 0.5)))
  ft <- mk_par(ft, i = 2, j = "a", value = as_paragraph("eq ", as_equation("\\frac{a}{b}", width = 1, height = 0.5)))
  ft <- align(ft, align = "right", part = "all")
  pml <- flextable:::gen_raw_pml(ft)
  expect_equal(lengths(regmatches(pml, gregexpr("<m:jc m:val=\"right\"/>", pml, fixed = TRUE))), 1L)
  expect_equal(lengths(regmatches(pml, gregexpr("<m:jc m:val=\"centerGroup\"/>", pml, fixed = TRUE))), 1L)
})

test_that("RTF equations are images on the baseline of the text", {
  skip_if_not(flextable:::can_draw_equations())
  ft <- flextable(data.frame(eq = c("\\frac{a}{b}", "\\frac{a}{b}", "x")))
  ft <- mk_par(ft, j = "eq", value = as_paragraph("eq: ", as_equation(eq)))
  str <- to_rtf(ft)
  s <- equatags::equation_size(c("\\frac{a}{b}", "x"), size = 11)
  pict <- sprintf(
    "{\\pict\\pngblip\\picwgoal%.0f\\pichgoal%.0f ",
    s$width * 1440,
    (s$height + s$depth) * 1440
  )
  # the fraction is lowered by its depth (half points)
  expect_match(
    str,
    paste0(sprintf("{\\dn%.0f ", round(s$depth[1] * 144)), pict[1]),
    fixed = TRUE
  )
  expect_match(str, pict[2], fixed = TRUE)
  expect_length(gregexpr("\\pngblip", str, fixed = TRUE)[[1]], 3)
})

test_that("RTF equations are LaTeX text when they can not be drawn", {
  local_mocked_bindings(can_draw_equations = function() FALSE)
  expect_warning(str <- to_rtf(equation_table()), "LaTeX text")
  expect_match(str, "\\frac{a}{b}", fixed = TRUE)
  expect_no_match(str, "\\pngblip", fixed = TRUE)
})
