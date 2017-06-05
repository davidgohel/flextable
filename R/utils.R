
globalVariables(c("str", "col_key", "id", ".", "str_is_run"))

function(x, i = NULL){

}


image_entry <- function(src, width, height){
  x <- tibble(image_src = src, width = width, height = height)
  class(x) <- c( "image_entry", class(x) )
  x
}

format.image_entry = function (x, type = "console", ...){
  stopifnot( length(type) == 1)
  stopifnot( type %in% c("wml", "pml", "html", "console") )

  if( type == "pml" ){
    out <- rep("", nrow(x))
  } else if( type == "console" ){
    out <- rep("{image_entry:{...}}", nrow(x))
  } else {
    out <- pmap_chr( x, function(image_src, width, height){
      format( external_img(src = image_src, width = width, height = height), type = type )
    })
  }
  out
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
#' @importFrom purrr pwalk
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

  src <- map_chr(seq_along(value), function(x) tempfile(fileext = ".png") )
  rasters <- purrr::pmap(list(value, n_empty), function(count_on, count_off, bg_on, bg_off ){
    as.raster( matrix(c(rep(bg_on, count_on), rep(bg_off, count_off)), nrow = 1) )
  }, bg_on = barcol, bg_off = bg )
  pwalk(list(src = src, raster = rasters ), function(src, raster, width, height){
    raster_write(x = raster, path = src, width = width*72, height = height*72 )
  }, width = width, height = height)

  image_entry(src = src, width = width, height = height)
}


#' @export
#' @title image
#' @description image
#' @param x dummy variable
#' @param src image filename
#' @param width,height size of the resulting png file in inches
#' @importFrom grDevices as.raster col2rgb rgb
as_image <- function(x, src, width = 1, height = .2) {
  image_entry(src = rep(src, length(x)),
              width = width, height = height)
}
