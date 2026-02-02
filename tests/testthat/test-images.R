data <- iris[c(1:3, 51:53, 101:104), ]
col_keys <- c("Species", "sep_1", "Sepal.Length", "Sepal.Width", "sep_2", "Petal.Length", "Petal.Width")
img.file <- file.path(R.home("doc"), "html", "logo.jpg")

rlogo <- tempfile(fileext = ".jpg")
file.copy(img.file, rlogo)

test_that("images", {
  ft <- flextable(data, col_keys = col_keys)
  ft <- compose(ft,
    j = "Sepal.Length",
    value = as_paragraph(
      as_chunk("blah blah "),
      as_image(rlogo, width = .3, height = 0.23), " ",
      as_chunk(sprintf("val: %.1f", Sepal.Length), props = fp_text(color = "orange", vertical.align = "superscript"))
    )
  )
  ft <- compose(ft,
    j = "sep_1",
    value = as_paragraph(
      as_image(rlogo, width = .3, height = 0.23)
    )
  )
  ft <- compose(ft,
    j = "Petal.Length",
    value = as_paragraph(
      "blah blah ",
      as_chunk(Sepal.Length, props = fp_text(color = "orange", vertical.align = "superscript"))
    )
  )
  ft <- style(ft,
    pr_c = fp_cell(margin = 0, border = fp_border(width = 0)),
    pr_p = fp_par(padding = 0, border = fp_border(width = 0)),
    pr_t = fp_text(font.size = 10), part = "all"
  )
  ft <- autofit(ft, add_w = 0, add_h = 0)

  dims <- ft$body$colwidths
  expect_equal(as.vector(dims["sep_1"]), .3, tolerance = .00001)


  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = ft)
  expect_error(
    {
      print(doc, target = docx_file)
    },
    NA
  )
})

plot1 <- tempfile(fileext = ".png")
plot2 <- tempfile(fileext = ".png")
ragg::agg_png(filename = plot1, width = 300, height = 300, units = "px")
plot(1:15, 1:15)
dev.off()
ragg::agg_png(filename = plot2, width = 300, height = 300, units = "px")
plot(1:150, 1:150)
dev.off()

df <- data.frame(
  plot = c(plot1, plot2)
)

test_that("multiple images", {
  skip_if_not_installed("magick")

  ft <- flextable(df)
  ft <- mk_par(ft, j = "plot", value = as_paragraph(as_image(rlogo, width = .3, height = 0.23)), part = "header")
  ft <- mk_par(ft, j = "plot", value = as_paragraph(as_image(plot, guess_size = TRUE)))
  chunk_info <- flextable::information_data_chunk(ft)
  expect_equal(chunk_info$img_data, c(rlogo, df$plot))
  expect_equal(chunk_info$width, c(.3, 300 / 72, 300 / 72))
  expect_equal(chunk_info$height, c(.23, 300 / 72, 300 / 72))


  docx_path <- save_as_docx(ft, path = tempfile(fileext = ".docx"))
  doc <- read_docx(docx_path)
  images_path <- doc$doc_obj$relationship()$get_images_path()
  expect_equal(
    gsub("([a-z0-9]+)(\\.png|\\.jpg)$", "\\2", basename(images_path)),
    c(".jpg", ".png", ".png")
  )

  html_path <- save_as_html(ft, path = tempfile(fileext = ".html"))
  doc <- read_html(html_path)
  all_imgs <- xml_find_all(doc, "//img")
  src_imgs <- xml_attr(all_imgs, "src")
  expect_length(src_imgs, 3)
  if (length(src_imgs) == 3) {
    expect_match(
      src_imgs[1],
      "data:image/jpeg",
      fixed = TRUE
    )
    expect_match(
      src_imgs[2],
      "data:image/png",
      fixed = TRUE
    )
    expect_match(
      src_imgs[3],
      "data:image/png",
      fixed = TRUE
    )
  }

  zz <- gen_grob(ft)
  expect_s3_class(zz$children$cell_1_1$children$contents$ftgrobs[[1]], "rastergrob")
  expect_s3_class(zz$children$cell_2_1$children$contents$ftgrobs[[1]], "rastergrob")
  expect_s3_class(zz$children$cell_3_1$children$contents$ftgrobs[[1]], "rastergrob")

  ft <- flextable(df)
  ft <- colformat_image(ft, j = "plot", width = 300 / 72, height = 300 / 72)
  zz <- gen_grob(ft)
  expect_s3_class(zz$children$cell_1_1$children$contents$ftgrobs[[1]], "text")
  expect_s3_class(zz$children$cell_2_1$children$contents$ftgrobs[[1]], "rastergrob")
  expect_s3_class(zz$children$cell_3_1$children$contents$ftgrobs[[1]], "rastergrob")
})

