#' @export
#' @title Constrain table width by shrinking font size
#' @description Decrease font size incrementally until the table fits
#' within `max_width`.
#'
#' To constrain width by wrapping text instead, see [fit_columns()].
#' To size columns to their content without a width constraint,
#' see [autofit()].
#' @inheritParams args_x_only
#' @param max_width maximum width to fit in inches
#' @param inc the font size decrease for each step
#' @param max_iter maximum iterations
#' @param unit unit for max_width, one of "in", "cm", "mm".
#' @examples
#' ft_1 <- qflextable(head(mtcars))
#' ft_1 <- width(ft_1, width = 1)
#' ft_1
#'
#' ft_2 <- fit_to_width(ft_1, max_width = 4)
#' ft_2
#' @family functions for flextable size management
fit_to_width <- function(x, max_width, inc = 1L, max_iter = 20, unit = "in") {
  max_width <- convin(unit = unit, x = max_width)

  for (i in seq_len(max_iter)) {
    fdim <- flextable_dim(x)
    do_stop <- FALSE
    if (fdim$widths > max_width) {
      if (nrow_part(x, part = "body") > 0) {
        new_font_sizes <- x$body$styles$text$font.size$data - inc
        if (all(new_font_sizes > 0)) {
          x$body$styles$text$font.size$data[] <- new_font_sizes
        } else {
          do_stop <- TRUE
        }
      }
      if (nrow_part(x, part = "footer") > 0) {
        new_font_sizes <- x$footer$styles$text$font.size$data - inc
        if (all(new_font_sizes > 0)) {
          x$footer$styles$text$font.size$data[] <- new_font_sizes
        } else {
          do_stop <- TRUE
        }
      }
      if (nrow_part(x, part = "header") > 0) {
        new_font_sizes <- x$header$styles$text$font.size$data - inc
        if (all(new_font_sizes > 0)) {
          x$header$styles$text$font.size$data[] <- new_font_sizes
        } else {
          do_stop <- TRUE
        }
      }
      if (do_stop) {
        warning(
          "The function has to be stopped because it results in negative font sizes."
        )
        return(x)
      }
      x <- autofit(x, add_w = 0.0, add_h = 0.0)
    } else {
      return(x)
    }
  }
  x
}


#' @export
#' @title Constrain table width by wrapping text
#' @description Shrink column widths so that the total table width
#' does not exceed `max_width`. Font sizes are unchanged; text wraps
#' inside the narrower cells.
#'
#' Columns that cannot shrink below their longest word (plus padding)
#' are clamped at that floor; remaining space is iteratively
#' redistributed among unclamped columns.
#'
#' Columns listed in `no_wrap` keep their optimal width (as computed
#' by [dim_pretty()]) and are not compressed.
#'
#' To constrain width by reducing font size instead, see
#' [fit_to_width()]. To size columns to their content without a
#' width constraint, see [autofit()].
#' @inheritParams args_x_only
#' @param max_width maximum total table width (in inches by default)
#' @param no_wrap column names or indices that must keep their
#'   optimal width (no compression, no text wrapping).
#' @param unit unit for `max_width`, one of "in", "cm", "mm".
#' @examples
#' ft <- qflextable(head(mtcars))
#' ft <- fit_columns(ft, max_width = 5)
#' flextable_dim(ft)$widths
#' ft
#' @family functions for flextable size management
#' @importFrom rlang %||%
fit_columns <- function(x, max_width, no_wrap = NULL, unit = "in") {
  stopifnot(inherits(x, "flextable"))
  max_width <- convin(unit = unit, x = max_width)

  # compute both optimal and floor widths (single fortify_content per part)
  metrics <- fit_columns_metrics(x)
  pretty_w <- metrics$pretty_w
  floor_w <- metrics$floor_w
  n_col <- length(pretty_w)

  # resolve no_wrap to integer indices
  if (!is.null(no_wrap)) {
    if (is.character(no_wrap)) {
      no_wrap <- match(no_wrap, x$col_keys)
      if (anyNA(no_wrap)) {
        stop(
          "Column(s) not found in flextable: ",
          paste(x$col_keys[is.na(no_wrap)], collapse = ", "),
          call. = FALSE
        )
      }
    }
    no_wrap <- as.integer(no_wrap)
    stopifnot(all(no_wrap >= 1L & no_wrap <= n_col))
  }

  # if already fits, just apply pretty widths and return
  if (sum(pretty_w) <= max_width) {
    x <- width(x, width = pretty_w)
    return(x)
  }

  # protected columns
  protected <- no_wrap %||% integer(0)
  protected_width <- sum(pretty_w[protected])

  if (protected_width >= max_width) {
    warning(
      "Protected (no_wrap) columns already exceed max_width; ",
      "returning the table unchanged.",
      call. = FALSE
    )
    return(x)
  }

  compressible <- setdiff(seq_len(n_col), protected)
  available <- max_width - protected_width

  # Proportional allocation with iterative floor clamping.
  #
  # Columns whose proportional share falls below their floor width
  # (longest word + padding) are fixed at that floor. The remaining
  # space is redistributed proportionally among still-free columns.
  # The loop repeats until no new column is clamped.
  #
  # The loop runs at most length(compressible) iterations (one column
  # clamped per iteration in the worst case), each iteration doing
  # only vector arithmetic (negligible cost).
  comp_pretty <- pretty_w[compressible]
  comp_floor <- floor_w[compressible]
  target <- rep(0, length(compressible))
  free <- rep(TRUE, length(compressible))

  repeat {
    free_pretty <- comp_pretty[free]
    total_free <- sum(free_pretty)
    if (total_free <= 0) {
      break
    }

    remaining <- available - sum(comp_floor[!free])
    target[free] <- free_pretty / total_free * remaining
    target[free] <- pmax(target[free], comp_floor[free])

    newly_clamped <- free & (target == comp_floor)
    if (!any(newly_clamped)) {
      break
    }

    free[newly_clamped] <- FALSE
    if (!any(free)) break
  }

  # warn if floors exceed available space
  if (sum(target) > available) {
    warning(
      "Column floor widths exceed max_width; some text wrapping ",
      "at word boundaries may not be achievable.",
      call. = FALSE
    )
  }

  # assemble les largeurs finales qui sont ensuite utilisee comme largeurs
  final_w <- pretty_w
  final_w[protected] <- pretty_w[protected]
  final_w[compressible] <- target
  x <- width(x, width = final_w)

  x
}


