#' @title Delete flextable content
#' @description Deletion of flextable content. Values will
#' be replaced with \code{NA} values.
#' @param x \code{flextable} object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table
#' @importFrom lazyeval lazy_eval
#' @examples
#' ft <- flextable(mtcars)
#' ft <- void(ft, ~ drat > 3.5, ~ vs + am + gear + carb )
#' @export
void <- function(x, i = NULL, j = NULL, part = "body" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body") ){
      x <- void(x = x, i = i, j = j, part = p)
    }
    return(x)
  }

  if( inherits(i, "formula") && any( "header" %in% part ) ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )

  for( j in x$col_keys[j]){
    x <- display(x, i = i, col_key = j, pattern = " ", formatters = list(), fprops = list(), part = part)
  }


  x
}
