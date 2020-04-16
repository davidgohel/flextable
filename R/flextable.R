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
#' @param defaults a list of default values for formats, supported options are
#' \code{fontname}, \code{font.size}, \code{color} and \code{padding}.
#' @param theme_fun a function theme to apply before returning the flextable.
#' set to NULL for none.
#' @note Function \code{regulartable} is maintained for compatibility with old codes
#' mades by users but be aware it produces the same exact object than \code{flextable}.
#' @examples
#' ft <- flextable(head(mtcars))
#' ft
#' @export
#' @importFrom stats setNames
#' @importFrom gdtools font_family_exists
#' @seealso [style()], [autofit()], [theme_booktabs()], [knit_print.flextable()],
#' [compose()], [footnote()]
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_flextable_1.png}{options: width=100\%}}
flextable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25,
                       defaults = list(), theme_fun = theme_booktabs ){


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

  # default values for formats
  if( "fontname" %in% names(defaults) ){
    font_family <- defaults$fontname
  } else {
    font_family <- ifelse( font_family_exists(font_family = "Roboto"), "Roboto", "Arial" )
  }
  if( "font.size" %in% names(defaults) ){
    font.size <- defaults$font.size
  } else {
    font.size <- 11
  }
  if( "color" %in% names(defaults) ){
    color <- defaults$color
  } else {
    color <- "#111111"
  }
  if( "padding" %in% names(defaults) ){
    padding.left <- padding.right <- padding.bottom <- padding.top <- defaults$padding
  } else {
    padding.left <- padding.right <- 5
    padding.bottom <- padding.top <- 2
  }

  out <- style( x = out,
                pr_t = fp_text(
                  font.family = font_family,
                  font.size = font.size, color = color
                ),
                pr_p = fp_par(text.align = "right", padding.left = padding.left, padding.right = padding.right,
                              padding.bottom = padding.bottom, padding.top = padding.top),
                pr_c = fp_cell(border = fp_border(color = "transparent")), part = "all")
  if( !is.null(theme_fun) )
    out <- theme_fun(out)
  out
}

#' @export
#' @rdname flextable
#' @section qflextable:
#' \code{qflextable} is a convenient tool to produce quickly
#' a flextable for reporting
qflextable <- function(data){
  autofit(flextable(data))
}

#' @export
#' @title set caption
#' @description set caption value in flextable
#' @param x flextable object
#' @param caption caption value
#' @param autonum an autonum representation. See \code{\link[officer]{run_autonum}}.
#' This has only an effect when output is Word. If used, the caption is preceded
#' by an auto-number sequence. In this case, the caption is preceded by an auto-number
#' sequence.
#' @param ref a single character identifier that will be used as bookmark label.
#' This has only an effect when output is Word. If used, the caption is bookmarked
#' and can be cross-referenced. See also \code{\link[officer]{run_reference}}.
#' @param style caption paragraph style name. These names are available with
#' function \code{\link[officer]{styles_info}}.
#' @param html_escape should HTML entities be escaped so that it can be safely
#' included as text or an attribute value within an HTML document.
#' @note
#' this will have an effect only when output is HTML or Word document.
#' @examples
#' ftab <- flextable( head( iris ) )
#' ftab <- set_caption(ftab, "my caption")
#' ftab
#' @importFrom officer run_autonum
set_caption <- function(x, caption,
    autonum = NULL, ref = NULL, style = "Table Caption",
    html_escape = TRUE){

  if( !inherits(x, "flextable") ) stop("set_caption supports only flextable objects.")

  if( !is.character(caption) && length(caption) != 1 ){
    stop("caption should be a single character value")
  }
  if(html_escape){
    caption <- htmlEscape(caption)
  }
  x$caption <- list(value = caption)

  if(!is.null(autonum) && inherits(autonum, "run_autonum")){
    x$caption$autonum <- autonum
  }
  x$caption$style <- style
  x$caption$ref <- ref

  x
}

#' @rdname flextable
#' @export
regulartable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){
  flextable(data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight)
}
