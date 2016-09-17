#' @title delete flextable content
#' @description deletion of flextable content. Intenally, values will
#' be replaced with \code{NA} values.
#' @param x \code{flextable} object
#' @param i rows selection
#' @param j columns selection
#' @param part partname of the table
#' @importFrom lazyeval lazy_eval
#' @examples
#' ft <- flextable(mtcars)
#' ft <- empty(ft, ~ drat > 3.5, ~ vs + am + gear + carb )
#' write_docx("empty_ft.docx", ft)
#' @export
empty <- function(x, i = NULL, j = NULL, part = "body" ){

  if( inherits(i, "formula") && any( "header" %in% part ) ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  }
  j <- get_columns_id(x[[part]], j )

  x[[part]]$dataset[i, j] <- NA

  x
}
