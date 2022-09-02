# utils -----

has_value <- function(x) {
  !is.null(x) && !is.na(x) && length(x) == 1
}

coalesce_options <- function(a = NULL, b = NULL) {
  if (is.null(a)) {
    return(b)
  }
  if (is.null(b)) {
    return(a)
  }
  if (length(b) == 1) {
    b <- rep(b, length(a))
  }
  out <- a
  out[!has_value(a)] <- b[!has_value(a)]
  out
}

mcoalesce_options <- function(...) {
  Reduce(coalesce_options, list(...))
}


wml_pars <- function(value, par_data) {
  data_ref_pars <- par_style_list(par_data)

  ## par style wml
  fp_par_wml <- data_ref_pars
  classnames <- data_ref_pars$classname
  fp_par_wml$classname <- NULL
  cols <- intersect(names(formals(fp_par)), colnames(fp_par_wml))
  fp_par_wml <- fp_par_wml[cols]
  fp_par_wml <- split(fp_par_wml, classnames)
  fp_par_wml <- lapply(fp_par_wml, function(x) {
    zz <- as.list(x)
    zz$border.bottom <- zz$border.bottom[[1]]
    zz$border.top <- zz$border.top[[1]]
    zz$border.right <- zz$border.right[[1]]
    zz$border.left <- zz$border.left[[1]]
    zz <- do.call(fp_par, zz)
    format(zz, type = "wml")
  })
  style_dat <- data.frame(
    fp_par_wml = as.character(fp_par_wml),
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
      "col_id", "fp_par_wml"
    )
  ]
  setDF(par_data)
  par_data
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

#' @importFrom data.table shift fcoalesce
wml_cells <- function(value, cell_data) {
  cell_heights <- fortify_height(value)
  cell_widths <- fortify_width(value)
  # cell_hrule <- fortify_hrule(value)

  cell_data$width <- NULL # need to get rid of originals that are empty, should probably rm them
  cell_data$height <- NULL
  # cell_data$hrule  <- NULL
  cell_data <- merge(cell_data, cell_widths, by = "col_id")
  cell_data <- merge(cell_data, cell_heights, by = c("part", "ft_row_id"))
  # cell_data <- merge(cell_data, cell_hrule, by = c("part", "ft_row_id"))

  setDT(cell_data)
  setorderv(cell_data, cols = c("part", "ft_row_id", "col_id"))

  first_partname <-
    if (nrow_part(value, "header")) {
      "header"
    } else if (nrow_part(value, "body")) {
      "body"
    } else {
      "footer"
    }

  cell_data[!(cell_data$part %in% first_partname & cell_data$ft_row_id %in% 1), c("border.width.top", "border.color.top", "border.style.top") :=
    list(
      fcoalesce(shift(.SD$border.width.bottom, 1L, type = "lag"), .SD$border.width.bottom),
      fcoalesce(shift(.SD$border.color.bottom, 1L, type = "lag"), .SD$border.color.bottom),
      fcoalesce(shift(.SD$border.style.bottom, 1L, type = "lag"), .SD$border.style.bottom)
    ),
  by = "col_id"
  ]

  data_ref_cells <- cell_style_list(cell_data)

  ## cell style wml
  fp_cell_wml <- data_ref_cells
  classnames <- data_ref_cells$classname
  fp_cell_wml$classname <- NULL

  cols <- intersect(names(formals(fp_cell)), colnames(fp_cell_wml))
  fp_cell_wml <- fp_cell_wml[cols]
  fp_cell_wml <- split(fp_cell_wml, classnames)
  fp_cell_wml <- lapply(fp_cell_wml, function(x) {
    zz <- as.list(x)
    zz$border.bottom <- zz$border.bottom[[1]]
    zz$border.top <- zz$border.top[[1]]
    zz$border.right <- zz$border.right[[1]]
    zz$border.left <- zz$border.left[[1]]
    zz <- do.call(fp_cell, zz)
    zz <- format(zz, type = "wml")
    zz <- gsub("<w:tcPr>", "", zz, fixed = TRUE)
    zz <- gsub("</w:tcPr>", "", zz, fixed = TRUE)
    zz
  })
  style_dat <- data.frame(
    fp_cell_wml = as.character(fp_cell_wml),
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
      "part", "ft_row_id",
      "col_id", "fp_cell_wml"
    )
  ]
  setDF(cell_data)
  cell_data
}



