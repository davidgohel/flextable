#' @title Delete flextable content
#' @description Set content display as a blank `" "`.
#' @param x `flextable` object
#' @param j columns selection
#' @param part partname of the table
#' @examples
#' ftab <- flextable(head(mtcars))
#' ftab <- void(ftab, ~ vs + am + gear + carb )
#' ftab
#' @export
void <- function(x, j = NULL, part = "body" ){

  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
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
  x[[part]]$content[,x$col_keys[j]] <- as_paragraph(as_chunk(x = "", fp_text()))
  x
}
