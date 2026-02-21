test_that("identical values within columns are merged", {
  dummy_df <- data.frame(values = rep(letters[1:3], each = 2), stringsAsFactors = FALSE)
  ft <- flextable(dummy_df)
  ft <- merge_v(x = ft, j = "values")
  expect_equal(ft$body$spans$columns[, 1], rep(c(2, 0), 3), ignore_attr = TRUE)
})

test_that("identical values within rows are merged", {
  dummy_df <- data.frame(
    col1 = letters,
    col2 = letters,
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  ft <- merge_h(x = ft)
  ref <- matrix(c(rep(2, 26), rep(0, 26)), ncol = 2)
  expect_equal(ft$body$spans$rows, ref, ignore_attr = TRUE)
})


test_that("span at", {
  dummy_df <- data.frame(
    col1 = letters,
    col2 = letters,
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  ft <- merge_at(x = ft, i = 1:4, j = 1:2)
  ref <- matrix(c(rep(2, 4), rep(1, 22), rep(0, 4), rep(1, 22)), ncol = 2)
  expect_equal(ft$body$spans$rows, ref, ignore_attr = TRUE)
  ref <- matrix(c(4, rep(0, 3), rep(1, 22), 4, rep(0, 3), rep(1, 22)), ncol = 2)
  expect_equal(ft$body$spans$columns, ref, ignore_attr = TRUE)
})


test_that("merged cells can be un-merged", {
  dummy_df <- data.frame(
    col1 = rep("a", 5),
    col2 = rep("a", 5),
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  ft <- merge_h(x = ft)
  expect_true(all(ft$body$spans$rows[, 1] == 2))
  ft <- merge_none(ft)
  expect_true(all(ft$body$spans$rows == 1))
  ft <- merge_v(x = ft)
  expect_true(all(ft$body$spans$columns[1, ] == 5))
  expect_true(all(ft$body$spans$columns[-1, ] == 0))
  ft <- merge_none(ft)
  expect_true(all(ft$body$spans$columns == 1))
})


test_that("delete_rows preserves vertical spans when deletion does not break them", {
  ft <- flextable(data.frame(
    col1 = rep(letters[1:3], each = 2),
    col2 = 1:6,
    stringsAsFactors = FALSE
  ))
  ft <- merge_v(ft, j = "col1")
  expect_equal(ft$body$spans$columns[, 1], c(2, 0, 2, 0, 2, 0), ignore_attr = TRUE)

  # delete rows 5:6 (the "c" group) — no span is broken
  ft2 <- delete_rows(ft, i = 5:6)
  expect_equal(ft2$body$spans$columns[, 1], c(2, 0, 2, 0), ignore_attr = TRUE)
})

test_that("delete_rows resets spans when deletion breaks a vertical span", {
  ft <- flextable(data.frame(
    col1 = rep(letters[1:3], each = 2),
    col2 = 1:6,
    stringsAsFactors = FALSE
  ))
  ft <- merge_v(ft, j = "col1")

  # delete row 3 — breaks the "b" group (rows 3:4)
  ft2 <- delete_rows(ft, i = 3)
  expect_true(all(ft2$body$spans$columns == 1))
  expect_true(all(ft2$body$spans$rows == 1))
})

test_that("delete_columns preserves horizontal spans when deletion does not break them", {
  ft <- flextable(data.frame(
    col1 = c("x", "y"),
    col2 = c("x", "y"),
    col3 = c("a", "b"),
    stringsAsFactors = FALSE
  ))
  ft <- merge_h(ft)
  expect_equal(ft$body$spans$rows[1, ], c(2, 0, 1), ignore_attr = TRUE)

  # delete col3 — no horizontal span is broken
  ft2 <- delete_columns(ft, j = "col3")
  expect_equal(ft2$body$spans$rows[1, ], c(2, 0), ignore_attr = TRUE)
})

test_that("delete_columns resets spans when deletion breaks a horizontal span", {
  ft <- flextable(data.frame(
    col1 = c("x", "y"),
    col2 = c("x", "y"),
    col3 = c("a", "b"),
    stringsAsFactors = FALSE
  ))
  ft <- merge_h(ft)

  # delete col1 — breaks the horizontal span col1+col2
  ft2 <- delete_columns(ft, j = "col1")
  expect_true(all(ft2$body$spans$columns == 1))
  expect_true(all(ft2$body$spans$rows == 1))
})

