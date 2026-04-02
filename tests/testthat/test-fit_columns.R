test_that("fit_columns returns unchanged widths when table fits", {
  ft <- qflextable(head(mtcars))
  original_w <- dim_pretty(ft)$widths
  ft2 <- fit_columns(ft, max_width = 20)
  expect_equal(unname(dim(ft2)$widths), unname(original_w))
})

test_that("fit_columns compresses to max_width", {
  ft <- qflextable(head(mtcars))
  ft2 <- suppressWarnings(fit_columns(ft, max_width = 4))
  expect_lte(sum(dim(ft2)$widths), sum(dim_pretty(ft)$widths))
})

test_that("fit_columns applies same widths to all parts", {
  ft <- qflextable(head(iris))
  ft2 <- suppressWarnings(fit_columns(ft, max_width = 3))
  w <- dim(ft2)$widths
  expect_true(all(is.finite(w)))
  expect_true(all(w > 0))
})

test_that("fit_columns no_wrap protects columns by name", {
  ft <- qflextable(head(iris))
  protected <- "Species"
  pretty_w <- dim_pretty(ft)$widths
  ft2 <- suppressWarnings(fit_columns(ft, max_width = 3, no_wrap = protected))
  idx <- match(protected, ft$col_keys)
  expect_equal(unname(dim(ft2)$widths[idx]), unname(pretty_w[idx]))
})

test_that("fit_columns no_wrap protects columns by index", {
  ft <- qflextable(head(iris))
  pretty_w <- dim_pretty(ft)$widths
  ft2 <- suppressWarnings(fit_columns(ft, max_width = 3, no_wrap = 5L))
  expect_equal(unname(dim(ft2)$widths[5]), unname(pretty_w[5]))
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
  expect_equal(dim(ft_in)$widths, dim(ft_cm)$widths, tolerance = 1e-6)
})

test_that("fit_columns iterative clamping redistributes correctly", {
  dat <- data.frame(
    A = "Supercalifragilisticexpialidocious",
    B = "a b c",
    C = "x y z",
    stringsAsFactors = FALSE
  )
  ft <- flextable(dat)
  ft <- autofit(ft, add_w = 0, add_h = 0)

  pretty_w <- dim_pretty(ft)$widths
  max_w <- sum(pretty_w) * 0.5
  ft2 <- suppressWarnings(fit_columns(ft, max_width = max_w))

  w <- dim(ft2)$widths
  expect_true(all(is.finite(w)))
  expect_true(all(w > 0))
})
