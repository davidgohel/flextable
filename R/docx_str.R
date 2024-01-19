# utils -----
ooxml_ppr <- function(paragraphs_properties, type = "wml") {
  data_ref_pars <- distinct_paragraphs_properties(paragraphs_properties)

  ## par style wml
  fp_par_xml <- data_ref_pars
  classnames <- data_ref_pars$classname
  fp_par_xml <- split(fp_par_xml, classnames)
  fp_par_xml <- vapply(fp_par_xml, function(x) {
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

    # delete names not in formals
    zz[grepl(pattern = "^(border\\.color|border\\.width|border\\.style)", names(zz))] <- NULL
    zz$classname <- NULL

    zz <- do.call(fp_par, zz)
    format(zz, type = type)
  }, FUN.VALUE = "", USE.NAMES = FALSE)

  style_dat <- data.frame(
    fp_par_xml = fp_par_xml,
    classname = classnames,
    stringsAsFactors = FALSE
  )

  # organise everything
  setDT(paragraphs_properties)

  paragraphs_properties <- merge(paragraphs_properties, data_ref_pars, by = intersect(colnames(paragraphs_properties), colnames(data_ref_pars)))
  paragraphs_properties <- merge(paragraphs_properties, style_dat, by = "classname")
  paragraphs_properties <- paragraphs_properties[, .SD,
    .SDcols = c(
      ".part", ".row_id",
      ".col_id", "fp_par_xml"
    )
  ]
  setDF(paragraphs_properties)
  paragraphs_properties
}

wml_spans <- function(value) {
  span_data <- fortify_span(value)

  gridspan <- rep("", nrow(span_data))
  gridspan[span_data$rowspan > 1] <-
    paste0(
      "<w:gridSpan w:val=\"",
      span_data$rowspan[span_data$rowspan > 1],
      "\"/>"
    )

  vmerge <- rep("", nrow(span_data))
  vmerge[span_data$colspan > 1] <- "<w:vMerge w:val=\"restart\"/>"
  vmerge[span_data$colspan < 1] <- "<w:vMerge/>"

  span_data$gridspan <- gridspan
  span_data$vmerge <- vmerge
  span_data
}

copy_border_bottom_to_next_border_top <- function(x, value) {
  first_partname <-
    if (nrow_part(value, "header")) {
      "header"
    } else if (nrow_part(value, "body")) {
      "body"
    } else {
      "footer"
    }

  if (nrow_part(value, "header")) {
    last_partname <- "header"
    max_n <- nrow_part(value, "header")
  }
  if (nrow_part(value, "body")) {
    last_partname <- "body"
    max_n <- nrow_part(value, "body")
  }
  if (nrow_part(value, "footer")) {
    last_partname <- "footer"
    max_n <- nrow_part(value, "footer")
  }

  x[
    !(x$.part %in% first_partname & x$.row_id %in% 1),
    c("border.width.top", "border.color.top", "border.style.top")
  ] <-
    x[
      !(x$.part %in% last_partname & x$.row_id %in% max_n),
      c("border.width.bottom", "border.color.bottom", "border.style.bottom")
    ]
  x
}
#' @importFrom data.table shift
wml_cells <- function(value, cell_data) {
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
  fp_cell_wml <- data_ref_cells
  classnames <- data_ref_cells$classname
  fp_cell_wml$classname <- NULL

  fp_cell_wml <- split(fp_cell_wml, classnames)
  fp_cell_wml <- vapply(fp_cell_wml, function(x) {
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
    zz <- format(zz, type = "wml")
    zz
  }, FUN.VALUE = "", USE.NAMES = FALSE)

  style_dat <- data.frame(
    fp_cell_wml = fp_cell_wml,
    classname = classnames,
    stringsAsFactors = FALSE
  )

  # organise everything
  cell_data <- merge(cell_data, data_ref_cells,
    by = intersect(colnames(cell_data), colnames(data_ref_cells))
  )
  cell_data <- merge(cell_data, style_dat, by = "classname")
  cell_data <- cell_data[, .SD,
    .SDcols = c(
      ".part", ".row_id",
      ".col_id", "fp_cell_wml"
    )
  ]
  setDF(cell_data)
  cell_data
}



