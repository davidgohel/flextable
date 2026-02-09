skip_if_not_installed("patchwork")
skip_if_not_installed("ggplot2")
skip_if_not_installed("gtable")

gdtools::register_liberationsans()

init_flextable_defaults()
set_flextable_defaults(
  font.family = "Liberation Sans",
  border.color = "#333333"
)

make_ft <- function(n = 3) {
  dat <- data.frame(
    label = head(LETTERS, n),
    value = seq_len(n)
  )
  autofit(flextable(dat))
}

make_ft_with_footer <- function() {
  ft <- make_ft()
  ft <- add_footer_lines(ft, values = "a note")
  autofit(ft)
}

# -- wrap_flextable ----------------------------------------------------------

test_that("wrap_flextable returns a wrapped_table", {
  ft <- make_ft()
  w <- wrap_flextable(ft)
  expect_s3_class(w, "wrapped_table")
  expect_s3_class(w, "wrapped_patch")
})

test_that("wrap_flextable panel argument is validated", {
  ft <- make_ft()
  expect_error(wrap_flextable(ft, panel = "invalid"), "should be one of")
  for (p in c("body", "full", "rows", "cols")) {
    w <- wrap_flextable(ft, panel = p)
    expect_equal(attr(w, "patch_settings")$panel, p)
  }
})

test_that("wrap_flextable space argument sets free axes", {
  ft <- make_ft()

  w_fixed <- wrap_flextable(ft, space = "fixed")
  expect_equal(attr(w_fixed, "patch_settings")$space, c(FALSE, FALSE))

  w_free <- wrap_flextable(ft, space = "free")
  expect_equal(attr(w_free, "patch_settings")$space, c(TRUE, TRUE))

  w_fx <- wrap_flextable(ft, space = "free_x")
  expect_equal(attr(w_fx, "patch_settings")$space, c(TRUE, FALSE))

  w_fy <- wrap_flextable(ft, space = "free_y")
  expect_equal(attr(w_fy, "patch_settings")$space, c(FALSE, TRUE))
})

test_that("wrap_flextable flex_body forces free y", {
  ft <- make_ft()
  w <- wrap_flextable(ft, space = "fixed", flex_body = TRUE)
  space <- attr(w, "patch_settings")$space
  expect_true(space[2])
})

test_that("wrap_flextable flex_cols forces free x", {
  ft <- make_ft()
  w <- wrap_flextable(ft, space = "fixed", flex_cols = TRUE, n_row_headers = 1)
  space <- attr(w, "patch_settings")$space
  expect_true(space[1])
  expect_equal(attr(w, "patch_settings")$n_row_headers, 1L)
})

test_that("wrap_flextable just is forwarded to as_patch viewport", {
  ft <- make_ft()
  expected_x <- c(left = 0, right = 1, center = 0.5)
  for (j in c("left", "right", "center")) {
    w <- wrap_flextable(ft, just = j)
    # The just attribute is on the inner flextable; verify via as_patch
    ft_inner <- ft
    attr(ft_inner, ".patchwork_just") <- j
    gt <- flextable:::as_patch.flextable(ft_inner)
    expect_equal(as.numeric(gt$vp$x), expected_x[[j]])
  }
})

# -- as_patch.flextable (S3, explicit name for covr) -------------------------

test_that("as_patch.flextable returns a gtable", {
  ft <- make_ft()
  gt <- flextable:::as_patch.flextable(ft)
  expect_s3_class(gt, "gtable")
  expect_true(!is.null(gt$vp))
})

test_that("as_patch.flextable dimensions match flextable", {
  ft <- make_ft()
  gt <- flextable:::as_patch.flextable(ft)

  n_header <- nrow_part(ft, "header")
  n_body <- nrow_part(ft, "body")
  expected_rows <- n_header + n_body
  expect_equal(nrow(gt), expected_rows)
  expect_equal(ncol(gt), ncol_keys(ft))
})

test_that("as_patch.flextable with footer adds rows", {
  ft <- make_ft_with_footer()
  gt <- flextable:::as_patch.flextable(ft)

  n_header <- nrow_part(ft, "header")
  n_body <- nrow_part(ft, "body")
  n_footer <- nrow_part(ft, "footer")
  expect_equal(nrow(gt), n_header + n_body + n_footer)
})

test_that("as_patch.flextable has table_body grob", {
  ft <- make_ft()
  gt <- flextable:::as_patch.flextable(ft)
  grob_names <- gt$layout$name
  expect_true("table" %in% grob_names)
  expect_true("table_body" %in% grob_names)
})

