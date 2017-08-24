#' @rdname flextable
#' @importFrom stats setNames
#' @importFrom purrr map
#' @export
regulartable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){

  blanks <- setdiff( col_keys, names(data))
  if( length( blanks ) > 0 ){
    blanks_col <- map(blanks, function(x, n) character(n), nrow(data) )
    blanks_col <- setNames(blanks_col, blanks )
    data[blanks] <- blanks_col
  }

  body <- simple_tabpart( data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data[blanks] <- as.list( rep("", length(blanks)) )
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE, check.names = FALSE)

  header <- simple_tabpart( data = header_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  out <- list( header = header, body = body, col_keys = col_keys,
               blanks = blanks )
  class(out) <- c("flextable", "regulartable")

  out <- style( x = out,
                pr_p = fp_par(text.align = "right", padding = 2),
                pr_c = fp_cell(border = fp_border()), part = "all")

  out
}



#' @title set column formatter functions
#' @description Define formatter functions associated to each column key.
#' Functions have a single argument (the vector) and are returning the formatted
#' values as a character vector.
#' @param x a flextable object
#' @param ... Name-value pairs of functions, names should be existing col_key values
#' @param part partname of the table (one of 'body' or 'header')
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

  part <- match.arg(part, c("body", "header"), several.ok = FALSE )
  formatters <- list(...)
  col_keys <- names(formatters)
  col_keys <- intersect(col_keys, x[[part]]$col_keys)
  x[[part]]$printers[col_keys] <- formatters[col_keys]
  x
}
