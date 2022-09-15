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

#' @importFrom data.table rbindlist setDF
#' @noRd
#' @title fortify style
#' @description create a data.frame with formatting information.
#' It can be used with cells/pars/text
fortify_style <- function(x, style_part = "pars") {
  dat <- list()
  if (nrow_part(x, "header") > 0) {
    dat$header <- as.data.frame(x$header$styles[[style_part]])
  }
  if (nrow_part(x, "body") > 0) {
    dat$body <- as.data.frame(x$body$styles[[style_part]])
  }
  if (nrow_part(x, "footer") > 0) {
    dat$footer <- as.data.frame(x$footer$styles[[style_part]])
  }
  dat <- rbindlist(dat, use.names = TRUE, idcol = "part")

  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  dat$col_id <- factor(dat$col_id, levels = x$col_keys)
  setorderv(dat, cols = c("part", "ft_row_id", "col_id"))

  setDF(dat)

  dat
}

#' @noRd
#' @title fortify width
#' @description create a data.frame with width information.
fortify_width <- function(x) {
  dat <- list()
  for (part in c("header", "body", "footer")) {
    nr <- nrow_part(x, part)
    if (nr > 0) {
      dat[[part]] <- data.frame(col_id = x$col_keys, width = x[[part]]$colwidths, stringsAsFactors = FALSE)
    }
  }
  dat <- data.table::rbindlist(dat)
  dat <- dat[, list(width = safe_stat(.SD$width, FUN = max )), by = "col_id"]
  setDF(dat)
  dat$col_id <- factor(dat$col_id, levels = x$col_keys)
  setorderv(dat, cols = c("col_id"))

  dat
}

#' @noRd
#' @title fortify width
#' @description create a data.frame with height information.
fortify_height <- function(x) {
  rows <- list()
  for (part in c("header", "body", "footer")) {
    nr <- nrow_part(x, part)
    if (nr > 0) {
      rows[[part]] <- data.frame(
        ft_row_id = seq_len(nr), height = x[[part]]$rowheights,
        stringsAsFactors = FALSE, check.names = FALSE
      )
    }
  }

  dat <- rbindlist(rows, use.names = TRUE, idcol = "part")
  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  setorderv(dat, cols = c("part", "ft_row_id"))

  setDF(dat)
  dat
}

#' @noRd
#' @title fortify hrule
#' @description create a data.frame with hrule information.
fortify_hrule <- function(x) {
  rows <- list()
  for (part in c("header", "body", "footer")) {
    nr <- nrow_part(x, part)
    if (nr > 0) {
      rows[[part]] <- data.frame(
        ft_row_id = seq_len(nr), hrule = x[[part]]$hrule,
        stringsAsFactors = FALSE, check.names = FALSE
      )
    }
  }

  dat <- rbindlist(rows, use.names = TRUE, idcol = "part")
  dat$part <- factor(dat$part, levels = c("header", "body", "footer"))
  setorderv(dat, cols = c("part", "ft_row_id"))
  setDF(dat)
  dat
}

#' @noRd
#' @title fortify rows and columns spans
#' @description create a data.frame with hrule information.
fortify_span <- function(x, parts = c("header", "body", "footer")) {
  rows <- list()
  for (part in parts) {
    if (nrow_part(x, part) > 0) {
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
  dat$col_id <- factor(dat$col_id, levels = x$col_keys)
  setorderv(dat, cols = c("part", "ft_row_id", "col_id"))

  setDF(dat)

  dat
}


# distinct_properties ----
#' @importFrom data.table setDT
#' @importFrom uuid UUIDgenerate
#' @noRd
distinct_text_properties <- function(x, add_columns = character(length = 0L)){

  columns <- c("color", "font.size", "bold", "italic", "underlined", "font.family",
               "hansi.family", "eastasia.family", "cs.family", "vertical.align",
               "shading.color", add_columns)
  dat <- as.data.table(x[columns])
  uid <- unique(dat)
  setDF(dat)

  classname <- UUIDgenerate(n = nrow(uid), use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  uid$classname <- classname

  setDF(uid)

  uid
}
distinct_paragraphs_properties <- function(x){

  # fp_columns <- intersect(names(formals(officer::fp_par)), colnames(x))
  columns <- c(
    "text.align", "line_spacing", "padding.bottom", "padding.top",
    "padding.left", "padding.right", "shading.color", "keep_with_next",
    "border.width.bottom", "border.width.top", "border.width.left",
    "border.width.right", "border.color.bottom", "border.color.top",
    "border.color.left", "border.color.right", "border.style.bottom",
    "border.style.top", "border.style.left", "border.style.right",
    "text.direction", "vertical.align"
  )
  columns <- intersect(columns, colnames(x))

  dat <- as.data.frame(x)[columns]
  setDT(dat)

  uid <- unique(dat)

  classname <- UUIDgenerate(n = nrow(uid), use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  uid$classname <- classname

  setDF(uid)

  uid
}

distinct_cells_properties <- function(x){
  # fp_columns <- intersect(names(formals(officer::fp_cell)), colnames(x))
  columns <- c(
    "vertical.align", "margin.bottom", "margin.top", "margin.left",
    "margin.right", "background.color", "text.direction",
    "text.align", "width", "height", "hrule",# workaround for some formats
    "border.width.bottom", "border.width.top", "border.width.left",
    "border.width.right", "border.color.bottom", "border.color.top",
    "border.color.left", "border.color.right", "border.style.bottom",
    "border.style.top", "border.style.left", "border.style.right",
    "rowspan", "colspan"
    )
  columns <- intersect(columns, colnames(x))

  dat <- as.data.frame(x)[columns]
  setDT(dat)

  uid <- unique(dat)
  classname <- UUIDgenerate(n = nrow(uid), use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  uid$classname <- classname

  setDF(uid)

  uid
}

# -----
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
fortify_run <- function(x, expand_special_chars = TRUE){
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
  dat$col_id <- factor(dat$col_id, levels = x$col_keys)
  setorderv(dat, cols = c("part", "ft_row_id", "col_id"))

  setDF(dat)
  dat
}

