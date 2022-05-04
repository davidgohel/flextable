dummy_fp_text_fun <- function(color = "black", font.size = 10,
                              bold = FALSE, italic = FALSE, underlined = FALSE,
                              font.family = "Arial",
                              vertical.align = "baseline",
                              shading.color = "transparent", line_spacing = 2) {

}

pml_runs <- function(value) {
  txt_data <- as_table_text(value)
  txt_data$col_id <- factor(txt_data$col_id, levels = value$col_keys)

  data_ref_text <- part_style_list(
    as.data.frame(txt_data),
    fun = dummy_fp_text_fun
  )

  fp_text_pml <- sapply(
    split(data_ref_text[-ncol(data_ref_text)], data_ref_text$classname),
    function(x) {
      z <- do.call(officer::fp_text_lite, x)
      format(z, type = "pml")
    }
  )
  style_dat <- data.frame(
    fp_text_pml = as.character(fp_text_pml),
    classname = data_ref_text$classname,
    stringsAsFactors = FALSE
  )

  is_soft_return <- txt_data$txt %in% "<br>"
  is_tab <- txt_data$txt %in% "<tab>"
  is_eq <- !is.na(txt_data$eq_data)
  is_hlink <- !is.na(txt_data$url)
  is_raster <- sapply(txt_data$img_data, function(x) {
    inherits(x, "raster") || is.character(x)
  })

  setDT(txt_data)
  txt_data <- merge(txt_data, data_ref_text, by = colnames(data_ref_text)[-ncol(data_ref_text)])
  txt_data <- merge(txt_data, style_dat, by = "classname")
  txt_data <- txt_data[, .SD,
    .SDcols = c(
      "part", "txt", "width", "height", "url",
      "eq_data", "img_data", "seq_index",
      "ft_row_id", "col_id", "fp_text_pml"
    )
  ]
  text_nodes_str <- paste0("<a:t>", htmlEscape(txt_data$txt), "</a:t>")
  text_nodes_str[is_raster] <- "<a:t></a:t>"
  text_nodes_str[is_soft_return] <- ""
  text_nodes_str[is_tab] <- "<a:t>\t</a:t>"

  # manage hlinks
  txt_data$url[is_hlink] <- vapply(txt_data$url[is_hlink], urlEncodePath, FUN.VALUE = "", USE.NAMES = FALSE)
  link_pr <- ifelse(is_hlink, paste0("<a:hlinkClick r:id=\"", txt_data$url, "\"/>"), "")

  # manage formula
  if (requireNamespace("equatags", quietly = TRUE) && any(is_eq)) {
    transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
    text_nodes_str[is_eq] <-
      paste0(
        "<mc:AlternateContent xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\"><mc:Choice xmlns:a14=\"http://schemas.microsoft.com/office/drawing/2010/main\" Requires=\"a14\">",
        "<a14:m xmlns:a14=\"http://schemas.microsoft.com/office/drawing/2010/main\"><m:oMathPara xmlns:m=\"http://schemas.openxmlformats.org/officeDocument/2006/math\"><m:oMathParaPr><m:jc m:val=\"centerGroup\"/></m:oMathParaPr>",
        transform_mathjax(txt_data$eq_data[is_eq], to = "mml"),
        "</m:oMathPara></a14:m>",
        "</mc:Choice></mc:AlternateContent>"
      )
  }

  # add url
  gmatch <- gregexpr(pattern = "</a:rPr>", txt_data$fp_text_pml, fixed = TRUE)
  end_tag <- paste0(link_pr, "</a:rPr>")
  regmatches(txt_data$fp_text_pml, gmatch) <- as.list(end_tag)

  opening_tag <- rep("<a:r>", nrow(txt_data))
  closing_tag <- rep("</a:r>", nrow(txt_data))
  opening_tag[is_eq] <- ""
  closing_tag[is_eq] <- ""
  opening_tag[is_soft_return] <- "<a:br>"
  closing_tag[is_soft_return] <- "</a:br>"

  txt_data$par_nodes_str <- paste0(
    opening_tag,
    txt_data$fp_text_pml, text_nodes_str,
    closing_tag
  )

  setorderv(txt_data, cols = c("part", "ft_row_id", "col_id", "seq_index"))

  unique_url <- unique(na.omit(txt_data$url))

  txt_data <- txt_data[, lapply(.SD, function(x) paste0(x, collapse = "")), by = c("part", "ft_row_id", "col_id"), .SDcols = "par_nodes_str"]
  setDF(txt_data)
  attr(txt_data, "url") <- unique_url
  txt_data
}

