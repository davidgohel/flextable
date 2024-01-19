context("check proc_freq")

library(utils)
library(xml2)

p <- structure(list(
  lengths = c(9894L, 104L, 1L, 1L),
  values = c("No", "Yes", NA, NA)
), class = "rle")
o <- structure(list(
  lengths = c(9641L, 252L, 1L, 23L, 81L, 1L, 1L),
  values = c("No", "Yes", NA, "No", "Yes", "No", NA)
), class = "rle")
dat <- data.frame(
  p = inverse.rle(p),
  o = inverse.rle(o)
)


full_dump_txt <-
  c(
    "o", "", "p", "p", "p", "p", "o", "", "No", "Yes", "Missing",
    "Total", "No", "Count", "9,641 (96.4%)", "", "23 (0.2%)", "",
    "1 (0.0%)", "", "9,665 (96.7%)", "", "No", "Mar. pct", " (1)",
    "", "97.4% ; 99.8%", "", "22.1% ; 0.2%", "", "50.0% ; 0.0%",
    "", "", "Yes", "Count", "252 (2.5%)", "", "81 (0.8%)", "", "",
    "", "333 (3.3%)", "", "Yes", "Mar. pct", "", "2.5% ; 75.7%",
    "", "77.9% ; 24.3%", "", "", "", "", "Missing", "Count", "1 (0.0%)",
    "", "", "", "1 (0.0%)", "", "2 (0.0%)", "", "Missing", "Mar. pct",
    "", "0.0% ; 50.0%", "", "", "", "50.0% ; 50.0%", "", "", "Total",
    "Count", "9,894 (98.9%)", "", "104 (1.0%)", "", "2 (0.0%)", "",
    "10,000 (100.0%)", "", " (1)", " Columns and rows percentages",
    "", "", "", "", ""
  )
single_dump_txt <-
  c(
    "o", "Count", "Percent", "No", "9,665", "96.7%", "Yes", "333",
    "3.3%", "Missing", "2", "0.0%", "Total", "10,000", "100.0%"
  )

count_only_dump_txt <-
  c(
    "o", "p", "p", "p", "p", "o", "No", "Yes", "Missing", "Total",
    "No", "9,641", "", "23", "", "1", "", "9,665", "", "Yes", "252",
    "", "81", "", "", "", "333", "", "Missing", "1", "", "", "",
    "1", "", "2", "", "Total", "9,894", "", "104", "", "2", "", "10,000",
    ""
  )

test_that("proc_freq executes without errors", {
  dummy_df <- data.frame(
    values = rep(letters[1:3], each = 2),
    groups = rep(letters[1:3], each = 2),
    stringsAsFactors = FALSE
  )
  ft <- proc_freq(dummy_df, "values", "groups")
  expect_equivalent(class(ft), "flextable")
})

test_that("proc_freq content", {
  ft <- proc_freq(dat, row = "o", col = "p")
  expect_equal(information_data_chunk(ft)$txt, full_dump_txt)
  ft <- proc_freq(dat, row = "o")
  expect_equal(information_data_chunk(ft)$txt, single_dump_txt)

  ft <- proc_freq(dat,
    row = "o", col = "p",
    include.table_percent = FALSE,
    include.row_percent = FALSE,
    include.column_percent = FALSE
  )
  expect_equal(information_data_chunk(ft)$txt, count_only_dump_txt)

  expect_error(proc_freq(dat))
})
