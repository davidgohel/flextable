test_that("gt object can be converted to flextable", {
  skip_if_not_installed("gt")

  d <- head(mtcars)
  gt_simple <- gt::gt(d)
  ft_simple <- as_flextable(gt_simple)

  expect_true(inherits(ft_simple, "flextable"))
  expect_equal(nrow(ft_simple$body$dataset), 6)

  gt_spanned <- gt::gt(head(mtcars, 2))
  gt_spanned <- gt::tab_spanner(gt_spanned, label = "Engine", columns = c("cyl", "disp"))
  ft_spanned <- as_flextable(gt_spanned)
  expect_true(inherits(ft_spanned, "flextable"))
})
