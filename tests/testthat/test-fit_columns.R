test_that("fit_columns returns unchanged widths when table fits", {
  ft <- qflextable(head(mtcars))
  original_w <- dim_pretty(ft)$widths
  ft2 <- fit_columns(ft, max_width = 20)
  expect_equal(unname(ft2$body$colwidths), unname(original_w))
})

test_that("fit_columns compresses to max_width", {
  ft <- qflextable(head(mtcars))
  ft2 <- suppressWarnings(fit_columns(ft, max_width = 4))
  # total should not exceed max_width + floor tolerance
  floor_w <- sum(flextable:::min_col_widths(ft))
  effective_max <- max(4, floor_w)
  expect_lte(sum(ft2$body$colwidths), effective_max + 1e-6)
})

test_that("fit_columns applies same widths to all parts", {
  ft <- qflextable(head(iris))
  ft2 <- suppressWarnings(fit_columns(ft, max_width = 3))
  expect_equal(ft2$header$colwidths, ft2$body$colwidths)
})

test_that("fit_columns no_wrap protects columns by name", {
  ft <- qflextable(head(iris))
  protected <- "Species"
  pretty_w <- dim_pretty(ft)$widths
  names(pretty_w) <- ft$col_keys
  ft2 <- suppressWarnings(fit_columns(ft, max_width = 3, no_wrap = protected))
  idx <- match(protected, ft$col_keys)
  expect_equal(unname(ft2$body$colwidths[idx]), unname(pretty_w[idx]))
})

test_that("fit_columns no_wrap protects columns by index", {
  ft <- qflextable(head(iris))
  pretty_w <- dim_pretty(ft)$widths
  ft2 <- suppressWarnings(fit_columns(ft, max_width = 3, no_wrap = 5L))
  expect_equal(unname(ft2$body$colwidths[5]), unname(pretty_w[5]))
})

test_that("fit_columns errors on invalid column names", {
  ft <- qflextable(head(iris))
  expect_error(
    fit_columns(ft, max_width = 3, no_wrap = "nonexistent"),
    "not found"
  )
})

test_that("fit_columns warns when protected columns exceed max_width", {
  ft <- qflextable(head(iris))
  expect_warning(
    fit_columns(ft, max_width = 0.01, no_wrap = names(iris)),
    "exceed max_width"
  )
})

test_that("fit_columns warns when floors exceed available space", {
  ft <- qflextable(head(mtcars))
  expect_warning(
    fit_columns(ft, max_width = 2),
    "floor widths exceed"
  )
})

test_that("fit_columns respects unit conversion", {
  ft <- qflextable(head(iris))
  ft_in <- suppressWarnings(fit_columns(ft, max_width = 4, unit = "in"))
  ft_cm <- suppressWarnings(fit_columns(ft, max_width = 4 * 2.54, unit = "cm"))
  expect_equal(ft_in$body$colwidths, ft_cm$body$colwidths, tolerance = 1e-6)
})

test_that("fit_columns iterative clamping redistributes correctly", {
  # build a table where single-pass would fail:
  # column A has a large floor, B and C have small floors
  dat <- data.frame(
    A = "Supercalifragilisticexpialidocious",
    B = "a b c",
    C = "x y z",
    stringsAsFactors = FALSE
  )
  ft <- flextable(dat)
  ft <- autofit(ft, add_w = 0, add_h = 0)

  pretty_w <- dim_pretty(ft)$widths
  # set max_width so A gets clamped but B and C should share the rest
  max_w <- sum(pretty_w) * 0.5
  ft2 <- suppressWarnings(fit_columns(ft, max_width = max_w))

  # all widths should be finite and positive
  expect_true(all(is.finite(ft2$body$colwidths)))
  expect_true(all(ft2$body$colwidths > 0))

  # A should be at its floor (longest word), B and C should share remaining
  floor_w <- flextable:::min_col_widths(ft)
  expect_equal(unname(ft2$body$colwidths[1]), unname(floor_w[1]))
})
