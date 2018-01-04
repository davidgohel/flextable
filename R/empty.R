#' @title Delete flextable content
#' @description Set content display as a blank \code{" "}.
#' @param x \code{flextable} object
#' @param j columns selection
#' @param part partname of the table
#' @examples
#' ft <- flextable(mtcars)
#' ft <- void(ft, ~ vs + am + gear + carb )
#' @export
void <- function(x, j = NULL, part = "body" ){

  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- void(x = x, j = j, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  j <- get_columns_id(x[[part]], j )
  display_singlespace(x = x, j = j, part = part )
}


display_singlespace <- function( x, j = NULL, part = "body" ){
  UseMethod("display_singlespace")
}

display_singlespace.complextable <- function(x, j = NULL, part = "body"){

  for( j in x$col_keys[j]){
    x <- display(x, i = NULL, col_key = j, pattern = " ",
                 formatters = list(), fprops = list(), part = part)
  }
  x

}

display_singlespace.regulartable <- function(x, j = NULL, part = "body"){
  args_ <- lapply( x$col_keys[j], function(z) function(x) rep(" ", length(x) ) )
  names(args_) <- x$col_keys[j]
  args_$x <- x
  args_$part <- part
  do.call(set_formatter, args_)
}
