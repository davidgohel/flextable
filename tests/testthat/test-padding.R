context("check paddings")

test_that("padding overwrite all paddings", {
  ft <- flextable(data.frame(a = c("", ""), stringsAsFactors = FALSE))
  ft <- padding(ft, padding = 5)

  new_paddings <- c(
    ft$body$styles$pars$padding.bottom$data[, ],
    ft$body$styles$pars$padding.top$data[, ],
    ft$body$styles$pars$padding.left$data[, ],
    ft$body$styles$pars$padding.right$data[, ]
  )
  new_paddings <- unique(new_paddings)

  expect_equal(new_paddings, 5)
})

test_that("padding overwrite all paddings but not missing", {
  ft <- flextable(iris)
  ft <- padding(ft, padding = 5, padding.top = 20)
  new_paddings <- c(
    ft$body$styles$pars$padding.bottom$data[, ],
    ft$body$styles$pars$padding.top$data[, ],
    ft$body$styles$pars$padding.left$data[, ],
    ft$body$styles$pars$padding.right$data[, ]
  )
  new_paddings <- unique(new_paddings)

  expect_equal(new_paddings, c(5, 20))
})