wml_rows <- function(value, split = FALSE) {
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
  run_data <- runs_as_wml(value, txt_data = information_data_chunk(value))

  cell_data <- wml_cells(value, cell_attributes)
  cell_heights <- fortify_height(value)
  cell_hrule <- fortify_hrule(value)

  setDT(cell_data)
  tab_data <- merge(cell_data, ooxml_ppr(paragraphs_properties), by = c(".part", ".row_id", ".col_id"))
  tab_data <- merge(tab_data, run_data, by = c(".part", ".row_id", ".col_id"))
  tab_data <- merge(tab_data, span_data, by = c(".part", ".row_id", ".col_id"))
  setorderv(tab_data, cols = c(".part", ".row_id", ".col_id"))

  tab_data[, c("wml", "fp_par_xml", "run_openxml") := list(
    paste0("<w:p>", .SD$fp_par_xml, .SD$run_openxml, "</w:p>"),
    NULL,
    NULL
  )]

  tab_data[tab_data$colspan < 1, c("wml") := list(
    gsub("<w:r\\b[^<]*>[^<]*(?:<[^<]*)*</w:r>", "", .SD$wml)
  )]

  tab_data[, c("wml") := list(
    paste0(
      "<w:tc>",
      .SD$fp_cell_wml,
      .SD$wml, "</w:tc>"
    )
  )]
  tab_data[tab_data$rowspan < 1, c("wml") := list("")]

  cells <- dcast(
    data = tab_data, formula = .part + .row_id ~ .col_id,
    drop = TRUE, fill = "", value.var = "wml",
    fun.aggregate = I
  )

  wml <- apply(as.matrix(cells), 1, paste0, collapse = "")

  split_str <- ""
  if (!split) split_str <- "<w:cantSplit/>"

  hrule <- cell_hrule$hrule
  hrule[hrule %in% "atleast"] <- "atLeast"

  header_str <- rep("", nrow(cell_hrule))
  header_str[cell_hrule$.part %in% "header"] <- "<w:tblHeader/>"

  rows <- paste0(
    "<w:tr><w:trPr>",
    split_str,
    "<w:trHeight",
    " w:val=",
    shQuote(round(cell_heights$height * 72 * 20, 0), type = "cmd"),
    " w:hRule=\"",
    hrule,
    "\"/>",
    header_str,
    "</w:trPr>", wml, "</w:tr>"
  )

  paste0(rows, collapse = "")
}


# docx_str -----
gen_raw_wml <- function(x, ...) {
  align <- x$properties$align

  align <- match.arg(align, c("center", "left", "right"), several.ok = FALSE)
  align <- c("center" = "center", "left" = "start", "right" = "end")[align]
  align <- as.character(align)

  dims <- dim(x)
  widths <- dims$widths

  out <- paste0(
    "<w:tbl xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" ",
    "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
    "xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\" ",
    "xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" ",
    "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
    "xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\"",
    ">"
  )
  if (x$properties$layout %in% "autofit") {
    pt <- prop_table(
      style = NULL,
      layout = table_layout(type = "autofit"),
      align = align,
      width = table_width(width = x$properties$width, unit = "pct"),
      colwidths = table_colwidths(double(0L)),
      word_title = x$properties$word_title,
      word_description = x$properties$word_description
    )
  } else {
    pt <- prop_table(
      style = NULL,
      layout = table_layout(type = "fixed"),
      align = align,
      width = table_width(
        unit = "in",
        width = sum(widths, na.rm = TRUE)
      ),
      colwidths = table_colwidths(widths),
      word_title = x$properties$word_title,
      word_description = x$properties$word_description
    )
  }

  properties_str <- to_wml(pt, add_ns = FALSE)

  out <- paste0(out, properties_str)

  tab_str <- wml_rows(x, split = x$properties$opts_word$split)
  out <- paste0(out, tab_str, "</w:tbl>")

  out
}