# compute both pretty and floor widths with a single fortify_content per part
#' @importFrom data.table copy
fit_columns_metrics <- function(x) {
  parts <- c("header", "body", "footer")
  all_pretty <- list()
  all_floor <- list()

  for (p in parts) {
    if (nrow_part(x, p) < 1) {
      next
    }
    part_obj <- x[[p]]

    txt_data <- fortify_content(
      x = part_obj$content,
      default_chunk_fmt = part_obj$styles$text
    )

    # --- pretty widths (text_metric + optimal_sizes logic) ---
    pretty_sizes <- .text_metric_from_data(part_obj, copy(txt_data))

    nr <- nrow(part_obj$spans$rows)
    rowspan <- data.frame(
      .col_id = rep(part_obj$col_keys, each = nr),
      .row_id = rep(seq_len(nr), length(part_obj$col_keys)),
      rowspan = as.vector(part_obj$spans$rows),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    pretty_sizes <- merge(pretty_sizes, rowspan, by = c(".col_id", ".row_id"))
    pretty_sizes[pretty_sizes$rowspan != 1, "width"] <- 0

    pretty_sizes$.col_id <- factor(
      pretty_sizes$.col_id,
      levels = part_obj$col_keys
    )
    pretty_sizes <- pretty_sizes[
      order(pretty_sizes$.col_id, pretty_sizes$.row_id),
    ]
    widths_mat <- as_wide_matrix_(
      data = pretty_sizes[, c(".col_id", "width", ".row_id")],
      idvar = ".row_id",
      timevar = ".col_id"
    )
    dimnames(widths_mat)[[2]] <- gsub(
      "^width\\.",
      "",
      dimnames(widths_mat)[[2]]
    )

    par_dim <- dim_paragraphs(part_obj)
    widths_mat <- widths_mat + par_dim$widths

    cell_dim <- dim_cells(part_obj)
    widths_mat <- widths_mat + cell_dim$widths

    all_pretty[[p]] <- apply(widths_mat, 2, max, na.rm = TRUE)

    # --- floor widths (min_col_widths logic) ---
    words <- strsplit(txt_data$txt, "(?<=[- ])", perl = TRUE)
    n_words <- vapply(words, length, integer(1))

    word_txt <- unlist(words, use.names = FALSE)
    word_col <- rep(txt_data$.col_id, n_words)
    word_fname <- rep(txt_data$font.family, n_words)
    word_fsize <- rep(txt_data$font.size, n_words)
    word_bold <- rep(txt_data$bold, n_words)
    word_ital <- rep(txt_data$italic, n_words)

    if (length(word_txt) > 0) {
      word_sizes <- gdtools::strings_sizes(
        word_txt,
        fontname = word_fname,
        fontsize = word_fsize,
        bold = word_bold,
        italic = word_ital
      )
      word_df <- data.frame(
        .col_id = word_col,
        width = word_sizes$width,
        stringsAsFactors = FALSE
      )
      agg <- tapply(word_df$width, word_df$.col_id, max, na.rm = TRUE)
      all_floor[[p]] <- agg
    }
  }

  all_cols <- x$col_keys

  # combine pretty widths across parts
  if (length(all_pretty) > 0) {
    pretty_mat <- do.call(rbind, all_pretty)
    pretty_w <- as.numeric(apply(pretty_mat, 2, max, na.rm = TRUE))
  } else {
    pretty_w <- rep(0, length(all_cols))
  }

  # combine floor widths across parts
  min_text_w <- setNames(rep(0, length(all_cols)), all_cols)
  for (agg in all_floor) {
    matched <- intersect(names(agg), all_cols)
    min_text_w[matched] <- pmax(min_text_w[matched], agg[matched])
  }

  pad_w <- rep(0, length(all_cols))
  names(pad_w) <- all_cols
  cell_w <- pad_w

  for (p in parts) {
    if (nrow_part(x, p) < 1) {
      next
    }
    part_obj <- x[[p]]

    par_dim <- dim_paragraphs(part_obj)
    pad_col <- apply(par_dim$widths, 2, max, na.rm = TRUE)
    pad_col <- setNames(
      as.numeric(pad_col),
      gsub("^width\\.", "", names(pad_col))
    )
    matched <- intersect(names(pad_col), all_cols)
    pad_w[matched] <- pmax(pad_w[matched], pad_col[matched])

    cell_dim <- dim_cells(part_obj)
    cell_col <- apply(cell_dim$widths, 2, max, na.rm = TRUE)
    cell_col <- setNames(
      as.numeric(cell_col),
      gsub("^width\\.", "", names(cell_col))
    )
    matched <- intersect(names(cell_col), all_cols)
    cell_w[matched] <- pmax(cell_w[matched], cell_col[matched])
  }

  floor_w <- as.numeric(min_text_w + pad_w + cell_w)

  list(pretty_w = pretty_w, floor_w = floor_w)
}

# text_metric logic accepting pre-computed txt_data
.text_metric_from_data <- function(x, txt_data) {
  widths <- txt_data$width
  heights <- txt_data$height

  setDT(txt_data)

  txt_data[, c("width", "height") := list(NULL, NULL)]

  txt_data[,
    c("fake_row_id") := list(
      fcase(
        .SD$txt %in% "<br>" , 1L ,
        default = 0L
      )
    )
  ]
  txt_data[,
    c("fake_row_id") := list(
      cumsum(.SD$fake_row_id)
    ),
    by = c(".row_id", ".col_id")
  ]
  txt_data[,
    c("fake_row_id") := list(
      rleid(.SD$fake_row_id)
    ),
    by = c(".row_id", ".col_id")
  ]

  txt_data$txt[txt_data$txt %in% "<br>"] <- ""
  txt_data$txt[txt_data$txt %in% "<tab>"] <- "mmmm"

  # line_spacing per cell for minimum line height
  ls_data <- par_struct_to_df(x$styles$pars)[, c(".row_id", ".col_id")]
  ls_data$line_spacing <- as.vector(x$styles$pars[["line_spacing"]]$data)
  txt_data <- merge(txt_data, ls_data, by = c(".row_id", ".col_id"))

  fontsize <- txt_data$font.size
  not_baseline <- !(txt_data$vertical.align %in% "baseline")
  fontsize[not_baseline] <- fontsize[not_baseline] / 2

  extents_values <- gdtools::strings_sizes(
    txt_data$txt,
    fontname = txt_data$font.family,
    fontsize = fontsize,
    bold = txt_data$bold,
    italic = txt_data$italic
  )
  glyph_height <- extents_values$ascent + extents_values$descent
  line_height <- fontsize * txt_data$line_spacing * 1.2 / 72
  extents_values$height <- pmax(glyph_height, line_height, 0, na.rm = TRUE)
  extents_values$ascent <- NULL
  extents_values$descent <- NULL
  colnames(extents_values) <- c("width", "height")

  extents_values$width <- ifelse(
    !is.na(widths),
    widths,
    extents_values$width
  )
  extents_values$height <- ifelse(
    !is.na(heights),
    heights,
    extents_values$height
  )

  txt_data <- cbind(txt_data, extents_values)

  td_data <- cell_struct_to_df(x$styles$cells)[, c(
    ".row_id",
    ".col_id",
    "text.direction"
  )]
  txt_data <- merge(txt_data, td_data, by = c(".row_id", ".col_id"))
  txt_data[
    txt_data$text.direction %in% c("tbrl", "btlr"),
    c("width", "height") := list(.SD$height, .SD$width)
  ]

  txt_data <- txt_data[,
    c(list(
      width = sum(.SD$width, na.rm = TRUE),
      height = max(.SD$height, na.rm = TRUE)
    )),
    by = c(".row_id", "fake_row_id", ".col_id")
  ]
  txt_data <- txt_data[,
    c(list(
      width = max(.SD$width, na.rm = TRUE),
      height = sum(.SD$height, na.rm = TRUE)
    )),
    by = c(".row_id", ".col_id")
  ]
  setDF(txt_data)
  txt_data
}


# minimum column widths: longest word per column + padding + margins
min_col_widths <- function(x) {
  parts <- c("header", "body", "footer")
  all_min_w <- list()

  for (p in parts) {
    if (nrow_part(x, p) < 1) {
      next
    }

    part_obj <- x[[p]]

    txt_data <- fortify_content(
      x = part_obj$content,
      default_chunk_fmt = part_obj$styles$text
    )

    # split text into words at spaces and hyphens (keep delimiter)
    words <- strsplit(txt_data$txt, "(?<=[- ])", perl = TRUE)
    n_words <- vapply(words, length, integer(1))

    word_txt <- unlist(words, use.names = FALSE)
    word_col <- rep(txt_data$.col_id, n_words)
    word_fname <- rep(txt_data$font.family, n_words)
    word_fsize <- rep(txt_data$font.size, n_words)
    word_bold <- rep(txt_data$bold, n_words)
    word_ital <- rep(txt_data$italic, n_words)

    if (length(word_txt) == 0) {
      next
    }

    # measure each word
    word_sizes <- gdtools::strings_sizes(
      word_txt,
      fontname = word_fname,
      fontsize = word_fsize,
      bold = word_bold,
      italic = word_ital
    )

    # max word width per column
    word_df <- data.frame(
      .col_id = word_col,
      width = word_sizes$width,
      stringsAsFactors = FALSE
    )
    agg <- tapply(word_df$width, word_df$.col_id, max, na.rm = TRUE)
    all_min_w[[p]] <- agg
  }

  if (length(all_min_w) == 0) {
    return(rep(0, length(x$col_keys)))
  }

  # combine across parts: max per column
  all_cols <- x$col_keys
  min_text_w <- setNames(rep(0, length(all_cols)), all_cols)
  for (agg in all_min_w) {
    matched <- intersect(names(agg), all_cols)
    min_text_w[matched] <- pmax(min_text_w[matched], agg[matched])
  }

  # add padding and margins (take max across rows per column)
  pad_w <- rep(0, length(all_cols))
  names(pad_w) <- all_cols
  cell_w <- pad_w

  for (p in parts) {
    if (nrow_part(x, p) < 1) {
      next
    }
    part_obj <- x[[p]]

    par_dim <- dim_paragraphs(part_obj)
    pad_col <- apply(par_dim$widths, 2, max, na.rm = TRUE)
    pad_col <- setNames(
      as.numeric(pad_col),
      gsub("^width\\.", "", names(pad_col))
    )
    matched <- intersect(names(pad_col), all_cols)
    pad_w[matched] <- pmax(pad_w[matched], pad_col[matched])

    cell_dim <- dim_cells(part_obj)
    cell_col <- apply(cell_dim$widths, 2, max, na.rm = TRUE)
    cell_col <- setNames(
      as.numeric(cell_col),
      gsub("^width\\.", "", names(cell_col))
    )
    matched <- intersect(names(cell_col), all_cols)
    cell_w[matched] <- pmax(cell_w[matched], cell_col[matched])
  }

  as.numeric(min_text_w + pad_w + cell_w)
}


#' @export
#' @title Set columns width
#' @description Defines the widths of one or more columns in the
#' table. This function will have no effect if you have
#' used `set_table_properties(layout = "autofit")`.
#'
#' [set_table_properties()] can provide an alternative to fixed-width layouts
#' that is supported with HTML and Word output that can be set
#' with `set_table_properties(layout = "autofit")`.
#'
#'
#' @inheritParams args_x_j
#' @param width width in inches
#' @param unit unit for width, one of "in", "cm", "mm".
#' @details
#' Heights are not used when flextable is been rendered into HTML.
#' @examples
#'
#' ft <- flextable(head(iris))
#' ft <- width(ft, width = 1.5)
#' ft
#' @family functions for flextable size management
width <- function(x, j = NULL, width, unit = "in") {
  width <- convin(unit = unit, x = width)
  j <- get_columns_id(x[["body"]], j)

  stopifnot(length(j) == length(width) || length(width) == 1)

  if (length(width) == 1) {
    width <- rep(width, length(j))
  }

  x$header$colwidths[j] <- width
  x$footer$colwidths[j] <- width
  x$body$colwidths[j] <- width

  x
}

#' @export
#' @title Set flextable rows height
#' @description control rows height for a part of the flextable when the line
#' height adjustment is "atleast" or "exact" (see [hrule()]).
#' @note
#' This function has no effect when the rule for line height is set to
#' "auto" (see [hrule()]), which is the default case, except with PowerPoint
#' which does not support this automatic line height adjustment feature.
#' @inheritParams args_x_i_part_no_all
#' @param height height in inches
#' @param unit unit for height, one of "in", "cm", "mm".
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- height(ft_1, height = .5)
#' ft_1 <- hrule(ft_1, rule = "exact")
#' ft_1
#' @family functions for flextable size management
height <- function(x, i = NULL, height, part = "body", unit = "in") {
  height <- convin(unit = unit, x = height)

  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE)

  if (inherits(i, "formula") && any(c("header", "footer") %in% part)) {
    stop("formula in argument i cannot adress part 'header' or 'footer'.")
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  i <- get_rows_id(x[[part]], i)
  if (!(length(i) == length(height) || length(height) == 1)) {
    stop(sprintf("height should be of length 1 or %.0f.", length(i)))
  }

  x[[part]]$rowheights[i] <- height

  x
}

#' @export
#' @title Set how row heights are determined
#' @description
#' `hrule()` controls whether row heights are automatic,
#' minimum or fixed. This only affects Word and PowerPoint
#' outputs; it has no effect on HTML or PDF.
#'
#' * `"auto"` (default): the row height adjusts to fit the
#'   content; any value set by [height()] is ignored.
#' * `"atleast"`: the row is at least as tall as the value
#'   set by [height()], but can grow if the content is taller.
#' * `"exact"`: the row is exactly the height set by
#'   [height()]; content that overflows is clipped.
#'
#' For PDF see the `ft.arraystretch` chunk option.
#' @inheritParams args_x_i_part
#' @param rule specify the meaning of the height. Possible values
#' are "atleast" (height should be at least the value specified), "exact"
#' (height should be exactly the value specified), or the default value "auto"
#' (height is determined based on the height of the contents, so the value is ignored).
#' @examples
#'
#' ft_1 <- flextable(head(iris))
#' ft_1 <- width(ft_1, width = 1.5)
#' ft_1 <- height(ft_1, height = 0.75, part = "header")
#' ft_1 <- hrule(ft_1, rule = "exact", part = "header")
#' ft_1
#'
#' ft_2 <- hrule(ft_1, rule = "auto", part = "header")
#' ft_2
#' @family functions for flextable size management
hrule <- function(x, i = NULL, rule = "auto", part = "body") {
  part <- match.arg(
    part,
    c("body", "header", "footer", "all"),
    several.ok = FALSE
  )

  if ("all" %in% part) {
    for (i in c("body", "header", "footer")) {
      x <- hrule(x, rule = rule, part = i)
    }
    return(x)
  }

  if (inherits(i, "formula") && any(c("header", "footer") %in% part)) {
    stop("formula in argument i cannot adress part 'header' or 'footer'.")
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  i <- get_rows_id(x[[part]], i)
  if (!(length(i) == length(height) || length(height) == 1)) {
    stop(sprintf("height should be of length 1 or %.0f.", length(i)))
  }

  x[[part]]$hrule[i] <- rule
  x
}


#' @export
#' @rdname height
#' @section height_all:
#' `height_all` is a convenient function for
#' setting the same height to all rows (selected
#' with argument `part`).
#' @examples
#'
#'
#' ft_2 <- flextable(head(iris))
#' ft_2 <- height_all(ft_2, height = 1)
#' ft_2 <- hrule(ft_2, rule = "exact")
#' ft_2
height_all <- function(x, height, part = "all", unit = "in") {
  height <- convin(unit = unit, x = height)

  part <- match.arg(
    part,
    c("body", "header", "footer", "all"),
    several.ok = FALSE
  )
  if (length(height) != 1 || !is.numeric(height) || height < 0.0) {
    stop("height should be a single positive numeric value", call. = FALSE)
  }

  if ("all" %in% part) {
    for (i in c("body", "header", "footer")) {
      x <- height_all(x, height = height, part = i)
    }
  }

  if (nrow_part(x, part) > 0) {
    i <- seq_len(nrow(x[[part]]$dataset))
    x[[part]]$rowheights[i] <- height
  }

  x
}

#' @export
#' @title Get overall width and height of a flextable
#' @description Returns the width, height and
#' aspect ratio of a flextable in a named list.
#' The aspect ratio is the ratio corresponding to `height/width`.
#'
#' Names of the list are `widths`, `heights` and `aspect_ratio`.
#' @inheritParams args_x_only
#' @param unit unit for returned values, one of "in", "cm", "mm".
#' @examples
#' ftab <- flextable(head(iris))
#' flextable_dim(ftab)
#' ftab <- autofit(ftab)
#' flextable_dim(ftab)
#' @family functions for flextable size management
flextable_dim <- function(x, unit = "in") {
  dims <- lapply(dim(x), function(x) convin(unit = unit, x = sum(x)))
  dims$aspect_ratio <- dims$heights / dims$widths
  dims
}


#' @title Get column widths and row heights of a flextable
#' @description returns widths and heights for each table columns and rows.
#' Values are expressed in inches.
#' @inheritParams args_x_only
#' @family functions for flextable size management
#' @examples
#' ftab <- flextable(head(iris))
#' dim(ftab)
#' @export
dim.flextable <- function(x) {
  max_widths <- list()
  max_heights <- list()
  for (j in c("header", "body", "footer")) {
    if (nrow_part(x, j) > 0) {
      max_widths[[j]] <- x[[j]]$colwidths
      max_heights[[j]] <- x[[j]]$rowheights
    }
  }

  mat_widths <- do.call("rbind", max_widths)
  if (is.null(mat_widths)) {
    out_widths <- numeric(0)
  } else {
    out_widths <- apply(mat_widths, 2, max)
    names(out_widths) <- x$col_keys
  }

  out_heights <- as.double(unlist(max_heights))
  list(widths = out_widths, heights = out_heights)
}

#' @export
#' @title Calculate optimal column widths and row heights
#' @description return minimum estimated widths and heights for
#' each table columns and rows in inches.
#' @inheritParams args_x_part
#' @param unit unit for returned values, one of "in", "cm", "mm".
#' @param hspans specifies how cells that are horizontally are included in the calculation.
#' It must be one of the following values "none", "divided" or "included". If
#' "none", widths of horizontally spanned cells is set to 0 (then do not affect the
#' widths); if "divided", widths of horizontally spanned cells is divided by
#' the number of spanned cells; if "included", all widths (included horizontally
#' spanned cells) will be used in the calculation.
#' @examples
#' ftab <- flextable(head(mtcars))
#' dim_pretty(ftab)
#' @family functions for flextable size management
dim_pretty <- function(x, part = "all", unit = "in", hspans = "none") {
  stopifnot(length(hspans) == 1, hspans %in% c("none", "divided", "included"))

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = TRUE
  )
  if ("all" %in% part) {
    part <- c("header", "body", "footer")
  }
  dimensions <- list()
  for (j in part) {
    if (nrow_part(x, j) > 0) {
      dimensions[[j]] <- optimal_sizes(x[[j]], hspans = hspans)
    } else {
      dimensions[[j]] <- list(
        widths = rep(0, length(x$col_keys)),
        heights = numeric(0)
      )
    }
  }
  widths <- lapply(dimensions, function(x) x$widths)
  widths <- as.numeric(apply(do.call(rbind, widths), 2, max, na.rm = TRUE))

  heights <- lapply(dimensions, function(x) x$heights)
  heights <- as.numeric(do.call(c, heights))

  list(
    widths = convmeters(unit = unit, x = widths),
    heights = convmeters(unit = unit, x = heights)
  )
}


#' @export
#' @title Adjust columns to their content size
#' @description Compute and apply the minimum widths and heights needed
#' to display each cell's content on a single line, with an optional
#' extra margin (`add_w`, `add_h`).
#'
#' This function sizes columns to fit their content. It does not
#' constrain the table to a given total width. To enforce a maximum
#' width, use [fit_columns()] (wraps text) or [fit_to_width()]
#' (shrinks font size).
#'
#' Note that this function is not related to 'Microsoft Word'
#' *Autofit* feature.
#'
#' There is an alternative to fixed-width layouts that works
#' well with HTML and Word output that can be set
#' with `set_table_properties(layout = "autofit")`, see
#' [set_table_properties()].
#' @inheritParams args_x_part
#' @param add_w extra width to add in inches
#' @param add_h extra height to add in inches
#' @param unit unit for add_h and add_w, one of "in", "cm", "mm".
#' @param hspans specifies how cells that are horizontally are included in the calculation.
#' It must be one of the following values "none", "divided" or "included". If
#' "none", widths of horizontally spanned cells is set to 0 (then do not affect the
#' widths); if "divided", widths of horizontally spanned cells is divided by
#' the number of spanned cells; if "included", all widths (included horizontally
#' spanned cells) will be used in the calculation.
#' @examples
#' ft_1 <- flextable(head(mtcars))
#' ft_1
#' ft_2 <- autofit(ft_1)
#' ft_2
#' @family functions for flextable size management
autofit <- function(
  x,
  add_w = 0.1,
  add_h = 0.1,
  part = c("body", "header"),
  unit = "in",
  hspans = "none"
) {
  add_w <- convin(unit = unit, x = add_w)
  add_h <- convin(unit = unit, x = add_h)

  stopifnot(inherits(x, "flextable"))
  stopifnot(length(hspans) == 1, hspans %in% c("none", "divided", "included"))

  parts <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = TRUE
  )
  if ("all" %in% parts) {
    parts <- c("header", "body", "footer")
  }

  dimensions_ <- dim_pretty(x, part = parts, hspans = hspans)
  names(dimensions_$widths) <- x$col_keys

  nrows <- lapply(parts, function(j) {
    nrow_part(x, j)
  })
  heights <- list(lengths = unlist(nrows), values = parts)
  class(heights) <- "rle"
  heights <- data.frame(
    part = inverse.rle(heights),
    height = dimensions_$heights + add_h,
    stringsAsFactors = FALSE
  )
  heights <- split(heights$height, heights$part)

  for (j in names(heights)) {
    x[[j]]$colwidths <- dimensions_$widths + add_w
    x[[j]]$rowheights <- heights[[j]]
  }
  x
}


