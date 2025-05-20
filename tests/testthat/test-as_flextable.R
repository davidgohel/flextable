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

test_that("grouped data structure", {
  init_flextable_defaults()
  set_flextable_defaults(
    post_process_pptx = function(x) {
      autofit(set_table_properties(x, layout = "fixed"))
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

  # pptx testing
  pptx_file <- tempfile(fileext = ".pptx")
  save_as_pptx(ft_1, path = pptx_file)
  doc <- read_pptx(pptx_file)

  xml_body <- doc$slide$get_slide(1)$get()
  xml_tbl <- xml_find_first(xml_body, "/p:sld/p:cSld/p:spTree/p:graphicFrame/a:graphic/a:graphicData/a:tbl")

  xml_cell_2_1 <- xml_child(xml_tbl, "a:tr[2]/a:tc[1]")
  expect_equal(xml_text(xml_cell_2_1), "Treatment: zoubi")
  expect_equal(xml_attr(xml_cell_2_1, "gridSpan"), "3")
  xml_cell_2_2 <- xml_child(xml_tbl, "a:tr[2]/a:tc[2]")
  expect_equal(xml_text(xml_cell_2_2), "")
  expect_equal(xml_attr(xml_cell_2_2, "hMerge"), "true")
  xml_cell_2_3 <- xml_child(xml_tbl, "a:tr[2]/a:tc[3]")
  expect_equal(xml_text(xml_cell_2_3), "")
  expect_equal(xml_attr(xml_cell_2_3, "hMerge"), "true")

  xml_cell_3_1 <- xml_child(xml_tbl, "a:tr[3]/a:tc[1]")
  expect_equal(xml_text(xml_cell_3_1), "85")
  xml_cell_3_2 <- xml_child(xml_tbl, "a:tr[3]/a:tc[2]")
  expect_equal(xml_text(xml_cell_3_2), "12.00")
  xml_cell_3_3 <- xml_child(xml_tbl, "a:tr[3]/a:tc[3]")
  expect_equal(xml_text(xml_cell_3_3), "10.00")

  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[1]/a:tcPr/a:lnL"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[1]/a:tcPr/a:lnR"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[1]/a:tcPr/a:lnB"), "w"), "19050")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[1]/a:tcPr/a:lnT"), "w"), "19050")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[2]/a:tcPr/a:lnL"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[2]/a:tcPr/a:lnR"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[2]/a:tcPr/a:lnB"), "w"), "19050")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[2]/a:tcPr/a:lnT"), "w"), "19050")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[3]/a:tcPr/a:lnL"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[3]/a:tcPr/a:lnR"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[3]/a:tcPr/a:lnB"), "w"), "19050")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[1]/a:tc[3]/a:tcPr/a:lnT"), "w"), "19050")

  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[2]/a:tc[1]/a:tcPr/a:lnL"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[2]/a:tc[1]/a:tcPr/a:lnR"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[2]/a:tc[1]/a:tcPr/a:lnB"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[2]/a:tc[1]/a:tcPr/a:lnT"), "w"), "0")

  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[22]/a:tc[1]/a:tcPr/a:lnL"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[22]/a:tc[1]/a:tcPr/a:lnR"), "w"), "0")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[22]/a:tc[1]/a:tcPr/a:lnB"), "w"), "19050")
  expect_equal(xml_attr(xml_child(xml_tbl, "a:tr[22]/a:tc[1]/a:tcPr/a:lnT"), "w"), "0")


  # docx testing
  docx_file <- tempfile(fileext = ".docx")
  save_as_docx(ft_1, path = docx_file)
  doc <- read_docx(docx_file)
  xml_doc <- docx_body_xml(doc)
  xml_tbl <- xml_find_first(xml_doc, "/w:document/w:body/w:tbl")
  xml_cell_2_1 <- xml_child(xml_tbl, "w:tr[2]/w:tc[1]")
  expect_equal(xml_text(xml_cell_2_1), "Treatment: zoubi")
  expect_equal(xml_attr(xml_child(xml_cell_2_1, "w:tcPr/w:gridSpan"), "val"), "3")
  xml_cell_2_2 <- xml_child(xml_tbl, "w:tr[2]/w:tc[2]")
  expect_s3_class(xml_cell_2_2, "xml_missing")

  xml_cell_1_1 <- xml_child(xml_tbl, "w:tr[1]/w:tc[1]")
  expect_equal(xml_text(xml_cell_1_1), "conc")
  xml_cell_1_2 <- xml_child(xml_tbl, "w:tr[1]/w:tc[2]")
  expect_equal(xml_text(xml_cell_1_2), "Quebec")
  xml_cell_1_3 <- xml_child(xml_tbl, "w:tr[1]/w:tc[3]")
  expect_equal(xml_text(xml_cell_1_3), "Mississippi")

  expect_equal(xml_attr(xml_child(xml_cell_1_3, "w:tcPr/w:tcBorders/w:bottom"), "sz"), "12")
  expect_equal(xml_attr(xml_child(xml_cell_1_3, "w:tcPr/w:tcBorders/w:top"), "sz"), "12")
  expect_equal(xml_attr(xml_child(xml_cell_1_3, "w:tcPr/w:tcBorders/w:left"), "sz"), "0")
  expect_equal(xml_attr(xml_child(xml_cell_1_3, "w:tcPr/w:tcBorders/w:right"), "sz"), "0")

  expect_equal(xml_attr(xml_child(xml_cell_2_1, "w:tcPr/w:tcBorders/w:bottom"), "sz"), "0")
  expect_equal(xml_attr(xml_child(xml_cell_2_1, "w:tcPr/w:tcBorders/w:top"), "sz"), "12")
  expect_equal(xml_attr(xml_child(xml_cell_2_1, "w:tcPr/w:tcBorders/w:left"), "sz"), "0")
  expect_equal(xml_attr(xml_child(xml_cell_2_1, "w:tcPr/w:tcBorders/w:right"), "sz"), "0")

  # html testing
  html_file <- tempfile(fileext = ".html")
  save_as_html(ft_1, path = html_file)
  xml_doc <- read_html(html_file)
  xml_tbl <- xml_find_first(xml_doc, "//table")

  xml_cell_2_1 <- xml_child(xml_tbl, "tbody/tr[1]/td[1]")
  expect_equal(xml_text(xml_cell_2_1), "Treatment: zoubi")
  expect_equal(xml_attr(xml_cell_2_1, "colspan"), "3")
  xml_cell_2_2 <- xml_child(xml_tbl, "tbody/tr[1]/td[2]")
  expect_s3_class(xml_cell_2_2, "xml_missing")

  xml_cell_1_1 <- xml_child(xml_tbl, "thead/tr[1]/th[1]")
  expect_equal(xml_text(xml_cell_1_1), "conc")
  xml_cell_1_2 <- xml_child(xml_tbl, "thead/tr[1]/th[2]")
  expect_equal(xml_text(xml_cell_1_2), "Quebec")
  xml_cell_1_3 <- xml_child(xml_tbl, "thead/tr[1]/th[3]")
  expect_equal(xml_text(xml_cell_1_3), "Mississippi")


  init_flextable_defaults()
})

