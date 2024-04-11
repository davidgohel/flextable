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
  expect_equal(attr(out_tmp, "groups"), "Treatment")
  expect_equal(attr(out_tmp, "columns"), c("conc", "Quebec", "Mississippi"))
  expect_equal(unlist(out_tmp, use.names = FALSE), c(1, NA, NA, NA))

  expect_s3_class(data_co2, "grouped_data")

  expect_silent(
    data_co2 <- as_grouped_data(x = data_co2, groups = c("Treatment"), expand_single = TRUE)
  )
  expect_true(all(is.na(unlist(data_co2[c(12, 13), , drop = TRUE], use.names = FALSE))))

  ft <- as_flextable(data_co2)
  expect_equal(
    information_data_chunk(ft)$txt[seq_len(9)],
    c("conc", "Quebec", "Mississippi", "Treatment", ": ", "nonchilled", "", "", "")
  )
  expect_equal(information_data_chunk(ft)$txt[15], "95")

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
    "Pr(>|t|)"
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

test_that("htest", {
  set.seed(16)
  M <- as.table(rbind(c(762, 327, 468), c(484, 239, 477)))
  dimnames(M) <- list(
    gender = c("F", "M"),
    party = c("Democrat", "Independent", "Republican")
  )
  ft <- as_flextable(stats::chisq.test(M))
  expect_equal(
    information_data_chunk(ft)$txt[6],
    "0.0000"
  )
})

test_that("continuous_summary works", {
  ft_1 <- continuous_summary(iris, names(iris)[1:4],
                             by = "Species",
                             hide_grouplabel = FALSE
  )
  expect_identical(
    information_data_chunk(ft_1)$txt[c(1, 11, 14, 71)],
    c("Species", "# na", "Sepal.Length", "setosa")
  )
})

test_that("transformation of mixed models works", {
  skip_if_not_installed("broom.mixed")
  skip_if_not_installed("nlme")
  m1 <- nlme::lme(distance ~ age, data = nlme::Orthodont)
  ft <- as_flextable(m1)
  expect_equal(
    information_data_chunk(ft)$txt[c(18, 108)],
    c("(Intercept)", "Akaike Information Criterion: 454.6")
  )
})

test_that("kmeans works", {
  set.seed(11)
  cl <- kmeans(scale(mtcars[1:7]), 5)
  ft <- as_flextable(cl)
  expect_equal(
    information_data_chunk(ft)$txt[c(37, 163)],
    c("1.0906", "BSS/TSS ratio: 80.1%")
  )
})

test_that("partitioning around medoids works", {
  skip_if_not_installed("cluster")
  set.seed(11)
  dat <- as.data.frame(scale(mtcars[1:7]))
  cl <- cluster::pam(dat, 3)
  ft <- as_flextable(cl)
  expect_equal(
    information_data_chunk(ft)$txt[c(37, 163, 17)],
    c("", NA, "2.2")
  )
})

test_that("grouped data exports work", {
  skip_if_not_local_testing(check_html = TRUE)
  snap_folder_test_file <- "as_flextable"
  defer_cleaning_snapshot_directory(snap_folder_test_file)

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
  handle_manual_snapshots(snap_folder_test_file, "pptx-grouped-data")
  doconv::expect_snapshot_doc(name = "pptx-grouped-data", x = path, engine = "testthat")

  # docx grouped-data
  path <- save_as_docx(ft_1, path = tempfile(fileext = ".docx"))
  handle_manual_snapshots(snap_folder_test_file, "docx-grouped-data")
  doconv::expect_snapshot_doc(x = path, name = "docx-grouped-data", engine = "testthat")

  # html grouped-data
  path <- save_as_html(ft_1, path = tempfile(fileext = ".html"))
  handle_manual_snapshots(snap_folder_test_file, "html-grouped-data")
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
  handle_manual_snapshots(snap_folder_test_file, "pptx-grouped-data-no-single")
  doconv::expect_snapshot_doc(x = path, name = "pptx-grouped-data-no-single", engine = "testthat")

  # docx grouped-data-no-single
  path <- save_as_docx(ft_2, path = tempfile(fileext = ".docx"))
  handle_manual_snapshots(snap_folder_test_file, "docx-grouped-data-no-single")
  doconv::expect_snapshot_doc(x = path, name = "docx-grouped-data-no-single", engine = "testthat")

  # html grouped-data-no-single
  path <- save_as_html(ft_2, path = tempfile(fileext = ".html"))
  handle_manual_snapshots(snap_folder_test_file, "html-grouped-data-no-single")
  doconv::expect_snapshot_html(name = "html-grouped-data-no-single", path, engine = "testthat")

  init_flextable_defaults()
})
