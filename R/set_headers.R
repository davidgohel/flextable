#' @title Set flextable's headers labels
#'
#' @description This function set labels for specified columns
#' in a single row header of a flextable.
#'
#' @param x a \code{flextable} object
#' @param ... named arguments (names are data colnames), each element is a single character
#' value specifying label to use.
#' @param values a named list (names are data colnames), each element is a single character
#' value specifying label to use. If provided, argument \code{...} will be ignored.
#' @examples
#' ft_1 <- flextable( head( iris ))
#' ft_1 <- set_header_labels(ft_1, Sepal.Length = "Sepal length",
#'   Sepal.Width = "Sepal width", Petal.Length = "Petal length",
#'   Petal.Width = "Petal width"
#' )
#'
#' ft_2 <- flextable( head( iris ))
#' ft_2 <- set_header_labels(ft_2,
#'   values = list(Sepal.Length = "Sepal length",
#'                 Sepal.Width = "Sepal width",
#'                 Petal.Length = "Petal length",
#'                 Petal.Width = "Petal width" ) )
#' ft_2
#' @export
set_header_labels <- function(x, ..., values = NULL){

  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")

  if( is.null(values)){
    values <- list(...)
    if( nrow_part(x, "header") < 1 )
      stop("there is no header row to be replaced")

  }

  x$header$content[nrow_part(x, "header"), names(values)] <- as_paragraph(as_chunk(unlist(values)))

  x
}


#' @export
#' @title delete flextable part
#'
#' @description indicate to not print a part of
#' the flextable, i.e. an header, footer or the body.
#'
#' @param x a \code{flextable} object
#' @param part partname of the table to delete (one of 'body', 'header' or 'footer').
#' @examples
#' ft <- flextable( head( iris ) )
#' ft <- delete_part(x = ft, part = "header")
#' ft
delete_part <- function(x, part = "header"){
  if( !inherits(x, "flextable") ) stop("delete_part supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )
  nrow_ <- nrow(x[[part]]$dataset)
  x[[part]]$dataset <- x[[part]]$dataset[-seq_len(nrow_),, drop = FALSE]
  x
}

# add header/footer row ----

#' @export
#' @title Add a row of labels in header or footer part
#'
#' @description Add a single row of labels in the flextable's header
#' or footer part. It can be inserted at the top or the bottom of the part.
#'
#' @param x a \code{flextable} object
#' @param top should the row be inserted at the top or the bottom.
#' @param ... a named list (names are data colnames) of strings
#' specifying corresponding labels to add.
#' @examples
#' ft <- flextable( head( iris ),
#'   col_keys = c("Species", "Sepal.Length", "Petal.Length", "Sepal.Width", "Petal.Width") )
#' ft <- add_header(x = ft, Sepal.Length = "length",
#'   Sepal.Width = "width", Petal.Length = "length",
#'   Petal.Width = "width", Species = "Species", top = FALSE )
#' ft <- add_header(ft, Sepal.Length = "Inches",
#'   Sepal.Width = "Inches", Petal.Length = "Inches",
#'   Petal.Width = "Inches", Species = "Species", top = TRUE )
#' ft <- merge_h(ft, part = "header")
#' ft <- add_footer(ft, Species = "This is a footnote" )
#' ft <- merge_at(ft, j = 1:5, part = "footer")
#' ft
#' @rdname add_header_footer
#' @name add_header_footer
add_header <- function(x, top = TRUE, ...){

  if( !inherits(x, "flextable") ) stop("add_header supports only flextable objects.")
  args <- list(...)
  args_ <- lapply(x$col_keys, function(x) "" )
  names(args_) <- x$col_keys
  args_[names(args)] <- lapply(args, format)
  header_data <- data.frame(as.list(args_), check.names = FALSE, stringsAsFactors = FALSE )
  x$header <- add_rows( x$header, header_data, first = top )

  x
}


#' @export
#' @rdname add_header_footer
add_footer <- function(x, top = TRUE, ...){
  if( !inherits(x, "flextable") ) stop("add_footer supports only flextable objects.")
  args <- list(...)
  args_ <- lapply(x$col_keys, function(x) "" )
  names(args_) <- x$col_keys
  args_[names(args)] <- lapply(args, format)
  footer_data <- data.frame(as.list(args_), check.names = FALSE, stringsAsFactors = FALSE )

  if( nrow_part(x, "footer") < 1 ) {
    x$footer <- complex_tabpart( data = footer_data, col_keys = x$col_keys, cwidth = .75, cheight = .25 )
  } else {
    x$footer <- add_rows( x$footer, footer_data, first = top )
  }

  x
}





# add header/footer with reference table ----

set_part_df <- function(x, mapping = NULL, key = "col_keys", part){

  keys <- data.frame( col_keys = x$col_keys, stringsAsFactors = FALSE )
  names(keys) <- key

  header_data <- merge(keys, mapping, by = key, all.x = TRUE, all.y = FALSE, sort = FALSE )
  header_data <- header_data[match( keys[[key]], header_data[[key]]),]

  header_data[[key]] <- NULL

  header_data <- do.call( rbind, header_data )
  dimnames(header_data) <- NULL
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE)
  names(header_data) <- x$col_keys

  if( length(x$blanks) ){
    blank_ <- character(nrow(header_data))
    replace_ <- lapply(x$blanks, function(x, bl) bl, blank_ )
    names(replace_) <- x$blanks
    header_data[x$blanks] <- replace_
  }


  colwidths <- x[[part]]$colwidths
  cheight <- x[[part]]$rowheights[length(x[[part]]$rowheights)]
  x[[part]] <- eval(call( class( x[[part]]), data = header_data, col_keys = x$col_keys, cwidth = .75, cheight = cheight ))
  x[[part]]$colwidths <- colwidths

  x
}

#' @export
#' @rdname set_header_footer_df
#' @name set_header_footer_df
#' @aliases headers footers
#' @title Set flextable's header or footer rows
#'
#' @description Use a data.frame to specify flextable's header or footer rows.
#'
#' The data.frame must contain a column whose values match flextable
#' \code{col_keys} argument, this column will be used as join key. The
#' other columns will be displayed as header or footer rows. The leftmost column
#' is used as the top header/footer row and the rightmost column
#' is used as the bottom header/footer row.
#'
#' @param x a \code{flextable} object
#' @param mapping a \code{data.frame} specyfing for each colname
#' content of the column.
#' @param key column to use as key when joigning data_mapping.
#' @examples
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length",
#'                 "Petal.Width", "Species" ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE )
#'
#' ft <- flextable( head( iris ))
#' ft <- set_header_df(ft, mapping = typology, key = "col_keys" )
#' ft <- merge_h(ft, part = "header")
#' ft <- merge_v(ft, j = "Species", part = "header")
#' ft <- theme_vanilla(ft)
#'
#'
set_header_df <- function(x, mapping = NULL, key = "col_keys"){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  set_part_df(x, mapping = mapping, key = key, part = "header")
}

#' @rdname set_header_footer_df
#' @export
#' @examples
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length",
#'                 "Petal.Width", "Species" ),
#'   unit = c("(cm)", "(cm)", "(cm)", "(cm)", ""),
#'   stringsAsFactors = FALSE )
#' ft <- set_footer_df(ft, mapping = typology, key = "col_keys" )
#' ft <- italic(ft, italic = TRUE, part = "footer" )
#' ft <- theme_booktabs(ft)
#' ft
set_footer_df <- function(x, mapping = NULL, key = "col_keys"){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  set_part_df(x, mapping = mapping, key = key, part = "footer")
}


