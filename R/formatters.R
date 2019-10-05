#' @title set column formatter functions
#' @description Define formatter functions associated to each column key.
#' Functions have a single argument (the vector) and are returning the formatted
#' values as a character vector.
#' @param x a flextable object
#' @param ... Name-value pairs of functions, names should be existing col_key values
#' @param values a list of name-value pairs of functions, names should be existing col_key values.
#' If values is supplied argument \code{...} is ignored.
#' @param part partname of the table (one of 'body' or 'header' or 'footer')
#' @examples
#' ft <- flextable( head( iris ) )
#' ft <- set_formatter( x = ft,
#'         Sepal.Length = function(x) sprintf("%.02f", x),
#'         Sepal.Width = function(x) sprintf("%.04f", x)
#'       )
#' ft <- theme_vanilla( ft )
#' ft
#' @export
set_formatter <- function(x, ..., values = NULL, part = "body"){


  if(!inherits(x, "flextable"))
    stop("argument `x` of function `set_formatter` should be a flextable object")

  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  if( is.null(values) ){
    values <- list(...)
  }
  col_keys <- intersect(names(values), x[[part]]$col_keys)

  for(key in col_keys){
    dat <- x[[part]]$dataset[, key]
    chk <- as_chunk(values[[key]](dat))
    x <- compose(x, j = key, value = as_paragraph(chk), part = part )
  }

  x
}


#' @export
#' @rdname set_formatter
#' @section set_formatter_type:
#' \code{set_formatter_type} is an helper function to quickly define
#' formatter functions regarding to column types.
#' @param fmt_double,fmt_integer arguments used by \code{sprintf} to
#' format double and integer columns.
#' @param fmt_date,fmt_datetime arguments used by \code{format} to
#' format date and date time columns.
#' @param false,true string to be used for logical columns
#' @param na_str string for NA values
set_formatter_type <- function(x, fmt_double = "%.03f", fmt_integer = "%.0f",
                               fmt_date = "%Y-%m-%d", fmt_datetime = "%Y-%m-%d %H:%M:%S",
                               true = "true", false = "false",
                               na_str = ""){

  stopifnot(inherits(x, "flextable"))

  col_keys <- x[["body"]]$col_keys
  for( varname in col_keys){
    x <- compose(x = x, j = varname, value = as_paragraph(as_chunk(
      format_fun(get(varname), na_string = na_str,
                 fmt_double = fmt_double,
                 fmt_integer = fmt_integer,
                 fmt_date = fmt_date,
                 fmt_datetime = fmt_datetime,
                 true = true, false = false)
      )), part = "body" )
  }
  x
}

#' @export
#' @title format character cells
#' @description Format character cells in a flextable.
#' @param x a flextable object
#' @param col_keys names of the colkeys. Will be deprectated in favor of j in the next
#' version.
#' @param j columns selection.
#' @param na_str string to be used for NA values
#' @param prefix,suffix string to be used as prefix or suffix
#' @param ... additional arguments, i can be used to specify a
#' row selector.
#' @family cells formatters
#' @examples
#' dat <- iris
#' ft <- flextable(dat)
#' ft <- colformat_char(
#'   x = ft, col_keys = "Species", suffix = "!")
#' autofit(ft)
colformat_char <- function(x, ...){
  UseMethod("colformat_char")
}

#' @export
#' @title format numeric cells
#' @description Format numeric cells in a flextable.
#' @inheritParams colformat_char
#' @param big.mark,digits see \code{\link[base]{formatC}}
#' @family cells formatters
#' @examples
#' dat <- iris
#' dat[1:4, 1] <- NA
#' dat[, 2] <- dat[, 2] * 1000000
#'
#' ft <- flextable(dat)
#' colkeys = c("Sepal.Length", "Sepal.Width",
#'             "Petal.Length", "Petal.Width")
#' ft <- colformat_num(
#'   x = ft, col_keys = colkeys,
#'   big.mark=",", digits = 2, na_str = "N/A")
#' autofit(ft)
colformat_num <- function(x, ...){
  UseMethod("colformat_num")
}

#' @title format integer cells
#' @description Format integer cells in a flextable.
#' @inheritParams colformat_char
#' @param big.mark see \code{\link[base]{formatC}}
#' @family cells formatters
#' @export
#' @examples
#' dat <- mtcars
#'
#' ft <- flextable(dat)
#' colkeys <- c("vs", "am", "gear", "carb")
#' ft <- colformat_int(x = ft, col_keys = colkeys, prefix = "# ")
#' autofit(ft)
colformat_int <- function(x, ...){
  UseMethod("colformat_int")
}

#' @title format logical cells
#' @description Format logical cells in a flextable.
#' @inheritParams colformat_char
#' @param false,true string to be used for logical
#' @family cells formatters
#' @export
#' @examples
#' dat <- data.frame(a = c(TRUE, FALSE), b = c(FALSE, TRUE))
#'
#' ft <- flextable(dat)
#' ft <- colformat_lgl(x = ft, col_keys = c("a", "b"))
#' autofit(ft)
colformat_lgl <- function(x, ...){
  UseMethod("colformat_lgl")
}


#' @export
#' @rdname colformat_num
colformat_num.flextable <- function(x, j = NULL, col_keys = NULL, big.mark=",", digits = 2, na_str = "", prefix = "", suffix = "", ...){

  if(!is.null(col_keys)){
    warning("argument col_keys is deprecated in favor of argument j")
    j <- col_keys
  }

  fun_ <- function(x) {
    out <- paste0(prefix, formatC(x, format="f", big.mark=big.mark, digits = digits), suffix )
    ifelse(is.na(x), na_str, out)
  }
  docall_display(j, fun_, x, ...)
}


#' @export
#' @rdname colformat_int
colformat_int.flextable <- function(x, j = NULL, col_keys = NULL, big.mark=",", na_str = "", prefix = "", suffix = "", ...){

  if(!is.null(col_keys)){
    warning("argument col_keys is deprecated in favor of argument j")
    j <- col_keys
  }

  fun_ <- function(x) {
    out <- paste0(prefix, formatC(x, format="f", big.mark=big.mark, digits = 0), suffix )
    ifelse(is.na(x), na_str, out)
  }
  docall_display(j, fun_, x, ...)
}

#' @export
#' @rdname colformat_lgl
colformat_lgl.flextable <- function(x, j = NULL, col_keys = NULL,
                                       true = "true", false = "false",
                                       na_str = "", prefix = "", suffix = "", ...){

  if(!is.null(col_keys)){
    warning("argument col_keys is deprecated in favor of argument j")
    j <- col_keys
  }

  fun_ <- function(x) {
    out <- ifelse(x, true, false)
    ifelse(is.na(x), na_str, out)
  }
  docall_display(j, fun_, x, ...)
}


#' @export
#' @rdname colformat_char
colformat_char.flextable <- function(x, j = NULL, col_keys = NULL, na_str = "", prefix = "", suffix = "", ...){

  if(!is.null(col_keys)){
    warning("argument col_keys is deprecated in favor of argument j")
    j <- col_keys
  }

  fun_ <- function(x) {
    out <- paste0(prefix, x, suffix )
    ifelse(is.na(x), na_str, out)
  }
  docall_display(j, fun_, x, ...)
}


docall_display <- function(j, format_fun, x, i = NULL){

  check_formula_i_and_part(i, "body")
  j <- get_columns_id(x[["body"]], j )
  col_keys <- x$col_keys[j]
  for( varname in col_keys){
    x <- compose(x = x, j = varname, i = i, value = as_paragraph(as_chunk(format_fun(get(varname)))), part = "body" )
  }
  x
}

