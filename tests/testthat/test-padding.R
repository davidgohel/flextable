context("check paddings")

library(utils)
library(xml2)

test_that("padding overwrite all paddings", {
  ft <- flextable(iris)
  ft <- padding(ft, padding = 5)
  key <- ft$body$styles$pars$get_pr_id_at(i = 1, j = "Sepal.Length")
  pr_par_ <- ft$body$styles$pars$get_fp()[[key]]
  paddings <- pr_par_$padding.bottom + pr_par_$padding.top + pr_par_$padding.left + pr_par_$padding.right
  expect_equal(paddings, 20 )
})

test_that("padding overwrite all paddings but not missing", {
  ft <- flextable(iris)
  ft <- padding(ft, padding = 5, padding.top = 20)
  key <- ft$body$styles$pars$get_pr_id_at(i = 1, j = "Sepal.Length")
  pr_par_ <- ft$body$styles$pars$get_fp()[[key]]
  paddings <- pr_par_$padding.bottom + pr_par_$padding.top + pr_par_$padding.left + pr_par_$padding.right
  expect_equal(paddings, 35 )
})
