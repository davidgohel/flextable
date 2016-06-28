#' @importFrom tools file_ext
#' @importFrom utils unzip
#' @importFrom oxbase pack_folder
#' @title Microsoft PowerPoint table
#'
#' @description
#' Table for Microsoft PowerPoint documents.
#' @param file filename of the Microsoft PowerPoint document to produce. File
#' extension must be \code{.pptx}.
#' @param x flextable
#' @param size slide size in inches.
#' A named vector (\code{width} and \code{height}).
#' @param offx,offy left and top offset in inches
#' @examples
#' ft <- flextable(head(iris))
#' write_pptx(file = "test.pptx", x = ft )
#' @export
write_pptx <- function(
  file, x,
  size = c(width = 10, height = 7.5),
  offx = 1L, offy = 1L) {

  if( file_ext(file) != "pptx" )
    stop(file , " should have '.pptx' as extension.")

  template_dir <- tempfile()
  unzip( zipfile = file.path( system.file(package = "flextable"), "templates/vanilla.pptx" ), exdir = template_dir )

  document_xml <- file.path( template_dir, "ppt/slides/", "slide1.xml" )
  sink(file = document_xml )
  cat("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n")
  cat("<p:sld ")
  cat("xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ")
  cat("xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ")
  cat("xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\"")
  cat(">")

  cat("<p:cSld>")
  dims_ <- dim(x)

  cat( a_sptree_open(FALSE, 1L, offx*72, offy*72, sum(dims_$width)*72, sum(dims_$height)*72) )
  cat(pml_flextable(x))
  cat( a_sptree_close() )

  cat("</p:cSld>")
  cat("</p:sld>")
  sink()

  # set slide size
  slide_size_str <- sprintf( "<p:sldSz cx=\"%d\" cy=\"%d\"/>", as.integer(size["width"] * 914400),  as.integer(size["height"] * 914400) )
  presentation_file <- file.path( template_dir, "ppt", "presentation.xml" )
  presentation_str <- scan( presentation_file, what = "character", quiet = T, sep = "\n" )
  presentation_str <- gsub(pattern = "<p:sldSz cx=\"9144000\" cy=\"6858000\" type=\"screen4x3\"/>",
                           replacement =  slide_size_str, x = presentation_str )
  sink(file = presentation_file )
  cat(presentation_str, sep = "")
  sink()


  # delete out_file if existing
  if( file.exists(file))
    unlink(file, force = TRUE)
  # write out_file
  out_file <- pack_folder(template_dir, file )
  # delete temporary dir
  unlink(template_dir, recursive = TRUE, force = TRUE)
  out_file
}

#' @export
#' @title graphic frame xml code
#' @description open xml wrapper for pptx
#' @param x \code{flextable} object
#' @param id unique identifier in the slide
#' @param size a named vector containing width and height in inches
#' @param offx x offset
#' @param offy y offset
get_graphic_frame <- function(x, id = 1L, size = c(width = 10, height = 7.5),
  offx = 1L, offy = 1L) {
  dims_ <- dim(x)
  out <- ""
  out <- a_graphic_frame_open(id, offx*72, offy*72, sum(dims_$width), sum(dims_$height) )
  out <- paste0( out,  pml_flextable(x))
  out <- paste0( out,  a_graphic_frame_close() )
  out
}

pml_flextable <- function( x ){
  out <- "<a:tbl>"

  dims_ <- dim(x = x)
  colswidths <- paste0("<a:gridCol w=\"", round(dims_$width*914400, 0), "\"/>", collapse = "")

  out = paste0(out,  "<a:tblPr/><a:tblGrid>" )
  out = paste0(out,  colswidths )
  out = paste0(out,  "</a:tblGrid>" )

  if( !is.null(x$header) )
    out = paste0(out, format(x$header, header = TRUE, type = "pml") )
  if( !is.null(x$body) )
    out = paste0(out, format(x$body, header = FALSE, type = "pml") )
  if( !is.null(x$footer) )
    out = paste0(out, format(x$footer, header = FALSE, type = "pml") )
  out = paste0(out,  "</a:tbl>" )

  out
}
