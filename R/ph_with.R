#' @importFrom officer ph_with
#' @export
#' @title add a flextable into a PowerPoint slide
#' @description Add a flextable in a PowerPoint document object produced
#' by [officer::read_pptx()].
#' @param x a pptx device
#' @param value flextable object
#' @param location a location for a placeholder. See [officer::ph_location_type()]
#' for example.
#' @param ... unused arguments.
#' @note
#' The width and height of the table can not be set with `location`. Use
#' functions [width()], [height()], [autofit()]
#' and [dim_pretty()] instead. The overall size is resulting from
#' cells, paragraphs and text properties (i.e. padding, font size, border widths).
#' @examples
#' library(officer)
#'
#' ft <- flextable(head(iris))
#'
#' doc <- read_pptx()
#' doc <- add_slide(doc, "Title and Content", "Office Theme")
#' doc <- ph_with(doc, ft, location = ph_location_left())
#'
#' fileout <- tempfile(fileext = ".pptx")
#' print(doc, target = fileout)
ph_with.flextable <- function(x, value, location, ...) {
  stopifnot(inherits(x, "rpptx"))

  value <- flextable_global$defaults$post_process_pptx(value)

  graphic_frame <- gen_raw_pml(value)
  ph_with(x = x, value = as_xml_document(graphic_frame), location = location, ...)
}
