docx_str <- function( x, ... ){
  UseMethod("docx_str")
}

docx_str.regulartable <- function(x, align = "center", split = FALSE, doc = NULL, ...){

  imgs <- character(0)
  hlinks <- character(0)

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

  if( nrow_part(x, "header") > 0 ){
    x$header <- correct_h_border(x$header)
    x$header <- correct_v_border(x$header)
    xml_content <- format(x$header, header = TRUE, split = split, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
    out = paste0(out, xml_content )
  }
  if( nrow_part(x, "body") > 0 ){
    x$body <- correct_h_border(x$body)
    x$body <- correct_v_border(x$body)
    xml_content <- format(x$body, header = FALSE, split = split, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
    out = paste0(out, xml_content )
  }
  if( nrow_part(x, "footer") > 0 ){
    x$footer <- correct_h_border(x$footer)
    x$footer <- correct_v_border(x$footer)
    xml_content <- format(x$footer, header = FALSE, split = split, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs")$image_src )
    hlinks <- append( hlinks, attr(xml_content, "htxt")$href )
    out = paste0(out, xml_content )
  }

  imgs <- unique(imgs)
  hlinks <- unique(hlinks)
  out <- paste0(out,  "</w:tbl>" )

  if( length(imgs) > 0 ) {
    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      doc <- docx_reference_img( doc, imgs )
      out <- wml_link_images( doc, out )
    }
  }
  if( length(hlinks) > 0 ){
    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      for( hl in hlinks ){
        rel <- doc$doc_obj$relationship()
        out <- process_url(rel, url = hl, str = out, pattern = "w:hyperlink", double_esc = FALSE)
      }
    }
  }

  out

}

docx_str.complextable <- docx_str.regulartable

