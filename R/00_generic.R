add_rows <- function(x, ...){
  UseMethod("add_rows")
}
format_fun <- function( x, na_string = "", ... ){
  UseMethod("format_fun")
}

#' @title method to convert object to flextable
#' @description This is a convenient function
#' to let users create flextable bindings
#' from any objects.
#' @param x object to be transformed as flextable
#' @param ... arguments for custom methods
#' @export
as_flextable <- function( x, ... ){
  UseMethod("as_flextable")
}

