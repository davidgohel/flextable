#' @title Set flextable's headers labels
#'
#' @description This function set labels for specified columns
#' in a single row header of a flextable.
#'
#' @param x a `flextable` object
#' @param ... named arguments (names are data colnames), each element is a single character
#' value specifying label to use.
#' @param values a named list (names are data colnames), each element is a single character
#' value specifying label to use. If provided, argument `...` will be ignored.
#' @examples
#' ft <- flextable( head( iris ))
#' ft <- set_header_labels(ft, Sepal.Length = "Sepal length",
#'   Sepal.Width = "Sepal width", Petal.Length = "Petal length",
#'   Petal.Width = "Petal width"
#' )
#'
#' ft <- flextable( head( iris ))
#' ft <- set_header_labels(ft,
#'   values = list(Sepal.Length = "Sepal length",
#'                 Sepal.Width = "Sepal width",
#'                 Petal.Length = "Petal length",
#'                 Petal.Width = "Petal width" ) )
#' ft
#' @export
#' @family headers and footers
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_set_header_labels_1.png}{options: width=50\%}}
set_header_labels <- function(x, ..., values = NULL){

  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")

  if( is.null(values)){
    values <- list(...)
    if( nrow_part(x, "header") < 1 )
      stop("there is no header row to be replaced")

  }

  values <- values[names(values) %in% names(x$header$dataset)]
  x$header$content[nrow_part(x, "header"), names(values)] <- as_paragraph(as_chunk(unlist(values)))

  x
}


