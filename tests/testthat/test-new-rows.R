context("check dim and new rows")

test_that("nrow_part or ncol_keys checks", {
  expect_error(nrow_part(12))
  expect_error(ncol_keys(12))
  ft <- flextable(head(iris))
  expect_equal(nrow_part(ft, part = "footer"), 0)
  expect_equal(nrow_part(ft, part = "body"), 6)
  expect_equal(ncol_keys(ft), 5)
})

test_that("add lines", {
  ft <- flextable(head(iris))

  newvals <- c("A", "B", "C", "D")

  ft <- add_header_lines(
    x = ft,
    values = newvals,
    top = TRUE)
  expect_equal(nrow_part(ft, part = "header"), 5)

  ft <- add_footer_lines(
    x = ft,
    values = newvals,
    top = FALSE)
  expect_equal(nrow_part(ft, part = "footer"), 4)

  x <- information_data_chunk(ft)

  header_sel <- x[x$.part %in% "header",]
  expect_equal(
    header_sel$txt,
    c(
      rep(newvals, each = 5),
      colnames(iris)
    )
  )
  footer_sel <- x[x$.part %in% "footer",]
  expect_equal(
    footer_sel$txt,
    rep(newvals, each = 5)
  )
})

test_that("separate_header", {
  x <- data.frame(
    Species = as.factor(c("setosa", "versicolor", "virginica")),
    Sepal.Length_mean_zzz = c(5.006, 5.936, 6.588),
    Sepal.Length_sd = c(0.35249, 0.51617, 0.63588),
    Sepal.Width_mean = c(3.428, 2.77, 2.974),
    Sepal.Width_sd_sfsf_dsfsdf = c(0.37906, 0.3138, 0.3225),
    Petal.Length_mean = c(1.462, 4.26, 5.552),
    Petal.Length_sd = c(0.17366, 0.46991, 0.55189),
    Petal.Width_mean = c(0.246, 1.326, 2.026),
    Petal.Width_sd = c(0.10539, 0.19775, 0.27465)
  )

  ft_1 <- flextable(x)
  ft_1 <- separate_header(x = ft_1,
                          opts = c("span-top", "bottom-vspan")
  )
  header_txt <- information_data_chunk(ft_1) |>
    subset(.part %in% "header")
  expect_equal(
    object = header_txt$txt,
    expected =
      c("Species", "Sepal", "Sepal", "Sepal", "Sepal", "Petal", "Petal",
        "Petal", "Petal", "", "Length", "Length", "Width", "Width", "Length",
        "Length", "Width", "Width", "", "mean", "sd", "mean", "sd", "mean",
        "sd", "mean", "sd", "", "zzz", "", "", "sfsf", "", "", "", "",
        "", "", "", "", "dsfsdf", "", "", "", "")
  )

})


