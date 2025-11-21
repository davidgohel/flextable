pml_spans <- function(value) {
  span_data <- fortify_span(value)
  span_data$grid_span <- ifelse(span_data$rowspan == 1, "",
    ifelse(span_data$rowspan > 1, paste0(" gridSpan=\"", span_data$rowspan, "\""), " hMerge=\"true\"")
  )
  span_data$row_span <- ifelse(span_data$colspan == 1, "",
    ifelse(span_data$colspan > 1, paste0(" rowSpan=\"", span_data$colspan, "\""),
      " vMerge=\"true\""
    )
  )
  span_data
}
default_fp_text_pml <- function(value) {
  default_chunks_properties <- information_data_default_chunk(value)
  unique_text_props <- distinct_text_properties(default_chunks_properties)
  rpr <- sapply(
    split(unique_text_props[setdiff(colnames(unique_text_props), "classname")], unique_text_props$classname),
    function(x) {
      z <- do.call(officer::fp_text_lite, x)
      val <- format(z, type = "pml")
      val <- gsub("<a:rPr", "<a:endParaRPr", val, fixed = TRUE)
      val <- gsub("</a:rPr>", "</a:endParaRPr>", val, fixed = TRUE)
      val
    }
  )

  unique_text_props$fp_txt_default <- unname(rpr[unique_text_props$classname])
  setDT(default_chunks_properties)
  default_chunks_properties <- merge(
    default_chunks_properties, unique_text_props,
    by = c("color", "font.size", "bold", "italic", "underlined", "strike", "font.family",
           "hansi.family", "eastasia.family", "cs.family", "vertical.align",
           "shading.color")
  )
  setDF(default_chunks_properties)
  default_chunks_properties <- default_chunks_properties[, c(".part", ".row_id", ".col_id", "fp_txt_default")]
  default_chunks_properties
}


#' @importFrom data.table shift
pml_cells <- function(value, cell_data) {
  cell_heights <- fortify_height(value)
  cell_widths <- fortify_width(value)
  cell_hrule <- fortify_hrule(value)

  cell_data$width <- NULL # need to get rid of originals that are empty, should probably rm them
  cell_data$height <- NULL
  cell_data$hrule <- NULL
  cell_data <- merge(cell_data, cell_widths, by = ".col_id")
  cell_data <- merge(cell_data, cell_heights, by = c(".part", ".row_id"))
  cell_data <- merge(cell_data, cell_hrule, by = c(".part", ".row_id"))

  setDT(cell_data)
  setorderv(cell_data, cols = c(".part", ".row_id", ".col_id"))

  data_ref_cells <- distinct_cells_properties(cell_data)

  ## cell style pml
  fp_cell_pml <- data_ref_cells
  classnames <- data_ref_cells$classname
  fp_cell_pml <- split(fp_cell_pml, classnames)
  fp_cell_pml <- lapply(fp_cell_pml, function(x) {
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
    format(zz, type = "pml")
  })
  style_dat <- data.frame(
    fp_cell_pml = as.character(fp_cell_pml),
    classname = classnames,
    stringsAsFactors = FALSE
  )

  # organise everything
  cell_data <- merge(cell_data, data_ref_cells, by = intersect(colnames(cell_data), colnames(data_ref_cells)))
  cell_data <- merge(cell_data, style_dat, by = "classname")
  cell_data <- cell_data[, .SD, .SDcols = c(".part", ".row_id", ".col_id", "fp_cell_pml")]
  setDF(cell_data)
  cell_data
}

