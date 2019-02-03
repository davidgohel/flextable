#' @title Merge flextable cells vertically
#'
#' @description Merge flextable cells vertically when consecutive cells have
#' identical values.
#'
#' @param x \code{flextable} object
#' @param j columns names/keys where cells have to be merged.
#' @param part partname of the table where merge has to be done.
#' @examples
#' ft_merge <- flextable(mtcars)
#' ft_merge <- merge_v(ft_merge, j = c("gear", "carb"))
#' ft_merge
#' @family flextable merging function
#' @export
merge_v <- function(x, j = NULL, part = "body" ){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  j <- get_columns_id(x[[part]], j = j )
  j <- x$col_keys[j]

  x[[part]] <- span_columns(x = x[[part]], columns = j)

  x
}

#' @title Merge flextable cells horizontally
#'
#' @description Merge flextable cells horizontally when consecutive cells have
#' identical values.
#'
#' @param x \code{flextable} object
#' @param i rows where cells have to be merged.
#' @param part partname of the table where merge has to be done.
#' @family flextable merging function
#' @examples
#' dummy_df <- data.frame( col1 = letters,
#' col2 = letters, stringsAsFactors = FALSE )
#' ft_merge <- flextable(dummy_df)
#' ft_merge <- merge_h(x = ft_merge)
#' ft_merge
#' @export
merge_h <- function(x, i = NULL, part = "body" ){

  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  i <- get_rows_id( x[[part]], i )
  x[[part]] <- span_rows(x = x[[part]], rows = i)

  x
}


#' @title Delete flextable merging informations
#'
#' @description Delete all merging informations from a flextable.
#'
#' @param x \code{flextable} object
#' @param part partname of the table where merge has to be done.
#' @family flextable merging function
#' @export
#' @examples
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
#' ft <- theme_tron_legacy( merge_none( ft ) )
#' ft
merge_none <- function(x, part = "all" ){

  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    args <- list()
    for( p in c("header", "footer", "body") ){
      x <- merge_none(x = x, part = p )
    }
  }

  x[[part]] <- span_free(x[[part]])

  x
}





#' @title Merge flextable cells into a single one
#'
#' @description Merge flextable cells into a single one. All
#' rows and columns must be consecutive.
#'
#' @param x \code{flextable} object
#' @param i,j columns and rows to merge
#' @param part partname of the table where merge has to be done.
#' @family flextable merging function
#' @examples
#' ft_merge <- flextable( head( mtcars ), cwidth = .5 )
#' ft_merge <- merge_at( ft_merge, i = 1:2, j = 1:3 )
#' ft_merge
#' @export
merge_at <- function(x, i = NULL, j = NULL, part = "body" ){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  j <- get_columns_id(x[[part]], j = j )
  j <- x$col_keys[j]

  i <- get_rows_id( x[[part]], i )

  x[[part]] <- span_cells_at(x = x[[part]], columns = j, rows = i)

  x
}


#' @title rowwise merge of a range of columns
#'
#' @description Merge flextable columns into a single one for each selected rows. All
#' columns must be consecutive.
#'
#' @param x \code{flextable} object
#' @param i selected rows
#' @param j1,j2 selected columns
#' @param part partname of the table where merge has to be done.
#' @family flextable merging function
#' @examples
#' ft <- flextable( head( mtcars ), cwidth = .5 )
#' ft <- merge_h_range( ft, i =  ~ cyl == 6, j1 = "am", j2 = "carb")
#' ft
#' @export
merge_h_range <- function(x, i = NULL, j1 = NULL, j2 = NULL, part = "body" ){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  j1 <- get_columns_id(x[[part]], j = j1 )
  j2 <- get_columns_id(x[[part]], j = j2 )

  seq_cols <- j1:j2

  i <- get_rows_id( x[[part]], i )
  x[[part]]$spans$rows[ i, seq_cols] <- 0
  x[[part]]$spans$rows[ i, j1] <- length(seq_cols)
  check_merge(x[[part]])


  x
}




