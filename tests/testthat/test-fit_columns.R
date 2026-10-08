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

test_that("fit_columns ignores spans when computing column floors (#731)", {
  dat <- data.frame(
    Item = c("Blue widget", "Red widget"),
    A = c(1.2, 2.3),
    B = c(1.3, 2.4),
    C = c(1.4, 2.5),
    D = c(1.5, 2.6),
    E = c(1.6, 2.7),
    F = c(1.7, 2.8),
    G = c(1.8, 2.9)
  )
  plain <- flextable(dat)
  merged <- add_header_row(
    plain,
    values = c("Item", "Measurements"),
    colwidths = c(1, 7)
  )

  # the merged heading only has to fit across the 7 columns it covers, so it
  # must not raise the floor of each of them
  expect_equal(
    fit_columns_metrics(merged)$floor_w,
    fit_columns_metrics(plain)$floor_w
  )

  expect_equal(flextable_dim(fit_columns(plain, max_width = 3.7))$widths, 3.7)
  expect_equal(flextable_dim(fit_columns(merged, max_width = 3.7))$widths, 3.7)
})

test_that("fit_columns keeps a span wide enough for its longest word", {
  dat <- data.frame(a = c("x", "y"), b = c("z", "w"), stringsAsFactors = FALSE)
  ft <- add_header_row(
    flextable(dat),
    values = "Unbreakablewordhere",
    colwidths = 2
  )

  floor_w <- fit_columns_metrics(ft)$floor_w
  word_w <- gdtools::strings_sizes("Unbreakablewordhere", fontsize = 11)$width

  # the columns it covers must be able to hold it together...
  expect_gte(sum(floor_w), word_w)
  # ...without either of them having to hold it alone
  expect_true(all(floor_w < word_w))
})

test_that("fit_columns does not warn on a table that fits exactly", {
  dat <- data.frame(
    Item = c("Blue widget", "Red widget"),
    A = c(1.2, 2.3),
    B = c(1.3, 2.4),
    stringsAsFactors = FALSE
  )
  ft <- flextable(dat)
  floor_sum <- sum(fit_columns_metrics(ft)$floor_w)

  expect_no_warning(fit_columns(ft, max_width = floor_sum))
})
