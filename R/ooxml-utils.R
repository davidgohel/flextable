#' @importFrom xml2 xml_attr<- xml_find_all xml_attr
#' @noRd
#' @title Fix urls encoded as url1, url2, ... in OOXML files
#' @description change urls encoded as url1, url2, ... in OOXML files
#' with the name of the element that is the real URL to be set
#'
#' When pptx_str() or docx_str() are called, during the `wml_runs()`
#' step, url are identified. They are stored as names of a character
#' vector of url id, for example `c('https://google.fr'='url1', ...)`.
process_url <- function(relation_object, urls_set, ooxml_str, pattern) {
  doc <- as_xml_document(ooxml_str)

  for (i in seq_along(urls_set)) {
    new_rid <- sprintf(
      "rId%.0f",
      relation_object$get_next_id()
    )

    curr_url <- names(urls_set)[i]

    curr_url_id <- urls_set[i]

    relation_object$add(
      id = new_rid,
      type = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
      target = curr_url,
      target_mode = "External"
    )

    linknodes <- xml_find_all(
      doc,
      paste0("//", pattern, "[@r:id=", shQuote(curr_url_id), "]")
    )
    xml_attr(linknodes, "r:id") <- new_rid
  }

  as.character(doc)
}

urls_to_keys <- function(urls, is_hlink) {
  unique_url_val <- unique(urls[is_hlink])
  unique_url_key <- paste0("url", seq_along(unique_url_val))
  names(unique_url_key) <- unique_url_val
  unique_url_key
}

ooxml_rotation_alignments <- function(rotation, align, valign) {
  halign_out <- align
  valign_out <- valign

  left_top <- rotation %in% "btlr" & valign %in% "top" & align %in% "left"
  center_top <- rotation %in% "btlr" & valign %in% "top" & align %in% "center"
  right_top <- rotation %in% "btlr" & valign %in% "top" & align %in% "right"
  left_middle <- rotation %in% "btlr" & valign %in% "center" & align %in% "left"
  center_middle <- rotation %in% "btlr" & valign %in% "center" & align %in% "center"
  right_middle <- rotation %in% "btlr" & valign %in% "center" & align %in% "right"
  left_bottom <- rotation %in% "btlr" & valign %in% "bottom" & align %in% "left"
  center_bottom <- rotation %in% "btlr" & valign %in% "bottom" & align %in% "center"
  right_bottom <- rotation %in% "btlr" & valign %in% "bottom" & align %in% "right"

  # left-top to right-top
  halign_out[left_top] <- "right"
  valign_out[left_top] <- "top"
  # center-top to right-center
  halign_out[center_top] <- "right"
  valign_out[center_top] <- "center"
  # right-top to right-bottom
  halign_out[right_top] <- "right"
  valign_out[right_top] <- "bottom"
  # left_middle to center-top
  halign_out[left_middle] <- "center"
  valign_out[left_middle] <- "top"
  # center_middle to center-center
  halign_out[center_middle] <- "center"
  valign_out[center_middle] <- "center"
  # right_middle to center-bottom
  halign_out[right_middle] <- "center"
  valign_out[right_middle] <- "bottom"
  # left_bottom to left-top
  halign_out[left_bottom] <- "left"
  valign_out[left_bottom] <- "top"
  # center_bottom to left-center
  halign_out[center_bottom] <- "left"
  valign_out[center_bottom] <- "center"
  # right_bottom to left-bottom
  halign_out[right_bottom] <- "left"
  valign_out[right_bottom] <- "bottom"

  left_top <- rotation %in% "tbrl" & valign %in% "top" & align %in% "left"
  center_top <- rotation %in% "tbrl" & valign %in% "top" & align %in% "center"
  right_top <- rotation %in% "tbrl" & valign %in% "top" & align %in% "right"
  left_middle <- rotation %in% "tbrl" & valign %in% "center" & align %in% "left"
  center_middle <- rotation %in% "tbrl" & valign %in% "center" & align %in% "center"
  right_middle <- rotation %in% "tbrl" & valign %in% "center" & align %in% "right"
  left_bottom <- rotation %in% "tbrl" & valign %in% "bottom" & align %in% "left"
  center_bottom <- rotation %in% "tbrl" & valign %in% "bottom" & align %in% "center"
  right_bottom <- rotation %in% "tbrl" & valign %in% "bottom" & align %in% "right"

  # left-top to left-bottom
  halign_out[left_top] <- "left"
  valign_out[left_top] <- "bottom"
  # center-top to left-center
  halign_out[center_top] <- "left"
  valign_out[center_top] <- "center"
  # right-top to left-top
  halign_out[right_top] <- "left"
  valign_out[right_top] <- "top"

  # left_middle
  halign_out[left_middle] <- "center"
  valign_out[left_middle] <- "bottom"
  # center_middle
  halign_out[center_middle] <- "center"
  valign_out[center_middle] <- "center"
  # right_middle
  halign_out[right_middle] <- "center"
  valign_out[right_middle] <- "top"

  # left_bottom
  halign_out[left_bottom] <- "right"
  valign_out[left_bottom] <- "bottom"
  # center_bottom
  halign_out[center_bottom] <- "right"
  valign_out[center_bottom] <- "center"
  # right_bottom
  halign_out[right_bottom] <- "right"
  valign_out[right_bottom] <- "top"
  list(align = halign_out, valign = valign_out)
}
