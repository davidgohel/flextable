#' @importFrom lazyeval as.lazy interp
lazy_format_simple <- function( col_key ){
  format_simple_l <- as.lazy( interp("fpar(x)", x = as.name(col_key) ), globalenv() )
  format_simple_l
}