labelled_df <- data.frame(
  region =
    structure(
      c(1, 2, 1, 9, 2, 3),
      labels = c(north = 1, south = 2, center = 3, missing = 9),
      label = "Region of the respondent"
    ),
  sex =
    structure(
      c("f", "f", "m", "m", "m", "f"),
      labels = c(female = "f", male = "m"),
      label = "Sex of the respondent"
    ),
  value = 1:6
)

test_that("labelled data", {
  ft <- flextable(labelled_df, use_labels = TRUE)
  expected_txt <- c(
    "Region of the respondent", "Sex of the respondent", "value",
    "north", "female", "1", "south", "female", "2", "north", "male",
    "3", "missing", "male", "4", "south", "male", "5", "center", "female",
    "6")
  expect_equal(
    information_data_chunk(ft)$txt,
    expected_txt
  )

  ft <- flextable(labelled_df, use_labels = FALSE)
  expected_txt <- c(
    "region", "sex", "value", "1", "f", "1", "2", "f", "2", "1",
    "m", "3", "9", "m", "4", "2", "m", "5", "3", "f", "6"
  )
  expect_equal(
    information_data_chunk(ft)$txt,
    expected_txt
  )

  expected_txt <- c(
    "region", "sex", "sex", "sex", "region", "female", "male",
    "Total", "north", "1", "", "1", "", "2", "", "south", "1", "",
    "1", "", "2", "", "center", "1", "", "", "", "1", "", "missing",
    "", "", "1", "", "1", "", "Total", "3", "", "3", "", "6", ""
  )
  ft <- proc_freq(
    labelled_df, row = "region", col = "sex",
    include.row_percent = FALSE,
    include.column_percent = FALSE,
    include.table_percent = FALSE
  )
  expect_equal(
    information_data_chunk(ft)$txt,
    expected_txt
  )

  expected_txt <- c(
    "", "", "", "Statistic", "<br>", "(N=6)", "Region of the respondent",
    "north", "", "2 (33.3%)", "Region of the respondent", "south",
    "", "2 (33.3%)", "Region of the respondent", "center", "", "1 (16.7%)",
    "Region of the respondent", "Missing", "", "1 (16.7%)", "Sex of the respondent",
    "female", "", "3 (50.0%)", "Sex of the respondent", "male", "",
    "3 (50.0%)", "value", "Mean (SD)", "", "3.5 (1.9)", "value",
    "Median (IQR)", "", "3.5 (2.5)", "value", "Range", "", "1.0 - 6.0"
  )
  ft <- as_flextable(summarizor(labelled_df))
  expect_equal(
    information_data_chunk(ft)$txt,
    expected_txt
  )
})

