#' @export
#' @title wml table code
#' @description produces the wml of a flextable
#' @param x a docx object
#' @param value \code{flextable} object
#' @param align left (default), center or right.
#' @param pos where to add the flextable relative to the cursor,
#' one of "after", "before", "on" (end of line).
#' @importFrom officer body_add_xml wml_link_images docx_reference_img
#' @examples
#' library(officer)
#' ft <- flextable(head(mtcars))
#' ft <- theme_zebra(ft)
#' \donttest{ft <- autofit(ft)}
#' doc <- read_docx()
#' doc <- body_add_flextable(doc, value = ft)
#' \donttest{print(doc, target = "test.docx")}
body_add_flextable <- function( x, value, align = "center", pos = "after"){
  stopifnot(inherits(x, "rdocx"))
  imgs <- character(0)

  align <- match.arg(align, c("center", "left", "right"), several.ok = FALSE)
  align <- c("center" = "center", "left" = "start", "right" = "end")[align]
  align <- as.character(align)

  dims <- dim(value)
  widths <- dims$widths
  colswidths <- paste0("<w:gridCol w:w=\"", round(widths*72*20, 0), "\"/>", collapse = "")

  out <- paste0(
      "<w:tbl xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" ",
      "xmlns:w15=\"http://schemas.microsoft.com/office/word/2012/wordml\" ",
      "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
      "xmlns:m=\"http://schemas.openxmlformats.org/officeDocument/2006/math\" ",
      "xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\" ",
      "xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" ",
      "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
      "xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" ",
      "xmlns:ns9=\"http://schemas.openxmlformats.org/schemaLibrary/2006/main\" ",
      "xmlns:wne=\"http://schemas.microsoft.com/office/word/2006/wordml\" ",
      "xmlns:c=\"http://schemas.openxmlformats.org/drawingml/2006/chart\" ",
      "xmlns:ns12=\"http://schemas.openxmlformats.org/drawingml/2006/chartDrawing\" ",
      "xmlns:dgm=\"http://schemas.openxmlformats.org/drawingml/2006/diagram\" ",
      "xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\" ",
      "xmlns:xdr=\"http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing\" ",
      "xmlns:dsp=\"http://schemas.microsoft.com/office/drawing/2008/diagram\" ",
      "xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" ",
      "xmlns:ns19=\"urn:schemas-microsoft-com:office:excel\" xmlns:w10=\"urn:schemas-microsoft-com:office:word\" ",
      "xmlns:ns21=\"urn:schemas-microsoft-com:office:powerpoint\" xmlns:ns23=\"http://schemas.microsoft.com/office/2006/coverPageProps\" ",
      "xmlns:odx=\"http://opendope.org/xpaths\" xmlns:odc=\"http://opendope.org/conditions\" ",
      "xmlns:odq=\"http://opendope.org/questions\" xmlns:oda=\"http://opendope.org/answers\" ",
      "xmlns:odi=\"http://opendope.org/components\" xmlns:odgm=\"http://opendope.org/SmartArt/DataHierarchy\" ",
      "xmlns:ns30=\"http://schemas.openxmlformats.org/officeDocument/2006/bibliography\" ",
      "xmlns:ns31=\"http://schemas.openxmlformats.org/drawingml/2006/compatibility\" ",
      "xmlns:ns32=\"http://schemas.openxmlformats.org/drawingml/2006/lockedCanvas\" ",
      "xmlns:wpc=\"http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas\" ",
      "xmlns:wpg=\"http://schemas.microsoft.com/office/word/2010/wordprocessingGroup\" ",
      "xmlns:wps=\"http://schemas.microsoft.com/office/word/2010/wordprocessingShape\">")

  out <- paste0(out, "<w:tblPr><w:tblLayout w:type=\"fixed\"/>",
                sprintf( "<w:jc w:val=\"%s\"/>", align ),
                "</w:tblPr>" )

  out = paste0(out,  "<w:tblGrid>" )
  out = paste0(out,  colswidths )
  out = paste0(out,  "</w:tblGrid>" )

  if( !is.null(value$header) ){
    xml_content <- format(value$header, header = TRUE, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    out = paste0(out, xml_content )
  }
  if( !is.null(value$body) ){
    xml_content <- format(value$body, header = FALSE, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    out = paste0(out, xml_content )
  }

  imgs <- unique(imgs)
  out <- paste0(out,  "</w:tbl>" )

  if( length(imgs) > 0 ) {
    x <- docx_reference_img( x, imgs )
    out <- wml_link_images( x, out )
  }

  body_add_xml(x = x, str = out, pos = pos)

}

