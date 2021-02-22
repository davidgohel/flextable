context("cell content")

library(utils)
library(xml2)
library(officer)
library(rmarkdown)


test_that("void works as expected", {
  ftab <- flextable(head(mtcars))
  ftab <- void(ftab, part = "all")
  expect_true(all(flextable:::as_table_text(ftab)$txt %in% ""))
})

z <-
structure(list(
  name = c("Matthieu Guillou-Poulain", "Noémi Pasquier d'Vaillant", "Honoré L'Delannoy", "Alice L'Bonneau", "Adrien Dupuy"),
  birthday = structure(c(25463, 7642, 13950, 23805, 21243), class = "Date"),
  n_children = c(4, 4, 4, 4, 2),
  weight = c(83.6459598876536, 61.8819103203714, NA, 52.6329895108938, 53.5817482229322),
  height = c(163.589849524116,171.920463847195, 169.474969328653, 164.460310102575, 167.755981621553),
  n_peanuts = c(821107L, 774581L, 721301L, 1116933L, 1009038L),
  eye_color = structure(c(2L,1L, 1L, 1L, 1L), .Label = c("dark", "green"), class = "factor")),
  row.names = c(NA,-5L), class = "data.frame")
z$timestamp <- as.POSIXct("2011-01-01 09:09:09")

test_that("flextable_defaults values for cell content", {
  set_flextable_defaults(decimal.mark = ",", big.mark = " ", digits = 1, na_str = "NA",
                         fmt_date = "%d %m %Y", fmt_datetime = "%d/%m/%Y %H:%M:%S")

  ft <- flextable(z)
  expected <-
  c("name", "birthday", "n_children", "weight", "height", "n_peanuts",
    "eye_color", "timestamp", "Matthieu Guillou-Poulain", "Noémi Pasquier d'Vaillant",
    "Honoré L'Delannoy", "Alice L'Bonneau", "Adrien Dupuy", "19 09 2039",
    "04 12 1990", "12 03 2008", "06 03 2035", "29 02 2028", "4",
    "4", "4", "4", "2", "83,64596", "61,88191", "NA", "52,63299",
    "53,58175", "163,5898", "171,9205", "169,4750", "164,4603", "167,7560",
    "821 107", "774 581", "721 301", "1 116 933", "1 009 038", "green",
    "dark", "dark", "dark", "dark", "01/01/2011 09:09:09", "01/01/2011 09:09:09",
    "01/01/2011 09:09:09", "01/01/2011 09:09:09", "01/01/2011 09:09:09"
  )
  expect_equivalent(object = flextable:::as_table_text(ft)$txt, expected)

  init_flextable_defaults()
})

test_that("colformat_* functions", {

  dat <- data.frame(
    letters1 = c("a", "b", "b", "c"),
    letters2 = c("d", "e", "b", "b"),
    number = 1:4*pi,
    count = as.integer(1:4),
    is_something = c(TRUE, FALSE, TRUE, FALSE),
    dt = as.POSIXct("2011-01-01 09:09:09") - 1:4,
    date = as.Date("2011-02-23") + 1:4,
    stringsAsFactors = FALSE )

  ft <- flextable(dat)
  ft <- colformat_char(x = ft, prefix = "-", suffix = "-")
  ft <- colformat_date(x = ft, fmt_date = "%d/%m/%Y", prefix = "-", suffix = "-")
  ft <- colformat_datetime(x = ft, fmt_date = "%d/%m/%Y %H%M%S", prefix = "-", suffix = "-")
  ft <- colformat_double(x = ft, big.mark = "", decimal.mark = ",", digits = 3,
                         prefix = "-", suffix = "-")
  ft <- colformat_int(x = ft, prefix = "-", suffix = "-")
  ft <- colformat_lgl(x = ft, true = "OUI", false = "NON", prefix = "-", suffix = "-")

  expected <-
    c("letters1", "letters2", "number", "count", "is_something",
      "dt", "date", "-a-", "-b-", "-b-", "-c-", "-d-", "-e-", "-b-",
      "-b-", "-3,142-", "-6,283-", "-9,425-", "-12,566-", "-1-", "-2-",
      "-3-", "-4-", "-OUI-", "-NON-", "-OUI-", "-NON-", "-01/01/2011 090908-",
      "-01/01/2011 090907-", "-01/01/2011 090906-", "-01/01/2011 090905-",
      "-24/02/2011-", "-25/02/2011-", "-26/02/2011-", "-27/02/2011-"
    )
  expect_equivalent(object = flextable:::as_table_text(ft)$txt, expected)

  ft <- colformat_num(x = ft, big.mark = "", decimal.mark = ".", prefix = "+", suffix = "+")
  expected <-
    c("letters1", "letters2", "number", "count", "is_something",
    "dt", "date", "-a-", "-b-", "-b-", "-c-", "-d-", "-e-", "-b-",
    "-b-", "+3.141593+", "+6.283185+", "+9.424778+", "+12.566371+",
    "+1+", "+2+", "+3+", "+4+", "-OUI-", "-NON-", "-OUI-", "-NON-",
    "-01/01/2011 090908-", "-01/01/2011 090907-", "-01/01/2011 090906-",
    "-01/01/2011 090905-", "-24/02/2011-", "-25/02/2011-", "-26/02/2011-",
    "-27/02/2011-")
  expect_equivalent(object = flextable:::as_table_text(ft)$txt, expected)
})

