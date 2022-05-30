context("check widths and heights")

library(utils)
library(xml2)

test_that("dimensions are valid", {
  dummy_df <- data.frame( my_col = rep(letters[1:3], each = 2), stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  dims <- dim(ft)
  expect_length(dims$widths, 1 )
  expect_length(dims$heights, 7 )

  ft <- add_header(ft, my_col = "second row header")
  dims <- dim(ft)
  expect_length(dims$widths, 1 )
  expect_length(dims$heights, 8 )

  ft <- height_all(ft, height = .15, part = "all")
  dims <- dim(ft)
  expect_true(all( is.finite(dims$widths)))
  expect_true(all( is.finite(dims$heights)))

  typology <- data.frame(
    col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species" ),
    what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
    measure = c("Length", "Width", "Length", "Width", "Species"),
    stringsAsFactors = FALSE )
  ft <- flextable( head( iris ) )
  ft <- set_header_df(ft, mapping = typology, key = "col_keys" )
  dims <- dim(ft)
  expect_length(dims$widths, 5 )
  expect_length(dims$heights, 8 )
})

test_that("autofit and dim_pretty usage", {
  typology <- data.frame(
    col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species" ),
    what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
    measure = c("Length", "Width", "Length", "Width", "Species"),
    stringsAsFactors = FALSE )
  ft <- flextable( head( iris ) )
  ft <- set_header_df(ft, mapping = typology, key = "col_keys" )
  ft <- autofit( ft, add_w = 0.0, add_h = 0.0 )
  dims <- dim(ft)
  expect_true(all( is.finite(dims$widths)))
  expect_true(all( is.finite(dims$heights)))

  dims <- dim_pretty(ft)
  expect_true(all( is.finite(dims$widths)))
  expect_true(all( is.finite(dims$heights)))
})


test_that("height usage", {
  dummy_df <- data.frame( my_col1 = rep(letters[1:3], each = 2),
                          my_col2 = rep(letters[4:6], each = 2),
                          stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  dims <- dim_pretty(ft)
  expect_silent({ft <- height_all(ft, height = .25, part = "all") })
  expect_error({ft <- height(ft, height = dims$heights[-1], part = "all") })
  expect_error({ft <- height(ft, height = 1:3, part = "body") })
})

test_that("width usage", {
  dummy_df <- data.frame( my_col1 = rep(letters[1:3], each = 2),
                          my_col2 = rep(letters[4:6], each = 2),
                          stringsAsFactors = FALSE )
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
    x = ft, i = 1, j = 1:2,
    part = "header")


  dims_divided <- dim_pretty(ft, hspans = "divided")
  dims_included <- dim_pretty(ft, hspans = "included")
  expect_gt(dims_included$widths[1], dims_divided$widths[1])

  dims_none <- dim_pretty(ft, hspans = "none")
  dims_included_no_header <- dim_pretty(ft, hspans = "included", part = "body")
  expect_equal(dims_none$widths, dims_included_no_header$widths)
})

