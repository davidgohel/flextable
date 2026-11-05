write_test_png <- function(path, color = "red", width = 20) {
  magick::image_write(
    magick::image_blank(width, 10, color = color),
    path = path,
    format = "png"
  )
  path
}

count_image_reads <- function(env = parent.frame()) {
  counter <- new.env()
  counter$n <- 0L
  decode <- read_image_file
  local_mocked_bindings(
    read_image_file = function(...) {
      counter$n <- counter$n + 1L
      decode(...)
    },
    .env = env
  )
  counter
}

local_empty_image_cache <- function(env = parent.frame()) {
  image_cache_reset()
  withr::defer(image_cache_reset(), envir = env)
}

# draw on a device and return the pixels: raster and native raster must give
# the same output
drawn_pixels <- function(image) {
  png <- withr::local_tempfile(fileext = ".png")
  ragg::agg_png(png, width = 200, height = 200, units = "px", res = 72)
  grid::grid.draw(grid::rasterGrob(
    image,
    width = grid::unit(1.5, "in"),
    height = grid::unit(1, "in")
  ))
  grDevices::dev.off()
  as.integer(magick::image_data(magick::image_read(png), "rgba"))
}

test_that("a native raster is drawn as a raster", {
  skip_if_not_installed("magick")
  gradient <- magick::image_blank(64, 48, pseudo_image = "gradient:red-blue")
  transparent <- magick::image_blank(40, 30, color = "#FF000080")
  images <- list(
    png = magick::image_convert(gradient, format = "png"),
    transparent_png = magick::image_convert(transparent, format = "png"),
    jpeg = magick::image_convert(gradient, format = "jpeg"),
    gray = magick::image_convert(gradient, format = "png", colorspace = "gray"),
    animated_gif = magick::image_animate(
      c(gradient, magick::image_flip(gradient)),
      fps = 5
    )
  )
  for (kind in names(images)) {
    path <- withr::local_tempfile(fileext = ".img")
    magick::image_write(images[[kind]], path = path)
    image <- magick::image_read(path)
    expect_identical(
      drawn_pixels(as_native_raster(image)),
      drawn_pixels(as.raster(image)),
      label = kind
    )
  }
})

test_that("an image is decoded once", {
  skip_if_not_installed("magick")
  local_empty_image_cache()
  reads <- count_image_reads()
  path <- write_test_png(withr::local_tempfile(fileext = ".png"))

  first <- image_raster(path)
  second <- image_raster(path)

  expect_identical(second, first)
  expect_s3_class(first, "nativeRaster")
  expect_equal(reads$n, 1L)
})

test_that("a file that has changed is read again", {
  skip_if_not_installed("magick")
  local_empty_image_cache()
  path <- write_test_png(withr::local_tempfile(fileext = ".png"))
  first <- image_raster(path)

  write_test_png(path, color = "blue", width = 30)
  second <- image_raster(path)

  expect_false(identical(second, first))
  expect_equal(dim(second), c(10L, 30L))
})

test_that("a different path gives its own raster", {
  skip_if_not_installed("magick")
  local_empty_image_cache()
  red <- write_test_png(withr::local_tempfile(fileext = ".png"), "red")
  blue <- write_test_png(withr::local_tempfile(fileext = ".png"), "blue")

  expect_false(identical(image_raster(red), image_raster(blue)))
})

test_that("size only matters for SVG files", {
  skip_if_not_installed("magick")
  skip_if_not_installed("rsvg")
  local_empty_image_cache()
  reads <- count_image_reads()

  png <- write_test_png(withr::local_tempfile(fileext = ".png"))
  image_raster(png, 1, 1)
  image_raster(png, 2, 2)
  expect_equal(reads$n, 1L)

  svg <- withr::local_tempfile(fileext = ".svg")
  writeLines(
    paste0(
      '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10">',
      '<rect width="10" height="10" fill="red"/></svg>'
    ),
    svg
  )
  small <- image_raster(svg, 1, 1)
  large <- image_raster(svg, 2, 2)
  expect_equal(reads$n, 3L)
  expect_equal(dim(small), c(72L, 72L))
  expect_equal(dim(large), c(144L, 144L))
  expect_identical(image_raster(svg, 1, 1), small)
  expect_equal(reads$n, 3L)
})