test_that("add part rows", {

  ft01 <- fp_text_default(color = "red")
  ft02 <- fp_text_default(color = "orange")

  pars <- as_paragraph(
    as_chunk(c("(1)", "(2)"), props = ft02), " ",
    as_chunk(c(
      "My tailor is rich",
      "My baker is rich"
    ), props = ft01)
  )

  ft_1 <- flextable(head(mtcars))
  ft_1 <- add_header_row(ft_1,
    values = pars,
    colwidths = c(5, 6), top = FALSE
  )
  ft_1 <- add_body_row(ft_1,
    values = pars,
    colwidths = c(5, 6), top = TRUE
  )
  ft_1 <- add_footer_row(ft_1,
    values = pars,
    colwidths = c(3, 8), top = FALSE
  )

  x <- information_data_chunk(ft_1)

  new_header_sel <- x[x$.part %in% "header" &
                        x$.row_id %in% 2 &
                        x$.col_id %in% "mpg",]
  expect_equal(new_header_sel$txt, c("(1)", " ", "My tailor is rich"))
  expect_equal(new_header_sel$color, c("orange", "black", "red"))
  new_header_sel <- x[x$.part %in% "header" &
                        x$.row_id %in% 2 &
                        x$.col_id %in% "wt",]
  expect_equal(new_header_sel$txt, c("(2)", " ", "My baker is rich"))
  expect_equal(new_header_sel$color, c("orange", "black", "red"))
  spans <- flextable:::fortify_span(ft_1, parts = "header")
  expect_equal(
    spans$rowspan,
    c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      5, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0)
  )
  expect_true(all(spans$colspan %in% 1))
  expect_equivalent(
    colSums(is.na(ft_1$header$dataset)),
    rep(0L, ncol(mtcars))
  )

  new_body_sel <- x[x$.part %in% "body" &
                        x$.row_id %in% 1 &
                        x$.col_id %in% "mpg",]
  expect_equal(new_body_sel$txt, c("(1)", " ", "My tailor is rich"))
  expect_equal(new_body_sel$color, c("orange", "black", "red"))
  new_body_sel <- x[x$.part %in% "body" &
                        x$.row_id %in% 1 &
                        x$.col_id %in% "wt",]
  expect_equal(new_body_sel$txt, c("(2)", " ", "My baker is rich"))
  expect_equal(new_body_sel$color, c("orange", "black", "red"))
  spans <- flextable:::fortify_span(ft_1, parts = "body")
  spans <- spans[spans$.row_id %in% 1,]
  expect_equal(
    spans$rowspan,
    c(5, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0)
  )
  expect_true(all(spans$colspan %in% 1))
  expect_equivalent(
    colSums(is.na(ft_1$body$dataset)),
    rep(1L, ncol(mtcars))
  )

  new_footer_sel <- x[x$.part %in% "footer" &
                        x$.row_id %in% 1 &
                        x$.col_id %in% "mpg",]
  expect_equal(new_footer_sel$txt, c("(1)", " ", "My tailor is rich"))
  new_footer_sel <- x[x$.part %in% "footer" &
                        x$.row_id %in% 1 &
                        x$.col_id %in% "hp",]
  expect_equal(new_header_sel$txt, c("(2)", " ", "My baker is rich"))
  spans <- flextable:::fortify_span(ft_1, parts = "footer")
  expect_equal(
    spans$rowspan,
    c(3, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0)
  )
  expect_true(all(spans$colspan %in% 1))
  expect_equivalent(
    colSums(is.na(ft_1$footer$dataset)),
    rep(0L, ncol(mtcars))
  )

})

test_that("add rows", {
  ft <- flextable(head(iris),
    col_keys = c(
      "Species", "Sepal.Length", "Petal.Length",
      "Sepal.Width", "Petal.Width"
    )
  )

  fun <- function(x) {
    paste0(
      c("min: ", "max: "),
      formatC(range(x))
    )
  }
  new_row <- list(
    Sepal.Length = fun(iris$Sepal.Length),
    Sepal.Width =  fun(iris$Sepal.Width),
    Petal.Width =  fun(iris$Petal.Width),
    Petal.Length = fun(iris$Petal.Length)
  )

  ft <- add_header(ft, values = new_row, top = FALSE)

  ft <- add_body(
    x = ft, Sepal.Length = 1:5,
    Sepal.Width = 1:5 * 2, Petal.Length = 1:5 * 3,
    Petal.Width = 1:5 + 10, Species = "Blah", top = FALSE
  )

  x <- information_data_chunk(ft)

  new_row_sel <- x[x$.part %in% "body" &
                        x$.row_id %in% 7:11 &
                        x$.col_id %in% "Species",]
  expect_equal(new_row_sel$txt, rep("Blah", 5))

  new_row_sel <- x[x$.part %in% "body" &
                        x$.row_id %in% 7:11 &
                        x$.col_id %in% "Sepal.Length",]
  expect_equal(new_row_sel$txt, as.character(1:5))

  expect_true(is.factor(ft$body$dataset[7:11,]$Species))
  expect_equal(levels(ft$body$dataset[7:11,]$Species), c("setosa", "versicolor", "virginica", "Blah"))
  expect_equal(as.character(ft$body$dataset[7:11,]$Species), rep("Blah", 5))
  expect_equal(ft$body$dataset[7:11,]$Sepal.Length, 1:5)

  new_header_sel <- x[x$.part %in% "header" &
                     x$.row_id %in% 2:3 &
                     x$.col_id %in% "Sepal.Width",]
  expect_equal(new_header_sel$txt, c("min: 2", "max: 4.4"))
  new_header_sel <- x[x$.part %in% "header" &
                     x$.row_id %in% 2:3 &
                     x$.col_id %in% "Species",]
  expect_equal(new_header_sel$txt, c("", ""))

})
