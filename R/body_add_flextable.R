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
body_add_flextable <- function( x, value, align = "center", pos = "after") {

  stopifnot(inherits(x, "rdocx"))
  
  out <- docx_str(value, doc = x, align = align)
  
  body_add_xml(x = x, str = out, pos = pos)

}