test_that("minibar", {
  ft <- flextable(data.frame(n = 1:2))

  ft <- mk_par(
    ft,
    j = 1,
    value = as_paragraph(
      minibar(value = n, max = 10, width = .5, barcol = "red", bg = "yellow")
    ),
    part = "body"
  )
  minibar1 <- flextable::information_data_chunk(ft)$img_data[[2]]
  expect_s3_class(minibar1, "raster")
  expect_equal(nrow(minibar1), 1)
  expect_equal(ncol(minibar1), 36)
  expect_equal(minibar1[1:3], rep("#FF0000", 3))
  expect_equal(minibar1[4:36], rep("#FFFF00", 33))

  minibar2 <- flextable::information_data_chunk(ft)$img_data[[3]]
  expect_s3_class(minibar2, "raster")
  expect_equal(nrow(minibar2), 1)
  expect_equal(ncol(minibar2), 36)
  expect_equal(minibar2[1:7], rep("#FF0000", 7))
  expect_equal(minibar2[8:36], rep("#FFFF00", 29))
})

# linerange ----
test_that("linerange basic", {
  ft <- flextable(head(iris, 5))
  ft <- compose(
    ft, j = "Sepal.Length",
    value = as_paragraph(
      linerange(value = Sepal.Length)
    ),
    part = "body"
  )
  chunk_info <- information_data_chunk(ft)
  body_chunks <- chunk_info[chunk_info$.part == "body", ]
  sl_chunks <- body_chunks[body_chunks$.col_id == "Sepal.Length", ]
  expect_equal(nrow(sl_chunks), 5)
  expect_true(all(sl_chunks$width == 1))
  expect_true(all(sl_chunks$height == 0.2))
  expect_true(
    all(vapply(sl_chunks$img_data, inherits, logical(1), "raster"))
  )
})

test_that("linerange with min max and colors", {
  vals <- c(2, 5, 8)
  ft <- flextable(data.frame(x = vals))
  ft <- compose(
    ft, j = "x",
    value = as_paragraph(
      linerange(
        value = x, min = 0, max = 10,
        rangecol = "blue", stickcol = "green",
        bg = "white", width = 2, height = .3
      )
    ),
    part = "body"
  )
  chunk_info <- information_data_chunk(ft)
  body_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "x",
  ]
  expect_equal(nrow(body_chunks), 3)
  expect_true(all(body_chunks$width == 2))
  expect_true(all(body_chunks$height == 0.3))
})

test_that("linerange all NA values", {
  ft <- flextable(data.frame(x = c(NA_real_, NA_real_)))
  ft <- compose(
    ft, j = "x",
    value = as_paragraph(
      linerange(value = x)
    ),
    part = "body"
  )
  chunk_info <- information_data_chunk(ft)
  body_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "x",
  ]
  expect_equal(nrow(body_chunks), 2)
})

test_that("linerange raster_width < 2 errors", {
  expect_error(
    linerange(value = 1:3, raster_width = 1),
    "raster_width"
  )
})

test_that("linerange unit cm", {
  vals <- c(3, 6)
  ft <- flextable(data.frame(x = vals))
  ft <- compose(
    ft, j = "x",
    value = as_paragraph(
      linerange(value = x, width = 2, height = 0.5,
                unit = "cm")
    ),
    part = "body"
  )
  chunk_info <- information_data_chunk(ft)
  body_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "x",
  ]
  # cm -> in conversion: 2cm / 2.54 ~ 0.787
  expect_true(all(abs(body_chunks$width - 2 / 2.54) < 0.01))
})

# plot_chunk ----
test_that("plot_chunk box type", {
  library(data.table)
  z <- as.data.table(iris)
  z <- z[, list(z = list(.SD$Sepal.Length)), by = "Species"]
  ft <- flextable(z, col_keys = c("Species", "box"))
  ft <- mk_par(
    ft, j = "box",
    value = as_paragraph(
      plot_chunk(value = z, type = "box")
    )
  )
  chunk_info <- information_data_chunk(ft)
  box_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "box",
  ]
  expect_equal(nrow(box_chunks), 3)
  expect_true(all(file.exists(unlist(box_chunks$img_data))))
})

test_that("plot_chunk line type", {
  library(data.table)
  z <- as.data.table(iris)
  z <- z[, list(z = list(.SD$Sepal.Length)), by = "Species"]
  ft <- flextable(z, col_keys = c("Species", "pl"))
  ft <- mk_par(
    ft, j = "pl",
    value = as_paragraph(
      plot_chunk(value = z, type = "line")
    )
  )
  chunk_info <- information_data_chunk(ft)
  pl_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "pl",
  ]
  expect_equal(nrow(pl_chunks), 3)
  expect_true(all(file.exists(unlist(pl_chunks$img_data))))
})

