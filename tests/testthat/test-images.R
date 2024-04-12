context("check images")

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
  expect_is(zz$children$cell_1_1$children$contents$ftgrobs[[1]], "rastergrob")
  expect_is(zz$children$cell_2_1$children$contents$ftgrobs[[1]], "rastergrob")
  expect_is(zz$children$cell_3_1$children$contents$ftgrobs[[1]], "rastergrob")

  ft <- flextable(df)
  ft <- colformat_image(ft, j = "plot", width = 300 / 72, height = 300 / 72)
  zz <- gen_grob(ft)
  expect_is(zz$children$cell_1_1$children$contents$ftgrobs[[1]], "text")
  expect_is(zz$children$cell_2_1$children$contents$ftgrobs[[1]], "rastergrob")
  expect_is(zz$children$cell_3_1$children$contents$ftgrobs[[1]], "rastergrob")
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
  expect_is(minibar1, "raster")
  expect_equal(nrow(minibar1), 1)
  expect_equal(ncol(minibar1), 36)
  expect_equal(minibar1[1:3], rep("#FF0000", 3))
  expect_equal(minibar1[4:36], rep("#FFFF00", 33))

  minibar2 <- flextable::information_data_chunk(ft)$img_data[[3]]
  expect_is(minibar2, "raster")
  expect_equal(nrow(minibar2), 1)
  expect_equal(ncol(minibar2), 36)
  expect_equal(minibar2[1:7], rep("#FF0000", 7))
  expect_equal(minibar2[8:36], rep("#FFFF00", 29))
})