pml_pars <- function(value){

  par_data <- fortify_style(value, "pars")
  par_data$col_id <- factor(par_data$col_id, levels = value$col_keys)

  data_ref_pars <- par_style_list(par_data)

  ## par style pml
  fp_par_pml <- data_ref_pars
  classnames <- data_ref_pars$classname
  fp_par_pml$classname <- NULL
  cols <- intersect(names(formals(fp_par)), colnames(fp_par_pml))
  fp_par_pml <- fp_par_pml[cols]
  fp_par_pml <- split(fp_par_pml, classnames)
  fp_par_pml <- lapply(fp_par_pml, function(x){
    zz <- as.list(x)
    zz$border.bottom <- zz$border.bottom[[1]]
    zz$border.top <- zz$border.top[[1]]
    zz$border.right <- zz$border.right[[1]]
    zz$border.left <- zz$border.left[[1]]
    zz <- do.call(fp_par, zz)
    format(zz, type = "pml")
  })
  style_dat <- data.frame(
    fp_par_pml = as.character(fp_par_pml),
    classname = classnames,
    stringsAsFactors = FALSE
  )

  # organise everything
  setDT(par_data)
  par_data <- merge(par_data, data_ref_pars, by = intersect(colnames(par_data), colnames(data_ref_pars)))
  par_data <- merge(par_data, style_dat, by = "classname")
  par_data <- par_data[, .SD,
                       .SDcols = c(
                         "part", "ft_row_id",
                         "col_id", "fp_par_pml"
                       )
  ]
  setDF(par_data)
  par_data
}

pml_spans <- function(value){
  span_data <- fortify_span(value)
  span_data$grid_span <- ifelse(span_data$rowspan == 1, "",
                                ifelse(span_data$rowspan > 1, paste0(" gridSpan=\"", span_data$rowspan,"\""), " hMerge=\"true\"") )
  span_data$row_span <- ifelse(span_data$colspan == 1, "",
                               ifelse(span_data$colspan > 1, paste0(" rowSpan=\"", span_data$colspan,"\""),
                                      " vMerge=\"true\"")
  )
  span_data
}

