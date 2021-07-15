test_that("Adds label for cross referencing with bookdown", {
  expect_identical(ref_label(), "")
  knitr::opts_current$set(label = 'foo')
  expect_identical(ref_label(), "(\\#tab:foo)")
})

