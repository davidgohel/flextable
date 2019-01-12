#' @title set column formatter functions
#' @description Define formatter functions associated to each column key.
#' Functions have a single argument (the vector) and are returning the formatted
#' values as a character vector.
#' @param x a regulartable object
#' @param ... Name-value pairs of functions, names should be existing col_key values
#' @param part partname of the table (one of 'body' or 'header' or 'footer')
#' @examples
#' ft <- regulartable( head( iris ) )
#' ft <- set_formatter( x = ft,
#'         Sepal.Length = function(x) sprintf("%.02f", x),
#'         Sepal.Width = function(x) sprintf("%.04f", x)
#'       )
#' ft <- theme_vanilla( ft )
#' ft
#' @export
set_formatter <- function(x, ..., part = "body"){

  stopifnot(inherits(x, "regulartable"))

  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )
  formatters <- list(...)
  col_keys <- names(formatters)
  col_keys <- intersect(col_keys, x[[part]]$col_keys)
  x[[part]]$printers[col_keys] <- formatters[col_keys]
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

  stopifnot(inherits(x, "regulartable"))

  col_keys <- setdiff(x[["body"]]$col_keys, x$blanks)
  formatters <- lapply(x[["body"]]$dataset[col_keys], function(x){
    function(x) format_fun(x, na_string = na_str,
                           fmt_double = fmt_double,
                           fmt_integer = fmt_integer,
                           fmt_date = fmt_date,
                           fmt_datetime = fmt_datetime,
                           true = true, false = false)
  })
  x[["body"]]$printers[col_keys] <- formatters[col_keys]
  x
}


#' @export
#' @title format character columns
#' @description Format character columns in a flextable or regulartable.
#' @param x a regulartable object
#' @param col_keys names of the colkeys
#' @param na_str string to be used for NA values
#' @param prefix,suffix string to be used as prefix or suffix
#' @family columns formatters
#' @examples
#' dat <- iris
#' ft <- regulartable(dat)
#' ft <- colformat_char(
#'   x = ft, col_keys = "Species", suffix = "!")
#' autofit(ft)
colformat_char <- function(x, col_keys, na_str = "", prefix = "", suffix = ""){
  UseMethod("colformat_char")
}

#' @export
#' @title format numeric columns
#' @description Format numeric columns in a flextable or regulartable.
#' @inheritParams colformat_char
#' @param big.mark,digits see \code{\link[base]{formatC}}
#' @family columns formatters
#' @examples
#' dat <- iris
#' dat[1:4, 1] <- NA
#' dat[, 2] <- dat[, 2] * 1000000
#'
#' ft <- regulartable(dat)
#' colkeys = c("Sepal.Length", "Sepal.Width",
#'             "Petal.Length", "Petal.Width")
#' ft <- colformat_num(
#'   x = ft, col_keys = colkeys,
#'   big.mark=",", digits = 2, na_str = "N/A")
#' autofit(ft)
#'
#' ft <- flextable(dat)
#' colkeys = c("Sepal.Length", "Sepal.Width",
#'             "Petal.Length", "Petal.Width")
#' ft <- colformat_num(
#'   x = ft, col_keys = colkeys,
#'   big.mark=",", digits = 2, na_str = "N/A")
#' autofit(ft)
colformat_num <- function(x, col_keys, big.mark=",", digits = 2, na_str = "", prefix = "", suffix = ""){
  UseMethod("colformat_num")
}

#' @title format integer columns
#' @description Format integer columns in a flextable or regulartable.
#' @inheritParams colformat_char
#' @param big.mark see \code{\link[base]{formatC}}
#' @family columns formatters
#' @export
#' @examples
#' dat <- mtcars
#'
#' ft <- regulartable(dat)
#' colkeys <- c("vs", "am", "gear", "carb")
#' ft <- colformat_int(x = ft, col_keys = colkeys, prefix = "# ")
#' autofit(ft)
colformat_int <- function(x, col_keys, big.mark=",", na_str = "", prefix = "", suffix = ""){
  UseMethod("colformat_int")
}

