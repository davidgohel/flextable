test_that("rtables pagination keeps the smallest labelled groups together", {
  skip_if_not_installed("rtables")
  skip_if_not_installed("formatters")

  df <- data.frame(
    param = factor(rep(c("ALT", "CK"), each = 6)),
    visit = factor(rep(rep(c("BASELINE", "WEEK 1", "WEEK 2"), each = 2), 2)),
    x = seq_len(12)
  )
  lyt <- rtables::basic_table() |>
    rtables::analyze(
      "x",
      afun = function(x) rtables::in_rows("All values" = length(x)),
      table_names = "total"
    ) |>
    rtables::split_rows_by("param") |>
    rtables::split_rows_by("visit") |>
    rtables::analyze(
      "x",
      afun = function(x) rtables::in_rows(n = length(x), Mean = mean(x))
    )
  tt <- rtables::build_table(lyt, df)

  ft <- as_flextable(tt)
  keep <- ft$body$styles$pars$keep_with_next$data[, 1]
  # body rows:
  # 1 All values, 2 ALT, 3 BASELINE, 4-5 n/Mean, 6 WEEK 1, 7-8,
  # 9 WEEK 2, 10-11, 12 CK, 13 BASELINE, ..., 21
  # a group per visit, the first one also holds the parameter label;
  # the data row before the first label row is not in any group
  expect_identical(which(!keep), c(1L, 5L, 8L, 11L, 15L, 18L, 21L))
})
