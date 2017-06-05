#' @importFrom lazyeval as.lazy interp
#' @importFrom stats setNames as.formula
lazy_format_simple <- function( col_key ){

  obj <- display_parser$new(x = paste0("{{", col_key, "}}"),
                            formatters = list( as.formula( paste0(col_key, "~format(", col_key, ", justify = \"none\", trim = T)") ) ),
                            fprops = list() )
  obj
}

