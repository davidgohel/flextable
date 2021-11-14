#' @title flextable creation
#'
#' @description Create a flextable object with function `flextable`.
#'
#' `flextable` are designed to make tabular reporting easier for
#' R users. Functions are available to let you format text, paragraphs and cells;
#' table cells can be merge vertically or horizontally, row headers can easilly
#' be defined, rows heights and columns widths can be manually set or automatically
#' computed.
#'
#' Default formatting properties are automatically applied to every
#' flextable you produce. You can change these default values with
#' function [set_flextable_defaults()].
#'
#' @details
#' A `flextable` is made of 3 parts: header, body and footer.
#'
#' Most functions have an argument named `part` that will be used
#' to specify what part of of the table should be modified.
#'
#' If working with R Markdown document, you should read about knitr
#' chunk options in [knit_print.flextable()] and about setting
#' default values with [set_flextable_defaults()].
#' @param data dataset
#' @param col_keys columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns by default.
#' @param cwidth,cheight initial width and height to use for cell sizes in inches.
#' @param defaults,theme_fun deprecated, use [set_flextable_defaults()] instead.
#' @note Function `regulartable` is maintained for compatibility with old codes
#' mades by users but be aware it produces the same exact object than `flextable`.
#' This function should be deprecated then removed in the next versions.
#' @examples
#' ft <- flextable(head(mtcars))
#' ft
#' @export
#' @importFrom stats setNames
#' @seealso [style()], [autofit()], [theme_booktabs()], [knit_print.flextable()],
#' [compose()], [footnote()], [set_caption()]
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

  # footer
  footer_data <- header_data[FALSE, , drop = FALSE]
  footer <- complex_tabpart( data = footer_data, col_keys = col_keys, cwidth = cwidth, cheight = cheight )

  out <- list( header = header, body = body, footer = footer, col_keys = col_keys,
               caption = list(value = NULL, style_id = NULL),
               blanks = blanks )
  class(out) <- c("flextable")

  out <- do.call(flextable_global$defaults$theme_fun, list(out))
  out <- set_table_properties(x = out, layout = flextable_global$defaults$table.layout)

  out
}

#' @export
#' @rdname flextable
#' @section qflextable:
#' `qflextable` is a convenient tool to produce quickly
#' a flextable for reporting where layoout is fixed and columns
#' widths adjusted with [autofit()].
qflextable <- function(data){
  ft <- flextable(data)
  ft <- set_table_properties(ft, layout = "fixed")
  autofit(ft)
}

#' @export
#' @title Set Caption
#' @description Set caption value in a flextable.
#'
#' * The caption will be associated with a paragraph style when
#' the output is Word. It can also be numbered as a auto-numbered
#' Word computed value.
#' * The PowerPoint format ignores captions.
#'
#' @section R Markdown:
#'
#' flextable captions can be defined from R Markdown documents by using
#' `knitr::opts_chunk$set()`. The following options are available:
#'
#' | **label**                                               |    **name**     | **value**  |
#' |:--------------------------------------------------------|:---------------:|:----------:|
#' | Word stylename to use for table captions.               | tab.cap.style   |    NULL    |
#' | prefix for numbering chunk (default to   "Table ").     | tab.cap.pre     |   Table    |
#' | suffix for numbering chunk (default to   ": ").         | tab.cap.sep     |    " :"    |
#' | title number depth                                      | tab.cap.tnd     |      0     |
#' | separator to use between title number and table number. | tab.cap.tns     |     "-"    |
#' | caption prefix formatting properties                    | tab.cap.fp_text | fp_text_lite(bold = TRUE) |
#' | caption id/bookmark                                     | tab.id          |    NULL    |
#' | caption                                                 | tab.cap         |    NULL    |
#' | display table caption on top of the table or not        | tab.topcaption  |    TRUE    |
#' | caption table sequence identifier.                      | tab.lp          |   "tab:"   |
#'
#' See [knit_print.flextable] for more details.
#'
#' @param x flextable object
#' @param caption caption value
#' @param autonum an autonum representation. See [officer::run_autonum()].
#' This has only an effect when output is Word. If used, the caption is preceded
#' by an auto-number sequence. In this case, the caption is preceded by an auto-number
#' sequence that can be cross referenced.
#' @param style caption paragraph style name. These names are available with
#' function [officer::styles_info()] when output is Word; if HTML, the
#' value is set as class value in the `caption` tag.
#' @param html_escape should HTML entities be escaped so that it can be safely
#' included as text or an attribute value within an HTML document.
#' @examples
#' ftab <- flextable( head( iris ) )
#' ftab <- set_caption(ftab, "my caption")
#' ftab
#'
#' library(officer)
#' autonum <- run_autonum(seq_id = "tab", bkm = "mtcars")
#' ftab <- flextable( head( mtcars ) )
#' ftab <- set_caption(ftab, caption = "mtcars data", autonum = autonum)
#' ftab
#' @importFrom officer run_autonum
#' @seealso [flextable()]
set_caption <- function(x, caption,
    autonum = NULL, style = "Table Caption",
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

  x
}

#' @rdname flextable
#' @export
regulartable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){
  flextable(data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight)
}
