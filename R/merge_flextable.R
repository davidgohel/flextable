#' @title merge flextable cells
#'
#' @description Merge flextable cells consecutive identical values. Function
#' \code{merge_none} delete all merging informations.
#'
#' @param x \code{flextable} object
#' @param j columns names/keys where cells have to be merged.
#' @param i rows where cells have to be merged.
#' @param part partname of the table where merge has to be done.
#' @examples
#' # merge_v example --------
#' ft_merge <- flextable(mtcars)
#' ft_merge <- merge_v(ft_merge, j = c("gear", "carb"))
#' write_docx("ft_merge_v.docx", ft_merge)
#'
#' # merge_h example --------
#' dummy_df <- data.frame( col1 = letters,
#' col2 = letters, stringsAsFactors = FALSE )
#' ft_merge <- flextable(dummy_df)
#' ft_merge <- merge_h(x = ft_merge)
#' write_docx("ft_merge_h.docx", ft_merge)
#' @rdname merge_flextable
#' @export
merge_v <- function(x, j = NULL, part = "body" ){
  part <- match.arg(part, c("body", "header"), several.ok = FALSE )

  if( inherits(j, "formula") ){
    j <- attr(terms(j), "term.labels")
  } else {
    j <- get_columns_id(x[[part]], j = j )
    j <- x$col_keys[j]
  }

  x[[part]] <- span_columns(x = x[[part]], columns = j)

  x
}

#' @importFrom lazyeval lazy_eval
#' @rdname merge_flextable
#' @export
merge_h <- function(x, i = NULL, part = "body" ){

  part <- match.arg(part, c("body", "header"), several.ok = FALSE )

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id( x[[part]], i )

  x[[part]] <- span_rows(x = x[[part]], rows = i)

  x
}

#' @importFrom lazyeval lazy_eval
#' @rdname merge_flextable
#' @export
#' @examples
#'
#' # merge_none example --------
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species" ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE )
#'
#' ft <- flextable( head( iris ) )
#' ft <- set_header_df(ft, mapping = typology, key = "col_keys" )
#' ft <- merge_v(ft, j = c("Species"))
#'
#' theme_tron_legacy( merge_none( ft ) )
merge_none <- function(x, part = "all" ){

  part <- match.arg(part, c("all", "body", "header"), several.ok = FALSE )

  if( part == "all" ){
    args <- list()
    for( p in c("header", "body") ){
      x <- merge_none(x = x, part = p )
    }
  }

  x[[part]] <- span_free(x[[part]])

  x
}

