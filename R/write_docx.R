#' @importFrom officer pack_folder read_relationship
#' @title Microsoft Word table
#'
#' @description
#' Table for Microsoft Word documents.
#' @param file filename of the Microsoft Word document to produce. File
#' extension must be \code{.docx}.
#' @param x flextable
#' @param pagesize Word document page size in inches.
#' A named vector (\code{width} and \code{height}).
#' @param margins Word document margins size in inches.
#' A named vector (\code{left}, \code{right}, \code{top}, \code{bottom}).
#' @examples
#' ft <- flextable(head(iris))
#' write_docx(file = "test.docx", x = ft )
#' @export
#' @importFrom officer docx
write_docx <- function( file, x,
                        pagesize = c(width = 8.5, height = 11),
                        margins = c( left = 1, right = 1, top = 1, bottom = 1 ) ) {

  if( file_ext(file) != "docx" )
    stop(file , " should have '.docx' as extension.")

  doc <- docx()
  doc <- docx_add_flextable( doc, x, pos = "on" )
  print(doc, target = file )
}

#' @export
#' @title wml table code
#' @description produces the wml of a flextable
#' @param x a docx object
#' @param value \code{flextable} object
#' @param pos where to add the flextable relative to the cursor,
#' one of "after", "before", "on" (end of line).
#' @importFrom officer add_xml_node wml_link_images docx_reference_img
docx_add_flextable <- function( x, value, pos = "after"){

  imgs <- character(0)

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

  out <- paste0(out, "<w:tblPr><w:tblLayout w:type=\"fixed\"/></w:tblPr>" )

  out = paste0(out,  "<w:tblGrid>" )
  out = paste0(out,  colswidths )
  out = paste0(out,  "</w:tblGrid>" )

  if( !is.null(value$header) ){
    xml_content <- format(value$header, header = TRUE, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs") )
    out = paste0(out, xml_content )
  }
  if( !is.null(value$body) ){
    xml_content <- format(value$body, header = FALSE, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs") )
    out = paste0(out, xml_content )
  }
  imgs <- unique(imgs)
  out <- paste0(out,  "</w:tbl>" )

  if( length(imgs) > 0 ) {
    rids <- docx_reference_img( x, imgs )
    out <- wml_link_images( out, rids )
  }


  add_xml_node(x = x, str = out, pos = pos)

}