#' @export
#' @title delete flextable part
#'
#' @description indicate to not print a part of
#' the flextable, i.e. an header, footer or the body.
#'
#' @param x a `flextable` object
#' @param part partname of the table to delete (one of 'body', 'header' or 'footer').
#' @examples
#' ft <- flextable( head( iris ) )
#' ft <- delete_part(x = ft, part = "header")
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_delete_part_1.png}{options: width=50\%}}
delete_part <- function(x, part = "header"){
  if( !inherits(x, "flextable") ) stop("delete_part supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )
  nrow_ <- nrow(x[[part]]$dataset)
  x[[part]] <- complex_tabpart(
    data = x[[part]]$dataset[-seq_len(nrow_),, drop = FALSE],
    col_keys = x$col_keys,
    cwidth = x[[part]]$colwidths, cheight = x[[part]]$rowheights )
  x
}


as_new_data <- function(x, ..., values = NULL){

  if( is.null(values) )
    values <- list(...)

  args_ <- lapply(x$col_keys, function(x, n) rep(NA, n), n = length(values[[1]]) )
  names(args_) <- x$col_keys
  args_[names(values)] <- values

  data.frame(as.list(args_), check.names = FALSE, stringsAsFactors = FALSE )
}

# add header/footer row ----

#' @export
#' @title Add rows in body part
#'
#' @description Add rows in the flextable's body.
#' It can be inserted at the top or the bottom.
#' The function is column oriented, labels are specified for each columns, there
#' can be more than a value - resulting in more than a new row.
#'
#' @param x a `flextable` object
#' @param top should the rows be inserted at the top or the bottom.
#' @param ... a named list (names are data colnames) of strings
#' specifying corresponding values to add. It is important
#' to insert data of the same type as the original data,
#' otherwise it will be transformed (probably into strings if
#' you add a `character' where a `double' is expected). This keeps
#' the ability to format cell contents with the `colformat_*` functions,
#' for example [colformat_num()].
#' @param values a list of name-value pairs of labels or values,
#' names should be existing col_key values. This argument can be used
#' instead of `...` for programming purpose (If `values` is
#' supplied argument `...` is ignored).
#' @examples
#' ft <- flextable(head(iris),
#'   col_keys = c(
#'     "Species", "Sepal.Length", "Petal.Length",
#'     "Sepal.Width", "Petal.Width"
#'   )
#' )
#'
#' ft <- add_body(
#'   x = ft, Sepal.Length = 1:5,
#'   Sepal.Width = 1:5 * 2, Petal.Length = 1:5 * 3,
#'   Petal.Width = 1:5 + 10, Species = "Blah", top = FALSE
#' )
#'
#' ft <- theme_booktabs(ft)
#' ft
#' @seealso [flextable()], [add_header()], [add_footer()]
add_body <- function(x, top = TRUE, ..., values = NULL){
  if( !inherits(x, "flextable") )
    stop("add_header supports only flextable objects.")
  new_data <- as_new_data(x = x, ..., values = values)
  x$body <- add_rows( x$body, new_data, first = top )
  x
}

#' @export
#' @title Add a rows of labels in header or footer part
#'
#' @description Add rows of labels in the flextable's header
#' or footer part. It can be inserted at the top or the bottom of the part.
#' The function is column oriented, labels are specified for each columns, there
#' can be more than a label - resulting in more than a new row.
#'
#' @note
#' when repeating values, they can be merged together with
#' function [merge_h()] and [merge_v()].
#'
#' @inheritParams add_body
#' @examples
#' ft <- flextable( head( iris ),
#'    col_keys = c("Species", "Sepal.Length", "Petal.Length",
#'                 "Sepal.Width", "Petal.Width") )
#'
#' # start with no header
#' ft <- delete_part(ft, part = "header")
#'
#' # add a line of row
#' ft <- add_header(x = ft, Sepal.Length = "length",
#'    Sepal.Width = "width", Petal.Length = "length",
#'    Petal.Width = "width", Species = "Species", top = FALSE )
#' # add another line of row at the top position
#' ft <- add_header(ft, Sepal.Length = "Inches",
#'    Sepal.Width = "Inches", Petal.Length = "Inches",
#'    Petal.Width = "Inches", top = TRUE )
#' # merge horizontally when there are identical values
#' ft <- merge_h(ft, part = "header")
#'
#'
#' # add a footnote in the footer part
#' ft <- add_footer(ft, Species = "This is a note in footer" )
#' ft <- merge_at(ft, j = 1:5, part = "footer")
#'
#' # theme the table
#' ft <- theme_box(ft)
#'
#' ft
#' @family headers and footers
#' @section Illustrations:
#' \if{html}{\figure{fig_add_header_1.png}{options: width=60\%}}
add_header <- function(x, top = TRUE, ..., values = NULL){
  if( !inherits(x, "flextable") ) stop("add_header supports only flextable objects.")
  header_data <- as_new_data(x = x, ..., values = values)
  x$header <- add_rows( x$header, header_data, first = top )

  x
}

#' @export
#' @rdname add_header
add_footer <- function(x, top = TRUE, ..., values = NULL){
  if( !inherits(x, "flextable") ) stop("add_footer supports only flextable objects.")
  footer_data <- as_new_data(x = x, ..., values = values)

  if( nrow_part(x, "footer") < 1 ) {
    x$footer <- complex_tabpart( data = footer_data, col_keys = x$col_keys, cwidth = .75, cheight = .25 )
  } else {
    x$footer <- add_rows( x$footer, footer_data, first = top )
  }

  x
}



#' @export
#' @title Add labels and merge cells in a new header or footer row
#'
#' @description Add an header or footer new row where some cells are merged,
#' labels are associated with a number of columns to merge. The function
#' is row oriented. One call allow to add one single row.
#'
#' @param x a `flextable` object
#' @param top should the row be inserted at the top or the bottom.
#' @param values values to add as a character vector
#' @param colwidths the number of columns to merge in the row for each label
#'
#' @examples
#' ft <- flextable( head( iris ) )
#' ft <- add_header_row(ft, values = "blah blah", colwidths = 5)
#' ft <- add_header_row(ft, values = c("blah", "blah"), colwidths = c(3,2))
#' ft <- theme_tron(ft)
#' ft
#' @family headers and footers
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_add_header_row_1.png}{options: width=50\%}}
add_header_row <- function(x, top = TRUE, values = character(0), colwidths = integer(0)){

  if( !inherits(x, "flextable") ) stop("add_header supports only flextable objects.")

  if( length(colwidths) < 1 ){
    colwidths <- rep(1L, length(x$col_keys))
  }

  if( sum(colwidths) != length(x$col_keys)){
    stop("colwidths' sum must be equal to the number of col_keys (", length(x$col_keys), ")" )
  }

  values_ <- inverse.rle(structure(list(lengths = colwidths, values = values), class = "rle"))
  values_ <- as.list(values_)

  names(values_) <- x$col_keys
  header_data <- as.data.frame(values_, check.names = FALSE, stringsAsFactors = FALSE )

  if( nrow_part(x, "header") < 1 ) {
    x$header <- complex_tabpart( data = header_data, col_keys = x$col_keys, cwidth = dim(x)$widths, cheight = .25 )
  } else {
    x$header <- add_rows( x$header, header_data, first = top )
  }


  row_span <- unlist( lapply(colwidths, function(x) {
    z <- integer(x)
    z[1] <- x
    z
  }) )
  i <- ifelse(top, 1, nrow(x$header$dataset))
  x$header$spans$rows[ i, ] <- row_span

  x
}