gen_raw_pml <- function(value, uid = 99999L, offx = 0, offy = 0, cx = 0, cy = 0) {
  cell_attributes <- information_data_cell(value)
  par_attributes <- information_data_paragraph(value)

  # cell_attributes and par_attributes must be ordered identically
  new_pos <- ooxml_rotation_alignments(
    rotation = cell_attributes$text.direction,
    valign = cell_attributes$vertical.align,
    align = par_attributes$text.align
  )

  par_attributes$text.align <- new_pos$align
  cell_attributes$vertical.align <- new_pos$valign

  setDT(cell_attributes)
  cell_attributes <- merge(
    cell_attributes,
    par_attributes[, c(".part", ".row_id", ".col_id", "padding.bottom", "padding.top")],
    by = c(".part", ".row_id", ".col_id")
  )
  cell_attributes[, c("margin.bottom", "margin.top") :=
    list(
      .SD$padding.bottom, .SD$padding.top
    )]
  cell_attributes[, c("padding.bottom", "padding.top") := NULL]
  setDF(cell_attributes)

  txt_data <- runs_as_pml(value)
  par_data <- ooxml_ppr(par_attributes, type = "pml")
  span_data <- pml_spans(value)
  cell_data <- pml_cells(value, cell_attributes)
  cell_heights <- fortify_height(value)

  default_chunks_properties <- default_fp_text_pml(value)

  setDT(cell_data)

  tab_data <- merge(cell_data, par_data, by = c(".part", ".row_id", ".col_id"))
  tab_data <- merge(tab_data, default_chunks_properties, by = c(".part", ".row_id", ".col_id"))
  tab_data <- merge(tab_data, txt_data, by = c(".part", ".row_id", ".col_id"))

  tab_data[tab_data$is_empty %in% TRUE, c("fp_par_xml") := list(
    paste0(.SD$fp_par_xml, .SD$fp_txt_default)
  )]
  tab_data[, c("fp_txt_default", "is_empty") := list(NULL, NULL)]

  tab_data <- merge(tab_data, span_data, by = c(".part", ".row_id", ".col_id"))
  tab_data$.col_id <- factor(tab_data$.col_id, levels = value$col_keys)
  setorderv(tab_data, cols = c(".part", ".row_id", ".col_id"))

  tab_data[, c("pml") := list(
    paste0(
      "<a:txBody><a:bodyPr/><a:lstStyle/>",
      "<a:p>", .SD$fp_par_xml,
      .SD$par_nodes_str, "</a:p>",
      "</a:txBody>"
    )
  )]
  tab_data[, c("fp_par_xml", "par_nodes_str") := list(NULL, NULL)]

  tab_data[, c("pml") := list(
    paste0(
      "<a:tc", .SD$grid_span, .SD$row_span, ">", .SD$pml,
      .SD$fp_cell_pml, "</a:tc>"
    )
  )]
  tab_data[, c("fp_cell_pml", "grid_span", "row_span") := list(NULL, NULL, NULL)]

  cells <- dcast(tab_data, .part + .row_id ~ .col_id, drop = TRUE, fill = "", value.var = "pml", fun.aggregate = I)
  cells <- merge(cells, cell_heights, by = c(".part", ".row_id"))

  rowheights <- cells$height
  cells[, c(".row_id", "height", ".part") := list(NULL, NULL, NULL)]
  rows <- apply(as.matrix(cells), 1, paste0, collapse = "")
  rows <- sprintf("<a:tr h=\"%.0f\">%s</a:tr>", rowheights * 914400, rows)
  rows <- paste0(rows, collapse = "")

  out <- "<a:tbl>"
  dims <- dim(value)
  widths <- dims$widths
  colswidths <- paste0(sprintf("<a:gridCol w=\"%.0f\"/>", widths * 914400), collapse = "")

  out <- paste0(out, "<a:tblPr/><a:tblGrid>")
  out <- paste0(out, colswidths)
  out <- paste0(out, "</a:tblGrid>")
  out <- paste0(out, rows)

  out <- paste0(out, "</a:tbl>")

  graphic_frame <- paste0(
    "<p:graphicFrame ",
    "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
    "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
    "xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\">",
    "<p:nvGraphicFramePr>",
    sprintf("<p:cNvPr id=\"%.0f\" name=\"\"/>", uid),
    "<p:cNvGraphicFramePr><a:graphicFrameLocks noGrp=\"true\"/></p:cNvGraphicFramePr>",
    "<p:nvPr/>",
    "</p:nvGraphicFramePr>",
    "<p:xfrm rot=\"0\">",
    sprintf("<a:off x=\"%.0f\" y=\"%.0f\"/>", offx * 914400, offy * 914400),
    sprintf("<a:ext cx=\"%.0f\" cy=\"%.0f\"/>", cx * 914400, cy * 914400),
    "</p:xfrm>",
    "<a:graphic>",
    "<a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">",
    out,
    "</a:graphicData>",
    "</a:graphic>",
    "</p:graphicFrame>"
  )
  graphic_frame
}
