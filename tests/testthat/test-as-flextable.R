context("check as_flextable")

test_that("data.frame", {
  dummy_df <- data.frame(
    A = rep(letters[1:3], each = 2),
    B = seq(0, 1, length = 6)
  )
  ft <- as_flextable(dummy_df)
  expect_equal(flextable:::fortify_run(ft)$txt,
               c("A", "B", "character", "numeric", "a", "0.0", "a", "0.2",
                 "b", "0.4", "b", "0.6", "c", "0.8", "c", "1.0", "n: 6", "n: 6"))
  ft <- as_flextable(dummy_df[1,])
  expect_equal(flextable:::fortify_run(ft)$txt,
               c("A", "<br>", "character", "a", "B", "<br>", "numeric", "0"))
})

