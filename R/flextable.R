#' @title flextable object
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
#' @param select columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns.
#' @examples
#' ft <- flextable(mtcars)
#' write_docx("ft.docx", ft)
#' @export
#' @import Rcpp
#' @importFrom stats setNames
#' @importFrom dplyr mutate_
#' @importFrom lazyeval interp
flextable <- function( data, select = names(data) ){

  blanks <- setdiff( select, names(data))
  if( length( blanks ) > 0 ){
    blanks_col <- map(blanks, function(x, n) character(n), nrow(data) )
    blanks_col <- setNames(blanks_col, blanks )
    data[blanks] <- blanks_col
  }

  orig_dataset <- data

  data <- data[, select, drop = FALSE]
  col_keys <- names(data)
  # body
  body <- table_part( data = data, col_keys = col_keys,
                      orig_dataset = orig_dataset )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE)

  header <- table_part( data = header_data, col_keys = col_keys )

  out <- list( header = header, body = body, footer = NULL, col_keys = col_keys,
               orig_dataset = orig_dataset )
  class(out) <- "flextable"
  out
}


#' @export
#' @param ... unused
#' @rdname flextable
print.flextable <- function(x, ...){
  if( interactive())
    print(tabwid(x))
  else invisible()
}

#' @export
#' @rdname flextable
#' @description Function \code{optim_dim} will return minimum estimated widths and heights for
#' each table columns and rows.
#' @examples
#'
#' # get estimated widths
#' ft <- flextable(mtcars)
#' optim_dim(ft)
optim_dim <- function( x ){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body")){
    if( !is.null(x[[j]])){
      dimensions_ <- get_dimensions(x[[j]])
      x[[j]]$colwidths <- dimensions_$widths
      x[[j]]$rowheights <- dimensions_$heights
    }
  }
  dim(x)
}

#' @rdname flextable
#' @description Function \code{dim} will return widths and heights for each table columns and rows.
#' @param x flextable object
#' @export
dim.flextable <- function(x){
  max_widths <- list()
  max_heights <- list()
  for(j in c("header", "body")){
    if( !is.null(x[[j]])){
      max_widths[[j]] <- x[[j]]$colwidths
      max_heights[[j]] <- x[[j]]$rowheights
    }
  }

  mat_widths <- do.call("rbind", max_widths)
  out_widths <- apply( mat_widths, 2, max )
  names(out_widths) <- x$col_keys

  out_heights <- as.double(unlist(max_heights))
  list(widths = out_widths, heights = out_heights )
}


#' @importFrom purrr map_lgl
#' @export
#' @title flextable display values
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
#'   gear = format_that("# {{ carb_ }}",
#'     carb_ = ftext(carb, pr_text(color="orange") ) ) )
#' write_docx("format_ft.docx", ft)
#' @export
display <- function(x, i = NULL, part = "body", ...){

  part <- match.arg(part, c("body", "header"), several.ok = FALSE )

  args <- lazy_dots(... )
  stopifnot(all( names(args) %in% x$col_keys ) )

  fun_call <- map( args, "expr")
  fun_call <- map(fun_call, function(x) x[[1]])
  fun_call <- map_chr(fun_call, as.character)

  invalid_fun_call <- !fun_call %in% c("format_that", "format_simple")
  if( any(invalid_fun_call) ){
    stop( paste0(names(args), collapse = ","), " should call format_simple or format_that." )
  }

  # stopifnot(all( fun_call %in% c("format_that", "format_simple") ) )

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


#' @importFrom purrr map_int
#' @importFrom stats setNames
#' @importFrom dplyr left_join
#' @importFrom purrr map
#' @importFrom purrr map_int
#' @export
#' @title set flextable's headers
#'
#' @description The definition of flextable's headers can be done
#' in different manner.
#'
#' @param x a \code{flextable} object
#' @param ... a named list (names are data colnames) with character
#' values specifying in reverse order content of the column.
#' @param data_mapping a \code{data.frame} specyfing for each colname
#' content of the column.
#' @param key column to use as key when joigning data_mapping.
#' @param values character vector indicating colnames' labels.
#' @examples
#'
#' # set_header - method 1 ------
#' ft_1 <- flextable( head( iris ))
#' ft_1 <- set_header(ft_1,
#'   values = c("Sepal length", "Sepal width",
#'              "Petal length", "Petal width", "Species") )
#' write_docx("ft_1.docx", ft_1)
#'
#' # set_header - method 2 ------
#' ft_2 <- flextable( head( iris ))
#' ft_2 <- set_header(x = ft_2,
#'   Sepal.Length = list("Sepal", "Length"),
#'   Sepal.Width = list("Sepal", "Width"),
#'   Petal.Length = list("Petal", "Length"),
#'   Petal.Width = list("Petal", "Width"),
#'   Species = list("Species", "Species") )
#' write_docx("ft_2.docx", ft_2)
#'
#' # set_header - method 3 ------
#' typology <- data.frame(
#'   col_keys = c( "Sepal.Length", "Sepal.Width", "Petal.Length",
#'                 "Petal.Width", "Species" ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE )
#'
#' ft_3 <- flextable( head( iris ))
#' ft_3 <- set_header(ft_3, data_mapping = typology, key = "col_keys" )
#' write_docx("ft_3.docx", ft_3)
set_header <- function(x, ..., data_mapping = NULL, key = "col_keys", values = NULL){

  if( !is.null(values) && !is.character(values) ){
    stop("values is expected to be a character vector")
  }
  if( !is.null(values) && length(values) != length(x$col_keys) ){
    stop("values' length should be ", length(x$col_keys) )
  }
  args <- list(...)[x$col_keys]

  if( !is.null(values) ){
    header_data <- setNames(as.list(values), x$col_keys)
    header_data <- as.data.frame(header_data, stringsAsFactors = FALSE )
  } else if( !is.null(data_mapping) ) {
    keys <- data.frame( col_keys = data_mapping[[key]], stringsAsFactors = FALSE )
    names(keys) <- key
    # keys <- keys[ keys[[key]] %in% x$col_keys, , drop = FALSE]
    header_data <- left_join(keys, data_mapping, by = setNames(key, key) )
    header_data <- header_data[ header_data[[key]] %in% x$col_keys, ]

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
  } else if( length(args) > 0 ) {
    args <- list(...)[x$col_keys]
    missing_cols <- setdiff(x$col_keys, names(args) )
    l_ <- map_int( args, length )
    args <- map( args, function(x, s){
      dat <- as.list(character(s))
      dat[seq_along(x)] <- rev(x)
      dat
    }, s = max(l_) )

    header_data <- as.data.frame( map(args, format), stringsAsFactors = FALSE )
    if( length(missing_cols) > 0){
      missing_data <- lapply( missing_cols, function(x, s) character(s), max(l_) )
      names(missing_data) <- missing_cols
      missing_data <- as.data.frame(missing_data)
      header_data <- cbind(header_data, missing_data)[, x$col_keys]
    }
  } else {
    stop("unimplemened case")
  }

  header_ <- table_part( data = header_data, col_keys = x$col_keys )
  header_ <- span_rows(header_, rows = seq_len(nrow(header_data)))
  x$header <- span_columns(header_, x$col_keys)
  x
}