test_that("package tables", {

  skip_if_not_installed("tables")
  require("tables", quietly = TRUE)
  x <- tabular((Factor(gear, "Gears") + 1) * ((n = 1) + Percent() +
         (RowPct = Percent("row")) + (ColPct = Percent("col"))) ~
         (Factor(carb, "Carburetors") + 1) * Format(digits = 1),
    data = mtcars)

  ft <- as_flextable(
    x,
    spread_first_col = TRUE,
    row_title = as_paragraph(
      colorize("Gears: ", color = "#666666"),
      colorize(as_b(.row_title), color = "red")
    )
  )
  idc <- information_data_chunk(ft)

  expected_txt <- c(
    "", "Carburetors", "", "", "", "", "", "", "", "1", "2", "3",
    "4", "6", "8", "All"
  )
  expect_equal(
    idc[idc$.part %in% "header",]$txt,
    expected_txt
  )

  expected_txt <- c(
    "Gears: ", "3", "", "", "", "", "", "", "", "n", "3", "4",
    "3", "5", "0", "0", "15", "Percent", "9", "12", "9", "16", "0",
    "0", "47", "RowPct", "20", "27", "20", "33", "0", "0", "100",
    "ColPct", "43", "40", "100", "50", "0", "0", "47"
  )
  expect_equal(
    idc[idc$.part %in% "body" & idc$.row_id < 6,]$txt,
    expected_txt
  )

  idp <- information_data_paragraph(ft)
  expect_equal(
    idp[idp$.part %in% "header",]$text.align,
    rep("center", 16)
  )
  expect_equal(
    idp[idp$.part %in% "body" & idp$.row_id < 6 & idp$.row_id > 1,]$text.align,
    rep("center", 32)
  )


})


