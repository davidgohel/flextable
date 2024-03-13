context("check as_flextable")

test_that("data.frame", {
  dummy_df <- data.frame(
    A = rep(letters[1:3], each = 2),
    B = seq(0, 1, length = 6)
  )
  ft <- as_flextable(dummy_df)
  expect_equal(
    information_data_chunk(ft)$txt,
    c(
      "A", "B", "character", "numeric", "a", "0.0", "a", "0.2",
      "b", "0.4", "b", "0.6", "c", "0.8", "c", "1.0", "n: 6", "n: 6"
    )
  )
  ft <- as_flextable(dummy_df[1, ])
  expect_equal(
    information_data_chunk(ft)$txt,
    c("A", "<br>", "character", "a", "B", "<br>", "numeric", "0")
  )
})

test_that("grouped_data", {
  my_CO2 <- CO2
  setDT(my_CO2)
  my_CO2$conc <- as.integer(my_CO2$conc)
  data_co2 <- dcast(my_CO2, Treatment + conc ~ Type,
                    value.var = "uptake", fun.aggregate = mean
  )
  expect_silent(
    data_co2 <- as_grouped_data(x = data_co2, groups = c("Treatment"))
  )
  expect_equal(
    data_co2$Treatment[seq_len(2)],
    factor(c("nonchilled", NA), levels = c("nonchilled", "chilled"))
  )
  expect_equal(
    data_co2$Treatment[c(8, 9, 10)],
    factor(c(NA, "chilled", NA), levels = c("nonchilled", "chilled"))
  )

  out_tmp <- data_co2[1, , drop = TRUE]
  expect_equal(attr(out_tmp,"groups"), "Treatment")
  expect_equal(attr(out_tmp,"columns"), c("conc", "Quebec", "Mississippi"))
  expect_equal(unlist(out_tmp, use.names = FALSE), c(1, NA, NA, NA))

  expect_s3_class(data_co2, "grouped_data")

  expect_silent(
    data_co2 <- as_grouped_data(x = data_co2, groups = c("Treatment"), expand_single = TRUE)
  )
  expect_true(all(is.na(unlist(data_co2[c(12, 13), , drop = TRUE], use.names = FALSE))))

  ft <- as_flextable(data_co2)
  expect_equal(
    information_data_chunk(ft)$txt[seq_len(9)],
    c("conc", "Quebec", "Mississippi", "Treatment", ": ", "nonchilled", "", "", "95")
  )

  ft <- as_flextable(data_co2, hide_grouplabel = TRUE)
  expect_equal(
    information_data_chunk(ft)$txt[seq_len(9)],
    c("conc", "Quebec", "Mississippi", "nonchilled", "", "", "", "", "")
  )
})

test_that("glm and lm", {
  skip_if_not_installed("broom")
  options("show.signif.stars" = TRUE)
  dat <- attitude
  dat$high.rating <- (dat$rating > 70)
  probit.model <- glm(high.rating ~ learning + critical +
                        advance, data = dat, family = binomial(link = "probit"))
  expect_silent(ft <- as_flextable(probit.model))

  expect_equal(
    information_data_chunk(ft)$txt[5],
    "Pr(>|z|)"
  )
  expect_equal(
    information_data_chunk(ft)$txt[31],
    "Signif. codes: 0 <= '***' < 0.001 < '**' < 0.01 < '*' < 0.05"
  )

  lmod <- lm(rating ~ complaints + privileges +
               learning + raises + critical, data = attitude)
  ft <- as_flextable(lmod)
  expect_equal(
    information_data_chunk(ft)$txt[5],
    "Pr(>|z|)"
  )
  expect_equal(
    information_data_chunk(ft)$txt[44],
    "Signif. codes: 0 <= '***' < 0.001 < '**' < 0.01 < '*' < 0.05"
  )
  expect_equal(
    information_data_chunk(ft)$txt[72],
    "F-statistic: 12.06 on 24 and 5 DF, p-value: 0.0000"
  )
})

test_that("grouped data exports work", {
  local_edition(3)
  skip_on_cran()
  skip_if_not_installed("doconv")
  skip_if_not(doconv::msoffice_available())
  skip_if_not(pandoc_version() >= numeric_version("2"))
  skip_if_not_installed("webshot2")

  init_flextable_defaults()
  set_flextable_defaults(
    post_process_pptx = function(x) {
      set_table_properties(x, layout = "fixed") |>
        autofit()
    }
  )

  data_co2 <-
    structure(
      list(
        Treatment = structure(c(3L, 1L, 1L, 1L, 1L, 1L, 1L, 1L, 2L, 2L, 2L, 2L, 2L, 2L, 2L, 4L, 4L),
          levels = c("nonchilled", "chilled", "zoubi", "bisou"), class = "factor"
        ),
        conc = c(85L, 95L, 175L, 250L, 350L, 500L, 675L, 1000L, 95L, 175L, 250L, 350L, 500L, 675L, 1000L, NA, 1000L),
        Quebec = c(
          12, 15.2666666666667, 30.0333333333333, 37.4, 40.3666666666667, 39.6, 41.5, 43.1666666666667,
          12.8666666666667, 24.1333333333333, 34.4666666666667, 35.8, 36.6666666666667,
          37.5, 40.8333333333333, 43, 43
        ),
        Mississippi = c(
          10, 11.3, 20.2, 27.5333333333333, 29.9, 30.6, 30.5333333333333, 31.6, 9.6, 14.7666666666667, 16.1,
          16.6, 16.6333333333333, 18.2666666666667, 18.7333333333333, 19, 19
        )
      ),
      row.names = c(NA, -17L),
      class = "data.frame"
    )
  gdata <- as_grouped_data(x = data_co2, groups = c("Treatment"))

  ft_1 <- as_flextable(gdata)
  ft_1 <- colformat_double(ft_1, digits = 2)
  ft_1 <- set_table_properties(ft_1, layout = "autofit")

  # pptx grouped-data
  path <- save_as_pptx(ft_1, path = tempfile(fileext = ".pptx"))
  doconv::expect_snapshot_doc(name = "pptx-grouped-data", x = path, engine = "testthat")

  # docx grouped-data
  path <- save_as_docx(ft_1, path = tempfile(fileext = ".docx"))
  doconv::expect_snapshot_doc(x = path, name = "docx-grouped-data", engine = "testthat")

  # html grouped-data
  path <- save_as_html(ft_1, path = tempfile(fileext = ".html"))
  doconv::expect_snapshot_html(name = "html-grouped-data", path, engine = "testthat")

  gdata <- as_grouped_data(
    x = data_co2, groups = c("Treatment"),
    expand_single = FALSE
  )

  ft_2 <- as_flextable(gdata)
  ft_2 <- colformat_double(ft_2, digits = 2)
  ft_2 <- autofit(ft_2)

  # pptx grouped-data-no-single
  path <- save_as_pptx(ft_2, path = tempfile(fileext = ".pptx"))
  doconv::expect_snapshot_doc(x = path, name = "pptx-grouped-data-no-single", engine = "testthat")

  # docx grouped-data-no-single
  path <- save_as_docx(ft_2, path = tempfile(fileext = ".docx"))
  doconv::expect_snapshot_doc(x = path, name = "docx-grouped-data-no-single", engine = "testthat")

  # html grouped-data-no-single
  path <- save_as_html(ft_2, path = tempfile(fileext = ".html"))
  doconv::expect_snapshot_html(name = "html-grouped-data-no-single", path, engine = "testthat")

  init_flextable_defaults()
})
