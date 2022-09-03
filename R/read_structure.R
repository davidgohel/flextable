#' @importFrom data.table is.data.table .N
expand_special_char <- function(x, what, with = NA, ...) {
  m <- gregexec(pattern = what, x$txt, ...)
  if (isTRUE(any(unlist(m) > -1))) {
    txt <- regmatches(x$txt, m, invert = NA)
    txt <- lapply(txt, function(z) z[nzchar(z)])
    if (is.character(with) && !is.na(with)) {
      txt <- lapply(txt, gsub, pattern = what, replacement = with, ...)
    }
    len <- lapply(txt, length)

    was_dt <- is.data.table(x)
    setDT(x)
    x <- x[rep(1:.N, len)][, "seq_index" := 1:.N]
    x$txt <- unlist(txt)
    if (!was_dt) setDF(x)
  }
  x
}

fortify_content <- function(x, default_chunk_fmt, ..., expand_special_chars = TRUE){
  if (isTRUE(expand_special_chars)) {
    x$content$data[] <- lapply(x$content$data, expand_special_char,
                               what = "\n", with = "<br>")
    x$content$data[] <- lapply(x$content$data, expand_special_char,
                               what = "\t", with = "<tab>")
  }

  row_id <- unlist( mapply( function(rows, data){
    rep(rows, nrow(data) )
  },
  rows = rep( seq_len(nrow(x$content$data)), ncol(x$content$data) ),
  x$content$data, SIMPLIFY = FALSE, USE.NAMES = FALSE ) )

  col_id <- unlist( mapply( function(columns, data){
    rep(columns, nrow(data) )
  },
  columns = rep( x$content$keys, each = nrow(x$content$data) ),
  x$content$data, SIMPLIFY = FALSE, USE.NAMES = FALSE ) )

  out <- rbindlist( apply(x$content$data, 2, rbindlist), use.names=TRUE, fill=TRUE)
  out$ft_row_id <- row_id
  out$col_id <- col_id
  setDF(out)

  default_props <- as.data.frame(default_chunk_fmt, stringsAsFactors = FALSE)
  out <- replace_missing_fptext_by_default(out, default_props)

  out$col_id <- factor( out$col_id, levels = default_chunk_fmt$color$keys )
  out <- out[order(out$col_id, out$ft_row_id, out$seq_index) ,]
  out

}


#' @importFrom data.table rbindlist setDF
as_table_text <- function(x, expand_special_chars = TRUE){
  dat <- list()
  if( nrow_part(x, "header") > 0 ){
    dat$header <- fortify_content(x$header$content, default_chunk_fmt = x$header$styles$text,
                                  expand_special_chars = expand_special_chars)
  }
  if( nrow_part(x, "body") > 0 ){
    dat$body <- fortify_content(x$body$content, default_chunk_fmt = x$body$styles$text,
                                expand_special_chars = expand_special_chars)
  }
  if( nrow_part(x, "footer") > 0 ){
    dat$footer <- fortify_content(x$footer$content, default_chunk_fmt = x$footer$styles$text,
                                  expand_special_chars = expand_special_chars)
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

fortify_width <- function(x){
  dat <- list()
  for(part in c("header", "body", "footer")){
    nr <- nrow_part(x, part)
    if( nr > 0 ){
      dat[[part]] <- data.frame(
        col_id = x$col_keys,
        width = x[[part]]$colwidths,
        stringsAsFactors = FALSE
      )
    }
  }

  dat[[1]]
}
fortify_height <- function(x){
  rows <- list()
  for(part in c("header", "body", "footer")){
    nr <- nrow_part(x, part)
    if( nr > 0 ){
      rows[[part]] <- data.frame(
        ft_row_id = seq_len(nr),
        height = x[[part]]$rowheights,
        stringsAsFactors = FALSE, check.names = FALSE
      )
    }
  }

  dat <- rbindlist(rows, use.names = TRUE, idcol = "part")
  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  setDF(dat)
  dat
}

fortify_hrule <- function(x){
  rows <- list()
  for(part in c("header", "body", "footer")){
    nr <- nrow_part(x, part)
    if( nr > 0 ){
      rows[[part]] <- data.frame(
        ft_row_id = seq_len(nr),
        hrule = x[[part]]$hrule,
        stringsAsFactors = FALSE, check.names = FALSE
      )
    }
  }

  dat <- rbindlist(rows, use.names = TRUE, idcol = "part")
  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  setDF(dat)
  dat
}

fortify_span <- function(x, parts = c("header", "body", "footer")){
  rows <- list()
  for(part in parts){
    if( nrow_part(x, part) > 0 ){
      nr <- nrow(x[[part]]$spans$rows)
      rows[[part]] <- data.frame(
        col_id = rep(x$col_keys, each = nr),
        ft_row_id = rep(seq_len(nr), length(x$col_keys)),
        rowspan = as.vector(x[[part]]$spans$rows),
        colspan = as.vector(x[[part]]$spans$columns),
        stringsAsFactors = FALSE, check.names = FALSE
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
  dat_cell <- dat_cell[, c("part", "ft_row_id", "col_id", "text.direction", "vertical.align")]
  dat_par <- merge(dat_par, dat_cell, by = c("part", "ft_row_id", "col_id"))
  setDF(dat_par)
  setDF(dat_cell)
  dat_par
}
fortify_cell_style <- function(par, cell){
  dat_par <- par
  dat_cell <- cell
  setDT(dat_par)
  setDT(dat_cell)
  dat_par <- dat_par[, c("part", "ft_row_id", "col_id", "text.align")]
  dat_cell <- merge(dat_cell, dat_par, by = c("part", "ft_row_id", "col_id"))
  setDF(dat_par)
  setDF(dat_cell)
  dat_cell
}
fortify_rows_styles <- function(x){
  dat <- list()
  if( nrow_part(x, "header") > 0 ){
    dat$header <- data.frame(hrule = x$header$hrule, ft_row_id = seq_len(nrow_part(x, "header")),
                             stringsAsFactors = FALSE, check.names = FALSE)
  }
  if( nrow_part(x, "body") > 0 ){
    dat$body <- data.frame(hrule = x$body$hrule, ft_row_id = seq_len(nrow_part(x, "body")),
                           stringsAsFactors = FALSE, check.names = FALSE)
  }
  if( nrow_part(x, "footer") > 0 ){
    dat$footer <- data.frame(hrule = x$footer$hrule, ft_row_id = seq_len(nrow_part(x, "footer")),
                             stringsAsFactors = FALSE, check.names = FALSE)
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
  setDF(dat)

  classname <- UUIDgenerate(n = nrow(uid), use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  uid$classname <- classname
  setDF(uid)
  uid
}
par_style_list <- function(x){

  fp_columns <- intersect(names(formals(officer::fp_par)), colnames(x))

  also <- c("text.direction", "vertical.align")
  also <- also[also %in% colnames(x)]

  dat <- as.data.frame(x)[c(fp_columns, also,
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

  dat <- as.data.frame(x)
  also <- c("text.align", "width", "height", "hrule")
  also <- also[also %in% colnames(x)]
  dat <- dat[c(fp_columns, also, grep("^border\\.", colnames(dat), value = TRUE))]

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


