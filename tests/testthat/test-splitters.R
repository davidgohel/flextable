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

test_that("split_columns moves the spans and styles of repeated columns", {
  ft <- flextable(head(iris, 2))
  ft <- add_header_row(ft, values = c("Sepal", "Petal", "Sp"), colwidths = c(2, 2, 1))
  ft <- width(ft, j = "Species", width = 1)
  ft <- bg(ft, j = "Species", bg = "yellow", part = "body")
  pages <- split_columns(ft, max_width = 3, rep_cols = "Species")
  p <- pages[[1]]
  expect_identical(p$col_keys, c("Species", "Sepal.Length", "Sepal.Width"))
  # "Sp" on the repeated column, "Sepal" merged over the two next ones
  expect_equal(p$header$spans$rows[1, ], c(1, 2, 0))
  header_txt <- vapply(
    p$col_keys,
    function(k) paste(p$header$content$data[[1, k]]$txt, collapse = ""),
    ""
  )
  expect_identical(unname(header_txt), c("Sp", "Sepal", "Sepal"))
  expect_equal(p$header$colwidths, c(1, 0.75, 0.75))
  expect_identical(
    unname(p$body$styles$cells$background.color$data[1, ]),
    c("yellow", "transparent", "transparent")
  )
})

test_that("split_columns frees spans broken by a repeated column", {
  ft <- flextable(head(iris, 2))
  ft <- add_header_row(ft, values = c("Group", "Sp"), colwidths = c(4, 1))
  pages <- split_columns(ft, max_width = 2.5, rep_cols = "Sepal.Width")
  for (p in pages) {
    expect_true(flextable:::valid_row_spans(p$header$spans$rows))
  }
})

test_that("split_rows reads the groups of paginate()", {
  dat <- iris[c(1:4, 51:54, 101:104), ]
  ft <- paginate(flextable(dat), group = "Species", group_def = "rle")
  expect_identical(flextable:::keep_with_next_starts(ft), c(1L, 5L, 9L))
  pages <- split_rows(ft, max_height = 2.2, group = "keep_with_next")
  species <- lapply(pages, function(p) unique(as.character(p$body$dataset$Species)))
  # each species on one page, none split
  expect_true(all(lengths(species) == 1L))
  expect_setequal(unlist(species), c("setosa", "versicolor", "virginica"))
  # the same through split_to_pages()
  expect_length(
    split_to_pages(ft, max_height = 2.2, group = "keep_with_next"),
    length(pages)
  )
  expect_error(split_rows(ft, max_height = 2, group = "rows"), "keep_with_next")
})

test_that("row heights are measured with the text wrapped at the widths", {
  dat <- data.frame(
    term = c(
      "Gastrointestinal disorders - Nausea and vomiting",
      "Headache",
      "Skin and subcutaneous tissue disorders"
    ),
    n = c("12 (5.1%)", "3 (1.2%)", "7 (2.9%)")
  )
  # no wrapping: the heights of dim_pretty()
  ft <- autofit(flextable(dat))
  expect_equal(flextable:::wrapped_row_heights(ft), dim_pretty(ft)$heights)

  # a narrow column: the heights of the rows drawn by gen_grob()
  ft <- width(flextable(dat), j = "term", width = 1.2)
  wrapped <- flextable:::wrapped_row_heights(ft)
  drawn <- gen_grob(ft, fit = "fixed", autowidths = FALSE, wrapping = TRUE)$ftpar$heights
  expect_equal(wrapped, drawn, tolerance = 0.03)
  # the long terms take several lines
  expect_gt(wrapped[2], 2 * dim_pretty(ft)$heights[2])
})

test_that("split_rows uses the heights of wrapped text", {
  dat <- data.frame(
    term = rep("Gastrointestinal disorders - Nausea and vomiting", 12),
    n = sprintf("%d (5.1%%)", 1:12)
  )
  ft <- width(flextable(dat), j = "term", width = 1.2)
  max_height <- 3
  pages <- split_rows(ft, max_height = max_height)
  # each page holds in max_height once wrapped
  for (p in pages) {
    expect_lte(sum(flextable:::wrapped_row_heights(p)), max_height)
  }
  # more pages than when the text does not wrap
  expect_gt(length(pages), length(split_rows(autofit(ft), max_height = max_height)))
})

test_that("split_columns uses the widths of the table", {
  dat <- data.frame(
    term = c("Gastrointestinal disorders - Nausea and vomiting", "Headache"),
    a = c("12 (5.1%)", "3 (1.2%)"),
    b = c("7 (2.9%)", "1 (0.4%)"),
    c = c("4 (1.7%)", "2 (0.8%)"),
    e = c("9 (3.8%)", "5 (2.1%)")
  )
  page_widths <- function(pages) vapply(pages, function(p) sum(dim(p)$widths), 1)

  # autofit(): each page holds in max_width
  ft <- autofit(flextable(dat))
  pages <- split_columns(ft, max_width = 6, rep_cols = "term")
  expect_true(all(page_widths(pages) <= 6))

  # a narrow column set by width(): the other columns share the pages
  ft <- width(ft, j = "term", width = 1.2)
  pages <- split_columns(ft, max_width = 4, rep_cols = "term")
  expect_length(pages, 2L)
  expect_true(all(page_widths(pages) <= 4))
})
