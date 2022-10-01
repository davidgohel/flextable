compare_image <- function(img1, img2){
  require("magick")
  img.reference <- image_raster(magick::image_read(img1), tidy = FALSE)
  img.empty <- image_raster(magick::image_read(img2), tidy = FALSE)
  sum(img.reference == img.empty) == length(img.reference)
}

save_pptx <- function(x, path) {
  require("doconv")
  pptx_path <- save_as_pptx(x, path = tempfile(fileext = ".pptx"))
  to_miniature(pptx_path, fileout = path, width = 1600)
  path
}

save_docx <- function(x, path) {
  require("doconv")
  docx_path <- save_as_docx(x, path = tempfile(fileext = ".docx"))
  to_miniature(docx_path, fileout = path, width = 1000)
  path
}
save_html <- function(x, path) {
  require("webshot")
  html_file <- tempfile(fileext = ".html")
  save_as_html(x, path = html_file)
  curr_wd <- getwd()
  path <- flextable:::absolute_path(path)
  setwd(dirname(html_file))
  tryCatch({
    webshot::webshot(url = basename(html_file), file = path, zoom = 3, expand = 0 )
  }, finally = {
    setwd(curr_wd)
  })
  path
}

docx_to_miniature <- function(x, path) {
  require("doconv")
  to_miniature(x, fileout = path, width = 1000)
  path
}
pdf_to_miniature <- function(x, path) {
  require("doconv")
  to_miniature(x, fileout = path, width = 1000)
  path
}
pptx_to_miniature <- function(x, path) {
  require("doconv")
  to_miniature(x, fileout = path, width = 1200)
  path
}
html_to_miniature <- function(x, path) {
  curr_wd <- getwd()
  x <- flextable:::absolute_path(x)
  setwd(dirname(x))
  tryCatch({
    webshot::webshot(url = basename(x), file = path, zoom = 3, expand = 0 )
  }, finally = {
    setwd(curr_wd)
  })
  path
}

expect_snapshot_rdocx <- function(name, x) {
  name <- paste0(name, ".png")
  announce_snapshot_file(name = name)
  docx_path <- tempfile(fileext = ".docx")
  path = tempfile(fileext = ".png")
  print(x, target = docx_path)
  doconv::to_miniature(docx_path, fileout = path, width = 1000)
  expect_snapshot_file(path, name, compare = compare_image)
}

expect_snapshot_to <- function(name, x, format = "docx") {
  name <- paste0(name, ".png")
  announce_snapshot_file(name = name)
  if ("docx" %in% format) {
    path <- save_docx(x, path = tempfile(fileext = ".png"))
  } else if ("pptx" %in% format) {
    path <- save_pptx(x, path = tempfile(fileext = ".png"))
  } else if ("pdf" %in% format) {
    path <- save_pdf(x, path = tempfile(fileext = ".png"))
  } else if ("html" %in% format) {
    path <- save_html(x, path = tempfile(fileext = ".png"))
  } else {
    path <- save_docx(x, path = tempfile(fileext = ".png"))
  }
  expect_snapshot_file(path, name, compare = compare_image)
}

expect_snapshot_rmd <- function(name, x, format = "docx") {
  name <- paste0(name, ".png")
  announce_snapshot_file(name = name)
  if ("docx" %in% format) {
    path <- docx_to_miniature(x, path = tempfile(fileext = ".png"))
  } else if ("pptx" %in% format) {
    path <- pptx_to_miniature(x, path = tempfile(fileext = ".png"))
  } else if ("pdf" %in% format) {
    path <- pdf_to_miniature(x, path = tempfile(fileext = ".png"))
  } else if ("html" %in% format) {
    path <- html_to_miniature(x, path = tempfile(fileext = ".png"))
  } else {
    stop("cas non gere")
  }
  expect_snapshot_file(path, name, compare = compare_image)
}

