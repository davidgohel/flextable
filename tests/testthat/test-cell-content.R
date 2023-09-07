context("cell content")

library(utils)
library(xml2)
library(officer)
library(rmarkdown)


test_that("void works as expected", {
  ftab <- flextable(head(mtcars))
  ftab <- void(ftab, part = "all")
  expect_true(all(flextable:::fortify_run(ftab)$txt %in% ""))
})

z <-
  structure(
    list(
      name = c("Matthieu Guillou-Poulain", "Noémi Pasquier d'Vaillant", "Honoré L'Delannoy", "Alice L'Bonneau", "Adrien Dupuy"),
      birthday = structure(c(25463, 7642, 13950, 23805, 21243), class = "Date"),
      n_children = c(4, 4, 4, 4, 2),
      weight = c(83.6459598876536, 61.8819103203714, NA, 52.6329895108938, 53.5817482229322),
      height = c(163.589849524116, 171.920463847195, 169.474969328653, 164.460310102575, 167.755981621553),
      n_peanuts = c(821107L, 774581L, 721301L, 1116933L, 1009038L),
      eye_color = structure(c(2L, 1L, 1L, 1L, 1L), .Label = c("dark", "green"), class = "factor")
    ),
    row.names = c(NA, -5L), class = "data.frame"
  )
z$timestamp <- as.POSIXct("2011-01-01 09:09:09")

test_that("flextable_defaults values for cell content", {
  set_flextable_defaults(
    decimal.mark = ",", big.mark = " ", digits = 1, na_str = "NA",
    fmt_date = "%d %m %Y", fmt_datetime = "%d/%m/%Y %H:%M:%S"
  )

  ft <- flextable(z)
  expected <-
    c(
      "name", "birthday", "n_children", "weight", "height", "n_peanuts",
      "eye_color", "timestamp", "Matthieu Guillou-Poulain", "19 09 2039",
      "4", "83,64596", "163,5898", "821 107", "green", "01/01/2011 09:09:09",
      "Noémi Pasquier d'Vaillant", "04 12 1990", "4", "61,88191",
      "171,9205", "774 581", "dark", "01/01/2011 09:09:09", "Honoré L'Delannoy",
      "12 03 2008", "4", "NA", "169,4750", "721 301", "dark", "01/01/2011 09:09:09",
      "Alice L'Bonneau", "06 03 2035", "4", "52,63299", "164,4603",
      "1 116 933", "dark", "01/01/2011 09:09:09", "Adrien Dupuy", "29 02 2028",
      "2", "53,58175", "167,7560", "1 009 038", "dark", "01/01/2011 09:09:09"
    )
  expect_equivalent(object = flextable:::fortify_run(ft)$txt, expected)

  init_flextable_defaults()
})

test_that("colformat_* functions", {
  dat <- data.frame(
    letters1 = c("a", "b", "b", "c"),
    letters2 = c("d", "e", "b", "b"),
    number = 1:4 * pi,
    count = as.integer(1:4),
    is_something = c(TRUE, FALSE, TRUE, FALSE),
    dt = as.POSIXct("2011-01-01 09:09:09") - 1:4,
    date = as.Date("2011-02-23") + 1:4,
    stringsAsFactors = FALSE
  )

  ft <- flextable(dat)
  ft <- colformat_char(x = ft, prefix = "-", suffix = "-")
  ft <- colformat_date(x = ft, fmt_date = "%d/%m/%Y", prefix = "-", suffix = "-")
  ft <- colformat_datetime(x = ft, fmt_date = "%d/%m/%Y %H%M%S", prefix = "-", suffix = "-")
  ft <- colformat_double(
    x = ft, big.mark = "", decimal.mark = ",", digits = 3,
    prefix = "-", suffix = "-"
  )
  ft <- colformat_int(x = ft, prefix = "-", suffix = "-")
  ft <- colformat_lgl(x = ft, true = "OUI", false = "NON", prefix = "-", suffix = "-")

  expected <-
    c(
      "letters1", "letters2", "number", "count", "is_something",
      "dt", "date", "-a-", "-d-", "-3,142-", "-1-", "-OUI-", "-01/01/2011 090908-",
      "-24/02/2011-", "-b-", "-e-", "-6,283-", "-2-", "-NON-", "-01/01/2011 090907-",
      "-25/02/2011-", "-b-", "-b-", "-9,425-", "-3-", "-OUI-", "-01/01/2011 090906-",
      "-26/02/2011-", "-c-", "-b-", "-12,566-", "-4-", "-NON-", "-01/01/2011 090905-",
      "-27/02/2011-"
    )
  expect_equivalent(object = flextable:::fortify_run(ft)$txt, expected)

  ft <- colformat_num(x = ft, big.mark = "", decimal.mark = ".", prefix = "+", suffix = "+")
  expected <-
    c(
      "letters1", "letters2", "number", "count", "is_something",
      "dt", "date", "-a-", "-d-", "+3.141593+", "+1+", "-OUI-", "-01/01/2011 090908-",
      "-24/02/2011-", "-b-", "-e-", "+6.283185+", "+2+", "-NON-", "-01/01/2011 090907-",
      "-25/02/2011-", "-b-", "-b-", "+9.424778+", "+3+", "-OUI-", "-01/01/2011 090906-",
      "-26/02/2011-", "-c-", "-b-", "+12.566371+", "+4+", "-NON-",
      "-01/01/2011 090905-", "-27/02/2011-"
    )
  expect_equivalent(object = flextable:::fortify_run(ft)$txt, expected)
})



test_that("append and prepend chunks structure", {
  ftab <- flextable(head(cars, n = 3))
  ftab <- append_chunks(ftab,
    j = 1,
    as_chunk(" Samurai"),
    colorize(as_i(" Shodown"), color = "magenta")
  )

  expect_equal(flextable:::fortify_run(ftab)$txt,
    expected = c(
      "speed", "dist", "4", " Samurai", " Shodown", "2", "4", " Samurai",
      " Shodown", "10", "7", " Samurai", " Shodown", "4"
    )
  )

  ftab <- flextable(head(cars, n = 3))
  ftab <- prepend_chunks(ftab,
    j = 1,
    as_chunk("Samurai"),
    colorize(as_i(" Shodown "), color = "magenta")
  )

  expect_equal(flextable:::fortify_run(ftab)$txt,
    expected = c(
      "speed", "dist", "Samurai", " Shodown ", "4", "2", "Samurai",
      " Shodown ", "4", "10", "Samurai", " Shodown ", "7", "4"
    )
  )
})
