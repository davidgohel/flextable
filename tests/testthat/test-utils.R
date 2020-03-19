test_that("Adds label for cross referencing with bookdown", {
  expect_identical(ref_label(), "")
  knitr::opts_current$set(label = 'foo')
  expect_identical(ref_label(), "(\\#tab:foo)")
})

test_that("Check if a reference label is explicitly specified", {
  expect_false(has_label('foo'))
  expect_true(has_label('(\\#tab:foo)'))
  expect_true(has_label('(\\#tab:fo-o)'))
})
