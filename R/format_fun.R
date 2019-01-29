format_fun.default <- function( x, na_string = "", ... ){
  ifelse( is.na(x), na_string, format(x) )
}

format_fun.character <- function( x, na_string = "", ... ){
  ifelse( is.na(x), na_string, x )
}

format_fun.factor <- function( x, na_string = "", ... ){
  ifelse( is.na(x), na_string, as.character(x) )
}

format_fun.logical <- function( x, na_string = "", true = "true", false = "false", ... ){
  ifelse( is.na(x), na_string, ifelse(x, true, false) )
}

format_fun.double <- function( x, na_string = "", fmt_double = "%.03f", ... ){
  ifelse( is.na(x), na_string, sprintf(fmt_double, x) )
}

format_fun.integer <- function( x, na_string = "", fmt_integer = "%.0f", ... ){
  ifelse( is.na(x), na_string, sprintf(fmt_integer, x) )
}

format_fun.Date <- function( x, na_string = "", fmt_date = "%Y-%m-%d", ... ){
  ifelse( is.na(x), na_string, format(x, fmt_date) )
}

format_fun.POSIXt <- function( x, na_string = "", fmt_datetime = "%Y-%m-%d %H:%M:%S", ... ){
  ifelse( is.na(x), na_string, format(x, fmt_datetime) )
}
