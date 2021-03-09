#' @export
#' @title Number of rows of a part
#' @family flextable dimensions
#' @description returns the number of lines in a part of flextable.
#' @param x flextable object
#' @param part partname of the table (one of 'body', 'header', 'footer')
#' @examples
#' library(flextable)
#' ft <- qflextable(head(cars))
#' nrow_part(ft, part = "body")
nrow_part <- function(x, part = "body"){
  if( !inherits(x, "flextable") ) stop("nrow_part supports only flextable objects.")
  if( is.null(x[[part]]) )
    0
  else if( is.null(x[[part]]$dataset) )
    0
  else nrow(x[[part]]$dataset)
}

#' @export
#' @title Number of columns
#' @family flextable dimensions
#' @description returns the number of columns displayed
#' @param x flextable object
#' @examples
#' library(flextable)
#' ft <- qflextable(head(cars))
#' ncol_keys(ft)
ncol_keys <- function(x){
  if( !inherits(x, "flextable") ) stop("ncol_keys supports only flextable objects.")
  length(x$col_keys)
}
