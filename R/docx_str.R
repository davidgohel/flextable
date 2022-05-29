# utils -----

has_value <- function(x){
  !is.null(x) && !is.na(x) && length(x) == 1
}

coalesce_options <- function(a=NULL, b=NULL) {
  if(is.null(a)) return(b)
  if(is.null(b)) return(a)
  if( length(b) == 1 ){
    b <- rep(b, length(a))
  }
  out <- a
  out[!has_value(a)] <- b[!has_value(a)]
  out
}

mcoalesce_options <- function(...) {
  Reduce(coalesce_options, list(...))
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

#' @importFrom htmltools urlEncodePath
wml_runs <- function(value) {
  txt_data <- as_table_text(value)
  txt_data$col_id <- factor(txt_data$col_id, levels = value$col_keys)

  data_ref_text <- part_style_list(
    as.data.frame(txt_data),
    fun = dummy_fp_text_fun
  )

  fp_text_wml <- sapply(
    split(data_ref_text[-ncol(data_ref_text)], data_ref_text$classname),
    function(x) {
      z <- do.call(officer::fp_text_lite, x)
      format(z, type = "wml")
    }
  )
  style_dat <- data.frame(
    fp_text_wml = as.character(fp_text_wml),
    classname = data_ref_text$classname,
    stringsAsFactors = FALSE
  )

  is_soft_return <- txt_data$txt %in% "<br>"
  is_tab <- txt_data$txt %in% "<tab>"
  is_eq <- !is.na(txt_data$eq_data)
  is_word_field <- !is.na(txt_data$word_field_data)
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
                         "word_field_data",
                         "ft_row_id", "col_id", "fp_text_wml"
                       )
  ]
  txt_data <- add_raster_as_filecolumn(txt_data)

  text_nodes_t <- paste0("<w:t xml:space=\"preserve\">", htmlEscape(txt_data$txt), "</w:t>")
  text_nodes_t[is_soft_return] <- "<w:br/>"
  text_nodes_t[is_tab] <- "<w:tab/>"

  text_nodes_run <- paste0(sprintf("<w:r %s>", base_ns), txt_data$fp_text_wml, text_nodes_t, "</w:r>")
  text_nodes_run[is_raster] <- txt_data$img_str[is_raster]

  text_nodes_run[is_word_field] <- to_wml_word_field(txt_data$word_field_data[is_word_field], pr_txt = txt_data$fp_text_wml[is_word_field])

  # manage hlinks
  url_vals <- vapply(txt_data$url[is_hlink], urlEncodePath, FUN.VALUE = "", USE.NAMES = FALSE)
  text_nodes_run[is_hlink] <- paste0("<w:hyperlink r:id=\"", url_vals, "\">", text_nodes_run[is_hlink], "</w:hyperlink>")

  # manage formula
  if (requireNamespace("equatags", quietly = TRUE) && any(is_eq)) {
    transform_mathjax <- getFromNamespace("transform_mathjax", "equatags")
    text_nodes_run[is_eq] <- transform_mathjax(txt_data$eq_data[is_eq], to = "mml")
  }

  txt_data$par_nodes_str <- text_nodes_run

  setorderv(txt_data, cols = c("part", "ft_row_id", "col_id", "seq_index"))

  unique_url <- unique(na.omit(txt_data$url))
  unique_img <- unique(na.omit(txt_data$file[is_raster]))

  txt_data <- txt_data[, lapply(.SD, function(x) paste0(x, collapse = "")), by = c("part", "ft_row_id", "col_id"), .SDcols = "par_nodes_str"]
  setDF(txt_data)
  attr(txt_data, "url") <- unique_url
  attr(txt_data, "imgs") <- unique_img
  txt_data
}

