#' @importFrom data.table rbindlist setDF
as_table_text <- function(x){
  dat <- list()
  if( nrow_part(x, "header") > 0 ){
    dat$header <- fortify_content(x$header$content, default_chunk_fmt = x$header$styles$text)
  }
  if( nrow_part(x, "body") > 0 ){
    dat$body <- fortify_content(x$body$content, default_chunk_fmt = x$body$styles$text)
  }
  if( nrow_part(x, "footer") > 0 ){
    dat$footer <- fortify_content(x$footer$content, default_chunk_fmt = x$footer$styles$text)
  }
  dat <- rbindlist(dat, use.names = TRUE, idcol = "part")
  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  setDF(dat)
  dat
}

#' @importFrom data.table rbindlist setDF
fortify_style <- function(x, style_part = "pars"){
  dat <- list()
  if( nrow_part(x, "header") > 0 ){
    dat$header <- as.data.frame(x$header$styles[[style_part]])
  }
  if( nrow_part(x, "body") > 0 ){
    dat$body <- as.data.frame(x$body$styles[[style_part]])
  }
  if( nrow_part(x, "footer") > 0 ){
    dat$footer <- as.data.frame(x$footer$styles[[style_part]])
  }
  dat <- rbindlist(dat, use.names = TRUE, idcol = "part")
  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  setDF(dat)
  dat
}

fortify_span <- function(x){
  rows <- list()
  for(part in c("header", "body", "footer")){
    if( nrow_part(x, part) > 0 ){
      nr <- nrow(x[[part]]$spans$rows)
      rows[[part]] <- data.frame(
        col_id = rep(x$col_keys, each = nr),
        row_id = rep(seq_len(nr), length(x$col_keys)),
        rowspan = as.vector(x[[part]]$spans$rows),
        colspan = as.vector(x[[part]]$spans$columns),
        stringsAsFactors = FALSE
      )
    }
  }
  dat <- rbindlist(rows, use.names = TRUE, idcol = "part")
  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  setDF(dat)
  dat
}
fortify_par_style <- function(par, cell){
  dat_par <- par
  dat_cell <- cell
  setDT(dat_par)
  setDT(dat_cell)
  dat_cell <- dat_cell[, c("part", "row_id", "col_id", "text.direction", "vertical.align")]
  dat_par <- merge(dat_par, dat_cell, by = c("part", "row_id", "col_id"))
  setDF(dat_par)
  setDF(dat_cell)
  dat_par
}
fortify_cell_style <- function(par, cell){
  dat_par <- par
  dat_cell <- cell
  setDT(dat_par)
  setDT(dat_cell)
  dat_par <- dat_par[, c("part", "row_id", "col_id", "text.align")]
  dat_cell <- merge(dat_cell, dat_par, by = c("part", "row_id", "col_id"))
  setDF(dat_par)
  setDF(dat_cell)
  dat_cell
}
fortify_rows_styles <- function(x){
  dat <- list()
  if( nrow_part(x, "header") > 0 ){
    dat$header <- data.frame(hrule = x$header$hrule,
                             row_id = seq_len(nrow_part(x, "header")),
                             stringsAsFactors = FALSE)
  }
  if( nrow_part(x, "body") > 0 ){
    dat$body <- data.frame(hrule = x$body$hrule,
                           row_id = seq_len(nrow_part(x, "body")),
                           stringsAsFactors = FALSE)
  }
  if( nrow_part(x, "footer") > 0 ){
    dat$footer <- data.frame(hrule = x$footer$hrule,
                             row_id = seq_len(nrow_part(x, "footer")),
                             stringsAsFactors = FALSE)
  }
  dat <- rbindlist(dat, use.names = TRUE, idcol = "part")
  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  setDF(dat)
  dat
}

