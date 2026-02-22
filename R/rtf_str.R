#' @importFrom data.table shift
rtf_cells <- function(value, cell_data, layout = "fixed") {
  cell_heights <- fortify_height(value)
  cell_widths <- fortify_width(value)

  cell_data$width <- NULL # need to get rid of originals that are empty, should probably rm them
  cell_data$height <- NULL
  cell_data <- merge(cell_data, cell_widths, by = ".col_id")
  cell_data <- merge(cell_data, cell_heights, by = c(".part", ".row_id"))

  setDT(cell_data)
  setorderv(cell_data, cols = c(".part", ".row_id", ".col_id"))

  # fix for word horiz. borders, copying the bottom props to top props of the next cell
  cell_data <- copy_border_bottom_to_next_border_top(cell_data, value = value)

  data_ref_cells <- distinct_cells_properties(cell_data)

  ## cell style wml
  fp_cell_rtf <- data_ref_cells
  classnames <- data_ref_cells$classname
  fp_cell_rtf$classname <- NULL

  fp_cell_rtf <- split(fp_cell_rtf, classnames)
  fp_cell_rtf <- vapply(fp_cell_rtf, function(x) {
    zz <- as.list(x)
    zz$border.bottom <- fp_border(
      color = zz$border.color.bottom,
      width = zz$border.width.bottom,
      style = zz$border.style.bottom
    )
    zz$border.top <- fp_border(
      color = zz$border.color.top,
      width = zz$border.width.top,
      style = zz$border.style.top
    )
    zz$border.right <- fp_border(
      color = zz$border.color.right,
      width = zz$border.width.right,
      style = zz$border.style.right
    )
    zz$border.left <- fp_border(
      color = zz$border.color.left,
      width = zz$border.width.left,
      style = zz$border.style.left
    )

    zz[c(
      "border.width.bottom", "border.width.top", "border.width.left",
      "border.width.right", "border.color.bottom", "border.color.top",
      "border.color.left", "border.color.right", "border.style.bottom",
      "border.style.top", "border.style.left", "border.style.right",
      "width", "height", "hrule"
    )] <- NULL
    zz$classname <- NULL
    zz <- do.call(fp_cell, zz)
    zz <- format(zz, type = "rtf")
    zz
  }, FUN.VALUE = "", USE.NAMES = FALSE)

  style_dat <- data.frame(
    fp_cell_rtf = fp_cell_rtf,
    classname = classnames,
    stringsAsFactors = FALSE
  )

  # organise everything
  cell_data <- merge(cell_data, data_ref_cells,
    by = intersect(colnames(cell_data), colnames(data_ref_cells))
  )
  cell_data <- merge(cell_data, style_dat, by = "classname")
  setorderv(cell_data, cols = c(".part", ".row_id", ".col_id"))
  if (layout %in% "fixed") {
    cell_data[, c("fp_cell_rtf") := list(
      sprintf("%s\\cellx%.0f", .SD$fp_cell_rtf, cumsum(.SD$width) * 1440)
    ),
    by = c(".part", ".row_id")
    ]
  } else {
    cell_data[, c("fp_cell_rtf") := list(
      sprintf("%s\\cellx", .SD$fp_cell_rtf)
    ),
    by = c(".part", ".row_id")
    ]
  }
  cell_data <- cell_data[, .SD, .SDcols = c(".part", ".row_id", ".col_id", "fp_cell_rtf")]
  setDF(cell_data)
  cell_data
}



