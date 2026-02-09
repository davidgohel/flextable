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
    x <- x[rep(seq_len(.N), len)][, ".chunk_index" := seq_len(.N)]
    x$txt <- unlist(txt)
    if (!was_dt) setDF(x)
  }
  x
}


#' @noRd
#' @title fortify width
#' @description create a data.frame with width information.
fortify_width <- function(x) {
  dat <- list()
  for (part in c("header", "body", "footer")) {
    nr <- nrow_part(x, part)
    if (nr > 0) {
      dat[[part]] <- data.frame(.col_id = x$col_keys, width = x[[part]]$colwidths, stringsAsFactors = FALSE)
    }
  }
  dat <- data.table::rbindlist(dat)
  dat <- dat[, list(width = safe_stat(.SD$width, FUN = max)), by = ".col_id"]
  setDF(dat)
  dat$.col_id <- factor(dat$.col_id, levels = x$col_keys)
  setorderv(dat, cols = c(".col_id"))

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
        .row_id = seq_len(nr), height = x[[part]]$rowheights,
        stringsAsFactors = FALSE, check.names = FALSE
      )
    }
  }

  dat <- rbindlist(rows, use.names = TRUE, idcol = ".part")
  dat$.part <- factor(dat$.part, levels = c("header", "body", "footer"))
  setorderv(dat, cols = c(".part", ".row_id"))

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
        .row_id = seq_len(nr), hrule = x[[part]]$hrule,
        stringsAsFactors = FALSE, check.names = FALSE
      )
    }
  }

  dat <- rbindlist(rows, use.names = TRUE, idcol = ".part")
  dat$.part <- factor(dat$.part, levels = c("header", "body", "footer"))
  setorderv(dat, cols = c(".part", ".row_id"))
  setDF(dat)
  dat
}

#' @noRd
#' @title fortify rows and columns spans
#' @description create a data.frame with span information.
fortify_span <- function(x, parts = c("header", "body", "footer")) {
  rows <- list()
  for (part in parts) {
    if (nrow_part(x, part) > 0) {
      nr <- nrow(x[[part]]$spans$rows)
      rows[[part]] <- data.frame(
        .col_id = rep(x$col_keys, each = nr),
        .row_id = rep(seq_len(nr), length(x$col_keys)),
        rowspan = as.vector(x[[part]]$spans$rows),
        colspan = as.vector(x[[part]]$spans$columns),
        stringsAsFactors = FALSE, check.names = FALSE
      )
    }
  }
  dat <- rbindlist(rows, use.names = TRUE, idcol = ".part")
  dat$.part <- factor(dat$.part, levels = c("header", "body", "footer"))
  dat$.col_id <- factor(dat$.col_id, levels = x$col_keys)
  setorderv(dat, cols = c(".part", ".row_id", ".col_id"))

  setDF(dat)

  dat
}


