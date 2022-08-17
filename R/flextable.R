#' @title flextable creation
#'
#' @description Create a flextable object with function `flextable`.
#'
#' `flextable` are designed to make tabular reporting easier for
#' R users. Functions are available to let you format text, paragraphs and cells;
#' table cells can be merge vertically or horizontally, row headers can easily
#' be defined, rows heights and columns widths can be manually set or automatically
#' computed.
#'
#' If working with 'R Markdown' documents, you should read about knitr
#' chunk options in [knit_print.flextable()] and about setting
#' default values with [set_flextable_defaults()].
#'
#' @section Reuse frequently used parameters:
#'
#' Some default formatting properties are automatically
#' applied to every flextable you produce.
#'
#' It is highly recommended to use this function because
#' its use will minimize the code. For example, instead of
#' calling the `fontsize()` function over and over again for
#' each new flextable, set the font size default value by
#' calling (before creating the flextables)
#' `set_flextable_defaults(font.size = 11)`. This is also
#' a simple way to have homogeneous arrays and make the
#' documents containing them easier to read.
#'
#' You can change these default values with function
#' [set_flextable_defaults()]. You can reset them
#' with function [init_flextable_defaults()]. You
#' can access these values by calling [get_flextable_defaults()].
#'
#' @section new lines and tabulations:
#'
#' The 'flextable' package will translate for you
#' the new lines expressed in the form `\n` and
#' the tabs expressed in the form `\t`.
#'
#' The new lines will be transformed into "soft-return",
#' that is to say a simple carriage return and not a
#' new paragraph.
#'
#' Tabs are different depending on the output format:
#'
#' - HTML is using entity *em space*
#' - Word - a Word 'tab' element
#' - PowerPoint - a PowerPoint 'tab' element
#' - latex - tag "\\quad "
#' @section flextable parts:
#'
#' A `flextable` is made of 3 parts: header, body and footer.
#'
#' Most functions have an argument named `part` that will be used
#' to specify what part of of the table should be modified.
#' @param data dataset
#' @param col_keys columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns by default.
#' @param cwidth,cheight initial width and height to use for cell sizes in inches.
#' @param defaults,theme_fun deprecated, use [set_flextable_defaults()] instead.
#' @examples
#' ft <- flextable(head(mtcars))
#' ft
#' @export
#' @importFrom stats setNames
#' @seealso [style()], [autofit()], [theme_booktabs()], [knit_print.flextable()],
#' [compose()], [footnote()], [set_caption()]
flextable <- function(data, col_keys = names(data),
                      cwidth = .75, cheight = .25,
                      defaults = list(), theme_fun = theme_booktabs ){


  stopifnot(is.data.frame(data), ncol(data) > 0 )
  if( any( duplicated(col_keys) ) ){
    stop("duplicated col_keys: ",
         paste0(unique(col_keys[duplicated(col_keys)]), collapse = ", "))
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
#' a flextable for reporting where layout is fixed (see
#' [set_table_properties()]) and columns
#' widths are adjusted with [autofit()].
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
#' * The PowerPoint format ignores captions. PowerPoint documents are not
#' structured and do not behave as HTML documents and paginated documents
#' (word, pdf), and it's not possible to know where we should create
#' a shape to contain the caption (technically it can't be in the
#' PowerPoint shape containing the table).
#'
#' @section R Markdown:
#'
#' flextable captions can be defined from R Markdown documents by using
#' `knitr::opts_chunk$set()`. The following options are available
#' with `officedown::rdocx_document` and/or bookdown:
#'
#' | **label**                                               |    **name**     | **value**  |
#' |:--------------------------------------------------------|:---------------:|:----------:|
#' | Word stylename to use for table captions.               | tab.cap.style   |    NULL    |
#' | caption id/bookmark                                     | tab.id          |    NULL    |
#' | caption                                                 | tab.cap         |    NULL    |
#' | display table caption on top of the table or not        | tab.topcaption  |    TRUE    |
#' | caption table sequence identifier.                      | tab.lp          |   "tab:"   |
#'
#' The following options are only available when used with `officedown::rdocx_document`:
#'
#' | **label**                                               |    **name**     | **value**  |
#' |:--------------------------------------------------------|:---------------:|:----------:|
#' | prefix for numbering chunk (default to   "Table ").     | tab.cap.pre     |   Table    |
#' | suffix for numbering chunk (default to   ": ").         | tab.cap.sep     |    " :"    |
#' | title number depth                                      | tab.cap.tnd     |      0     |
#' | separator to use between title number and table number. | tab.cap.tns     |     "-"    |
#' | caption prefix formatting properties                    | tab.cap.fp_text | fp_text_lite(bold = TRUE) |
#'
#'
#' See [knit_print.flextable] for more details.
#'
#' @section Using 'Quarto':
#'
#' 'Quarto' manage captions and cross-references instead of flextable. That's why
#' `set_caption()` is not useful in a 'Quarto' document except for Word documents
#' where 'Quarto' does not manage captions.
#'
#' knitr options are the same than those detailled in the R Markdown section (see upper),
#' but be aware that 'Quarto' manage captions and related items can be overwritten by
#' Quarto.
#'
#' @param x flextable object
#' @param caption caption value
#' @param autonum an autonum representation. See [officer::run_autonum()].
#' This has only an effect when output is Word. If used, the caption is preceded
#' by an auto-number sequence. In this case, the caption is preceded by an auto-number
#' sequence that can be cross referenced.
#' @param word_stylename,style 'Word' style name to associate with caption paragraph. These names are available with
#' function [officer::styles_info()] when output is Word. Argument `style`
#' is deprecated in favor of `word_stylename`.
#' @param html_classes css class(es) to apply to associate with caption paragraph
#' when output is 'Word'.
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
#' @importFrom htmltools htmlEscape
#' @seealso [flextable()]
set_caption <- function(
    x,
    caption,
    autonum = NULL,
    word_stylename = "Table Caption",
    style = word_stylename,
    html_classes = NULL,
    html_escape = TRUE
    ){

  if( !inherits(x, "flextable") ) {
    stop("set_caption supports only flextable objects.")
  }

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
  x$caption$word_stylename <- word_stylename
  x$caption$html_classes <- paste(html_classes, collapse = " ")

  x
}

#' @keywords internal
#' @title flextable old functions
#' @description The function is maintained for compatibility with old codes
#' mades by users but be aware it produces the same exact object than [flextable()].
#' This function should be deprecated then removed in the next versions.
#' @param data dataset
#' @param col_keys columns names/keys to display. If some column names are not in
#' the dataset, they will be added as blank columns by default.
#' @param cwidth,cheight initial width and height to use for cell sizes in inches.
#' @export
regulartable <- function( data, col_keys = names(data), cwidth = .75, cheight = .25 ){
  flextable(data = data, col_keys = col_keys, cwidth = cwidth, cheight = cheight)
}
