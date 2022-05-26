#' @export
#' @title add flextable into a Word document
#' @description add a flextable into a Word document.
#' @param x an rdocx object
#' @param value `flextable` object
#' @param align left, center (default) or right.
#' @param split set to TRUE if you want to activate Word
#' option 'Allow row to break across pages'.
#' @param keepnext Word option 'keep rows together' can be
#' activated when TRUE. It avoids page break within tables.
#' @param pos where to add the flextable relative to the cursor,
#' one of "after", "before", "on" (end of line).
#' @param topcaption if TRUE caption is added before the table, if FALSE,
#' caption is added after the table.
#' @importFrom officer body_add_xml wml_link_images docx_reference_img block_caption
#' @examples
#' library(officer)
#'
#' # autonum for caption
#' autonum <- run_autonum(seq_id = "tab", bkm = "mtcars")
#'
#' ftab <- flextable( head( mtcars ) )
#' ftab <- set_caption(ftab, caption = "mtcars data", autonum = autonum)
#' ftab <- autofit(ftab)
#' doc <- read_docx()
#' doc <- body_add_flextable(doc, value = ftab)
#' fileout <- tempfile(fileext = ".docx")
#' # fileout <- "test.docx" # uncomment to write in your working directory
#' print(doc, target = fileout)
body_add_flextable <- function( x, value, align = "center", pos = "after", split = FALSE,
                                topcaption = TRUE,
                                keepnext = TRUE) {

  stopifnot(inherits(x, "rdocx"))
  stopifnot(inherits(value, "flextable"))

  value <- flextable_global$defaults$post_process_docx(value)

  if(topcaption && !is.null(value$caption$value)){
    bc <- block_caption(label = value$caption$value,
                        style = value$caption$style,
                        autonum = value$caption$autonum)
    x <- body_add_xml(x = x, str = to_wml(bc, base_document = x, add_ns = TRUE), pos = pos)
  }
  out <- docx_str(value, doc = x, align = align, split = split,
                  keep_with_next = keepnext)

  x <- body_add_xml(x = x, str = out, pos = pos)

  if(!topcaption && !is.null(value$caption$value)){
    bc <- block_caption(label = value$caption$value,
                        style = value$caption$style,
                        autonum = value$caption$autonum)
    x <- body_add_xml(x = x, str = to_wml(bc, base_document = x, add_ns = TRUE), pos = pos)
  }

  x


}

#' @export
#' @rdname body_add_flextable
#' @param bookmark bookmark id
#' @section body_replace_flextable_at_bkm:
#' Use this function if you want to replace a paragraph containing
#' a bookmark with a flextable. As a side effect, the bookmark will be lost.
#' @importFrom officer cursor_bookmark
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
  str <- docx_str(value, doc = x, align = "center", keep_with_next = FALSE)
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
  str <- docx_str(value, doc = x, align = "center", keep_with_next = FALSE)
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