# distinct_properties ----
#' @importFrom data.table setDT
#' @importFrom uuid UUIDgenerate
#' @noRd
distinct_text_properties <- function(x, add_columns = character(length = 0L)) {
  columns <- c(
    "color", "font.size", "bold", "italic", "underlined", "strike", "font.family",
    "hansi.family", "eastasia.family", "cs.family", "vertical.align",
    "shading.color", add_columns
  )
  dat <- as.data.table(x[columns])
  uid <- unique(dat)
  setDF(dat)

  classname <- UUIDgenerate(n = nrow(uid), use.time = TRUE)
  classname <- gsub("(^[[:alnum:]]+)(.*)$", "cl-\\1", classname)
  uid$classname <- classname

  setDF(uid)

  uid
}
distinct_paragraphs_properties <- function(x) {
  # fp_columns <- intersect(names(formals(officer::fp_par)), colnames(x))
  columns <- c(
    "text.align", "line_spacing", "padding.bottom", "padding.top",
    "padding.left", "padding.right", "shading.color", "keep_with_next",
    "border.width.bottom", "border.width.top", "border.width.left",
    "border.width.right", "border.color.bottom", "border.color.top",
    "border.color.left", "border.color.right", "border.style.bottom",
    "border.style.top", "border.style.left", "border.style.right",
    "text.direction", "vertical.align", "tabs", "word_style"
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

distinct_cells_properties <- function(x) {
  # fp_columns <- intersect(names(formals(officer::fp_cell)), colnames(x))
  columns <- c(
    "vertical.align", "margin.bottom", "margin.top", "margin.left",
    "margin.right", "background.color", "text.direction",
    "text.align", "width", "height", "hrule", # workaround for some formats
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

# information data -----
fortify_content <- function(x, default_chunk_fmt, ..., expand_special_chars = TRUE) {
  if (isTRUE(expand_special_chars)) {
    x$data[] <- lapply(x$data, expand_special_char,
      what = "\n", with = "<br>"
    )
    x$data[] <- lapply(x$data, expand_special_char,
      what = "\t", with = "<tab>"
    )
  }

  row_id <- unlist(mapply(
    function(rows, data) {
      rep(rows, nrow(data))
    },
    rows = rep(seq_len(nrow(x$data)), ncol(x$data)),
    x$data, SIMPLIFY = FALSE, USE.NAMES = FALSE
  ))

  .col_id <- unlist(mapply(
    function(columns, data) {
      rep(columns, nrow(data))
    },
    columns = rep(x$keys, each = nrow(x$data)),
    x$data, SIMPLIFY = FALSE, USE.NAMES = FALSE
  ))

  out <- rbindlist(apply(x$data, 2, rbindlist), use.names = TRUE, fill = TRUE)
  out$.row_id <- row_id
  out$.col_id <- .col_id
  setDF(out)

  default_props <- text_struct_to_df(default_chunk_fmt, stringsAsFactors = FALSE)
  out <- replace_missing_fptext_by_default(out, default_props)

  out$.col_id <- factor(out$.col_id, levels = default_chunk_fmt$color$keys)
  out <- out[order(out$.col_id, out$.row_id, out$.chunk_index), ]
  out
}

information_data_default_chunk <- function(x) {
  dat <- list()
  if (nrow_part(x, "header") > 0) {
    dat$header <- text_struct_to_df(x$header$styles[["text"]])
  }
  if (nrow_part(x, "body") > 0) {
    dat$body <- text_struct_to_df(x$body$styles[["text"]])
  }
  if (nrow_part(x, "footer") > 0) {
    dat$footer <- text_struct_to_df(x$footer$styles[["text"]])
  }
  dat <- rbindlist(dat, use.names = TRUE, idcol = ".part")

  dat$.part <- factor(dat$.part, levels = c("header", "body", "footer"))
  dat$.col_id <- factor(dat$.col_id, levels = x$col_keys)
  setorderv(dat, cols = c(".part", ".row_id", ".col_id"))
  setcolorder(dat, neworder = c(".part", ".row_id", ".col_id"))

  setDF(dat)

  dat
}

#' @importFrom data.table rbindlist setDF setcolorder
#' @export
#' @title Get chunk-level content information from a flextable
#' @description
#' This function takes a flextable object and returns a data.frame containing
#' information about each text chunk within the flextable. The data.frame includes
#' details such as the text content, formatting properties, position within the
#' paragraph, paragraph row, and column.
#' @inheritParams args_x_only
#' @section don't use this:
#'
#' These data structures should not be used, as they
#' represent an interpretation of the underlying data
#' structures, which may evolve over time.
#'
#' **They are exported to enable two packages that exploit
#' these structures to make a transition, and should not
#' remain available for long.**
#'
#' @return a data.frame containing information about chunks:
#'
#' - text chunk (column `txt`) and other content (`url`
#' for the linked url, `eq_data` for content of type 'equation',
#' `word_field_data` for content of type 'word_field' and
#' `img_data` for content of type 'image'),
#' - formatting properties,
#' - part (`.part`), position within the paragraph (`.chunk_index`),
#' row (`.row_id`) and column (`.col_id`).
#' @keywords internal
#' @examples
#' ft <- as_flextable(iris)
#' x <- information_data_chunk(ft)
#' head(x)
#' @family information data functions
information_data_chunk <- function(x, expand_special_chars = TRUE) {
  dat <- list()
  if (nrow_part(x, "header") > 0) {
    dat$header <- fortify_content(x$header$content,
      default_chunk_fmt = x$header$styles$text,
      expand_special_chars = expand_special_chars
    )
  }
  if (nrow_part(x, "body") > 0) {
    dat$body <- fortify_content(x$body$content,
      default_chunk_fmt = x$body$styles$text,
      expand_special_chars = expand_special_chars
    )
  }
  if (nrow_part(x, "footer") > 0) {
    dat$footer <- fortify_content(x$footer$content,
      default_chunk_fmt = x$footer$styles$text,
      expand_special_chars = expand_special_chars
    )
  }
  dat <- rbindlist(dat, use.names = TRUE, idcol = ".part")

  dat$.part <- factor(dat$.part, levels = c("header", "body", "footer"))
  dat$.col_id <- factor(dat$.col_id, levels = x$col_keys)
  setorderv(dat, cols = c(".part", ".row_id", ".col_id"))
  setcolorder(dat, neworder = c(".part", ".row_id", ".col_id", ".chunk_index"))

  setDF(dat)
  dat
}


#' @importFrom data.table rbindlist setDF
#' @title Get paragraph-level information from a flextable
#' @description
#' This function takes a flextable object and returns a data.frame containing
#' information about each paragraph within the flextable. The data.frame includes
#' details about formatting properties and position within the
#' row and column.
#' @inheritParams args_x_only
#' @section don't use this:
#'
#' These data structures should not be used, as they
#' represent an interpretation of the underlying data
#' structures, which may evolve over time.
#'
#' **They are exported to enable two packages that exploit
#' these structures to make a transition, and should not
#' remain available for long.**
#'
#' @return a data.frame containing information about paragraphs:
#'
#' - formatting properties,
#' - part (`.part`), row (`.row_id`) and column (`.col_id`).
#' @keywords internal
#' @examples
#' ft <- as_flextable(iris)
#' x <- information_data_paragraph(ft)
#' head(x)
#' @export
#' @family information data functions
information_data_paragraph <- function(x) {
  dat <- list()
  if (nrow_part(x, "header") > 0) {
    dat$header <- par_struct_to_df(x$header$styles[["pars"]])
  }
  if (nrow_part(x, "body") > 0) {
    dat$body <- par_struct_to_df(x$body$styles[["pars"]])
  }
  if (nrow_part(x, "footer") > 0) {
    dat$footer <- par_struct_to_df(x$footer$styles[["pars"]])
  }
  dat <- rbindlist(dat, use.names = TRUE, idcol = ".part")

  dat$.part <- factor(dat$.part, levels = c("header", "body", "footer"))
  dat$.col_id <- factor(dat$.col_id, levels = x$col_keys)
  setorderv(dat, cols = c(".part", ".row_id", ".col_id"))
  setcolorder(dat, neworder = c(".part", ".row_id", ".col_id"))

  setDF(dat)

  dat
}

#' @title Get cell-level information from a flextable
#' @description
#' This function takes a flextable object and returns a data.frame containing
#' information about each cell within the flextable. The data.frame includes
#' details about formatting properties and position within the
#' row and column.
#' @inheritParams args_x_only
#' @section don't use this:
#'
#' These data structures should not be used, as they
#' represent an interpretation of the underlying data
#' structures, which may evolve over time.
#'
#' **They are exported to enable two packages that exploit
#' these structures to make a transition, and should not
#' remain available for long.**
#'
#' @return a data.frame containing information about cells:
#'
#' - formatting properties,
#' - part (`.part`), row (`.row_id`) and column (`.col_id`).
#' @keywords internal
#' @examples
#' ft <- as_flextable(iris)
#' x <- information_data_cell(ft)
#' head(x)
#' @export
#' @family information data functions
information_data_cell <- function(x) {
  dat <- list()
  if (nrow_part(x, "header") > 0) {
    dat$header <- cell_struct_to_df(x$header$styles[["cells"]])
  }
  if (nrow_part(x, "body") > 0) {
    dat$body <- cell_struct_to_df(x$body$styles[["cells"]])
  }
  if (nrow_part(x, "footer") > 0) {
    dat$footer <- cell_struct_to_df(x$footer$styles[["cells"]])
  }
  dat <- rbindlist(dat, use.names = TRUE, idcol = ".part")

  dat$.part <- factor(dat$.part, levels = c("header", "body", "footer"))
  dat$.col_id <- factor(dat$.col_id, levels = x$col_keys)
  setorderv(dat, cols = c(".part", ".row_id", ".col_id"))
  setcolorder(dat, neworder = c(".part", ".row_id", ".col_id"))

  setDF(dat)

  dat
}
