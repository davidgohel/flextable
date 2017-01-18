#' @importFrom utils unzip
#' @importFrom oxbase pack_folder read_relationship
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
write_docx <- function( file, x,
                        pagesize = c(width = 8.5, height = 11),
                        margins = c( left = 1, right = 1, top = 1, bottom = 1 ) ) {

  if( file_ext(file) != "docx" )
    stop(file , " should have '.docx' as extension.")


  template_dir <- tempfile()
  unzip( zipfile = file.path( system.file(package = "flextable"), "templates/vanilla.docx" ), exdir = template_dir )
  drop_dir <- file.path(template_dir, "__MACOSX")
  if( file.exists(drop_dir) ) unlink(drop_dir, force = TRUE, recursive = TRUE)

  dml_file <- tempfile()

  pagesize <- ( pagesize * 20 * 72 )
  margins <- ( margins * 20 * 72 )

  document_xml <- file.path( template_dir, "word", "document.xml" )
  document_rel <- file.path( template_dir, "word", "_rels/document.xml.rels" )

  relationships <- read_relationship( x = document_rel )

  dml_str <- wml_flextable(x = x, relationships = relationships, standalone = FALSE )

  expected_rels <- attr(dml_str, "relations")
  copy_files <- attr(dml_str, "copy_files")
  if( !is.null( expected_rels ) ){
    new_rels <- rbind(relationships, expected_rels)
    Relationship <- paste0("<Relationship Id=\"", new_rels$id, "\" Type=\"", new_rels$type, "\" Target=\"", new_rels$target , "\"/>")
    Relationship <- paste0(Relationship, collapse = "\n")

    sink(file = document_rel )
    cat("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n")
    cat("<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">\n")
    cat(Relationship)
    cat("\n</Relationships>")
    sink( )
    dir.create(file.path(template_dir, "word", "media"), recursive = TRUE)
    for(i in unique(copy_files) ){
      file.copy(from = i, to = file.path(template_dir, "word", "media"))
    }
  }

  sink(file = document_xml )
  cat("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>")
  cat("<w:document
      xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"
      xmlns:w15=\"http://schemas.microsoft.com/office/word/2012/wordml\"
      xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\"
      xmlns:m=\"http://schemas.openxmlformats.org/officeDocument/2006/math\"
      xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\"
      xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\"
      xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\"
      xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\"
      xmlns:ns9=\"http://schemas.openxmlformats.org/schemaLibrary/2006/main\"
      xmlns:wne=\"http://schemas.microsoft.com/office/word/2006/wordml\"
      xmlns:c=\"http://schemas.openxmlformats.org/drawingml/2006/chart\"
      xmlns:ns12=\"http://schemas.openxmlformats.org/drawingml/2006/chartDrawing\"
      xmlns:dgm=\"http://schemas.openxmlformats.org/drawingml/2006/diagram\"
      xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\"
      xmlns:xdr=\"http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing\"
      xmlns:dsp=\"http://schemas.microsoft.com/office/drawing/2008/diagram\"
      xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:o=\"urn:schemas-microsoft-com:office:office\"
      xmlns:ns19=\"urn:schemas-microsoft-com:office:excel\" xmlns:w10=\"urn:schemas-microsoft-com:office:word\"
      xmlns:ns21=\"urn:schemas-microsoft-com:office:powerpoint\" xmlns:ns23=\"http://schemas.microsoft.com/office/2006/coverPageProps\"
      xmlns:odx=\"http://opendope.org/xpaths\" xmlns:odc=\"http://opendope.org/conditions\"
      xmlns:odq=\"http://opendope.org/questions\" xmlns:oda=\"http://opendope.org/answers\"
      xmlns:odi=\"http://opendope.org/components\" xmlns:odgm=\"http://opendope.org/SmartArt/DataHierarchy\"
      xmlns:ns30=\"http://schemas.openxmlformats.org/officeDocument/2006/bibliography\"
      xmlns:ns31=\"http://schemas.openxmlformats.org/drawingml/2006/compatibility\"
      xmlns:ns32=\"http://schemas.openxmlformats.org/drawingml/2006/lockedCanvas\"
      xmlns:wpc=\"http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas\"
      xmlns:wpg=\"http://schemas.microsoft.com/office/word/2010/wordprocessingGroup\"
      xmlns:wps=\"http://schemas.microsoft.com/office/word/2010/wordprocessingShape\">")

  cat("<w:body>")
  cat(dml_str)
  cat("<w:sectPr>")
  cat("<w:pgSz w:w=\"")
  cat(as.integer(pagesize["width"]))
  cat("\" w:h=\"")
  cat(as.integer(pagesize["height"]))
  cat("\" w:code=\"1\" />")
  cat("<w:pgMar w:top=\"")
  cat(as.integer(margins["top"]))
  cat("\" w:right=\"")
  cat(as.integer(margins["right"]))
  cat("\" w:bottom=\"")
  cat(as.integer(margins["bottom"]))
  cat("\" w:left=\"")
  cat(as.integer(margins["left"]))
  cat("\"/>
      </w:sectPr>
      </w:body>
      </w:document>")
  sink()


  # delete out_file if existing
  if( file.exists(file))
    unlink(file, force = TRUE)
  # write out_file
  out_file <- pack_folder(template_dir, file )
  # delete temporary dir
  unlink(template_dir, recursive = TRUE, force = TRUE)
  invisible(out_file)
}

#' @export
#' @title wml table code
#' @description produces the wml of a flextable
#' @param x \code{flextable} object
#' @param relationships relationships dataset
#' @param standalone specify to produce a standalone XML file.
#' If FALSE, omits xml header and default namespace.
wml_flextable <- function( x, relationships, standalone = TRUE ){

  imgs <- character(0)

  dims <- dim(x)
  widths <- dims$widths
  colswidths <- paste0("<w:gridCol w:w=\"", round(widths*72*20, 0), "\"/>", collapse = "")

  if( standalone )
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
  else out <- "<w:tbl>"

  out <- paste0(out, "<w:tblPr><w:tblLayout w:type=\"fixed\"/></w:tblPr>" )

  out = paste0(out,  "<w:tblGrid>" )
  out = paste0(out,  colswidths )
  out = paste0(out,  "</w:tblGrid>" )

  if( !is.null(x$header) ){
    xml_content <- format(x$header, header = TRUE, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs") )
    out = paste0(out, xml_content )
  }
  if( !is.null(x$body) ){
    xml_content <- format(x$body, header = FALSE, type = "wml")
    imgs <- append( imgs, attr(xml_content, "imgs") )
    out = paste0(out, xml_content )
  }
  imgs <- unique(imgs)
  out = paste0(out,  "</w:tbl>" )

  if( length( imgs ) > 0 ){
    int_id <- as.integer(
      gsub(pattern = "^rId", replacement = "", x = relationships$id ) )
    last_id <- as.integer( max(int_id) )

    rids <- get_rids( last_id = last_id, imgs = imgs)
    out <- rids_substitute_xml( out = out, rids = rids )
    expected_rels_ <- expected_rels(rids)
    attr(out, "relations") <- expected_rels_
    attr(out, "copy_files") <- rids$src
  }
  out
}