wml_pars <- function(value, par_data){

  data_ref_pars <- par_style_list(par_data)

  ## par style wml
  fp_par_wml <- data_ref_pars
  classnames <- data_ref_pars$classname
  fp_par_wml$classname <- NULL
  cols <- intersect(names(formals(fp_par)), colnames(fp_par_wml))
  fp_par_wml <- fp_par_wml[cols]
  fp_par_wml <- split(fp_par_wml, classnames)
  fp_par_wml <- lapply(fp_par_wml, function(x){
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

wml_spans <- function(value){

  span_data <- fortify_span(value)

  gridspan <- rep("", nrow(span_data))
  gridspan[span_data$rowspan > 1] <-
    paste0("<w:gridSpan w:val=\"",
           span_data$rowspan[span_data$rowspan > 1],
           "\"/>")

  vmerge <- rep("", nrow(span_data))
  vmerge[span_data$colspan > 1] <- "<w:vMerge w:val=\"restart\"/>"
  vmerge[span_data$colspan < 1] <- "<w:vMerge/>"

  span_data$gridspan <- gridspan
  span_data$vmerge <- vmerge
  span_data
}

#' @importFrom data.table shift fcoalesce
wml_cells <- function(value, cell_data){

  cell_heights <- fortify_height(value)
  cell_widths <- fortify_width(value)
  # cell_hrule <- fortify_hrule(value)

  cell_data$width  <- NULL# need to get rid of originals that are empty, should probably rm them
  cell_data$height  <- NULL
  # cell_data$hrule  <- NULL
  cell_data <- merge(cell_data, cell_widths, by = "col_id")
  cell_data <- merge(cell_data, cell_heights, by = c("part", "ft_row_id"))
  # cell_data <- merge(cell_data, cell_hrule, by = c("part", "ft_row_id"))

  setDT(cell_data)
  setorderv(cell_data, cols = c("part", "ft_row_id", "col_id"))
  cell_data[!(cell_data$part %in% "header" & cell_data$ft_row_id %in% 1), c("border.width.top", "border.color.top", "border.style.top" ) :=
              list(
                fcoalesce(shift(.SD$border.width.bottom, 1L, type="lag"), .SD$border.width.bottom),
                fcoalesce(shift(.SD$border.color.bottom, 1L, type="lag"), .SD$border.color.bottom),
                fcoalesce(shift(.SD$border.style.bottom, 1L, type="lag"), .SD$border.style.bottom)
              ),
            by = "col_id"]

  data_ref_cells <- cell_style_list(cell_data)

  ## cell style wml
  fp_cell_wml <- data_ref_cells
  classnames <- data_ref_cells$classname
  fp_cell_wml$classname <- NULL

  cols <- intersect(names(formals(fp_cell)), colnames(fp_cell_wml))
  fp_cell_wml <- fp_cell_wml[cols]
  fp_cell_wml <- split(fp_cell_wml, classnames)
  fp_cell_wml <- lapply(fp_cell_wml, function(x){
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
                     by = intersect(colnames(cell_data), colnames(data_ref_cells)))
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



wml_rows <- function(value, split = FALSE){

  cell_attributes <- fortify_style(value, "cells")
  cell_attributes$col_id <- factor(cell_attributes$col_id, levels = value$col_keys)
  cell_attributes$part <- factor(cell_attributes$part, levels = c("header", "body", "footer"))

  par_attributes <- fortify_style(value, "pars")
  par_attributes$col_id <- factor(par_attributes$col_id, levels = value$col_keys)

  new_pos <- ooxml_rotation_alignments(
    rotation = cell_attributes$text.direction,
    valign = cell_attributes$vertical.align,
    align = par_attributes$text.align)

  par_attributes$text.align <- new_pos$align
  cell_attributes$vertical.align <- new_pos$valign

  txt_data <- wml_runs(value)
  par_data <- wml_pars(value, par_attributes)
  span_data <- wml_spans(value)
  cell_data <- wml_cells(value, cell_attributes)
  cell_heights <- fortify_height(value)
  cell_hrule <- fortify_hrule(value)

  hlinks <- attr(txt_data, "url")
  imgs <- attr(txt_data, "imgs")

  setDT(cell_data)

  tab_data <- merge(cell_data, par_data, by = c("part", "ft_row_id", "col_id"))
  tab_data <- merge(tab_data, txt_data, by = c("part", "ft_row_id", "col_id"))
  tab_data <- merge(tab_data, span_data, by = c("part", "ft_row_id", "col_id"))
  tab_data$col_id <- factor(tab_data$col_id, levels = value$col_keys)
  setorderv(tab_data, cols = c("part", "ft_row_id", "col_id"))

  tab_data[, c("wml", "fp_par_wml", "par_nodes_str") := list(
    paste0("<w:p>", .SD$fp_par_wml,
           .SD$par_nodes_str, "</w:p>"),
    NULL,
    NULL
  )]

  tab_data[ tab_data$colspan < 1, c("wml") := list(
    gsub("<w:r\\b[^<]*>[^<]*(?:<[^<]*)*</w:r>", "", .SD$wml)
  )]
  tab_data[, c("wml") := list(
    paste0("<w:tc>",
           "<w:tcPr>", .SD$gridspan, .SD$vmerge, .SD$fp_cell_wml, "</w:tcPr>",
           .SD$wml, "</w:tc>")
  )]
  tab_data[ tab_data$rowspan < 1, c("wml") := list("")]

  tab_data[, c("fp_cell_wml", "gridspan", "vmerge", "colspan", "rowspan") := list(NULL, NULL, NULL, NULL, NULL)]

  cells <- dcast(
    data = tab_data, formula = part + ft_row_id ~ col_id,
    drop = TRUE, fill = "", value.var = "wml",
    fun.aggregate = I)

  wml <- apply(as.matrix(cells), 1, paste0, collapse = "")

  split_str <- ""
  if(!split) split_str <- "<w:cantSplit/>"

  hrule <- cell_hrule$hrule
  hrule[hrule %in% "atleast"] <- "atLeast"

  header_str <- rep("", nrow(cell_hrule))
  header_str[cell_hrule$part %in% "header"] <- "<w:tblHeader/>"

  rows <- paste0( "<w:tr><w:trPr>",
                  split_str,
                  "<w:trHeight",
                  " w:val=",
                  shQuote( round(cell_heights$height * 72*20, 0 ), type = "cmd"),
                  " w:hRule=\"",
                  hrule ,
                  "\"/>",
                  header_str,
                  "</w:trPr>", wml, "</w:tr>")

  rows <- paste0(rows, collapse = "")

  attr(rows, "imgs") <- imgs
  attr(rows, "htxt") <- hlinks

  rows
}


# docx_str -----
docx_str <- function(x, align = "center", split = FALSE, keep_with_next = TRUE, doc = NULL, ...){

  imgs <- character(0)
  hlinks <- character(0)

  align <- match.arg(align, c("center", "left", "right"), several.ok = FALSE)
  align <- c("center" = "center", "left" = "start", "right" = "end")[align]
  align <- as.character(align)

  dims <- dim(x)
  widths <- dims$widths

  x <- keep_wn(x, part  = "all", keep_with_next = keep_with_next)

  out <- paste0(
      "<w:tbl xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" ",
      "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ",
      "xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\" ",
      "xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" ",
      "xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ",
      "xmlns:pic=\"http://schemas.openxmlformats.org/drawingml/2006/picture\"",
      ">")
  if(x$properties$layout %in% "autofit"){
    pt <- prop_table(style = NULL,
      layout = table_layout(type = "autofit"),
      align = align,
      width = table_width(width = x$properties$width, unit = "pct"),
      colwidths = table_colwidths(double(0L)))
  } else {
    pt <- prop_table(style = NULL,
      layout = table_layout(type = "fixed"),
      align = align,
      width = table_width(unit = "in",
                          width = sum(widths, na.rm = TRUE)
      ),
      colwidths = table_colwidths(widths))
  }

  properties_str <- to_wml(pt, add_ns= FALSE, base_document = doc)

  out <- paste0(out, properties_str )

  tab_str <- wml_rows(x, split = split)
  out <- paste0(out, tab_str,  "</w:tbl>")

  imgs <- unique(attr(tab_str, "imgs"))
  hlinks <- unique(attr(tab_str, "htxt"))

  if( length(imgs) > 0 ) {
    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      doc <- docx_reference_img( doc, imgs )
      out <- wml_link_images( doc, out )
    }
  }
  if( length(hlinks) > 0 ){
    if (!is.null(doc)) {
      stopifnot(inherits(doc, "rdocx"))
      for( hl in hlinks ){
        rel <- doc$doc_obj$relationship()
        out <- process_url(rel, url = hl, str = out, pattern = "w:hyperlink", double_esc = FALSE)
      }
    }
  }

  out

}

#' @importFrom officer run_bookmark ftext
caption_docx_bookdown <- function(x){
  tab_props <- opts_current_table()

  tab_props$id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id, opts_current$get('label'))
  tab_props$cap <- mcoalesce_options(x$caption$value, tab_props$cap)
  tab_props$cap.style <- mcoalesce_options(x$caption$style, tab_props$cap.style)

  has_caption_label <- !is.null(tab_props$cap)
  has_caption_style <- !is.null(tab_props$cap.style)
  style_start <- ""
  style_end <- ""

  if(has_caption_style) {
    style_start <- sprintf("::: {custom-style=\"%s\"}\n", tab_props$cap.style)
    style_end <- "\n:::\n"
  }

  if(!has_caption_label) return("")

  caption <- tab_props$cap

  zz <- if(!is.null(tab_props$id)){
    paste0("(\\#", tab_props$tab.lp, tab_props$id,")")
  } else {
    ""
  }

  caption <- paste(
    style_start,
    paste0("<caption>", zz, caption, "</caption>"),
    style_end,
    "", sep = "\n")

  caption
}

caption_docx_standard <- function(x){
  tab_props <- opts_current_table()

  caption_label <- mcoalesce_options(x$caption$value, tab_props$cap)
  caption_style <- mcoalesce_options(x$caption$style, tab_props$cap.style)
  caption_id <- mcoalesce_options(x$caption$autonum$bookmark, tab_props$id, opts_current$get('label'))
  caption_lp <- mcoalesce_options(if( !is.null(tab_props$tab.lp) )
                                    gsub(":$", "", tab_props$tab.lp)
                                  else NULL,
                                  x$caption$autonum$seq_id)
  caption_pre_label <- mcoalesce_options(tab_props$cap.pre, x$caption$autonum$pre_label)
  caption_post_label <- mcoalesce_options(tab_props$cap.sep, x$caption$autonum$post_label)
  caption_tnd <- mcoalesce_options(tab_props$cap.tnd, x$caption$autonum$tnd)
  caption_tns <- mcoalesce_options(tab_props$cap.tns, x$caption$autonum$tns)
  caption_fp_text <- mcoalesce_options(tab_props$cap.fp_text, x$caption$autonum$pr)

  autonum <- run_autonum(
    seq_id = caption_lp,
    pre_label = caption_pre_label,
    post_label = caption_post_label,
    bkm = caption_id, bkm_all = FALSE,
    tnd = caption_tnd,
    tns = caption_tns,
    prop = caption_fp_text
  )
  bc <- block_caption(label = caption_label, style = caption_style, autonum = autonum)
  caption <- to_wml(bc, knitting = TRUE)
  caption
}

caption_docx_str <- function(x, bookdown = FALSE){
  if(bookdown) caption_docx_bookdown(x)
  else caption_docx_standard(x)
}
