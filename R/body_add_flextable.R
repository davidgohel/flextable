#' @export
#' @title add flextable into a Word document
#' @description add a flextable into a Word document.
#' @param x an rdocx object
#' @param value \code{flextable} object
#' @param align left, center (default) or right.
#' @param split set to TRUE if you want to activate Word
#' option 'Allow row to break across pages'.
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
body_add_flextable <- function( x, value, align = "center", pos = "after", split = FALSE) {

  stopifnot(inherits(x, "rdocx"))

  out <- docx_str(value, doc = x, align = align, split = split)

  body_add_xml(x = x, str = out, pos = pos)

}

#' @export
#' @rdname body_add_flextable
#' @param bookmark bookmark id
#' @section body_replace_flextable_at_bkm:
#' Use this function if you want to replace a paragraph containing
#' a bookmark with a flextable. As a side effect, the bookmark will be lost.
body_replace_flextable_at_bkm <- function(x, bookmark, value, align = "center", split = FALSE){
  x <- cursor_bookmark(x, bookmark)
  x <- body_add_flextable(x = x, value = value, pos = "on", align = align, split = split)
  x
}

#' @export
#' @title add flextable at a bookmark location in document's header
#' @description replace in the header of a document  a paragraph containing a bookmark by a flextable.
#' A bookmark will be considered as valid if enclosing words
#' within a paragraph; i.e., a bookmark along two or more paragraphs is invalid,
#' a bookmark set on a whole paragraph is also invalid, but bookmarking few words
#' inside a paragraph is valid.
#' @importFrom xml2 xml_replace as_xml_document
#' @param x an rdocx object
#' @param bookmark bookmark id
#' @param value a flextable object
headers_flextable_at_bkm <- function( x, bookmark, value ){
  stopifnot(inherits(x, "rdocx"), inherits(value, "flextable"))
  str <- docx_str(value, doc = x, align = "center")
  xml_elt <- as_xml_document(str)
  for(header in x$headers){
    if( header$has_bookmark(bookmark) ){
      header$cursor_bookmark(bookmark)
      cursor_elt <- header$get_at_cursor()
      xml_replace(cursor_elt, xml_elt)
    }

  }

  x
}

#' @export
#' @title add flextable at a bookmark location in document's footer
#' @description replace in the footer of a document  a paragraph containing a bookmark by a flextable.
#' A bookmark will be considered as valid if enclosing words
#' within a paragraph; i.e., a bookmark along two or more paragraphs is invalid,
#' a bookmark set on a whole paragraph is also invalid, but bookmarking few words
#' inside a paragraph is valid.
#' @param x an rdocx object
#' @param bookmark bookmark id
#' @param value a flextable object
footers_flextable_at_bkm <- function( x, bookmark, value ){
  stopifnot(inherits(x, "rdocx"), inherits(value, "flextable"))
  str <- docx_str(value, doc = x, align = "center")
  xml_elt <- as_xml_document(str)
  for(footer in x$footers){
    if( footer$has_bookmark(bookmark) ){
      footer$cursor_bookmark(bookmark)
      cursor_elt <- footer$get_at_cursor()
      xml_replace(cursor_elt, xml_elt)
    }

  }

  x
}