#' @importFrom data.table shift fcoalesce
pml_cells <- function(value){

  cell_heights <- fortify_height(value)
  cell_widths <- fortify_width(value)
  cell_hrule <- fortify_hrule(value)

  cell_data <- fortify_style(value, "cells")
  cell_data$col_id <- factor(cell_data$col_id, levels = value$col_keys)
  cell_data$part <- factor(cell_data$part, levels = c("header", "body", "footer"))

  cell_data$width  <- NULL# need to get rid of originals that are empty, should probably rm them
  cell_data$height  <- NULL
  cell_data$hrule  <- NULL
  cell_data <- merge(cell_data, cell_widths, by = "col_id")
  cell_data <- merge(cell_data, cell_heights, by = c("part", "ft_row_id"))
  cell_data <- merge(cell_data, cell_hrule, by = c("part", "ft_row_id"))

  setDT(cell_data)
  setorderv(cell_data, cols = c("part", "ft_row_id", "col_id"))
  cell_data[, c("border.width.top", "border.color.top", "border.style.top" ) :=
              list(
                fcoalesce(shift(.SD$border.width.bottom, 1L, type="lag"), .SD$border.width.bottom),
                fcoalesce(shift(.SD$border.color.bottom, 1L, type="lag"), .SD$border.color.bottom),
                fcoalesce(shift(.SD$border.style.bottom, 1L, type="lag"), .SD$border.style.bottom)
              ),
            by = "col_id"]

  data_ref_cells <- cell_style_list(cell_data)

  ## cell style pml
  fp_cell_pml <- data_ref_cells
  classnames <- data_ref_cells$classname
  fp_cell_pml$classname <- NULL
  cols <- intersect(names(formals(fp_par)), colnames(fp_cell_pml))
  fp_cell_pml <- fp_cell_pml[cols]
  fp_cell_pml <- split(fp_cell_pml, classnames)
  fp_cell_pml <- lapply(fp_cell_pml, function(x){
    zz <- as.list(x)
    zz$border.bottom <- zz$border.bottom[[1]]
    zz$border.top <- zz$border.top[[1]]
    zz$border.right <- zz$border.right[[1]]
    zz$border.left <- zz$border.left[[1]]
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
  cell_data <- cell_data[, .SD,
                       .SDcols = c(
                         "part", "ft_row_id",
                         "col_id", "fp_cell_pml"
                       )
  ]
  setDF(cell_data)
  cell_data
}

pptx_str <- function(value, uid = 99999L, offx = 0, offy = 0, cx = 0, cy = 0){

  txt_data <- pml_runs(value)
  par_data <- pml_pars(value)
  span_data <- pml_spans(value)
  cell_data <- pml_cells(value)
  cell_heights <- fortify_height(value)

  hlinks <- attr(txt_data, "url")

  setDT(cell_data)

  tab_data <- merge(cell_data, par_data, by = c("part", "ft_row_id", "col_id"))
  tab_data <- merge(tab_data, txt_data, by = c("part", "ft_row_id", "col_id"))
  tab_data <- merge(tab_data, span_data, by = c("part", "ft_row_id", "col_id"))
  tab_data$col_id <- factor(tab_data$col_id, levels = value$col_keys)
  setorderv(tab_data, cols = c("part", "ft_row_id", "col_id"))

  tab_data[, c("pml") := list(
    paste0("<a:txBody><a:bodyPr/><a:lstStyle/>",
           "<a:p>", .SD$fp_par_pml,
           .SD$par_nodes_str, "</a:p>",
           "</a:txBody>")
  )]
  tab_data[, c("fp_par_pml", "par_nodes_str") := list(NULL, NULL)]

  tab_data[, c("pml") := list(
    paste0("<a:tc", .SD$grid_span, .SD$row_span,">", .SD$pml,
           .SD$fp_cell_pml, "</a:tc>")
  )]
  tab_data[, c("fp_cell_pml", "grid_span", "row_span") := list(NULL, NULL, NULL)]

  cells <- dcast(tab_data, part + ft_row_id ~ col_id, drop=TRUE, fill="", value.var = "pml", fun.aggregate = I)
  cells <- merge(cells, cell_heights, by = c("part", "ft_row_id"))

  rowheights <- cells$height
  cells[, c("ft_row_id", "height", "part") := list(NULL, NULL, NULL)]
  rows <- apply(as.matrix(cells), 1, paste0, collapse = "")
  rows <- paste0( "<a:tr h=\"", round(rowheights * 914400, 0 ), "\">", rows, "</a:tr>")
  rows <- paste0(rows, collapse = "")

  out <- "<a:tbl>"
  dims <- dim(value)
  widths <- dims$widths
  colswidths <- paste0("<a:gridCol w=\"", round(widths*914400, 0), "\"/>", collapse = "")

  out = paste0(out,  "<a:tblPr/><a:tblGrid>" )
  out = paste0(out,  colswidths )
  out = paste0(out,  "</a:tblGrid>" )
  out = paste0(out,  rows)

  out = paste0(out,  "</a:tbl>" )

  graphic_frame <- paste0(
    "<p:graphicFrame ",
    "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
    "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
    "xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\">",
    "<p:nvGraphicFramePr>",
    sprintf("<p:cNvPr id=\"%.0f\" name=\"\"/>", uid ),
    "<p:cNvGraphicFramePr><a:graphicFrameLocks noGrp=\"true\"/></p:cNvGraphicFramePr>",
    "<p:nvPr/>",
    "</p:nvGraphicFramePr>",
    "<p:xfrm rot=\"0\">",
    sprintf("<a:off x=\"%.0f\" y=\"%.0f\"/>", offx*914400, offy*914400),
    sprintf("<a:ext cx=\"%.0f\" cy=\"%.0f\"/>", cx*914400, cy*914400),
    "</p:xfrm>",
    "<a:graphic>",
    "<a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">",
    out,
    "</a:graphicData>",
    "</a:graphic>",
    "</p:graphicFrame>"
  )
  attr(graphic_frame, "hlinks") <- hlinks
  graphic_frame
}