test_that("plot_chunk points type", {
  library(data.table)
  z <- as.data.table(iris)
  z <- z[, list(z = list(.SD$Sepal.Length)), by = "Species"]
  ft <- flextable(z, col_keys = c("Species", "pl"))
  ft <- mk_par(
    ft, j = "pl",
    value = as_paragraph(
      plot_chunk(value = z, type = "points")
    )
  )
  chunk_info <- information_data_chunk(ft)
  pl_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "pl",
  ]
  expect_equal(nrow(pl_chunks), 3)
  expect_true(all(file.exists(unlist(pl_chunks$img_data))))
})

test_that("plot_chunk density type", {
  library(data.table)
  z <- as.data.table(iris)
  z <- z[, list(z = list(.SD$Sepal.Length)), by = "Species"]
  ft <- flextable(z, col_keys = c("Species", "pl"))
  ft <- mk_par(
    ft, j = "pl",
    value = as_paragraph(
      plot_chunk(value = z, type = "density")
    )
  )
  chunk_info <- information_data_chunk(ft)
  pl_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "pl",
  ]
  expect_equal(nrow(pl_chunks), 3)
  expect_true(all(file.exists(unlist(pl_chunks$img_data))))
})

test_that("plot_chunk free_scale", {
  library(data.table)
  z <- as.data.table(iris)
  z <- z[, list(z = list(.SD$Sepal.Length)), by = "Species"]
  ft <- flextable(z, col_keys = c("Species", "pl"))
  ft <- mk_par(
    ft, j = "pl",
    value = as_paragraph(
      plot_chunk(
        value = z, type = "box",
        free_scale = TRUE
      )
    )
  )
  chunk_info <- information_data_chunk(ft)
  pl_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "pl",
  ]
  expect_equal(nrow(pl_chunks), 3)
})

# gg_chunk ----
test_that("gg_chunk", {
  skip_if_not_installed("ggplot2")
  library(ggplot2)
  library(data.table)

  z <- as.data.table(iris)
  z <- z[, list(
    gg = list(
      ggplot(.SD, aes(Sepal.Length, Sepal.Width)) +
        geom_point() + theme_void()
    )
  ), by = "Species"]

  ft <- flextable(z)
  ft <- mk_par(
    ft, j = "gg",
    value = as_paragraph(
      gg_chunk(value = gg, width = 1, height = 1)
    )
  )
  chunk_info <- information_data_chunk(ft)
  gg_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "gg",
  ]
  expect_equal(nrow(gg_chunks), 3)
  expect_true(all(file.exists(unlist(gg_chunks$img_data))))
  expect_true(all(gg_chunks$width == 1))
  expect_true(all(gg_chunks$height == 1))
})

test_that("gg_chunk unit cm", {
  skip_if_not_installed("ggplot2")
  library(ggplot2)

  plots <- list(
    ggplot(iris, aes(Sepal.Length)) +
      geom_histogram() + theme_void()
  )
  ft <- flextable(data.frame(g = "a"))
  ft <- mk_par(
    ft, j = "g",
    value = as_paragraph(
      gg_chunk(
        value = plots,
        width = 3, height = 2, unit = "cm"
      )
    )
  )
  chunk_info <- information_data_chunk(ft)
  gg_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "g",
  ]
  expect_true(abs(gg_chunks$width - 3 / 2.54) < 0.01)
  expect_true(abs(gg_chunks$height - 2 / 2.54) < 0.01)
})

# grid_chunk ----
test_that("grid_chunk", {
  library(grid)

  grobs <- list(
    circleGrob(gp = gpar(fill = "red", col = "transparent")),
    rectGrob(gp = gpar(fill = "blue", col = "transparent"))
  )
  ft <- flextable(data.frame(a = c("circle", "rect")))
  ft <- mk_par(
    ft, j = "a",
    value = as_paragraph(
      grid_chunk(
        value = grobs,
        width = .5, height = .5
      )
    )
  )
  chunk_info <- information_data_chunk(ft)
  grid_chunks <- chunk_info[
    chunk_info$.part == "body" &
      chunk_info$.col_id == "a",
  ]
  expect_equal(nrow(grid_chunks), 2)
  expect_true(all(file.exists(unlist(grid_chunks$img_data))))
  expect_true(all(grid_chunks$width == 0.5))
  expect_true(all(grid_chunks$height == 0.5))
})

test_that("grid_chunk in docx output", {
  library(grid)

  grobs <- list(
    circleGrob(gp = gpar(fill = "green", col = "transparent"))
  )
  ft <- flextable(data.frame(a = "dot"))
  ft <- mk_par(
    ft, j = "a",
    value = as_paragraph(
      grid_chunk(value = grobs, width = .3, height = .3)
    )
  )
  docx_file <- tempfile(fileext = ".docx")
  doc <- read_docx()
  doc <- body_add_flextable(doc, value = ft)
  expect_no_error(print(doc, target = docx_file))
  expect_true(file.exists(docx_file))
})
