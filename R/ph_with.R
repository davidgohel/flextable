pml_flextable <- function(value, uid = 99999L, offx = 0, offy = 0, cx = 0, cy = 0){
  out <- "<a:tbl>"
  dims <- dim(value)
  widths <- dims$widths
  colswidths <- paste0("<a:gridCol w=\"", round(widths*914400, 0), "\"/>", collapse = "")
  hlinks <- character(0)

  out = paste0(out,  "<a:tblPr/><a:tblGrid>" )
  out = paste0(out,  colswidths )
  out = paste0(out,  "</a:tblGrid>" )

  if( nrow_part(value, "header") > 0 ){
    xml_content <- format(value$header, header = TRUE, type = "pml")
    out = paste0(out, xml_content )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
  }
  if( nrow_part(value, "body") > 0 ){
    xml_content <- format(value$body, header = FALSE, type = "pml")
    out = paste0(out, xml_content )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
  }
  if( nrow_part(value, "footer") > 0 ){
    xml_content <- format(value$footer, header = FALSE, type = "pml")
    out = paste0(out, xml_content )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
  }
  out = paste0(out,  "</a:tbl>" )

  graphic_frame <- paste0(
    "<p:graphicFrame ",
    "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
    "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
    "xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\">",
    "<p:nvGraphicFramePr>",
    sprintf("<p:cNvPr id=\"%.0f\" name=\"\"/>", uid ),
    "<p:cNvGraphicFramePr><a:graphicFrameLocks noGrp=\"true\"/></p:cNvGraphicFramePr>",
    "<p:nvPr/>",
    "</p:nvGraphicFramePr>",
    "<p:xfrm rot=\"0\">",
    sprintf("<a:off x=\"%.0f\" y=\"%.0f\"/>", offx*914400, offy*914400),
    sprintf("<a:ext cx=\"%.0f\" cy=\"%.0f\"/>", cx*914400, cy*914400),
    "</p:xfrm>",
    "<a:graphic>",
    "<a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">",
    out,
    "</a:graphicData>",
    "</a:graphic>",
    "</p:graphicFrame>"
  )
  attr(graphic_frame, "hlinks") <- hlinks
  graphic_frame
}

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
#' ft = flextable(head(iris))
#'
#' doc <- read_pptx()
#' doc <- add_slide(doc, "Title and Content", "Office Theme")
#' doc <- ph_with(doc, ft, location = ph_location_left())
#'
#' fileout <- tempfile(fileext = ".pptx")
#' print(doc, target = fileout)
ph_with.flextable <- function( x, value, location, ... ){
  stopifnot(inherits(x, "rpptx"))
  graphic_frame <- pml_flextable(value)
  hlinks <- attr(graphic_frame, "hlinks")
  if( length(hlinks) > 0 ){
    slide <- x$slide$get_slide(x$cursor)
    rel <- slide$relationship()
    graphic_frame <- process_url(rel, url = hlinks, str = graphic_frame, pattern = "a:hlinkClick", double_esc = FALSE)
  }
  ph_with(x = x, value = as_xml_document(graphic_frame), location = location, ... )
}