wml_rows <- function(value, split = FALSE) {
  cell_attributes <- fortify_style(value, "cells")
  cell_attributes$col_id <- factor(cell_attributes$col_id, levels = value$col_keys)
  cell_attributes$part <- factor(cell_attributes$part, levels = c("header", "body", "footer"))

  par_attributes <- fortify_style(value, "pars")
  par_attributes$col_id <- factor(par_attributes$col_id, levels = value$col_keys)

  new_pos <- ooxml_rotation_alignments(
    rotation = cell_attributes$text.direction,
    valign = cell_attributes$vertical.align,
    align = par_attributes$text.align
  )

  par_attributes$text.align <- new_pos$align
  cell_attributes$vertical.align <- new_pos$valign

  txt_data <- as_table_text(value)
  txt_data$col_id <- factor(txt_data$col_id, levels = value$col_keys)
  txt_data <- runs_as_wml(value, txt_data)

  par_data <- wml_pars(value, par_attributes)

  span_data <- wml_spans(value)
  cell_data <- wml_cells(value, cell_attributes)
  cell_heights <- fortify_height(value)
  cell_hrule <- fortify_hrule(value)

  hlinks <- attr(txt_data, "hlinks")
  imgs <- attr(txt_data, "imgs")
  setDT(txt_data)
  setDT(cell_data)
  tab_data <- merge(cell_data, par_data, by = c("part", "ft_row_id", "col_id"))
  tab_data <- merge(tab_data, txt_data, by = c("part", "ft_row_id", "col_id"))
  tab_data <- merge(tab_data, span_data, by = c("part", "ft_row_id", "col_id"))
  tab_data$col_id <- factor(tab_data$col_id, levels = value$col_keys)
  setorderv(tab_data, cols = c("part", "ft_row_id", "col_id"))

  tab_data[, c("wml", "fp_par_wml", "run_openxml") := list(
    paste0("<w:p>", .SD$fp_par_wml, .SD$run_openxml, "</w:p>"),
    NULL,
    NULL
  )]

  tab_data[tab_data$colspan < 1, c("wml") := list(
    gsub("<w:r\\b[^<]*>[^<]*(?:<[^<]*)*</w:r>", "", .SD$wml)
  )]
  tab_data[, c("wml") := list(
    paste0(
      "<w:tc>",
      "<w:tcPr>", .SD$gridspan, .SD$vmerge, .SD$fp_cell_wml, "</w:tcPr>",
      .SD$wml, "</w:tc>"
    )
  )]
  tab_data[tab_data$rowspan < 1, c("wml") := list("")]

  tab_data[, c("fp_cell_wml", "gridspan", "vmerge", "colspan", "rowspan") := list(NULL, NULL, NULL, NULL, NULL)]

  cells <- dcast(
    data = tab_data, formula = part + ft_row_id ~ col_id,
    drop = TRUE, fill = "", value.var = "wml",
    fun.aggregate = I
  )

  wml <- apply(as.matrix(cells), 1, paste0, collapse = "")

  split_str <- ""
  if (!split) split_str <- "<w:cantSplit/>"

  hrule <- cell_hrule$hrule
  hrule[hrule %in% "atleast"] <- "atLeast"

  header_str <- rep("", nrow(cell_hrule))
  header_str[cell_hrule$part %in% "header"] <- "<w:tblHeader/>"

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

  rows <- paste0(rows, collapse = "")

  attr(rows, "imgs") <- imgs
  attr(rows, "hlinks") <- hlinks

  rows
}


# docx_str -----
docx_str <- function(x, align = "center", split = FALSE, keep_with_next = TRUE, doc = NULL, ...) {
  align <- match.arg(align, c("center", "left", "right"), several.ok = FALSE)
  align <- c("center" = "center", "left" = "start", "right" = "end")[align]
  align <- as.character(align)

  dims <- dim(x)
  widths <- dims$widths

  x <- keep_wn(x, part = "all", keep_with_next = keep_with_next)

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

  properties_str <- to_wml(pt, add_ns = FALSE, base_document = doc)

  out <- paste0(out, properties_str)

  tab_str <- wml_rows(x, split = split)
  out <- paste0(out, tab_str, "</w:tbl>")

  imgs <- unique(attr(tab_str, "imgs"))
  hlinks <- attr(tab_str, "hlinks")

  if (length(imgs) > 0) {
    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      doc <- docx_reference_img(doc, imgs)
      out <- wml_link_images(doc, out)
    }
  }
  if (length(hlinks) > 0) {
    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      rel <- doc$doc_obj$relationship()
      out <- process_url(
        relation_object = rel,
        urls_set = hlinks,
        ooxml_str = out,
        pattern = "w:hyperlink"
      )
    }
  }

  out
}