rtf_rows <- function(value) {
  # prepare cells formatting properties and add span information
  cell_attributes <- information_data_cell(value)
  span_data <- fortify_span(value)
  setDT(cell_attributes)
  cell_attributes <- merge(cell_attributes, span_data, by = c(".part", ".row_id", ".col_id"))
  setDF(cell_attributes)

  # prepare paragraphs formatting properties
  paragraphs_properties <- information_data_paragraph(value)

  # transform alignments for rotated text
  # and add them back to paragraphs_properties and cell_attributes
  new_pos <- ooxml_rotation_alignments(
    rotation = cell_attributes$text.direction,
    valign = cell_attributes$vertical.align,
    align = paragraphs_properties$text.align
  )
  paragraphs_properties$text.align <- new_pos$align
  cell_attributes$vertical.align <- new_pos$valign

  # get runs in wml format and get hyperlinks and images information
  run_data <- runs_as_rtf(value, chunk_data = information_data_chunk(value))
  cell_data <- rtf_cells(
    value, cell_attributes,
    layout = value$properties$layout
  )
  cell_heights <- fortify_height(value)
  cell_hrule <- fortify_hrule(value)

  setDT(cell_data)
  tab_data <- merge(cell_data, ooxml_ppr(paragraphs_properties, type = "rtf"), by = c(".part", ".row_id", ".col_id"))
  tab_data <- merge(tab_data, run_data, by = c(".part", ".row_id", ".col_id"))
  tab_data <- merge(tab_data, span_data, by = c(".part", ".row_id", ".col_id"))
  setorderv(tab_data, cols = c(".part", ".row_id", ".col_id"))

  tab_data[tab_data$colspan < 1, c("txt") := list("")]
  tab_data[tab_data$rowspan < 1, c("txt") := list("")]

  tab_data[, c("txt", "fp_par_xml") := list(
    paste0(.SD$fp_par_xml, .SD$txt),
    NULL
  )]

  cells <- tab_data[, list(
    fp_cell_rtf = paste0(.SD$fp_cell_rtf, collapse = ""),
    content_rtf = paste0(.SD$txt, "\\cell", collapse = "")
  ), by = c(".part", ".row_id")]

  split_str <- ""
  if (!value$properties$opts_word$split) split_str <- "\\trkeep"

  align <- match.arg(value$properties$align, c("center", "left", "right"), several.ok = FALSE)
  align <- c("center" = "\\trqc", "left" = "\\trql", "right" = "\\trqr")[align]

  hrule <- cell_hrule$hrule
  heights <- round(cell_heights$height * 1440, 0)
  heights[hrule %in% "auto"] <- 0
  heights[hrule %in% "exact"] <- -heights[hrule %in% "exact"]
  heights <- paste0("\\trrh", heights)

  header_str <- rep("", nrow(cell_hrule))
  header_str[cell_hrule$.part %in% "header"] <- "\\trhdr"

  if (value$properties$layout %in% "fixed") {
    autofit <- "\\trautofit0"
  } else {
    autofit <- "\\trautofit1"
  }

  header_str <- rep("", nrow(cell_hrule))
  header_str[cell_hrule$.part %in% "header"] <- "\\trhdr"

  rows <- paste0(
    "\\trowd",
    autofit,
    "\\trgaph0\\trleft0\\tapltr",
    align,
    split_str,
    heights,
    header_str, cells$fp_cell_rtf, cells$content_rtf,
    "\\row\\pard\n"
  )

  paste0(paste0(rows, collapse = ""), "\\vertalt")
}

#' @export
to_rtf.flextable <- function(x, topcaption = TRUE, ...) {
  tab_str <- rtf_rows(x)
  if (has_caption(x)) {
    if (topcaption) {
      tab_str <- paste0(caption_default_rtf(x), "\n\n", tab_str)
    } else {
      tab_str <- paste0(tab_str, "\n\n", caption_default_rtf(x))
    }
  }
  tab_str
}

#' @export
#' @importFrom officer rtf_add
#' @title Add a 'flextable' into an RTF document
#' @family officer_integration
#' @description [officer::rtf_add()] method for adding
#' flextable objects into 'RTF' documents.
#' @param x rtf object, created by [officer::rtf_doc()].
#' @param value a flextable object
#' @param ... unused arguments
#' @examples
#' library(flextable)
#' library(officer)
#'
#' ft <- flextable(head(iris))
#' ft <- autofit(ft)
#'
#' z <- rtf_doc()
#' z <- rtf_add(z, ft)
#'
#' print(z, target = tempfile(fileext = ".rtf"))
rtf_add.flextable <- function(x, value, ...) {
  x$content[[length(x$content) + 1]] <- value
  x
}
