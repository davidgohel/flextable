layout_text <- function(pieces, max_width = Inf, ...) {
  layout_lines(
    width = nchar(pieces),
    newline = pieces == "\n",
    space = pieces == " ",
    max_width = max_width,
    ...
  )
}

test_that("pieces that fit stay on the first line", {
  expect_equal(layout_text(c("ab", " ", "cd"), 5), c(1L, 1L, 1L))
  expect_equal(layout_text(c("ab", " ", "cd")), c(1L, 1L, 1L))
})

test_that("a line is only too wide above the maximum width", {
  expect_equal(layout_text(c("ab", "cd"), 4), c(1L, 1L))
  expect_equal(layout_text(c("ab", "cd"), 3.9), c(1L, 2L))
})

test_that("a piece too wide stays on its line if it is the first one", {
  expect_equal(layout_text(c("abcdef", "g"), 3), c(1L, 2L))
  expect_equal(layout_text(c("a", "bcdef", "g"), 3), c(1L, 2L, 3L))
})

test_that("a space that does not fit is dropped", {
  expect_equal(layout_text(c("abc", " ", "d"), 3), c(1L, 0L, 2L))
})

test_that("spaces are kept at the start of the text and after a line break", {
  expect_equal(layout_text(c(" ", "a")), c(1L, 1L))
  expect_equal(layout_text(c("a", "\n", " ", "b")), c(1L, 0L, 2L, 2L))
  expect_equal(layout_text(c("a", "\n", " ", " ", "b")), c(1L, 0L, 2L, 2L, 2L))
  # the line break follows an automatic one
  expect_equal(layout_text(c("abcdef", "\n", " ", "b"), 3), c(1L, 0L, 2L, 2L))
})

test_that("spaces are dropped at the start of a wrapped line", {
  expect_equal(layout_text(c("abc", " ", " ", "d"), 3), c(1L, 0L, 0L, 2L))
  expect_equal(layout_text(c("abcdef", " ", "d"), 3), c(1L, 0L, 2L))
})

test_that("line breaks end lines and empty lines are kept", {
  expect_equal(layout_text(c("a", "\n", "b")), c(1L, 0L, 2L))
  expect_equal(layout_text(c("a", "\n", "\n", "b")), c(1L, 0L, 2L, 3L))
  expect_equal(layout_text(c("\n", "a")), c(1L, 2L))
  expect_equal(layout_text(c("\n", "\n", "a")), c(1L, 2L, 3L))
})

test_that("a line break just after an automatic one adds no empty line", {
  expect_equal(layout_text(c("abcdef", "\n", "g"), 3), c(1L, 0L, 2L))
  expect_equal(layout_text(c("abc", " ", "\n", "g"), 3), c(1L, 0L, 0L, 2L))
})

test_that("lines numbers have no gap", {
  set.seed(1)
  for (k in 1:200) {
    pieces <- sample(c("a", "bcd", "efghij", " ", "\n"), 25, replace = TRUE)
    line <- layout_text(pieces, 5)
    kept <- line[line > 0L]
    expect_true(all(diff(kept) %in% c(0L, 1L)))
    expect_equal(kept[1], 1L)
  }
})

test_that("first_line and hanging change the available width", {
  pieces <- c("ab", "cd", "ef", "gh")
  expect_equal(layout_text(pieces, 4), c(1L, 1L, 2L, 2L))
  expect_equal(layout_text(pieces, 4, first_line = 2), c(1L, 2L, 2L, 3L))
  expect_equal(layout_text(pieces, 4, hanging = 2), c(1L, 1L, 2L, 3L))
})

test_that("columns group consecutive pieces of a chunk", {
  expect_equal(
    layout_columns(c(1L, 1L, 1L, 2L, 2L), c(1L, 1L, 2L, 2L, 3L)),
    c(1L, 1L, 2L, 1L, 2L)
  )
  expect_equal(layout_columns(c(1L, 0L, 2L), c(1L, 1L, 1L)), c(1L, 0L, 1L))
})

test_that("wrap children are the next rows of the next level", {
  dat <- data.frame(
    wrap_level = c(1L, 2L, 2L, 3L, 3L, 2L),
    .chunk_index = 1:6,
    child_count = c(3L, 2L, 0L, 0L, 0L, 0L)
  )
  expect_equal(
    calc_grid_wrap_children(dat),
    list(c(2L, 3L, 6L), c(4L, 5L), integer(0), integer(0), integer(0), integer(0))
  )
})

test_that("wrap children are limited to the rows that exist", {
  # fewer rows than child_count
  dat <- data.frame(
    wrap_level = c(1L, 2L),
    .chunk_index = 1:2,
    child_count = c(5L, 0L)
  )
  expect_equal(calc_grid_wrap_children(dat), list(2L, integer(0)))

  # no row at the next level: the row must keep its entry
  dat <- data.frame(
    wrap_level = c(1L, 1L, 1L),
    .chunk_index = 1:3,
    child_count = c(2L, 0L, 0L)
  )
  expect_equal(
    calc_grid_wrap_children(dat),
    list(integer(0), integer(0), integer(0))
  )
})

