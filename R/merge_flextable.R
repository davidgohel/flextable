#' @title merge flextable cells
#'
#' @description Merge flextable cells consecutive identical values.
#'
#' @param x \code{flextable} object
#' @param j columns names/keys where cells have to be merged.
#' @param i rows where cells have to be merged.
#' @param part partname of the table where merge has to be done.
#' @examples
#' ft_merge <- flextable(mtcars)
#' ft_merge <- merge_v(ft_merge, j = c("gear", "carb"))
#' write_docx("ft_merge_v.docx", ft_merge)
#'
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


