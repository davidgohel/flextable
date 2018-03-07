#' @export
#' @title hyperlink wrapper
#' @description The function has to be used with function display().
#' It lets add hyperlinks within flextable.
#' @param url,label url and label to be used
#' @seealso \code{\link{display}}
#' @examples
#' dat <- data.frame(
#'   col = "CRAN website", href = "https://cran.r-project.org",
#'   stringsAsFactors = FALSE)
#'
#' ft <- flextable(dat)
#' ft <- display(
#'   ft, col_key = "col", pattern = "# {{mylink}}",
#'   formatters = list(mylink ~ hyperlinked_text(href, col) )
#' )
#' ft
#'
#'
#' dat <- data.frame(
#'   col = "Google it",
#'   href = "https://www.google.fr/search?source=hp&q=officer+R+package",
#'   stringsAsFactors = FALSE)
#'
#' ft <- flextable(dat)
#' ft <- display( x = ft,
#'   col_key = "col",
#'   pattern = "This is a link: {{mylink}}",
#'   formatters = list(mylink ~ hyperlink_text(href, col) ) )
#' ft
hyperlink_text <- function(url, label = url){
  x <- data.frame( str = label, href = url, stringsAsFactors = FALSE)
  class(x) <- c( "hyperlinked_text", class(x) )
  x
}


#' @export
#' @title draw a single bar
#' @description This function is used to insert bars into flextable with function \code{display}
#' @param value bar height
#' @param max max bar height
#' @param barcol bar color
#' @param bg background color
#' @param width,height size of the resulting png file in inches
#' @importFrom grDevices as.raster col2rgb rgb
minibar <- function(value, max, barcol = "#CCCCCC", bg = "transparent", width = 1, height = .2) {
  stopifnot(value >= 0, max >= 0)
  barcol <- rgb(t(col2rgb(barcol))/255)
  bg <- ifelse( bg == "transparent", bg, rgb(t(col2rgb(bg))/255) )
  if( any(value > max) ){
    warning("value > max, truncate to max")
    value[value > max] <- max
  }
  width_ <- as.integer(width * 72)
  value <- as.integer( (value / max) * width_ )
  n_empty <- width_ - value

  src <- sapply(seq_along(value), function(x) tempfile(fileext = ".png") )

  rasters <- mapply(function(count_on, count_off, bg_on, bg_off ){
    as.raster( matrix(c(rep(bg_on, count_on), rep(bg_off, count_off)), nrow = 1) )
  }, value, n_empty, bg_on = barcol, bg_off = bg,
  SIMPLIFY = FALSE )
  mapply(function(src, raster, width, height){
    raster_write(x = raster, path = src, width = width*72, height = height*72 )
  }, src = src, raster = rasters, width = width, height = height,
  SIMPLIFY = FALSE )

  image_entry(src = src, width = width, height = height)
}


#' @export
#' @title image wrapper
#' @description The function has to be used with function display().
#' It lets add images within flextable.
#' @param x image will be repeated while iterating this variable. The variable should be
#' one of the original data frame. Note its values are not used, only its size.
#' @param src image filename
#' @param width,height size of the png file in inches
#' @seealso \code{\link{display}}
#' @examples
#' library(officer)
#' img.file <- file.path( R.home("doc"), "html", "logo.jpg" )
#' myft <- flextable(head( mtcars, n = 10))
#' myft <- display(myft,
#'     i = ~ qsec > 18, col_key = "qsec", pattern = "{{r_logo}}",
#'     formatters = list( r_logo ~ as_image(qsec,
#'       src = img.file, width = .20, height = .15)),
#'     fprops = list(qsec = fp_text(color = "orange")) )
#' myft
as_image <- function(x, src, width = 1, height = .2) {
  image_entry(src = rep(src, length(x)),
              width = width, height = height)
}
