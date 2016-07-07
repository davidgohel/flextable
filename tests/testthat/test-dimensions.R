context("check widths and heights")

library(utils)
library(xml2)

test_that("dim is valid", {
  dummy_df <- data.frame( my_col = rep(letters[1:3], each = 2), stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  dims <- dim(ft)
  expect_length(dims$widths, 1 )
  expect_length(dims$heights, 7 )
  ft <- set_header(ft, my_col = list("second row header", "first row header"))
  dims <- dim(ft)
  expect_length(dims$widths, 1 )
  expect_length(dims$heights, 8 )

  ft <- height(ft, height = .15, part = "all")
  dims <- dim(ft)
  expect_true(all( is.finite(dims$widths)))
  expect_true(all( is.finite(dims$heights)))

})

test_that("height usage", {
  dummy_df <- data.frame( my_col1 = rep(letters[1:3], each = 2),
                          my_col2 = rep(letters[4:6], each = 2),
                          stringsAsFactors = FALSE )
  ft <- flextable(dummy_df)
  dims <- optim_dim(ft)
  expect_silent({ft <- height(ft, height = dims$heights, part = "all") })
  expect_error({ft <- height(ft, height = dims$heights[-1], part = "all") })
  expect_silent({ft <- height(ft, height = .25, part = "all") })
  expect_error({ft <- height(ft, height = 1:3, part = "body") })
})