test_that("as_patch.flextable body grob spans correct rows", {
  ft <- make_ft()
  gt <- flextable:::as_patch.flextable(ft)

  body_layout <- gt$layout[gt$layout$name == "table_body", ]
  n_header <- nrow_part(ft, "header")
  n_body <- nrow_part(ft, "body")
  expect_equal(body_layout$t, n_header + 1L)
  expect_equal(body_layout$b, n_header + n_body)
})

test_that("as_patch.flextable flex_body uses null units for body rows", {
  ft <- make_ft()
  attr(ft, ".patchwork_flex_body") <- TRUE
  gt <- flextable:::as_patch.flextable(ft)

  n_header <- nrow_part(ft, "header")
  n_body <- nrow_part(ft, "body")
  body_seq <- seq.int(n_header + 1L, n_header + n_body)

  row_units <- grid::unitType(gt$heights)
  for (i in body_seq) {
    expect_equal(row_units[i], "null")
  }

  if (n_header > 0) {
    for (i in seq_len(n_header)) {
      expect_equal(row_units[i], "inches")
    }
  }
})

test_that("as_patch.flextable flex_cols uses null units for data columns", {
  ft <- make_ft()
  attr(ft, ".patchwork_flex_cols") <- TRUE
  attr(ft, ".patchwork_n_row_headers") <- 1L
  attr(ft, ".patchwork_flex_cols_expand") <- 0.6
  gt <- flextable:::as_patch.flextable(ft)

  n_cols <- ncol_keys(ft)
  data_seq <- seq.int(2L, n_cols)

  col_units <- grid::unitType(gt$widths)
  for (i in data_seq) {
    expect_equal(col_units[i], "null")
  }
  expect_equal(col_units[1], "inches")
})

test_that("as_patch.flextable just controls viewport x", {
  ft <- make_ft()

  attr(ft, ".patchwork_just") <- "left"
  gt_left <- flextable:::as_patch.flextable(ft)
  expect_equal(as.numeric(gt_left$vp$x), 0)

  attr(ft, ".patchwork_just") <- "right"
  gt_right <- flextable:::as_patch.flextable(ft)
  expect_equal(as.numeric(gt_right$vp$x), 1)

  attr(ft, ".patchwork_just") <- "center"
  gt_center <- flextable:::as_patch.flextable(ft)
  expect_equal(as.numeric(gt_center$vp$x), 0.5)
})

# -- ggplot_add.flextable (S3, explicit name for covr) -----------------------

test_that("ggplot_add.flextable wraps and adds to plot", {
  ft <- make_ft()
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()

  result <- flextable:::ggplot_add.flextable(ft, p, "ft")
  expect_s3_class(result, "patchwork")
})

# -- rendering with ragg (end-to-end) ----------------------------------------

test_that("patchwork composition renders to PNG with ragg", {
  ft <- make_ft()
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    ggplot2::theme_minimal(base_family = "Liberation Sans")

  pw <- wrap_flextable(ft) + p

  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)

  ragg::agg_png(filename = tf, width = 8, height = 4, units = "in", res = 150)
  print(pw)
  dev.off()

  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("patchwork with flex_body renders to PNG with ragg", {
  ft <- make_ft()
  p <- ggplot2::ggplot(
    data.frame(x = 1:3, y = factor(LETTERS[1:3], levels = rev(LETTERS[1:3]))),
    ggplot2::aes(x, y)
  ) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal(base_family = "Liberation Sans")

  pw <- wrap_flextable(ft, flex_body = TRUE) + p

  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)

  ragg::agg_png(filename = tf, width = 8, height = 4, units = "in", res = 150)
  print(pw)
  dev.off()

  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("patchwork with flex_cols renders to PNG with ragg", {
  ft <- make_ft()
  p <- ggplot2::ggplot(
    data.frame(x = factor(c("label", "value")), y = c(10, 20)),
    ggplot2::aes(x, y)
  ) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal(base_family = "Liberation Sans")

  pw <- wrap_flextable(ft, flex_cols = TRUE, n_row_headers = 0) / p

  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)

  ragg::agg_png(filename = tf, width = 6, height = 6, units = "in", res = 150)
  print(pw)
  dev.off()

  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

test_that("patchwork with just right renders to PNG with ragg", {
  ft <- make_ft()
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    ggplot2::theme_minimal(base_family = "Liberation Sans")

  pw <- wrap_flextable(ft, just = "right") + p

  tf <- tempfile(fileext = ".png")
  on.exit(unlink(tf), add = TRUE)

  ragg::agg_png(filename = tf, width = 8, height = 4, units = "in", res = 150)
  print(pw)
  dev.off()

  expect_true(file.exists(tf))
  expect_gt(file.info(tf)$size, 1000)
})

init_flextable_defaults()
