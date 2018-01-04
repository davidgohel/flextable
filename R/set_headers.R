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
add_header <- function(x, top = TRUE, ...){

  args <- list(...)
  args_ <- lapply(x$col_keys, function(x) "" )
  names(args_) <- x$col_keys
  args_[names(args)] <- lapply(args, format)
  header_data <- data.frame(as.list(args_), check.names = FALSE, stringsAsFactors = FALSE )
  x$header <- add_rows( x$header, header_data, first = top )

  x
}

#' @export
#' @rdname add_header
add_footer <- function(x, top = TRUE, ...){

  args <- list(...)
  args_ <- lapply(x$col_keys, function(x) "" )
  names(args_) <- x$col_keys
  args_[names(args)] <- lapply(args, format)
  footer_data <- data.frame(as.list(args_), check.names = FALSE, stringsAsFactors = FALSE )

  x$footer <- add_rows( x$footer, footer_data, first = top )

  x
}



#' @title Set flextable's headers labels
#'
#' @description This function set labels for specified columns
#' in a single row header of a flextable.
#'
#' @param x a \code{flextable} object
#' @param ... a named list (names are data colnames), each element is a single character
#' value specifying label to use.
#' @examples
#' ft_1 <- flextable( head( iris ))
#' ft_1 <- set_header_labels(ft_1, Sepal.Length = "Sepal length",
#'   Sepal.Width = "Sepal width", Petal.Length = "Petal length",
#'   Petal.Width = "Petal width"
#' )
#' ft_1
#' @export
set_header_labels <- function(x, ...){

  args <- list(...)

  if( nrow(x$header$dataset) < 1 )
    stop("there is no header row to be replaced")

  header_ <- x$header$dataset

  values <- as.list(tail(x$header$dataset, n = 1))
  args <- args[is.element(names(args), x$col_keys)]
  values[names(args)] <- args

  x$header$dataset <- rbind( header_[-nrow(header_),],
                                 as.data.frame(values, stringsAsFactors = FALSE, check.names = FALSE ))
  x
}



#' @export
#' @title Set flextable's header rows
#'
#' @description Use a data.frame to specify flextable's header rows.
#'
#' The data.frame must contain a column whose values match flextable
#' \code{col_keys} argument, this column will be used as join key. The
#' other columns will be displayed as header rows. The leftmost column
#' is used as the top header row and the rightmost column
#' is used as the bottom header row.
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
#' ft
set_header_df <- function(x, mapping = NULL, key = "col_keys"){

  keys <- data.frame( col_keys = x$col_keys, stringsAsFactors = FALSE )
  names(keys) <- key

  header_data <- merge(keys, mapping, by = key, all.x = TRUE, all.y = FALSE, sort = FALSE )
  header_data <- header_data[match( keys[[key]], header_data[[key]]),]

  header_data[[key]] <- NULL
  header_data <- lapply(header_data, function(x){
    if( is.character(x))
      x
    else if( is.integer(x) || is.logical(x) || is.factor(x) )
      as.character(x)
    else if( is.double(x) )
      formatC(x)
    else format(x)
  })
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


  colwidths <- x$header$colwidths
  cheight <- x$header$rowheights[length(x$header$rowheights)]
  x$header <- eval(call( class( x$header), data = header_data, col_keys = x$col_keys, cwidth = .75, cheight = cheight ))
  x$header$colwidths <- colwidths

  x
}
