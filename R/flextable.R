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
#' @note Function \code{regulartable} is maintained for compatibility with old codes
#' mades by users but be aware it produces the same exact object than \code{flextable}.
#' @examples
#' ft <- flextable(mtcars)
#' ft
#' @export
#' @importFrom stats setNames
#' @importFrom gdtools font_family_exists
flextable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){


  stopifnot(is.data.frame(data), ncol(data) > 0 )
  if( any( duplicated(col_keys) ) ){
    stop("duplicated col_keys")
  }
  if( inherits(data, "data.table") || inherits(data, "tbl_df") || inherits(data, "tbl") )
    data <- as.data.frame(data, stringsAsFactors = FALSE)

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
               caption = list(value = NULL, style_id = NULL),
               blanks = blanks )
  class(out) <- c("flextable")

  out <- style( x = out,
                pr_t = fp_text(
                  font.family = ifelse( font_family_exists(font_family = "Roboto"), "Roboto", "Arial" ),
                  font.size = 11, color = "#111111"
                ),
                pr_p = fp_par(text.align = "right", padding.left = 5, padding.right = 5,
                              padding.bottom = 2, padding.top = 2),
                pr_c = fp_cell(border = fp_border(color = "transparent")), part = "all")

  theme_booktabs(out)
}

#' @export
#' @title set caption
#' @description set caption value in flextable
#' @param x flextable object
#' @param caption caption value
#' @note
#' this will have an effect only when output is HTML.
#' @examples
#' ft <- flextable( head( iris ) )
#' ft <- set_caption(ft, "my caption")
#' ft
set_caption <- function(x, caption){

  if( !inherits(x, "flextable") ) stop("set_caption supports only flextable objects.")

  if( !is.character(caption) && length(caption) != 1 ){
    stop("caption should be a single character value")
  }

  x$caption <- list(value = caption)
  x
}

#' @rdname flextable
#' @export
regulartable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){
  flextable(data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight)
}
