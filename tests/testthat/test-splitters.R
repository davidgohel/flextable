# --- split_columns ---

test_that("split_columns returns single page when table fits", {
  ft <- flextable(head(mtcars[, 1:3]))
  pages <- split_columns(ft, max_width = 20)
  expect_length(pages, 1)
})

test_that("split_columns splits wide table", {
  ft <- flextable(head(mtcars))
  pages <- split_columns(ft, max_width = 5)
  expect_gt(length(pages), 1)
  for (p in pages) {
    expect_s3_class(p, "flextable")
  }
})

test_that("split_columns rep_cols by name repeats columns", {
  ft <- flextable(head(mtcars))
  pages <- split_columns(ft, max_width = 5, rep_cols = c("mpg", "cyl"))
  for (p in pages) {
    expect_true(all(c("mpg", "cyl") %in% p$col_keys))
  }
})

test_that("split_columns rep_cols by index repeats columns", {
  ft <- flextable(head(mtcars))
  pages <- split_columns(ft, max_width = 5, rep_cols = 1:2)
  for (p in pages) {
    expect_true(all(c("mpg", "cyl") %in% p$col_keys))
  }
})

test_that("split_columns preserves rep_cols order", {
  ft <- flextable(head(mtcars))
  pages <- split_columns(ft, max_width = 5, rep_cols = c("am", "mpg"))
  for (p in pages) {
    idx_am <- match("am", p$col_keys)
    idx_mpg <- match("mpg", p$col_keys)
    expect_lt(idx_am, idx_mpg)
  }
})

test_that("split_columns warns on invalid column name", {
  ft <- flextable(head(mtcars))
  expect_warning(
    split_columns(ft, max_width = 5, rep_cols = "nonexistent"),
    "can not be found"
  )
})

test_that("split_columns warns when rep_cols exceed max_width", {
  ft <- flextable(head(mtcars))
  expect_warning(
    split_columns(ft, max_width = 0.01, rep_cols = names(mtcars)),
    "too small"
  )
})

test_that("split_columns respects unit conversion", {
  ft <- flextable(head(mtcars))
  p_in <- split_columns(ft, max_width = 5, unit = "in")
  p_cm <- split_columns(ft, max_width = 5 * 2.54, unit = "cm")
  expect_equal(length(p_in), length(p_cm))
})

test_that("split_columns preserves header on every page", {
  ft <- flextable(head(mtcars))
  pages <- split_columns(ft, max_width = 5)
  for (p in pages) {
    expect_gt(nrow_part(p, "header"), 0)
  }
})

# --- split_rows ---

test_that("split_rows returns single page when table fits", {
  ft <- flextable(head(iris))
  pages <- split_rows(ft, max_height = 20)
  expect_length(pages, 1)
})

test_that("split_rows splits tall table", {
  ft <- flextable(iris)
  pages <- split_rows(ft, max_height = 3)
  expect_gt(length(pages), 1)
  for (p in pages) {
    expect_s3_class(p, "flextable")
  }
})

test_that("split_rows keeps group together", {
  ft <- flextable(iris)
  # groups start at rows 1, 51, 101
  pages <- split_rows(ft, max_height = 3, group = c(1L, 51L, 101L))
  # each page should only contain rows from contiguous groups
  total_rows <- sum(sapply(pages, nrow_part, part = "body"))
  expect_equal(total_rows, 150)
})

test_that("split_rows errors on unsorted group", {
  ft <- flextable(iris)
  expect_error(
    split_rows(ft, max_height = 3, group = c(51L, 1L)),
    "strictly increasing"
  )
})

test_that("split_rows errors on out-of-range group", {
  ft <- flextable(iris)
  expect_error(
    split_rows(ft, max_height = 3, group = c(0L, 50L)),
    "between 1 and"
  )
})

test_that("split_rows warns when max_height too small", {
  ft <- flextable(iris)
  ft <- add_footer_lines(ft, values = rep("footer line", 50))
  expect_warning(
    split_rows(ft, max_height = 0.01),
    "too small"
  )
})

test_that("split_rows respects unit conversion", {
  ft <- flextable(iris)
  p_in <- split_rows(ft, max_height = 3, unit = "in")
  p_cm <- split_rows(ft, max_height = 3 * 2.54, unit = "cm")
  expect_equal(length(p_in), length(p_cm))
})

test_that("split_rows repeats footer on every page", {
  ft <- flextable(iris)
  ft <- add_footer_lines(ft, values = "a footnote")
  pages <- split_rows(ft, max_height = 3)
  for (p in pages) {
    expect_equal(nrow_part(p, "footer"), 1)
  }
})

# --- split_to_pages ---

test_that("split_to_pages with max_height only equals split_rows", {
  ft <- flextable(iris)
  p_pages <- split_to_pages(ft, max_height = 3)
  p_rows <- split_rows(ft, max_height = 3)
  expect_equal(length(p_pages), length(p_rows))
})

test_that("split_to_pages with max_width only equals split_columns", {
  ft <- flextable(head(mtcars))
  p_pages <- split_to_pages(ft, max_width = 5)
  p_cols <- split_columns(ft, max_width = 5)
  expect_equal(length(p_pages), length(p_cols))
})

test_that("split_to_pages with both produces more pages", {
  ft <- flextable(iris)
  p_h <- split_to_pages(ft, max_height = 3)
  p_w <- split_to_pages(ft, max_width = 4)
  p_both <- split_to_pages(ft, max_width = 4, max_height = 3)
  expect_gte(length(p_both), length(p_h))
  expect_gte(length(p_both), length(p_w))
})

test_that("split_to_pages with no constraints returns single-element list", {
  ft <- flextable(head(iris))
  pages <- split_to_pages(ft)
  expect_true(is.list(pages))
  expect_length(pages, 1)
  expect_s3_class(pages[[1]], "flextable")
})

test_that("split_to_pages always returns a list", {
  ft <- flextable(head(iris))
  # even when table fits
  pages <- split_to_pages(ft, max_width = 20, max_height = 20)
  expect_true(is.list(pages))
  expect_length(pages, 1)
})

test_that("split_to_pages every element is a flextable", {
  ft <- flextable(iris)
  pages <- split_to_pages(ft, max_width = 4, max_height = 3)
  for (p in pages) {
    expect_s3_class(p, "flextable")
  }
})
