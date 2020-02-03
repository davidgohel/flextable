#' @export
#' @title add flextable into a PowerPoint slide
#' @description add a flextable as a new shape in the current slide.
#'
#' These functions will be deprecated in the next release and
#' method \code{\link[officer]{ph_with}} should be used instead.
#' @note
#' The width and height of the table can not be set with this function. Use
#' functions \code{\link{width}}, \code{\link{height}}, \code{\link{autofit}}
#' and \code{\link{dim_pretty}} instead. The overall size is resulting from
#' cells, paragraphs and text properties (i.e. padding, font size, border widths).
#' @param x an rpptx device
#' @param value \code{flextable} object
#' @param type placeholder type
#' @param index placeholder index (integer). This is to be used when a placeholder type
#' is not unique in the current slide, e.g. two placeholders with type 'body'.
#' @importFrom officer ph_location_type
ph_with_flextable <- function( x, value, type = "body", index = 1 ){
  .Deprecated(new = "officer::ph_with")
  stopifnot(inherits(x, "rpptx"))
  ph_with(x, value, location = ph_location_type(type = type, id = index))
}

#' @title Define flextable displayed values
#' @description Modify flextable displayed values by specifying a
#' string expression. Function is deprecated in favor of \code{\link{compose}}.
#' @param x a flextable object
#' @param i rows selection
#' @param col_key column to modify, a single character
#' @param pattern string to format
#' @param formatters a list of formula, left side for the name,
#' right side for the content.
#' @param fprops a named list of \link[officer]{fp_text}
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @section pattern:
#' It defined the template used to format the produced strings. Names enclosed
#' by double braces will be evaluated as R code, the corresponding R code is defined
#' with the argument \code{formatters}.
#' @section formatters:
#' Each compound is specifying the R code to execute to produce strings that will be
#' substituted in the \code{pattern} argument. An element must be a formula: the
#' left-hand side is a name (matching a name enclosed by double braces in
#' \code{pattern}) and the right-hand side is an R expression to be evaluated (that
#' will produce the corresponding strings).
#'
#' The function is designed to work with columns in the dataset provided to
#' \code{flextable} (the col_keys).
#' @section fprops:
#' A named list of \link[officer]{fp_text}. It defines the formatting properties
#' associated to a compound in \code{formatters}. If not defined for an element
#' of \code{formatters}, the default formatting properties will be applied.
#' @export
display <- function(x, i = NULL, col_key,
                    pattern, formatters = list(), fprops = list(),
                    part = "body"){

  .Deprecated("compose")

  if( !inherits(x, "flextable") ) stop("display supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  stopifnot(is.character(pattern), length(pattern)==1)

  if( length( fprops ) && !all(sapply( fprops, inherits, "fp_text")) ){
    stop("argument fprops should be a list of fp_text")
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], col_key )

  newcontent <- old_display_init(x = pattern,
                                 formatters = formatters, fprops = fprops, x[[part]]$dataset[i,])
  x[[part]]$content[i, j] <- newcontent

  x
}

