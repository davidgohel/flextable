#' @rdname flextable
#' @importFrom stats setNames
#' @export
regulartable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){
  stopifnot(is.data.frame(data), ncol(data) > 0 )

  if( any( duplicated(col_keys) ) ){
    stop("duplicated col_keys")
  }

  blanks <- setdiff( col_keys, names(data))
  if( length( blanks ) > 0 ){
    blanks_col <- lapply(blanks, function(x, n) character(n), nrow(data) )
    blanks_col <- setNames(blanks_col, blanks )
    data[blanks] <- blanks_col
  }

  body <- simple_tabpart( data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data[blanks] <- as.list( rep("", length(blanks)) )
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE, check.names = FALSE)

  header <- simple_tabpart( data = header_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  footer_data <- header_data[FALSE, , drop = FALSE]
  footer <- simple_tabpart( data = footer_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  out <- list( header = header, body = body, footer = footer, col_keys = col_keys,
               blanks = blanks )
  class(out) <- c("flextable", "regulartable")

  out <- style( x = out,
                pr_p = fp_par(text.align = "right", padding = 2),
                pr_c = fp_cell(border = fp_border()), part = "all")
  out <- set_formatter_type(out)
  theme_booktabs(out)
}