test_that("the least recently used rasters are dropped", {
  skip_if_not_installed("magick")
  local_empty_image_cache()
  withr::defer(image_cache$max_bytes <- 256 * 1024^2)
  reads <- count_image_reads()
  # 20 x 10 pixels: 800 bytes each, room for two of them
  image_cache$max_bytes <- 1600

  a <- write_test_png(withr::local_tempfile(fileext = ".png"), "red")
  b <- write_test_png(withr::local_tempfile(fileext = ".png"), "green")
  c <- write_test_png(withr::local_tempfile(fileext = ".png"), "blue")

  image_raster(a)
  image_raster(b)
  image_raster(a) # b is now the oldest
  image_raster(c) # b is dropped
  expect_equal(length(image_cache$entries), 2L)
  expect_equal(reads$n, 3L)

  image_raster(a)
  expect_equal(reads$n, 3L)
  image_raster(b)
  expect_equal(reads$n, 4L)
})

test_that("a raster larger than the limit is kept when it is the last one", {
  skip_if_not_installed("magick")
  local_empty_image_cache()
  withr::defer(image_cache$max_bytes <- 256 * 1024^2)
  reads <- count_image_reads()
  image_cache$max_bytes <- 1

  a <- write_test_png(withr::local_tempfile(fileext = ".png"), "red")
  b <- write_test_png(withr::local_tempfile(fileext = ".png"), "blue")

  image_raster(a)
  image_raster(a)
  expect_equal(reads$n, 1L)
  image_raster(b)
  expect_equal(length(image_cache$entries), 1L)
})

test_that("an unreadable file is an error and is not cached", {
  skip_if_not_installed("magick")
  local_empty_image_cache()
  bad <- withr::local_tempfile(fileext = ".png")
  writeLines("not an image", bad)

  expect_error(image_raster(bad))
  expect_length(image_cache$entries, 0L)
})

test_that("gen_grob() decodes an image used by many cells once", {
  skip_if_not_installed("magick")
  local_empty_image_cache()
  reads <- count_image_reads()
  path <- write_test_png(withr::local_tempfile(fileext = ".png"))

  ft <- flextable(data.frame(a = rep("x", 5)))
  ft <- compose(
    ft,
    j = "a",
    value = as_paragraph(as_image(path, width = .2, height = .1))
  )
  gen_grob(ft, fit = "fixed")
  expect_equal(reads$n, 1L)

  gen_grob(ft, fit = "fixed")
  expect_equal(reads$n, 1L)
})

test_that("cells of a grob share the same raster", {
  skip_if_not_installed("magick")
  skip_if_not(capabilities("profmem"))
  local_empty_image_cache()
  path <- write_test_png(withr::local_tempfile(fileext = ".png"))

  find_rasters <- function(x) {
    if (inherits(x, "rastergrob")) {
      return(list(x$raster))
    }
    unlist(lapply(x$children, find_rasters), recursive = FALSE)
  }
  # tracemem() returns the address of the object
  address <- function(x) {
    res <- tracemem(x)
    untracemem(x)
    res
  }

  ft <- flextable(data.frame(a = rep("x", 5)))
  ft <- compose(
    ft,
    j = "a",
    value = as_paragraph("text ", as_image(path, width = .2, height = .1))
  )
  rasters <- find_rasters(gen_grob(ft, fit = "fixed"))

  expect_length(rasters, 5L)
  expect_setequal(
    vapply(rasters, address, character(1)),
    address(image_raster(path))
  )
})

test_that("gen_grob() warns on missing and unreadable files", {
  skip_if_not_installed("magick")
  local_empty_image_cache()

  missing_file <- withr::local_tempfile(fileext = ".png")
  ft <- compose(
    flextable(data.frame(a = "x")),
    j = "a",
    value = as_paragraph(as_image(missing_file, width = .2, height = .1))
  )
  expect_warning(gen_grob(ft, fit = "fixed"), "can not be found")

  bad <- withr::local_tempfile(fileext = ".png")
  writeLines("not an image", bad)
  ft <- compose(
    flextable(data.frame(a = "x")),
    j = "a",
    value = as_paragraph(as_image(bad, width = .2, height = .1))
  )
  expect_warning(gen_grob(ft, fit = "fixed"), "error reading image")
})