#' @title format logical columns
#' @description Format logical columns in a flextable or regulartable.
#' @inheritParams colformat_char
#' @param false,true string to be used for logical columns
#' @family columns formatters
#' @export
#' @examples
#' dat <- data.frame(a = c(TRUE, FALSE), b = c(FALSE, TRUE))
#'
#' ft <- regulartable(dat)
#' ft <- colformat_lgl(x = ft, col_keys = c("a, "b""))
#' autofit(ft)
#'
#' ft <- flextable(dat)
#' ft <- colformat_lgl(x = ft, col_keys = c("a, "b""))
#' autofit(ft)
colformat_lgl <- function(x, col_keys,
                          true = "true", false = "false",
                          na_str = "", prefix = "", suffix = ""){
  UseMethod("colformat_lgl")
}


#' @export
colformat_num.regulartable <- function(x, col_keys, big.mark=",", digits = 2, na_str = "", prefix = "", suffix = ""){
  fun_ <- function(x) {
    out <- paste0(prefix, formatC(x, format="f", big.mark=big.mark, digits = digits), suffix )
    ifelse(is.na(x), na_str, out)
  }
  docall_set_formatter(col_keys, fun_, x)
}

#' @export
colformat_num.complextable <- function(x, col_keys, big.mark=",", digits = 2, na_str = "", prefix = "", suffix = ""){
  str_formulas <- "%s ~ ifelse(is.na(%s), '%s', paste0('%s', formatC(%s, format='f', big.mark = '%s', digits = %.0f), '%s') )"
  str_formulas <- sprintf(str_formulas, col_keys, col_keys, na_str, prefix, col_keys, big.mark, digits, suffix)
  names(str_formulas) <- col_keys
  docall_display(col_keys, str_formulas, x)
}



#' @export
colformat_int.regulartable <- function(x, col_keys, big.mark=",", na_str = "", prefix = "", suffix = ""){
  fun_ <- function(x) {
    out <- paste0(prefix, formatC(x, format="f", big.mark=big.mark, digits = 0), suffix )
    ifelse(is.na(x), na_str, out)
  }
  docall_set_formatter(col_keys, fun_, x)
}

#' @export
colformat_int.complextable <- function(x, col_keys, big.mark=",", na_str = "", prefix = "", suffix = ""){
  str_formulas <- "%s ~ ifelse(is.na(%s), '%s', paste0('%s', formatC(%s, format='f', big.mark = '%s', digits = 0), '%s') )"
  str_formulas <- sprintf(str_formulas, col_keys, col_keys, na_str, prefix, col_keys, big.mark, suffix)
  names(str_formulas) <- col_keys
  docall_display(col_keys, str_formulas, x)
}

#' @export
colformat_lgl.regulartable <- function(x, col_keys, true, false, na_str = "", prefix = "", suffix = ""){
  fun_ <- function(x) {
    out <- ifelse(x, true, false)
    ifelse(is.na(x), na_str, out)
  }
  docall_set_formatter(col_keys, fun_, x)
}

#' @export
colformat_lgl.complextable <- function(x, col_keys, true, false, na_str = "", prefix = "", suffix = ""){
  str_formulas <- "%s ~ ifelse(is.na(%s), '%s', paste0('%s', ifelse(%s, '%s', '%s'), '%s') )"
  str_formulas <- sprintf(str_formulas, col_keys, col_keys, na_str, prefix, col_keys, true, false, suffix)
  names(str_formulas) <- col_keys
  docall_display(col_keys, str_formulas, x)
}


#' @export
colformat_char.regulartable <- function(x, col_keys, na_str = "", prefix = "", suffix = ""){
  fun_ <- function(x) {
    out <- paste0(prefix, x, suffix )
    ifelse(is.na(x), na_str, out)
  }
  docall_set_formatter(col_keys, fun_, x)
}
#' @export
colformat_char.complextable <- function(x, col_keys, na_str = "", prefix = "", suffix = ""){
  str_formulas <- "%s ~ ifelse(is.na(%s), '%s', paste0('%s', %s, '%s') )"
  str_formulas <- sprintf(str_formulas, col_keys, col_keys, na_str, prefix, col_keys, suffix)
  names(str_formulas) <- col_keys
  docall_display(col_keys, str_formulas, x)
}





docall_set_formatter <- function(col_keys, fun, x){
  sf_args <- rep(c(fun), length(col_keys))
  names(sf_args) <- col_keys
  sf_args$x <- x
  do.call(set_formatter, sf_args)
}

docall_display <- function(col_keys, str_formulas, x){
  for( varname in col_keys){
    x <- display(x = x, col_key = varname,
                 pattern = paste0("{{", varname, "}}"),
                 formatters = list( as.formula( str_formulas[varname] ) ),
                 fprops = list(), part = "body" )
  }
  x
}




