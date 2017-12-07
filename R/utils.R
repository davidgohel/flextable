
globalVariables(c("str", ".", "str_is_run"))

image_entry <- function(src, width, height){
  x <- data.frame(image_src = src, width = width, height = height, stringsAsFactors = FALSE)
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
    out <- mapply( function(image_src, width, height){
      format( external_img(src = image_src, width = width, height = height), type = type )
    }, x$image_src, x$width, x$height, SIMPLIFY = FALSE)
    out <- setNames(unlist(out), NULL)
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
#' img.file <- file.path( Sys.getenv("R_HOME"), "doc", "html", "logo.jpg" )
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

drop_column <- function(x, cols){
  x[, !(colnames(x) %in% cols), drop = FALSE]
}





as_grp_index <- function(x){
  sprintf( "gp_%09.0f", x )
}

group_index <- function(x, by, varname = "grp"){
  order_ <- do.call( order, x[ by ] )
  x$ids_ <- seq_along(order_)
  x <- x[order_, ,drop = FALSE]
  gprs <- cumsum(!duplicated(x[, by ]) )
  gprs <- gprs[order(x$ids_)]
  as_grp_index(gprs)
}

group_ref <- function(x, by, varname = "grp"){
  order_ <- do.call( order, x[ by ] )
  x$ids_ <- seq_along(order_)
  x <- x[order_, ,drop = FALSE]
  ref <- x[!duplicated(x[, by ]), by]
  ref$index_ <- as_grp_index( seq_len( nrow(ref) ) )
  row.names(ref) <- NULL
  ref
}

drop_useless_blank <- function( x ){
  grp <- group_index(x, by = c("col_key", "id") )
  x <- split( x, grp)
  x <- lapply( x, function(x){
    non_empty <- which( !x$str %in% c("", NA) | x$type_out %in% "image_entry" )
    if(length(non_empty)) x[non_empty,]
    else x[1,]
  })
  do.call(rbind, x)
}

get_i_from_formula <- function( f, data ){
  if( length(f) > 2 )
    stop("formula selection is not as expected ( ~ condition )", call. = FALSE)
  i <- eval(as.call(f[[2]]), envir = data)
  if( !is.logical(i) )
    stop("formula selection should return a logical vector", call. = FALSE)
  i
}
get_j_from_formula <- function( f, data ){
  if( length(f) > 2 )
    stop("formula selection is not as expected ( ~ variables )", call. = FALSE)
  j <- attr(terms(f), "term.labels")
  names_ <- names(data)
  if( any( invalid_names <- (!j %in% names_) ) ){
    invalid_names <- paste0("[", j[invalid_names], "]", collapse = ", ")
    stop("unknown variables:", invalid_names, call. = FALSE)
  }
  j
}

check_formula_i_and_part <- function(i, part){
  if( inherits(i, "formula") && "header" %in% part ){
    stop("formula in argument i cannot adress part 'header'.", call. = FALSE)
  }
  TRUE
}


