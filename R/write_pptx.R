#' @importFrom officer read_pptx add_slide
#' @title Microsoft PowerPoint table
#'
#' @description
#' Table for Microsoft PowerPoint documents.
#' @param file filename of the Microsoft PowerPoint document to produce. File
#' extension must be \code{.pptx}.
#' @param x flextable
#' @examples
#' ft <- flextable(head(mtcars))
#' ft <- theme_zebra(ft)
#' ft <- autofit(ft)
#' write_pptx(file = "test.pptx", x = ft )
#' @export
write_pptx <- function(file, x) {
  doc <- read_pptx()
  doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
  doc <- ph_with_flextable(doc, value = x, type = "body")
  print(doc, target = file )
}


#' @export
#' @title wml table code
#' @description produces the wml of a flextable
#' @param x a pptx device
#' @param value \code{flextable} object
#' @param type placeholder type
#' @param index placeholder index (integer). This is to be used when a placeholder type
#' is not unique in the current slide, e.g. two placeholders with type 'body'.
#' @examples
#' library(officer)
#' ft <- flextable(head(mtcars))
#' ft <- theme_zebra(ft)
#' ft <- autofit(ft)
#' doc <- read_pptx()
#' doc <- add_slide(doc, layout = "Title and Content", master = "Office Theme")
#' doc <- ph_with_flextable(doc, value = ft, type = "body")
#' print(doc, target = "test.pptx" )
#' @importFrom officer ph_from_xml
ph_with_flextable <- function( x, value, type, index = 1 ){

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

  ph_from_xml(x = x, value = graphic_frame, type = type, index = index )
}

