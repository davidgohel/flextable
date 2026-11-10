test_that("dimensions are valid", {
  dummy_df <- data.frame(
    my_col = rep(letters[1:3], each = 2),
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  dims <- dim(ft)
  expect_length(dims$widths, 1)
  expect_length(dims$heights, 7)

  ft <- add_header(ft, my_col = "second row header")
  dims <- dim(ft)
  expect_length(dims$widths, 1)
  expect_length(dims$heights, 8)

  ft <- height_all(ft, height = .15, part = "all")
  dims <- dim(ft)
  expect_true(all(is.finite(dims$widths)))
  expect_true(all(is.finite(dims$heights)))

  typology <- data.frame(
    col_keys = c(
      "Sepal.Length",
      "Sepal.Width",
      "Petal.Length",
      "Petal.Width",
      "Species"
    ),
    what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
    measure = c("Length", "Width", "Length", "Width", "Species"),
    stringsAsFactors = FALSE
  )
  ft <- flextable(head(iris))
  ft <- set_header_df(ft, mapping = typology, key = "col_keys")
  dims <- dim(ft)
  expect_length(dims$widths, 5)
  expect_length(dims$heights, 8)
})

test_that("autofit and dim_pretty usage", {
  typology <- data.frame(
    col_keys = c(
      "Sepal.Length",
      "Sepal.Width",
      "Petal.Length",
      "Petal.Width",
      "Species"
    ),
    what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
    measure = c("Length", "Width", "Length", "Width", "Species"),
    stringsAsFactors = FALSE
  )
  ft <- flextable(head(iris))
  ft <- set_header_df(ft, mapping = typology, key = "col_keys")
  ft <- autofit(ft, add_w = 0.0, add_h = 0.0)
  dims <- dim(ft)
  expect_true(all(is.finite(dims$widths)))
  expect_true(all(is.finite(dims$heights)))

  dims <- dim_pretty(ft)
  expect_true(all(is.finite(dims$widths)))
  expect_true(all(is.finite(dims$heights)))
})


test_that("height usage", {
  dummy_df <- data.frame(
    my_col1 = rep(letters[1:3], each = 2),
    my_col2 = rep(letters[4:6], each = 2),
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  dims <- dim_pretty(ft)
  expect_silent({
    ft <- height_all(ft, height = .25, part = "all")
  })
  expect_error({
    ft <- height(ft, height = dims$heights[-1], part = "all")
  })
  expect_error({
    ft <- height(ft, height = 1:3, part = "body")
  })
})

test_that("width usage", {
  dummy_df <- data.frame(
    my_col1 = rep(letters[1:3], each = 2),
    my_col2 = rep(letters[4:6], each = 2),
    stringsAsFactors = FALSE
  )
  ft <- flextable(dummy_df)
  expect_silent(width(ft, j = "my_col1", width = 1))
  expect_silent(width(ft, j = 1:2, width = .7))
  expect_error(width(ft, j = 1:2, width = rep(.7, 3)))
})

test_that("autofit with horizontal spans", {
  dat <-
    data.frame(
      `Header should span 2 cols` = c("Whoooo", "Whaaaat", "Whyyyyy"),
      dummy_title = c("Whoooo", "Whaaaat", "Whyyyyy"),
      check.names = FALSE
    )

  ft <- flextable(dat)
  ft <- merge_at(
    x = ft,
    i = 1,
    j = 1:2,
    part = "header"
  )

  dims_divided <- dim_pretty(ft, hspans = "divided")
  dims_included <- dim_pretty(ft, hspans = "included")
  expect_gt(dims_included$widths[1], dims_divided$widths[1])

  dims_none <- dim_pretty(ft, hspans = "none")
  dims_included_no_header <- dim_pretty(ft, hspans = "included", part = "body")
  expect_equal(dims_none$widths, dims_included_no_header$widths)
})

test_that("HTML table width when autofit layout", {
  x <- data.frame(
    x = c(
      "[-0.36, -0.01]",
      "[0, 0]",
      "000, 000",
      "0000 0000"
    )
  )

  ft <- flextable(x)
  ft <- set_table_properties(
    x = ft,
    layout = "autofit"
  )
  str <- flextable:::gen_raw_html(ft)
  expect_false(grepl("table-layout:auto;width:", str, fixed = TRUE))

  ft <- set_table_properties(
    x = ft,
    layout = "autofit",
    width = .1
  )
  str <- flextable:::gen_raw_html(x = ft)
  expect_true(grepl("table-layout:auto;width:", str, fixed = TRUE))
})

test_that("sizes given to chunks stay with their cell", {
  # sizes are stored per chunk and were applied to the wrong cells when the
  # chunks of a table with several columns were reordered
  df <- data.frame(a = c("x", "y"), b = c("u", "v"))
  ft <- flextable(df)
  ft <- mk_par(
    ft,
    j = "b",
    value = as_paragraph(
      as_equation(b, width = c(2, 0.5), height = c(0.2, 1))
    )
  )
  ft <- padding(ft, padding = 0, part = "all")
  dims <- dim_pretty(ft)
  # column b is as wide as its widest equation, column a is not
  expect_equal(dims$widths[2], 2)
  expect_lt(dims$widths[1], 0.5)
  # the second row is as high as its equation (plus its border)
  expect_equal(dims$heights[3], 1, tolerance = 0.02)
  expect_lt(dims$heights[2], 1)
})