#' @importFrom data.table setDT
#' @importFrom uuid UUIDgenerate
part_style_list <- function(x, fun = NULL, more_args = list()){

  fp_columns <- intersect(names(formals(fun)), colnames(x))
  dat <- x[fp_columns]
  if(length(more_args)>0){
    dat[names(more_args)] <- more_args
  }
  setDT(dat)
  uid <- unique(dat)
  classname <- UUIDgenerate(n = nrow(uid), use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  uid$classname <- classname
  setDF(uid)
  uid
}
par_style_list <- function(x){

  fp_columns <- intersect(names(formals(officer::fp_par)), colnames(x))
  dat <- x[c(fp_columns, "text.direction", "vertical.align",
             grep("^border\\.", colnames(x), value = TRUE))]
  setDT(dat)
  uid <- unique(dat)
  classname <- UUIDgenerate(n = nrow(uid), use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  uid$classname <- classname

  border.bottom <- mapply(fp_border, color = uid$border.color.bottom,
                          style = uid$border.style.bottom,
                          width = uid$border.width.bottom,
                          SIMPLIFY = FALSE, USE.NAMES = FALSE)
  border.left <- mapply(fp_border, color = uid$border.color.left,
                        style = uid$border.style.left,
                        width = uid$border.width.left,
                        SIMPLIFY = FALSE, USE.NAMES = FALSE)
  border.top <- mapply(fp_border, color = uid$border.color.top,
                       style = uid$border.style.top,
                       width = uid$border.width.top,
                       SIMPLIFY = FALSE, USE.NAMES = FALSE)
  border.right <- mapply(fp_border, color = uid$border.color.right,
                         style = uid$border.style.right,
                         width = uid$border.width.right,
                         SIMPLIFY = FALSE, USE.NAMES = FALSE)

  # uid[, grep("^border\\.", colnames(x), value = TRUE) := NULL]
  uid$border.bottom <- border.bottom
  uid$border.left <- border.left
  uid$border.top <- border.top
  uid$border.right <- border.right

  setDF(uid)

  uid
}

cell_style_list <- function(x){

  fp_columns <- intersect(names(formals(officer::fp_cell)), colnames(x))
  dat <- x[c(fp_columns, "text.align", grep("^border\\.", colnames(x), value = TRUE))]
  setDT(dat)
  uid <- unique(dat)
  classname <- UUIDgenerate(n = nrow(uid), use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  uid$classname <- classname

  border.bottom <- mapply(fp_border, color = uid$border.color.bottom,
                          style = uid$border.style.bottom,
                          width = uid$border.width.bottom,
                          SIMPLIFY = FALSE, USE.NAMES = FALSE)
  border.left <- mapply(fp_border, color = uid$border.color.left,
                        style = uid$border.style.left,
                        width = uid$border.width.left,
                        SIMPLIFY = FALSE, USE.NAMES = FALSE)
  border.top <- mapply(fp_border, color = uid$border.color.top,
                       style = uid$border.style.top,
                       width = uid$border.width.top,
                       SIMPLIFY = FALSE, USE.NAMES = FALSE)
  border.right <- mapply(fp_border, color = uid$border.color.right,
                         style = uid$border.style.right,
                         width = uid$border.width.right,
                         SIMPLIFY = FALSE, USE.NAMES = FALSE)

  # uid[, grep("^border\\.", colnames(x), value = TRUE) := NULL]
  uid$border.bottom <- border.bottom
  uid$border.left <- border.left
  uid$border.top <- border.top
  uid$border.right <- border.right

  setDF(uid)

  uid
}

# html output ----
htmlize <- function(x){
  x <-  gsub("\n", "<br>", htmlEscape(x))
  x <-  gsub("\t", "&emsp;", x)
  x
}

text_css_styles <- function(x){

  shading <- ifelse(
    colalpha(x$shading.color) > 0,
    sprintf("background-color:%s;", colcodecss(x$shading.color) ),
    "background-color:transparent;")
  color <- ifelse(
    colalpha(x$color) > 0,
    sprintf("color:%s;", colcodecss(x$color) ),
    "")

  family <- sprintf("font-family:'%s';", x$font.family )

  positioning_val <- ifelse( x$vertical.align %in% "superscript", .3,
                             ifelse(x$vertical.align %in% "subscript", .3, NA_real_ ) )
  positioning_what <- ifelse( x$vertical.align %in% "superscript", "bottom",
                              ifelse(x$vertical.align %in% "subscript", "top", NA_character_ ) )
  vertical.align <- sprintf("position: relative;%s:%s;", positioning_what,
                            css_px(x$font.size * positioning_val))
  vertical.align <- ifelse(is.na(positioning_val), "", vertical.align)

  font.size <- sprintf(
    "font-size:%s;", css_px(x$font.size * ifelse(
      x$vertical.align %in% "superscript", .6,
      ifelse(x$vertical.align %in% "subscript", .6, 1.0 )
    ) )
  )

  bold <- ifelse(x$bold, "font-weight:bold;", "font-weight:normal;" )
  italic <- ifelse(x$italic, "font-style:italic;", "font-style:normal;" )
  underline <- ifelse(x$underlined, "text-decoration:underline;", "text-decoration:none;" )


  style_column <- paste0(family, font.size, bold, italic, underline,
                         color, shading, vertical.align)

  paste0(".", x$classname, "{", style_column, "}", collapse = "")
}

par_css_styles <- function(x){
  shading <- ifelse( colalpha(x$shading.color) > 0,
                     sprintf("background-color:%s;", colcodecss(x$shading.color) ),
                     "background-color:transparent;")

  textdir <- ifelse(x$text.direction %in% "tbrl", "writing-mode:vertical-rl;",
                    ifelse(x$text.direction %in% "btlr", "writing-mode:vertical-lr;transform: rotate(180deg);", "")
  )
  textalign <- sprintf("text-align:%s;", x$text.align )
  textalign_margins <- rep("", nrow(x))

  textalign_margins[x$text.direction %in% "tbrl" & x$vertical.align %in% "center"] <- "margin-left:auto;margin-right:auto;"
  textalign_margins[x$text.direction %in% "tbrl" & x$vertical.align %in% "top"] <- "margin-left:auto;"
  textalign_margins[x$text.direction %in% "tbrl" & x$vertical.align %in% "bottom"] <- "margin-right:auto;"
  textalign_margins[x$text.direction %in% "btlr" & x$vertical.align %in% "center"] <- "margin-left:auto;margin-right:auto;"
  textalign_margins[x$text.direction %in% "btlr" & x$vertical.align %in% "top"] <- "margin-right:auto;"
  textalign_margins[x$text.direction %in% "btlr" & x$vertical.align %in% "bottom"] <- "margin-left:auto;"
  textalign <- paste0(textalign, textalign_margins)

  bb <- border_css(
    color = x$border.color.bottom, width = x$border.width.bottom,
    style = x$border.style.bottom, side = "bottom")
  bt <- border_css(
    color = x$border.color.top, width = x$border.width.top,
    style = x$border.style.top, side = "top")
  bl <- border_css(
    color = x$border.color.left, width = x$border.width.left,
    style = x$border.style.left, side = "left")
  br <- border_css(
    color = x$border.color.right, width = x$border.width.right,
    style = x$border.style.right, side = "right")

  padding.bottom <- sprintf("padding-bottom:%s;", css_px(x$padding.bottom) )
  padding.top <- sprintf("padding-top:%s;", css_px(x$padding.top) )
  padding.left <- sprintf("padding-left:%s;", css_px(x$padding.left) )
  padding.right <- sprintf("padding-right:%s;", css_px(x$padding.right) )

  line_spacing <- sprintf("line-height: %.2f;", x$line_spacing )

  style_column <- paste0("margin:0;", textalign, textdir, bb, bt, bl, br,
                         padding.bottom, padding.top, padding.left, padding.right,
                         line_spacing, shading )
  paste0(".", x$classname, "{", style_column, "}", collapse = "")
}

cell_css_styles <- function(x){

  background.color <- ifelse( colalpha(x$background.color) > 0,
                              sprintf("background-clip: padding-box;background-color:%s;", colcodecss(x$background.color) ),
                              "background-color:transparent;")

  width <- ifelse( is.na(x$width), "", sprintf("width:%s;", css_px(x$width * 72) ) )
  height <- ifelse( is.na(x$height) | x$hrule %in% "exact", sprintf("height:%s;", css_px(x$height * 72 ) ), "" )

  vertical.align <- ifelse(
    x$vertical.align %in% "center", "vertical-align: middle;",
    ifelse(x$vertical.align %in% "top", "vertical-align: top;", "vertical-align: bottom;") )
  vertical.align[x$text.direction %in% "tbrl" & x$text.align %in% "center"] <- "vertical-align:middle;"
  vertical.align[x$text.direction %in% "tbrl" & x$text.align %in% "left"] <- "vertical-align:top;"
  vertical.align[x$text.direction %in% "tbrl" & x$text.align %in% "right"] <- "vertical-align:bottom;"

  bb <- border_css(
    color = x$border.color.bottom, width = x$border.width.bottom,
    style = x$border.style.bottom, side = "bottom")
  bt <- border_css(
    color = x$border.color.top, width = x$border.width.top,
    style = x$border.style.top, side = "top")
  bl <- border_css(
    color = x$border.color.left, width = x$border.width.left,
    style = x$border.style.left, side = "left")
  br <- border_css(
    color = x$border.color.right, width = x$border.width.right,
    style = x$border.style.right, side = "right")

  margin.bottom <- sprintf("margin-bottom:%s;", css_px(x$margin.bottom) )
  margin.top <- sprintf("margin-top:%s;", css_px(x$margin.top) )
  margin.left <- sprintf("margin-left:%s;", css_px(x$margin.left) )
  margin.right <- sprintf("margin-right:%s;", css_px(x$margin.right) )

  style_column <- paste0(width, height, background.color, vertical.align, bb, bt, bl, br,
                         margin.bottom, margin.top, margin.left, margin.right)
  paste0(".", x$classname, "{", style_column, "}", collapse = "")
}

#' @importFrom data.table setnames setorderv := setcolorder setDT setDF dcast
html_chunks <- function(x){

  par_data_f <- fortify_style(x, "pars")
  cell_data_f <- fortify_style(x, "cells")
  txt_data <- as_table_text(x)
  par_data <- fortify_par_style(par_data_f, cell_data_f)
  cell_data <- fortify_cell_style(par_data_f, cell_data_f)

  span_data <- fortify_span(x)

  data_ref_text <- part_style_list(txt_data, fun = officer::fp_text)
  data_ref_pars <- par_style_list(par_data)
  data_ref_cells <- cell_style_list(cell_data)

  setDT(txt_data)
  setDT(data_ref_text)
  setDT(par_data)
  setDT(data_ref_pars)
  setDT(cell_data)
  setDT(data_ref_cells)

  by_columns <- intersect(colnames(data_ref_text), colnames(txt_data))
  txt_data <- merge(txt_data, data_ref_text, by = by_columns)
  txt_data$txt <- sprintf("<span class=\"%s\">%s</span>", txt_data$classname, htmlize(txt_data$txt))
  txt_data <- txt_data[, list(span_tag = paste0(get("txt"), collapse = "")), by = c("part", "row_id", "col_id")]

  by_columns <- intersect(colnames(par_data), colnames(data_ref_pars))
  par_data <- merge(par_data, data_ref_pars, by = by_columns)
  par_data <- par_data[, list(p_tag = paste0("<p class=\"", get("classname"), "\">")), by = c("part", "row_id", "col_id")]

  by_columns <- intersect(colnames(cell_data), colnames(data_ref_cells))
  cell_data <- merge(cell_data, data_ref_cells, by = by_columns)
  cell_data <- merge(cell_data, span_data, by = c("part", "row_id", "col_id"))

  cell_data <- cell_data[, list(
    td_tag = paste0("<td ",
                    paste0(
                      ifelse(get("rowspan") > 1, paste0(" colspan=\"", get("rowspan"),"\""), ""),
                      ifelse(get("colspan") > 1, paste0(" rowspan=\"", get("colspan"),"\""), "")
                    ),
                    "class=\"", get("classname"), "\">")
    ),
    by = c("part", "row_id", "col_id")]


  dat <- merge(txt_data, par_data , by = c("part", "row_id", "col_id"))
  dat$p_tag <- paste0(dat$p_tag, dat$span_tag, "</p>")
  dat <- merge(dat, cell_data , by = c("part", "row_id", "col_id"))
  dat$td_tag <- paste0(dat$td_tag, dat$p_tag, "</td>")

  rows_data <- fortify_rows_styles(x)
  rows_data$tr_tag <- ifelse(rows_data$hrule %in% "exact", "<tr>", "<tr style=\"overflow-wrap:break-word;\">")
  rows_data <- rows_data[c("part", "row_id",  "tr_tag")]

  dat <- merge(dat, span_data, by = c("part", "row_id", "col_id"))
  dat$col_id <- factor(dat$col_id, levels = x$col_keys)
  dat$td_tag[dat$rowspan < 1 | dat$colspan < 1] <- ""

  z <- dcast(dat, part + row_id ~ col_id, drop=TRUE, fill="", value.var = "td_tag", fun.aggregate = I)
  z <- merge(z, rows_data, by = c("part", "row_id"))
  setorderv(z, c("part", "row_id"))
  z$tr_end <- "</tr>"

  parts <- z$part
  header_start <- head(which(parts %in% "header"), n = 1)
  header_end <- tail(which(parts %in% "header"), n = 1)
  body_start <- head(which(parts %in% "body"), n = 1)
  body_end <- nrow(z)

  z$tpart_start <- ""
  z$tpart_end <- ""
  z$tpart_start[header_start] <- "<thead>"
  z$tpart_end[header_end] <- "</thead>"
  z$tpart_start[body_start] <- "<tbody>"
  z$tpart_end[body_end] <- "</tbody>"
  setcolorder(z, neworder = c("tpart_start", "tr_tag"))

  z[, c("part", "row_id") := NULL]

  html <- apply(as.matrix(z), 1, paste0, collapse = "")
  html <- paste0(html, collapse = "")

  span_style_str <- text_css_styles(data_ref_text)
  par_style_str <- par_css_styles(data_ref_pars)
  cell_style_str <- cell_css_styles(data_ref_cells)

  list(
    html = html,
    css = paste0(span_style_str, par_style_str, cell_style_str)
  )
}



