#' @title Create a flextable object
#'
#' @description Create a flextable object with function \code{flextable}.
#'
#' \code{flextable} are designed to make tabular reporting easier for
#' R users.
#'
#' An API lets you format text, paragraphs and cells, table elements can
#' be merge vertically or horizontally.
#'
#' A \code{flextable} is made of 2 parts: header and body.
#' @param data dataset
#' @param col_keys columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns.
#' @examples
#' ft <- flextable(mtcars)
#' ft
#' @export
#' @import Rcpp
#' @importFrom stats setNames
#' @importFrom dplyr mutate_
#' @importFrom lazyeval interp
flextable <- function( data, col_keys = names(data) ){

  blanks <- setdiff( col_keys, names(data))
  if( length( blanks ) > 0 ){
    blanks_col <- map(blanks, function(x, n) character(n), nrow(data) )
    blanks_col <- setNames(blanks_col, blanks )
    data[blanks] <- blanks_col
  }

  body <- table_part( data = data, col_keys = col_keys )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data[blanks] <- as.list( rep("", length(blanks)) )
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE)

  header <- table_part( data = header_data, col_keys = col_keys )

  out <- list( header = header, body = body, col_keys = col_keys )
  class(out) <- "flextable"

  out <- style( x = out,
                pr_p = fp_par(text.align = "right", padding = 2),
                pr_c = fp_cell(border = fp_border()), part = "all")

  out
}


print.flextable <- function(x, ...){
  print(x$body$dataset)
}




#' @importFrom purrr map_lgl
#' @import oxbase
#' @export
#' @title Define flextable displayed values
#' @description Modify flextable displayed values.
#' @param x a flextable object
#' @param ... see details.
#' @param i rows selection
#' @param part partname of the table (one of 'all', 'body', 'header')
#' @details
#'
#' Use format_that or format_simple to define cell content.
#'
#' @seealso \code{\link{flextable}}
#' @examples
#'
#' # Formatting data values example ------
#' ft <- flextable(head( mtcars, n = 10))
#' ft <- display(ft, i = ~ drat > 3.5,
#'   carb = fpar("# ", ftext(carb, fp_text(color="orange") ) ) ) %>%
#'   autofit()
#' write_docx("format_ft.docx", ft)
#' @export
display <- function(x, i = NULL, part = "body", ...){

  part <- match.arg(part, c("body", "header"), several.ok = FALSE )

  args <- lazy_dots(... )
  stopifnot(all( names(args) %in% x$col_keys ) )

  fun_call <- map( args, "expr")
  fun_call <- map(fun_call, function(x) x[[1]])
  fun_call <- map_chr(fun_call, as.character)
  invalid_fun_call <- !fun_call %in% c("fpar")
  if( any(invalid_fun_call) ){
    stop( paste0(names(args), collapse = ","), " should call fpar." )
  }

  if( inherits(i, "formula") && any( "header" %in% part ) ){
    stop("formula in argument i cannot adress part 'header'.")
  }

  if( inherits(i, "formula") ){
    i <- lazy_eval(i[[2]], x[[part]]$dataset)
  }
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], names(args) )

  lazy_f_id <- map_chr(args, digest )
  x[[part]]$style_ref_table$formats[lazy_f_id] <- args
  x[[part]]$styles$formats[i, j ] <- matrix( rep.int(lazy_f_id, length(i)), nrow = length(i), byrow = TRUE )

  x
}


#' @importFrom purrr map
#' @importFrom purrr map_int
#' @export
#' @title Add a row of labels in headers
#'
#' @description Add a single row of labels in the flextable's header part. It can
#' be inserted at the top or the bottom of header part.
#'
#' @param x a \code{flextable} object
#' @param top should the row be inserted at the top or the bottom.
#' @param ... a named list (names are data colnames) of strings
#' specifying corresponding labels to add.
#' @examples
#' ft <- flextable( head( iris ))
#' ft <- set_header_labels(x = ft, Sepal.Length = "Sepal",
#'   Sepal.Width = "Sepal", Petal.Length = "Petal",
#'   Petal.Width = "Petal", Species = "Species" )
#' ft <- add_header(x = ft, Sepal.Length = "length",
#'   Sepal.Width = "width", Petal.Length = "length",
#'   Petal.Width = "width", Species = "Species", top = FALSE )
#' ft <- add_header(ft, Sepal.Length = "Inches",
#'   Sepal.Width = "Inches", Petal.Length = "Inches",
#'   Petal.Width = "Inches", Species = "Species", top = TRUE )
#' write_docx("ft_add_header.docx", ft)
add_header <- function(x, top = TRUE, ...){

  args <- list(...)
  # missing_cols <- setdiff(x$col_keys, names(args) )
  # if( length(missing_cols) > 0){
  #   msg <- paste0(missing_cols, collapse = ", ")
  #   msg <- paste0("you need to specify labels for the following columns: ", msg)
  #   stop(msg)
  # }
  args_ <- map(x$col_keys, function(x) "" )
  names(args_) <- x$col_keys
  args_[names(args)] <- map(args, format)
  header_data <- as.data.frame( args_, stringsAsFactors = FALSE )
  header_ <- add_rows( x$header, header_data, first = top )

  header_ <- span_rows(header_, rows = seq_len(nrow(header_data)))
  x$header <- span_columns(header_, x$col_keys)

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
#' write_docx("ft_1.docx", ft_1)
#' @export
set_header_labels <- function(x, ...){

  args <- list(...)

  if( nrow(x$header$dataset) < 1 )
    stop("there is no header row to be replaced")

  header_ <- x$header$dataset

  values <- as.list(tail(x$header$dataset, n = 1))
  args <- args[is.element(names(args), x$col_keys)]
  values[names(args)] <- args

  x$header$dataset <- bind_rows( header_[-nrow(header_),],
             as.data.frame(values, stringsAsFactors = FALSE ))
  x
}




#' @importFrom dplyr left_join
#' @importFrom purrr map
#' @export
#' @title Set flextable's header rows
#'
#' @description Use a data.frame to specify flextable's header rows.
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
#' write_docx("header_df.docx", ft)
set_header_df <- function(x, mapping = NULL, key = "col_keys"){

  keys <- data.frame( col_keys = x$col_keys, stringsAsFactors = FALSE )
  names(keys) <- key
  header_data <- left_join(keys, mapping, by = setNames(key, key) )

  header_data[[key]] <- NULL
  header_data <- map(header_data, function(x){
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

  header_ <- table_part( data = header_data, col_keys = x$col_keys )
  header_ <- span_rows(header_, rows = seq_len(nrow(header_data)))
  x$header <- span_columns(header_, x$col_keys)
  x
}


