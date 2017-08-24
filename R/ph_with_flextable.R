pml_flextable <- function(value){
  out <- "<a:tbl>"
  dims <- dim(value)
  widths <- dims$widths
  colswidths <- paste0("<a:gridCol w=\"", round(widths*914400, 0), "\"/>", collapse = "")

  out = paste0(out,  "<a:tblPr/><a:tblGrid>" )
  out = paste0(out,  colswidths )
  out = paste0(out,  "</a:tblGrid>" )

  if( !is.null(value$header) )
    out = paste0(out, format(value$header, header = TRUE, type = "pml") )
  if( !is.null(value$body) )
    out = paste0(out, format(value$body, header = FALSE, type = "pml") )
  out = paste0(out,  "</a:tbl>" )

  graphic_frame <- paste0(
    "<p:graphicFrame ",
    "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
    "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
    "xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\">",
    "<p:nvGraphicFramePr>",
    "<p:cNvPr id=\"\" name=\"\"/>",
    "<p:cNvGraphicFramePr><a:graphicFrameLocks noGrp=\"true\"/></p:cNvGraphicFramePr>",
    "<p:nvPr/>",
    "</p:nvGraphicFramePr>",
    "<p:xfrm rot=\"0\">",
    "<a:off x=\"0\" y=\"0\"/>",
    "<a:ext cx=\"0\" cy=\"0\"/>",
    "</p:xfrm>",
    "<a:graphic>",
    "<a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">",
    out,
    "</a:graphicData>",
    "</a:graphic>",
    "</p:graphicFrame>"
  )
  graphic_frame
}

#' @export
#' @title add flextable into a PowerPoint slide
#' @description add a flextable as a new shape in the current slide.
#' @param x a pptx device
#' @param value \code{flextable} object
#' @param type placeholder type
#' @param index placeholder index (integer). This is to be used when a placeholder type
#' is not unique in the current slide, e.g. two placeholders with type 'body'.
#' @examples
#' library(officer)
#' ft <- flextable(head(mtcars))
#' \donttest{
#' doc <- read_pptx()
#' doc <- add_slide(doc, layout = "Title and Content",
#'                  master = "Office Theme")
#' doc <- ph_with_flextable(doc, value = ft, type = "body")
#' doc <- ph_with_flextable_at(doc, value = ft, left = 4, top = 5)
#' \donttest{print(doc, target = "test.pptx" )}
#' }
#' @importFrom officer ph_from_xml
ph_with_flextable <- function( x, value, type, index = 1 ){
  stopifnot(inherits(x, "rpptx"))
  graphic_frame <- pml_flextable(value)
  ph_from_xml(x = x, value = graphic_frame, type = type, index = index )
}

#' @export
#' @param left,top location of flextable on the slide
#' @rdname ph_with_flextable
#' @importFrom officer ph_from_xml_at
ph_with_flextable_at <- function( x, value, left, top ){
  stopifnot(inherits(x, "rpptx"))
  stopifnot(inherits(x, "rpptx"))
  graphic_frame <- pml_flextable(value)
  ph_from_xml_at(x = x, value = graphic_frame, left = left, top = top, width = 0, height = 0 )
}

