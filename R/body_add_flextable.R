#' @export
#' @title Add flextable into a Word document
#' @description add a flextable into a Word document.
#' @param x an rdocx object
#' @param value `flextable` object
#' @param align left, center (default) or right.
#' @param split set to TRUE if you want to activate Word
#' option 'Allow row to break across pages'.
#' @param keepnext Defunct in favor of [paginate()].
#' @param pos where to add the flextable relative to the cursor,
#' one of "after", "before", "on" (end of line).
#' @param topcaption if TRUE caption is added before the table, if FALSE,
#' caption is added after the table.
#' @importFrom officer body_add_xml
#' @examples
#' library(officer)
#'
#' # autonum for caption
#' autonum <- run_autonum(seq_id = "tab", bkm = "mtcars")
#'
#' ftab <- flextable(head(mtcars))
#' ftab <- set_caption(ftab, caption = "mtcars data", autonum = autonum)
#' ftab <- autofit(ftab)
#' doc <- read_docx()
#' doc <- body_add_flextable(doc, value = ftab)
#' fileout <- tempfile(fileext = ".docx")
#' # fileout <- "test.docx" # uncomment to write in your working directory
#' print(doc, target = fileout)
body_add_flextable <- function(x, value,
                               align = NULL,
                               pos = "after",
                               split = NULL,
                               topcaption = TRUE,
                               keepnext = NULL) {
  stopifnot(
    inherits(x, "rdocx"),
    inherits(value, "flextable")
  )

  if (!is.null(align)) {
    value$properties$align <- align
  }
  if (!is.null(split)) {
    value$properties$opts_word$split <- split
  }

  value <- flextable_global$defaults$post_process_docx(value)

  caption_str <- NULL
  if (has_caption(value)) {
    if (topcaption) {
      apply_cap_kwn <- TRUE
    } else {
      value <- keep_with_next(value, part = "all", value = TRUE)
      apply_cap_kwn <- FALSE
    }
    caption_str <- caption_default_docx_openxml(
      x = value,
      keep_with_next = apply_cap_kwn,
      allow_autonum = TRUE
    )
    if ("" %in% caption_str) caption_str <- NULL
  }

  if (topcaption && !is.null(caption_str)) {
    x <- body_add_xml(x = x, str = caption_str, pos = pos)
  }
  out <- gen_raw_wml(value, doc = x)

  x <- body_add_xml(x = x, str = out, pos = pos)

  if (!topcaption && !is.null(caption_str)) {
    x <- body_add_xml(x = x, str = caption_str, pos = pos)
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
body_replace_flextable_at_bkm <- function(x, bookmark, value, align = "center", split = FALSE) {
  x <- cursor_bookmark(x, bookmark)
  x <- body_add_flextable(x = x, value = value, pos = "on", align = align, split = split)
  x
}

#' @export
#' @title Add flextable at a bookmark location in document's header
#' @description replace in the header of a document  a paragraph containing a bookmark by a flextable.
#' A bookmark will be considered as valid if enclosing words
#' within a paragraph; i.e., a bookmark along two or more paragraphs is invalid,
#' a bookmark set on a whole paragraph is also invalid, but bookmarking few words
#' inside a paragraph is valid.
#' @importFrom xml2 xml_replace as_xml_document xml_find_first xml_parent
#' @param x an rdocx object
#' @param bookmark bookmark id
#' @param value a flextable object
#' @keywords internal
headers_flextable_at_bkm <- function(x, bookmark, value) {
  stopifnot(inherits(x, "rdocx"), inherits(value, "flextable"))
  str <- gen_raw_wml(value, doc = x)
  xml_elt <- as_xml_document(str)
  for (header in x$headers) {
    node <- xml_find_first(header$get(), '//w:bookmarkStart[@w:name="hd_summary_tbl"]')
    if (!inherits(node, "xml_missing")) {
      node <- xml_parent(node)
      xml_replace(node, xml_elt)
    }
  }

  x
}

#' @export
#' @title Add flextable at a bookmark location in document's footer
#' @description replace in the footer of a document  a paragraph containing a bookmark by a flextable.
#' A bookmark will be considered as valid if enclosing words
#' within a paragraph; i.e., a bookmark along two or more paragraphs is invalid,
#' a bookmark set on a whole paragraph is also invalid, but bookmarking few words
#' inside a paragraph is valid.
#' @param x an rdocx object
#' @param bookmark bookmark id
#' @param value a flextable object
#' @keywords internal
footers_flextable_at_bkm <- function(x, bookmark, value) {
  stopifnot(inherits(x, "rdocx"), inherits(value, "flextable"))
  str <- gen_raw_wml(value, doc = x)
  xml_elt <- as_xml_document(str)
  for (footer in x$footers) {
    node <- xml_find_first(footer$get(), '//w:bookmarkStart[@w:name="hd_summary_tbl"]')
    if (!inherits(node, "xml_missing")) {
      node <- xml_parent(node)
      xml_replace(node, xml_elt)
    }
  }

  x
}
