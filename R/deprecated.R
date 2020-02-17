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

