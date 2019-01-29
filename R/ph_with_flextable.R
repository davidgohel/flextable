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
    value$header <- correct_h_border(value$header)
    value$header <- correct_v_border(value$header)
    xml_content <- format(value$header, header = TRUE, type = "pml")
    out = paste0(out, xml_content )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
  }
  if( nrow_part(value, "body") > 0 ){
    value$body <- correct_h_border(value$body)
    value$body <- correct_v_border(value$body)
    xml_content <- format(value$body, header = FALSE, type = "pml")
    out = paste0(out, xml_content )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
  }
  if( nrow_part(value, "footer") > 0 ){
    value$footer <- correct_h_border(value$footer)
    value$footer <- correct_v_border(value$footer)
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

#' @export
#' @title add flextable into a PowerPoint slide
#' @description add a flextable as a new shape in the current slide.
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
ph_with_flextable <- function( x, value, type = "body", index = 1 ){
  stopifnot(inherits(x, "rpptx"))
  graphic_frame <- pml_flextable(value)

  hlinks <- attr(graphic_frame, "hlinks")
  if( length(hlinks) > 0 ){
    slide <- x$slide$get_slide(x$cursor)
    rel <- slide$relationship()
    graphic_frame <- process_url(rel, url = hlinks, str = graphic_frame, pattern = "a:hlinkClick")
  }
  ph_from_xml(x = x, value = graphic_frame, type = type, index = index )
}

#' @export
#' @param left,top location of flextable on the slide in inches
#' @rdname ph_with_flextable
#' @importFrom officer ph_from_xml_at
ph_with_flextable_at <- function( x, value, left, top ){
  stopifnot(inherits(x, "rpptx"))
  graphic_frame <- pml_flextable(value)

  hlinks <- attr(graphic_frame, "hlinks")
  if( length(hlinks) > 0 ){
    for( hl in hlinks ){
      slide <- x$slide$get_slide(x$cursor)
      rel <- slide$relationship()
      graphic_frame <- process_url(rel, url=hl, str = graphic_frame, pattern = "a:hlinkClick")
    }
  }

  ph_from_xml_at(x = x, value = graphic_frame, left = left, top = top,
                 width = 0, height = 0 )
}

