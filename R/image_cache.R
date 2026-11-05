# Decoding an image is slow and the same file is often used by many cells, so
# rasters are kept for the session. A file that changes gets a new key, and the
# least recently used rasters are dropped above `max_bytes`.
image_cache <- new.env(parent = emptyenv())
image_cache$entries <- list()
image_cache$tick <- 0
image_cache$max_bytes <- 256 * 1024^2

image_cache_reset <- function() {
  image_cache$entries <- list()
  invisible(NULL)
}

is_svg_file <- function(path) {
  grepl("\\.svg$", ignore.case = TRUE, x = path)
}

# SVG files are rendered at the requested size, other files do not depend on it
image_cache_key <- function(path, width = NULL, height = NULL) {
  info <- file.info(path, extra_cols = FALSE)
  id <- c(
    normalizePath(path),
    sprintf("%.6f", as.numeric(info$mtime)),
    info$size
  )
  if (is_svg_file(path)) {
    id <- c(id, width, height)
  }
  paste(id, collapse = "|")
}

read_image_file <- function(path, width = NULL, height = NULL) {
  if (is_svg_file(path)) {
    image <- magick::image_read_svg(path, width * 72, height * 72)
  } else {
    image <- magick::image_read(path)
  }
  as.raster(image)
}

# keeps at least the last raster, even if it is larger than `max_bytes`
image_cache_shrink <- function() {
  repeat {
    entries <- image_cache$entries
    bytes <- vapply(entries, function(z) z$bytes, numeric(1))
    if (sum(bytes) <= image_cache$max_bytes || length(entries) < 2L) {
      return(invisible(NULL))
    }
    ticks <- vapply(entries, function(z) z$tick, numeric(1))
    image_cache$entries[[names(entries)[which.min(ticks)]]] <- NULL
  }
}

#' @export
#' @title Read an image as a raster, with a cache
#' @description Read an image file as a raster object. The raster is kept for
#' the R session, so that an image used many times is only decoded once. The
#' file is read again if it has changed, and the least recently used rasters
#' are dropped when the cache becomes too large.
#'
#' This function is used by [gen_grob()] and is exported for packages that
#' draw the same images with 'grid'. Package 'magick' is required.
#' @param path path to the image file.
#' @param width,height size in inches at which an SVG file is rendered, they
#' are ignored with other formats.
#' @return A raster object. An error is raised if the file can not be read.
#' @keywords internal
image_raster <- function(path, width = NULL, height = NULL) {
  key <- image_cache_key(path, width, height)
  image_cache$tick <- image_cache$tick + 1
  entry <- image_cache$entries[[key]]
  if (is.null(entry)) {
    raster <- read_image_file(path, width, height)
    # a raster is a matrix of pointers to strings
    bytes <- prod(dim(raster)) * 8
    image_cache$entries[[key]] <- list(
      raster = raster,
      bytes = bytes,
      tick = image_cache$tick
    )
    image_cache_shrink()
    return(raster)
  }
  image_cache$entries[[key]]$tick <- image_cache$tick
  entry$raster
}
