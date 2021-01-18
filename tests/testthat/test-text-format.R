context("check cell content")

# library(charlatan)
# n <- 10
# dat <- data.frame(
#   name = ch_name(n = n, locale = "fr_FR"),
#   birthday = as.Date(as.POSIXct(unlist(ch_date_time(n = n)), origin = "1970-01-01")) + 20*365,
#   n_children = ch_integer(n = n, min = 0, max = 4),
#   weight = runif(n = n, min = 50, max = 90),
#   height = rnorm(n = n, mean = 170, sd = 5),
#   n_peanuts = as.integer(ch_integer(n = n, min = 500000, max = 1225193)),
#   eye_color = as.factor(sample(c("blue", "green", "dark"), prob = c(.15, .3, .55), size = n, replace = TRUE)),
#   stringsAsFactors = FALSE
# )
# dat[2:4, 4] <- NA_real_
# dat$name <- stringi::stri_trans_general(dat$name, "latin-ascii")
# dput(dat)

dat <- structure(list(name = c("Paul Maillet L'Levy", "Laurent-Noel Perrier",
"Josephine Gay L'Barbe", "Danielle Fernandez", "Margot Reynaud",
"Pauline Letellier-Evrard", "Dorothee Guillaume", "Thibaut Riou-Joubert",
"Frederic Neveu L'Baudry", "Jules L'Seguin"), birthday = structure(c(19044,
8255, 20452, 20618, 23202, 19945, 13216, 9387, 13351, 14256), class = "Date"),
n_children = c(4, 4, 4, 2, 0, 1, 3, 2, 0, 4), weight = c(86.4220319781452,
NA, NA, NA, 80.5819069221616, 56.9144685473293, 65.6374617107213,
66.1636104527861, 81.8135797139257, 65.3504419513047), height = c(174.218385674984,
165.908258780227, 163.437738845983, 169.655977591364, 172.136157002837,
170.46386294309, 160.959774430904, 167.704730753585, 170.85103552782,
168.729435038402), n_peanuts = c(722672L, 859897L, 953004L,
1057745L, 957027L, 803071L, 1045133L, 669134L, 841065L, 801122L
), eye_color = structure(c(2L, 2L, 1L, 1L, 2L, 2L, 3L, 1L,
2L, 2L), .Label = c("blue", "dark", "green"), class = "factor")), row.names = c(NA,
-10L), class = "data.frame")

content <- structure(c("Paul Maillet L'Levy", "Laurent-Noel Perrier", "Josephine Gay L'Barbe",
"Danielle Fernandez", "Margot Reynaud", "Pauline Letellier-Evrard",
"Dorothee Guillaume", "Thibaut Riou-Joubert", "Frederic Neveu L'Baudry",
"Jules L'Seguin", "21/02/2022", "08/08/1992", "30/12/2025", "14/06/2026",
"11/07/2033", "10/08/2024", "09/03/2006", "14/09/1995", "22/07/2006",
"12/01/2009", "4,00", "4,00", "4,00", "2,00", "0,00", "1,00",
"3,00", "2,00", "0,00", "4,00", "86,42", "na", "na", "na", "80,58",
"56,91", "65,64", "66,16", "81,81", "65,35", "174,22", "165,91",
"163,44", "169,66", "172,14", "170,46", "160,96", "167,70", "170,85",
"168,73", "722 672", "859 897", "953 004", "1 057 745", "957 027",
"803 071", "1 045 133", "669 134", "841 065", "801 122", "color: dark",
"color: dark", "color: blue", "color: blue", "color: dark", "color: dark",
"color: green", "color: blue", "color: dark", "color: dark"), .Dim = c(10L,
7L))

content_matrix <- function(x){
  zz <- x$body$content$content
  matrix(sapply(zz$data, function(x) {
    paste(x$txt, collapse = "")
    }), nrow = nrow(x$body$dataset))
}

test_that("colformat functions have the expected effect", {
  ft <- flextable(dat)
  ft <- colformat_num(x = ft, big.mark = " ", decimal.mark = ",", digits = 2, na_str = "na")
  ft <- colformat_int(x = ft, big.mark = " ")
  ft <- colformat_char(x = ft, j = "eye_color", prefix = "color: ")
  ft <- colformat_date(x = ft, fmt_date = "%d/%m/%Y")
  zz <- content_matrix(ft)

  expect_equal(zz, content)
})

content <- structure(c("Paul Maillet L'Levy", "Laurent-Noel Perrier", "Josephine Gay L'Barbe",
"Danielle Fernandez", "Margot Reynaud", "Pauline Letellier-Evrard",
"Dorothee Guillaume", "Thibaut Riou-Joubert", "Frederic Neveu L'Baudry",
"Jules L'Seguin", "test 19,044.0 test", "test 8,255.0 test",
"test 20,452.0 test", "test 20,618.0 test", "test 23,202.0 test",
"test 19,945.0 test", "test 13,216.0 test", "test 9,387.0 test",
"test 13,351.0 test", "test 14,256.0 test", "test 4.0 test",
"test 4.0 test", "test 4.0 test", "test 2.0 test", "test 0.0 test",
"test 1.0 test", "test 3.0 test", "test 2.0 test", "test 0.0 test",
"test 4.0 test", "test 86.4 test", "", "", "", "test 80.6 test",
"test 56.9 test", "test 65.6 test", "test 66.2 test", "test 81.8 test",
"test 65.4 test", "test 174.2 test", "test 165.9 test", "test 163.4 test",
"test 169.7 test", "test 172.1 test", "test 170.5 test", "test 161.0 test",
"test 167.7 test", "test 170.9 test", "test 168.7 test", "722,672",
"859,897", "953,004", "1,057,745", "957,027", "803,071", "1,045,133",
"669,134", "841,065", "801,122", "dark", "dark", "blue", "blue",
"dark", "dark", "green", "blue", "dark", "dark"), .Dim = c(10L, 7L))

test_that("suffix and prefix is working", {
  ft <- flextable(dat)
  ft <- colformat_double(x = ft, prefix = "test ", suffix = " test")
  zz <- content_matrix(ft)
  expect_equal(zz, content)
})
