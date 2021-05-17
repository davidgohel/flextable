context("latex table structure")

test_that("white spaces are protected", {
  ft <- flextable(data.frame(x = ""))
  ft <- delete_part(ft, part = "header")
  ft <- mk_par(ft, 1, 1, as_paragraph("foo", " ", "bar"))
  str <- flextable:::latex_str(ft)
  expect_true(grepl("{\\ }", str, fixed = TRUE))
})