#' @importFrom gdtools strings_sizes
optimal_sizes <- function(x, hspans = "none") {
  sizes <- text_metric(x)

  nr <- nrow(x$spans$rows)
  rowspan <- data.frame(
    .col_id = rep(x$col_keys, each = nr),
    .row_id = rep(seq_len(nr), length(x$col_keys)),
    rowspan = as.vector(x$spans$rows),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  sizes <- merge(sizes, rowspan, by = c(".col_id", ".row_id"))

  if (hspans %in% "none") {
    sizes[sizes$rowspan != 1, "width"] <- 0
  } else if (hspans %in% "divided") {
    sizes[sizes$rowspan > 1, "width"] <- sizes[sizes$rowspan > 1, "width"] /
      sizes[sizes$rowspan > 1, "rowspan"]
    sizes[sizes$rowspan < 1, "width"] <- 0
  }

  sizes$.col_id <- factor(sizes$.col_id, levels = x$col_keys)
  sizes <- sizes[order(sizes$.col_id, sizes$.row_id), ]
  widths <- as_wide_matrix_(
    data = sizes[, c(".col_id", "width", ".row_id")],
    idvar = ".row_id",
    timevar = ".col_id"
  )
  dimnames(widths)[[2]] <- gsub("^width\\.", "", dimnames(widths)[[2]])
  heights <- as_wide_matrix_(
    data = sizes[, c(".col_id", "height", ".row_id")],
    idvar = ".row_id",
    timevar = ".col_id"
  )
  dimnames(heights)[[2]] <- gsub("^height\\.", "", dimnames(heights)[[2]])

  par_dim <- dim_paragraphs(x)
  widths <- widths + par_dim$widths
  heights <- heights + par_dim$heights

  cell_dim <- dim_cells(x)
  widths <- widths + cell_dim$widths
  heights <- heights + cell_dim$heights

  list(
    widths = apply(widths, 2, max, na.rm = TRUE),
    heights = apply(heights, 1, max, na.rm = TRUE)
  )
}


# utils ----
#' @importFrom stats reshape
as_wide_matrix_ <- function(data, idvar, timevar = "col_key") {
  x <- reshape(
    data = data,
    idvar = idvar,
    timevar = timevar,
    direction = "wide"
  )
  x[[idvar]] <- NULL
  as.matrix(x)
}


dim_paragraphs <- function(x) {
  par_dim <- par_struct_to_df(x$styles$pars)

  par_dim$width <- as.vector(
    x$styles$pars[["padding.right"]]$data +
      x$styles$pars[["padding.left"]]$data
  ) *
    (4 / 3) /
    72
  par_dim$height <- as.vector(
    x$styles$pars[["padding.top"]]$data +
      x$styles$pars[["padding.bottom"]]$data
  ) /
    72

  selection_ <- c(".row_id", ".col_id", "width", "height")
  par_dim[, selection_]

  list(
    widths = as_wide_matrix_(
      par_dim[, c(".col_id", "width", ".row_id")],
      idvar = ".row_id",
      timevar = ".col_id"
    ),
    heights = as_wide_matrix_(
      par_dim[, c(".col_id", "height", ".row_id")],
      idvar = ".row_id",
      timevar = ".col_id"
    )
  )
}

dim_cells <- function(x) {
  cell_dim <- cell_struct_to_df(x$styles$cells)
  cell_dim$width <- as.vector(
    x$styles$cells[["margin.right"]]$data + x$styles$cells[["margin.left"]]$data
  ) *
    (4 / 3) /
    72
  cell_dim$height <- as.vector(
    x$styles$cells[["margin.top"]]$data + x$styles$cells[["margin.bottom"]]$data
  ) /
    72 +
    as.vector(
      x$styles$cells[["border.width.top"]]$data +
        x$styles$cells[["border.width.bottom"]]$data
    ) /
      2 /
      72
  selection_ <- c(".row_id", ".col_id", "width", "height")
  cell_dim <- cell_dim[, selection_]

  cellwidths <- as_wide_matrix_(
    cell_dim[, c(".col_id", "width", ".row_id")],
    idvar = ".row_id",
    timevar = ".col_id"
  )
  cellheights <- as_wide_matrix_(
    cell_dim[, c(".col_id", "height", ".row_id")],
    idvar = ".row_id",
    timevar = ".col_id"
  )

  list(widths = cellwidths, heights = cellheights)
}


text_metric <- function(x) {
  txt_data <- fortify_content(
    x = x$content,
    default_chunk_fmt = x$styles$text
  )

  widths <- txt_data$width
  heights <- txt_data$height

  setDT(txt_data)

  txt_data[, c("width", "height") := list(NULL, NULL)]

  # build a fake_row_id so that new lines are considered
  txt_data[,
    c("fake_row_id") := list(
      fcase(
        .SD$txt %in% "<br>" , 1L ,
        default = 0L
      )
    )
  ]
  txt_data[,
    c("fake_row_id") := list(
      cumsum(.SD$fake_row_id)
    ),
    by = c(".row_id", ".col_id")
  ]
  txt_data[,
    c("fake_row_id") := list(
      rleid(.SD$fake_row_id)
    ),
    by = c(".row_id", ".col_id")
  ]

  # set new lines to blank
  txt_data$txt[txt_data$txt %in% "<br>"] <- ""
  # set tabs to 4 'm'
  txt_data$txt[txt_data$txt %in% "<tab>"] <- "mmmm"

  # line_spacing per cell for minimum line height
  ls_data <- par_struct_to_df(x$styles$pars)[, c(".row_id", ".col_id")]
  ls_data$line_spacing <- as.vector(x$styles$pars[["line_spacing"]]$data)
  txt_data <- merge(txt_data, ls_data, by = c(".row_id", ".col_id"))

  fontsize <- txt_data$font.size
  not_baseline <- !(txt_data$vertical.align %in% "baseline")
  fontsize[not_baseline] <- fontsize[not_baseline] / 2

  extents_values <- gdtools::strings_sizes(
    txt_data$txt,
    fontname = txt_data$font.family,
    fontsize = fontsize,
    bold = txt_data$bold,
    italic = txt_data$italic
  )
  glyph_height <- extents_values$ascent + extents_values$descent
  line_height <- fontsize * txt_data$line_spacing * 1.2 / 72
  extents_values$height <- pmax(glyph_height, line_height, 0, na.rm = TRUE)
  extents_values$ascent <- NULL
  extents_values$descent <- NULL
  colnames(extents_values) <- c("width", "height")

  extents_values$width <- ifelse(
    !is.na(widths),
    widths,
    extents_values$width
  )
  extents_values$height <- ifelse(
    !is.na(heights),
    heights,
    extents_values$height
  )

  txt_data <- cbind(txt_data, extents_values)

  # swap width/height when cell is rotated
  td_data <- cell_struct_to_df(x$styles$cells)[, c(
    ".row_id",
    ".col_id",
    "text.direction"
  )]
  txt_data <- merge(txt_data, td_data, by = c(".row_id", ".col_id"))
  txt_data[
    txt_data$text.direction %in% c("tbrl", "btlr"),
    c("width", "height") := list(.SD$height, .SD$width)
  ]

  txt_data <- txt_data[,
    c(list(
      width = sum(.SD$width, na.rm = TRUE),
      height = max(.SD$height, na.rm = TRUE)
    )),
    by = c(".row_id", "fake_row_id", ".col_id")
  ]
  txt_data <- txt_data[,
    c(list(
      width = max(.SD$width, na.rm = TRUE),
      height = sum(.SD$height, na.rm = TRUE)
    )),
    by = c(".row_id", ".col_id")
  ]
  setDF(txt_data)
  txt_data
}
