docx_str <- function( x, ... ){
  UseMethod("docx_str")
}

## This is basically a copy of (old) body_add_flextable, which just generates
## needed XML without inserting into a document (x is a flextable object here),
## as a consequence images are not supported since a document is needed for that.
docx_str.regulartable <- function(x, align = "center", doc = NULL, ...){

  imgs <- character(0)

  align <- match.arg(align, c("center", "left", "right"), several.ok = FALSE)
  align <- c("center" = "center", "left" = "start", "right" = "end")[align]
  align <- as.character(align)

  dims <- dim(x)
  widths <- dims$widths
  colswidths <- paste0("<w:gridCol w:w=\"", round(widths*72*20, 0), "\"/>", collapse = "")

  out <- paste0(
      "<w:tbl xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" ",
      "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
      "xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\" ",
      "xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" ",
      "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
      "xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\" ",
      ">")

  out <- paste0(out, "<w:tblPr><w:tblLayout w:type=\"fixed\"/>",
                sprintf( "<w:jc w:val=\"%s\"/>", align ),
                "</w:tblPr>" )

  out = paste0(out,  "<w:tblGrid>" )
  out = paste0(out,  colswidths )
  out = paste0(out,  "</w:tblGrid>" )

  if( !is.null(x$header) ){
    xml_content <- format(x$header, header = TRUE, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    out = paste0(out, xml_content )
  }
  if( !is.null(x$body) ){
    xml_content <- format(x$body, header = FALSE, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    out = paste0(out, xml_content )
  }

  imgs <- unique(imgs)
  out <- paste0(out,  "</w:tbl>" )

  if( length(imgs) > 0 ) {

    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      doc <- docx_reference_img( doc, imgs )
      out <- wml_link_images( doc, out )
    } else
      warning("Images are not supported yet for docx-rmarkdwon generation",
          call. = FALSE)
  }

  out

}

docx_str.complextable <- docx_str.regulartable

