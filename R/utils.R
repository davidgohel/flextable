
globalVariables(c(".", "size", "col_key", "fid", "font.family",
                  "id", "pptag", "ref", "value",
                  "fp_p", "fp_t", "p"))

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
  if( value > max ){
    warning("value > max, truncate to max")
    value <- max
  }
  width_ <- as.integer(width * 72)
  value <- as.integer( (value / max) * width_ )
  n_empty <- width_ - value
  out <- tempfile(fileext = ".png")
  class(out) <- c("minibar", "cot")
  attr(out, "dims") <- list(width = width, height = height)
  attr(out, "r") <- as.raster( matrix(c(rep(barcol, value), rep(bg, n_empty)), nrow = 1) )

  out
}

#' @rdname minibar
#' @param x \code{minibar} object
#' @export
dim.minibar <- function( x ){
  x <- attr(x, "dims")
  data.frame(width = x$width, height = x$height)
}

#' @rdname minibar
#' @export
as.data.frame.minibar <- function( x, ... ){
  dimx <- attr(x, "dims")
  data.frame(path = as.character(x), width = dimx$width, height = dimx$height)
}

#' @param type output format
#' @param ... unused
#' @export
#' @importFrom gdtools raster_write raster_str
#' @rdname minibar
format.minibar = function (x, type = "console", ...){
  stopifnot( length(type) == 1)
  stopifnot( type %in% c("wml", "pml", "html", "console") )
  dims <- dim(x)
  width <- attr(x, "dims")$width * 72
  height <- attr(x, "dims")$height * 72
  r_ <- attr(x, "r")
  if( type == "pml" ){
    out <- ""
  } else if( type == "console" ){
    out <- "{raster:{...}}"
  } else {
    file <- raster_write(x = r_, path = as.character(x), width = width, height = height )
    out <- format( external_img(src = file, width = attr(x, "dims")$width, height = attr(x, "dims")$height), type = type )
  }
  out
}