test_that("package xtable", {

  skip_if_not_installed("xtable")
  require("xtable", quietly = TRUE)

  tli <- data.frame(
    grade = c(6L, 7L, 5L, 3L, 8L, 5L, 8L, 4L, 6L, 7L),
    sex = factor(c("M", "M", "F", "M", "M", "M", "F", "M", "M", "M")),
    disadvg = factor(c("YES", "NO", "YES", "YES", "YES", "NO", "YES", "YES", "NO", "YES")),
    ethnicty = factor(
      c(
        "HISPANIC", "BLACK", "HISPANIC", "HISPANIC", "WHITE", "BLACK", "HISPANIC",
        "BLACK", "WHITE", "HISPANIC"
      ),
      levels = c("BLACK", "HISPANIC", "OTHER", "WHITE")
    ),
    tlimth = c(43L, 88L, 34L, 65L, 75L, 74L, 72L, 79L, 88L, 87L)
  )

  tli.table <- xtable(tli)
  align(tli.table) <- rep("r", 6)
  align(tli.table) <- "|r|r|clr|r|"
  ft <- as_flextable(
    tli.table,
    rotate.colnames = TRUE,
    include.rownames = FALSE)
  ft <- height(ft, i = 1, part = "header", height = 1)

  idc <- information_data_chunk(ft)

  expected_txt <- c(
    "grade", "sex", "disadvg", "ethnicty", "tlimth", "6", "M",
    "YES", "HISPANIC", "43", "7", "M", "NO", "BLACK", "88", "5",
    "F", "YES", "HISPANIC", "34", "3", "M", "YES", "HISPANIC", "65",
    "8", "M", "YES", "WHITE", "75", "5", "M", "NO", "BLACK", "74",
    "8", "F", "YES", "HISPANIC", "72", "4", "M", "YES", "BLACK",
    "79", "6", "M", "NO", "WHITE", "88", "7", "M", "YES", "HISPANIC",
    "87"
  )
  expect_equal(
    idc$txt,
    expected_txt
  )

  idc <- information_data_cell(ft)
  expect_equal(
    idc$text.direction,
    c(rep("btlr", 5), rep("lrtb", 50))
  )

})

test_that("gam models", {

  skip_if_not_installed("mgcv")
  require("mgcv", quietly = TRUE)

  set.seed(2)
  dat <- gamSim(1, n = 400, dist = "normal", scale = 2)
  b <- gam(y ~ s(x0) + s(x1) + s(x2) + s(x3), data = dat)
  options(show.signif.stars = FALSE)
  ft <- as_flextable(b)
  ft <- delete_part(ft, part = "footer")

  idc <- information_data_chunk(ft)

  expected_txt <- c(
    "Component", "Term", "Estimate", "Std Error", "t-value", "p-value",
    "A. parametric coefficients", "(Intercept)", "7.833", "0.099",
    "79.303", "0.0000", "Component", "Term", "edf", "Ref. df", "F-value",
    "p-value", "B. smooth terms", "s(x0)", "2.500", "3.115", "6.921",
    "0.0001", "B. smooth terms", "s(x1)", "2.401", "2.984", "81.858",
    "0.0000", "B. smooth terms", "s(x2)", "7.698", "8.564", "88.158",
    "0.0000", "B. smooth terms", "s(x3)", "1.000", "1.000", "4.343",
    "0.0378"
  )
  expect_equal(
    idc$txt,
    expected_txt
  )

  idp <- information_data_paragraph(ft)
  expect_equal(
    idp$text.align,
    c(
      "left", "left", "right", "right", "right", "right", "left",
      "left", "right", "right", "right", "right", "left", "left", "right",
      "right", "right", "right", "left", "left", "right", "right",
      "right", "right", "left", "left", "right", "right", "right",
      "right", "left", "left", "right", "right", "right", "right",
      "left", "left", "right", "right", "right", "right"
    )
  )
})
