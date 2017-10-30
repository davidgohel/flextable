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


#' @title Render flextable in rmarkdown (including Word output)
#' @description Function to use in the knitr/rmarkdown's \code{render} chunk 
#' option.
#' For Word (docx) output, if pandoc vesion >= 2.0 is used, a raw XML block 
#' with the table code will be inserted.
#' For HTML output, you won't need an extra call to \code{\link{tabwid}}, but 
#' can just use \code{\link{flextable}} inside a chunk.  
#' @note To insert all flextables automatically, define 
#' \code{knit_print.flextable = render_flextable} in the beginning of 
#' the rmarkdown document.
#' @seealso vignette("knit_print", package = "knitr")
#' @param x a \code{flextable} object
#' @param ... further arguments
#' @author Maxim Nazarov
#' @export
render_flextable <- function(x, ...) {

  # so that knitr/rmarkdown can stay in 'suggests'
  if (requireNamespace("knitr", quietly = TRUE) && 
      requireNamespace("rmarkdown", quietly = TRUE)) {
    
    if (is.null(knitr::opts_knit$get("rmarkdown.pandoc.to")))
      stop("`render_flextable` needs to be used as a renderer for ", 
           "a knitr/rmarkdown R code chunk")
     
    if (knitr::opts_knit$get("rmarkdown.pandoc.to") == "docx") { 
      
      if (rmarkdown::pandoc_version() >= 2) {
        # insert rawBlock with Open XML
        knitr::asis_output(
            paste("```{=openxml}", docx_str(x), "```", sep = "\n")
        )
      } else {
        stop("pandoc version >= 2.0 required for flextable rendering in docx")
      }
      
    } else if (knitr::opts_knit$get("rmarkdown.pandoc.to") == "html") {
      # show widget
      knitr::knit_print(tabwid(x))
    } else 
      stop("unsupported format for flextable rendering")
    
  } else {
    stop("`knitr` and `rmarkdown` packages are needed to use `render_flextable`")
  }

}
