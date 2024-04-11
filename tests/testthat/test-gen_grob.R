gdtools::register_liberationsans()

init_flextable_defaults()

set_flextable_defaults(
  font.family = "Liberation Sans",
  border.color = "#333333")


test_that("png is created", {
  ft <- as_flextable(iris)
  file <- tempfile(fileext = ".png")
  try(invisible(save_as_image(x = ft, path = file, res = 150)),
      silent = TRUE)
  expect_true(file.exists(file))
  expect_gt(file.info(file)$size, 20000)
})

test_that("merged borders", {
  local_edition(3)

  dat <- data.frame(a = c(1, 1, 2, 2, 5), b = 6:10)

  ft <- flextable(dat)
  ft <- merge_v(ft, ~a, part = "body")
  ft <- hline(
    x = ft,
    i = 2, part = "body",
    border = fp_border(color = "red")
  )

  gr <- gen_grob(ft)

  expect_length(gr$children, 10)

  expect_equal(gr$children[[3]]$children$borders$children[[1]]$gp$col, "red")

  expect_length(gr$children[[1]]$children$borders$children, 2)
  expect_equal(gr$children[[1]]$children$borders$children[[1]]$gp$col, "#333333")
  expect_equal(gr$children[[1]]$children$borders$children[[1]]$x0, grid::unit(0, "npc"))
  expect_equal(gr$children[[1]]$children$borders$children[[1]]$x1, grid::unit(1, "npc"))
  expect_equal(gr$children[[1]]$children$borders$children[[1]]$y0, grid::unit(1, "npc"))
  expect_equal(gr$children[[1]]$children$borders$children[[1]]$y1, grid::unit(1, "npc"))

  expect_equal(gr$children[[1]]$children$borders$children[[2]]$gp$col, "#333333")
  expect_equal(gr$children[[1]]$children$borders$children[[2]]$x0, grid::unit(0, "npc"))
  expect_equal(gr$children[[1]]$children$borders$children[[2]]$x1, grid::unit(1, "npc"))
  expect_equal(gr$children[[1]]$children$borders$children[[2]]$y0, grid::unit(0, "npc"))
  expect_equal(gr$children[[1]]$children$borders$children[[2]]$y1, grid::unit(0, "npc"))

  expect_length(gr$children[[10]]$children$borders$children, 1)

  expect_equal(gr$children[[10]]$children$borders$children[[1]]$gp$col, "#333333")
  expect_equal(gr$children[[10]]$children$borders$children[[1]]$x0, grid::unit(0, "npc"))
  expect_equal(gr$children[[10]]$children$borders$children[[1]]$x1, grid::unit(1, "npc"))
  expect_equal(gr$children[[10]]$children$borders$children[[1]]$y0, grid::unit(0, "npc"))
  expect_equal(gr$children[[10]]$children$borders$children[[1]]$y1, grid::unit(0, "npc"))

})

test_that("text wrapping", {

  text <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
  source1 <- "DATA_SOURCE_A.COURSE_TITLE\nDATA_SOURCE_A.SUBJECT_DESCR\nDATA_SOURCE_A.CATALOG_NUMBER"
  source2 <- "DATA_SOURCE_A.GRADING_BASIS\nDATA_SOURCE_A.OFFICIAL_GRADE\nDATA_SOURCE_B.STUDENT_GROUP"

  temp_dat <- data.frame(
    label = c("Sources", "", "Notes"),
    col1 = c(source1, "", text),
    col2 = c(source2, "", text)
  )

  # Create table
  ft <- flextable(temp_dat)
  ft <- merge_h(ft, part = "body")

  gr <- gen_grob(ft, fit = "fixed")

  expect_length(gr$children, 9)
  expect_equal(gr$children[[5]]$children$contents$ftgrobs[[1]]$label, source1)
  expect_equal(gr$children[[6]]$children$contents$ftgrobs[[1]]$label, source2)

  # check wrap on 3 rows
  expect_length(gr$children[[5]]$children$contents$children, 3)
  expect_length(gr$children[[6]]$children$contents$children, 3)
  expect_equal(gr$children[[8]]$children$contents$ftgrobs[[1]]$label, "Notes")
  expect_length(gr$children[[8]]$children$contents$children, 1)
  expect_equal(gr$children[[9]]$children$contents$ftgrobs[[1]]$label, text)
  # check wrap on 3 rows
  expect_length(gr$children[[9]]$children$contents$children, 3)

  # check that height and width are greater than those of smaller cells
  expect_gt(gr$children$cell_2_2$children$contents$ftpar$height,
            gr$children$cell_1_2$children$contents$ftpar$height
            )
  expect_gt(gr$children$cell_2_2$children$contents$ftpar$width,
            gr$children$cell_2_1$children$contents$ftpar$width
            )
})

test_that("grid with raster", {
  skip_if_not_installed("magick")

  img.file <- file.path(
    R.home("doc"),
    "html", "logo.jpg"
  )
  myft <- flextable(head(iris))
  myft <- prepend_chunks(
    x = myft,
    i = 1:2, j = 1,
    as_image(src = img.file),
    part = "body"
  )
  ft <- autofit(myft)

  gr <- gen_grob(ft)

  expect_s3_class(gr$children[[6]]$children$contents$ftgrobs[[1]], "rastergrob")
  expect_s3_class(gr$children[[6]]$children$contents$ftgrobs[[2]], "text")
  expect_s3_class(gr$children[[11]]$children$contents$ftgrobs[[1]], "rastergrob")
  expect_s3_class(gr$children[[11]]$children$contents$ftgrobs[[2]], "text")
  expect_s3_class(gr$children[[12]]$children$contents$ftgrobs[[1]], "text")
})

