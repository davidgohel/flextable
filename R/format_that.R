#' @export
#' @title format_that
#' @description format_that generic function.
#' @importFrom stringr str_locate_all
#' @importFrom stringr str_sub
#' @importFrom lazyeval lazy_eval
#' @importFrom lazyeval lazy_dots
#' @param str string template
#' @param pr_text_ default text properties
#' @param pr_par_ default paragraph properties
#' @param ... named arguments, element should be a call to \code{ftext} or \code{external_img}
#' @examples
#' format_that("I like to {{ x }} it", x = ftext("move", fp_italic()), prop = fp_text())
format_that <- function( str, pr_text_ = fp_text(), pr_par_ = fp_par(), ... ){
  args <- lazy_dots( ... )
  location <- str_locate_all(str, pattern = paste0("\\{\\{ ", names(args)," \\}\\}"))
  location <- do.call(rbind, location)
  location <- as.data.frame(location)
  location$argname <- str_sub(str, start = location$start + 3, end = location$end - 3 )
  curr_pos <- 1
  index_in_p <- 1
  p <- paragraph$new(prop = pr_par_ )
  if( nchar(str) < 1 )
    p$add(ftext("", prop = pr_text_ ))
  else while( index_in_p <= nchar(str) ){
    if( location[curr_pos, "start"] == index_in_p ){
      ftext_ <- lazy_eval(args[[location[curr_pos, "argname"]]], args )
      p$add(ftext_)
      index_in_p <- location[curr_pos, "end"] + 1
      if( curr_pos < nrow(location) )
        curr_pos <- curr_pos + 1
    } else if( index_in_p < location[curr_pos, "start"] ) {
      text <- substring(str, index_in_p, location[curr_pos, "start"] - 1)
      p$add(ftext(text, prop = pr_text_ ))
      index_in_p <- location[curr_pos, "start"]
    } else {
      text <- substring(str, index_in_p, nchar(str))
      p$add(ftext(text, prop = pr_text_ ))
      index_in_p <- nchar(str) + 1
    }
  }
  p
}


#' @export
#' @title format_simple
#' @description format_simple generic function
#' @param expr a call to \code{ftext} or \code{external_img}
#' @param pr_text_ default text properties
#' @param pr_par_ default paragraph properties
#' @examples
#' format_simple("hello", pr_text_ = fp_text())
format_simple <- function( expr, pr_text_ = fp_text(), pr_par_ = fp_par() ){
  p <- paragraph$new(prop = pr_par_ )
  text <- eval(expr)
  text <- ifelse(text == "", " ", text)
  ftext_ <- ftext(text, pr_text_ )
  p$add(ftext_)
  p
}

lazy_format_simple <- function( col_key ){
  inter_ <- paste0( "format_simple(format_default(x) )")
  format_simple_l <- as.lazy( interp(inter_, x = as.name(col_key) ), globalenv() )
  format_simple_l
}

