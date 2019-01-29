#' @title flextable creation
#'
#' @description Create a flextable object with function \code{flextable}.
#'
#' \code{flextable} are designed to make tabular reporting easier for
#' R users. Functions are available to let you format text, paragraphs and cells;
#' table cells can be merge vertically or horizontally, row headers can easilly
#' be defined, rows heights and columns widths can be manually set or automatically
#' computed.
#'
#' @details
#' A \code{flextable} is made of 3 parts: header, body and footer.
#'
#' Most functions have an argument named \code{part} that will be used
#' to specify what part of of the table should be modified.
#' @param data dataset
#' @param col_keys columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns by default.
#' @param cwidth,cheight initial width and height to use for cell sizes in inches.
#' @examples
#' ft <- flextable(mtcars)
#' ft
#' @export
#' @importFrom stats setNames
flextable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){

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

  body <- complex_tabpart( data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  # header
  header_data <- setNames(as.list(col_keys), col_keys)
  header_data[blanks] <- as.list( rep("", length(blanks)) )
  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE, check.names = FALSE)

  header <- complex_tabpart( data = header_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  # header
  footer_data <- header_data[FALSE, , drop = FALSE]
  footer <- complex_tabpart( data = footer_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  out <- list( header = header, body = body, footer = footer, col_keys = col_keys,
               blanks = blanks )
  class(out) <- c("flextable")

  out <- style( x = out,
                pr_p = fp_par(text.align = "right", padding = 2),
                pr_c = fp_cell(border = fp_border(color = "transparent")), part = "all")

  theme_booktabs(out)
}


