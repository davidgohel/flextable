ft <- flextable(iris)

test_that("print as log", {
  expect_output(print(ft, preview = "log"), "a flextable object")
  expect_output(print(ft, preview = "log"), "header has 1 row")
  expect_output(print(ft, preview = "log"), "body has 150 row")
})


test_that("data selectors", {
  ft <- flextable(
    data = iris,
    col_keys = c("ouch", "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species", "blop")
  )

  expect_equal(
    flextable:::as_col_keys(ft$body, 2, blanks = ft$blanks),
    "Sepal.Width"
  )

  expect_equal(
    flextable:::as_col_keys(ft$body, -5, blanks = ft$blanks),
    c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")
  )

  expect_equal(
    flextable:::as_col_keys(ft$body, c(1, 2), blanks = ft$blanks),
    c("Sepal.Length", "Sepal.Width")
  )

  expect_equal(
    flextable:::as_col_keys(ft$body, NULL, blanks = ft$blanks),
    colnames(iris)
  )

  expect_equal(
    flextable:::as_col_keys(ft$body, c(TRUE, FALSE, TRUE, FALSE, TRUE),
      blanks = ft$blanks
    ),
    c("Sepal.Length", "Petal.Length", "Species")
  )

  expect_warning(
    flextable:::as_col_keys(ft$body, "Julio-Iglesias", blanks = ft$blanks)
  )
})

test_that("selection and merge_v", {
  ft <- flextable(
    data = iris[98:103, ],
    col_keys = c("aaa", "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")
  )
  ft <- theme_box(ft)
  ft <- merge_v(ft, target = "aaa", j = "Species")

  expect_equal(
    ft$body$spans$columns[, 1],
    c(3L, 0L, 0L, 3L, 0L, 0L)
  )

  expect_warning(merge_v(ft, target = "aaa", j = "zzz"))
  expect_error(merge_v(ft, target = "Species", j = "Sepal.Width"))
})

test_that("selection and colors", {
  colourer <- function(z) {
    x <- rep("pink", length(z))
    x[is.na(z)] <- "#999999"
    w_avg <- which(z < mean(z, na.rm = TRUE))
    x[w_avg] <- "cyan"
    x
  }

  dat <- iris[98:103, ]
  dat[1, 1] <- NA
  dat[2, 2] <- NA
  dat[3, 3] <- NA
  dat[4, 4] <- NA
  ft <- flextable(data = dat)
  ft <- theme_box(ft)
  ft <- bg(ft, j = ~ . - Species, bg = colourer)

  expected_values <- c(
    "#999999", "cyan", "cyan", "pink", "cyan", "pink",
    "cyan", "#999999", "cyan", "pink", "cyan", "pink", "cyan", "cyan",
    "#999999", "pink", "pink", "pink", "cyan", "cyan", "cyan", "#999999",
    "pink", "pink", "transparent", "transparent", "transparent",
    "transparent", "transparent", "transparent"
  )
  bg_values <- as.vector(ft$body$styles$cells$background.color$data)
  expect_equal(bg_values, expected_values)

  ft <- bg(ft,
    source = "Species", j = "Sepal.Length",
    bg = function(z) {
      x <- rep("red", length(z))
      x[is.na(z)] <- "#999999"
      w_ver <- which(z %in% "versicolor")
      x[w_ver] <- "blue"
      x
    }
  )
  bg_values <- as.vector(ft$body$styles$cells$background.color$data[, 1])
  expect_equal(bg_values, rep(c("blue", "red"), each = 3))
})