#' @export
#' @rdname add_header_row
#' @examples
#' ft <- flextable( head( iris ) )
#' ft <- add_footer_row(ft, values = "blah blah", colwidths = 5)
#' ft <- add_footer_row(ft, values = c("blah", "blah"), colwidths = c(3,2))
#' ft
add_footer_row <- function(x, top = TRUE, values = character(0), colwidths = integer(0)){

  if( !inherits(x, "flextable") ) stop("add_footer supports only flextable objects.")

  if( sum(colwidths) != length(x$col_keys)){
    stop("colwidths' sum must be equal to the number of col_keys (", length(x$col_keys), ")" )
  }

  values_ <- inverse.rle(structure(list(lengths = colwidths, values = values), class = "rle"))
  values_ <- as.list(values_)

  names(values_) <- x$col_keys

  footer_data <- as.data.frame(values_, check.names = FALSE, stringsAsFactors = FALSE )

  if( nrow_part(x, "footer") < 1 ) {
    x$footer <- complex_tabpart( data = footer_data, col_keys = x$col_keys, cwidth = dim(x)$widths, cheight = .25 )
  } else {
    x$footer <- add_rows( x$footer, footer_data, first = top )
  }

  row_span <- unlist( lapply(colwidths, function(x) {
    z <- integer(x)
    z[1] <- x
    z
  }) )
  i <- ifelse(top, 1, nrow(x$footer$dataset))
  x$footer$spans$rows[ i, ] <- row_span

  x
}

#' @export
#' @title Add a label in a header or footer new row.
#'
#' @description Add an header or footer new row made of one cell.
#' This is a sugar function to be used when you need to add a
#' title row to a flextable, most of the time it will be used in a
#' context of adding a footnote or adding a title on the top line
#' of the flextable.
#'
#' @param x a `flextable` object
#' @param values a character vector, each element will be added a a new
#' row in the header or footer part.
#' @param top should the row be inserted at the top or the bottom.
#' @family headers and footers
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_add_header_lines_1.png}{options: width=50\%}}
#'
#' \if{html}{\figure{fig_add_header_lines_2.png}{options: width=50\%}}
#' @examples
#'
#' ft_1 <- flextable( head( iris ) )
#' ft_1 <- add_header_lines(ft_1, values = "blah blah")
#' ft_1 <- add_header_lines(ft_1, values = c("blah 1", "blah 2"))
#' ft_1 <- autofit(ft_1)
#' ft_1
add_header_lines <- function(x, values = character(0), top = TRUE){

  for( value in values ){
    x <- add_header_row(x, values = value, colwidths = length(x$col_keys), top = top )
  }
  x
}


#' @export
#' @rdname add_header_lines
#' @examples
#' ft_2 <- flextable( head( iris ) )
#' ft_2 <- add_footer_lines(ft_2, values = "blah blah")
#' ft_2 <- add_footer_lines(ft_2, values = c("blah 1", "blah 2"))
#' ft_2 <- theme_tron(ft_2)
#' ft_2
add_footer_lines <- function(x, values = character(0), top = FALSE){

  for( value in values ){
    x <- add_footer_row(x, values = value, colwidths = length(x$col_keys), top = top )
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
  x[[part]] <- eval(call( class( x[[part]]), data = header_data, col_keys = x$col_keys, cwidth = .75, cheight = .25 ))
  cheight <- optimal_sizes(x[[part]])$heights

  x[[part]]$colwidths <- colwidths
  x[[part]]$rowheights <- cheight
  x
}

#' @export
#' @rdname set_header_footer_df
#' @name set_header_footer_df
#' @title Set flextable's header or footer rows
#'
#' @description Use a data.frame to specify flextable's header or footer rows.
#'
#' The data.frame must contain a column whose values match flextable
#' `col_keys` argument, this column will be used as join key. The
#' other columns will be displayed as header or footer rows. The leftmost column
#' is used as the top header/footer row and the rightmost column
#' is used as the bottom header/footer row.
#'
#' @param x a `flextable` object
#' @param mapping a `data.frame` specyfing for each colname
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
#' ft_1 <- flextable( head( iris ))
#' ft_1 <- set_header_df(ft_1, mapping = typology, key = "col_keys" )
#' ft_1 <- merge_h(ft_1, part = "header")
#' ft_1 <- merge_v(ft_1, j = "Species", part = "header")
#' ft_1 <- theme_vanilla(ft_1)
#' ft_1 <- fix_border_issues(ft_1)
#' ft_1
#' @family headers and footers
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_set_header_footer_df_1.png}{options: width=50\%}}
#'
#' \if{html}{\figure{fig_set_header_footer_df_2.png}{options: width=50\%}}
set_header_df <- function(x, mapping = NULL, key = "col_keys"){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  set_part_df(x, mapping = mapping, key = key, part = "header")
}

#' @rdname set_header_footer_df
#' @export
#' @examples
#'
#'
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length",
#'                 "Petal.Width", "Species" ),
#'   unit = c("(cm)", "(cm)", "(cm)", "(cm)", ""),
#'   stringsAsFactors = FALSE )
#' ft_2 <- set_footer_df(ft_1, mapping = typology, key = "col_keys" )
#' ft_2 <- italic(ft_2, italic = TRUE, part = "footer" )
#' ft_2 <- theme_booktabs(ft_2)
#' ft_2 <- fix_border_issues(ft_2)
#' ft_2
set_footer_df <- function(x, mapping = NULL, key = "col_keys"){
  if( !inherits(x, "flextable") ) stop("set_header_labels supports only flextable objects.")
  set_part_df(x, mapping = mapping, key = key, part = "footer")
}


