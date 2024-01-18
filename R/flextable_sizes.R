#' @export
#' @title Fit a flextable to a maximum width
#' @description decrease font size for each cell incrementally until
#' it fits a given max_width.
#' @param x flextable object
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
#' @family flextable dimensions
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
        warning("The function has to be stopped because it results in negative font sizes.")
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
#' @param x a [flextable()] object
#' @param j columns selection
#' @param width width in inches
#' @param unit unit for width, one of "in", "cm", "mm".
#' @details
#' Heights are not used when flextable is been rendered into HTML.
#' @examples
#'
#' ft <- flextable(head(iris))
#' ft <- width(ft, width = 1.5)
#' ft
#' @family flextable dimensions
width <- function(x, j = NULL, width, unit = "in") {
  width <- convin(unit = unit, x = width)
  j <- get_columns_id(x[["body"]], j)

  stopifnot(length(j) == length(width) || length(width) == 1)

  if (length(width) == 1) width <- rep(width, length(j))

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
#' @param x flextable object
#' @param i rows selection
#' @param height height in inches
#' @param unit unit for height, one of "in", "cm", "mm".
#' @param part partname of the table
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- height(ft_1, height = .5)
#' ft_1 <- hrule(ft_1, rule = "exact")
#' ft_1
#' @family flextable dimensions
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
#' @title Set flextable rule for rows heights
#' @description control rules of each height for a part
#' of the flextable, this is only for Word and PowerPoint outputs, it
#' will not have any effect when output is HTML or PDF.
#'
#' For PDF see the `ft.arraystretch` chunk option.
#' @param x flextable object
#' @param i rows selection
#' @param rule specify the meaning of the height. Possible values
#' are "atleast" (height should be at least the value specified), "exact"
#' (height should be exactly the value specified), or the default value "auto"
#' (height is determined based on the height of the contents, so the value is ignored).
#' @param part partname of the table, one of "all", "header", "body", "footer"
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
#' @family flextable dimensions
hrule <- function(x, i = NULL, rule = "auto", part = "body") {
  part <- match.arg(part, c("body", "header", "footer", "all"), several.ok = FALSE)

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

  part <- match.arg(part, c("body", "header", "footer", "all"), several.ok = FALSE)
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
#' @title Get width and height of a flextable object
#' @description Returns the width, height and
#' aspect ratio of a flextable in a named list.
#' The aspect ratio is the ratio corresponding to `height/width`.
#'
#' Names of the list are `widths`, `heights` and `aspect_ratio`.
#' @param x a flextable object
#' @param unit unit for returned values, one of "in", "cm", "mm".
#' @examples
#' ftab <- flextable(head(iris))
#' flextable_dim(ftab)
#' ftab <- autofit(ftab)
#' flextable_dim(ftab)
#' @family flextable dimensions
flextable_dim <- function(x, unit = "in") {
  dims <- lapply(dim(x), function(x) convin(unit = unit, x = sum(x)))
  dims$aspect_ratio <- dims$heights / dims$widths
  dims
}


#' @title Get widths and heights of flextable
#' @description returns widths and heights for each table columns and rows.
#' Values are expressed in inches.
#' @param x flextable object
#' @family flextable dimensions
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
#' @title Calculate pretty dimensions
#' @description return minimum estimated widths and heights for
#' each table columns and rows in inches.
#' @param x flextable object
#' @param part partname of the table (one of 'all', 'body', 'header' or 'footer')
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
#' @family flextable dimensions
dim_pretty <- function(x, part = "all", unit = "in", hspans = "none") {
  stopifnot(length(hspans) == 1, hspans %in% c("none", "divided", "included"))

  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = TRUE)
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

  list(widths = convmeters(unit = unit, x = widths), heights = convmeters(unit = unit, x = heights))
}



#' @export
#' @title Adjusts cell widths and heights
#' @description compute and apply optimized widths and heights
#' (minimum estimated widths and heights for each table columns and rows
#' in inches returned by function [dim_pretty()]).
#'
#' This function is to be used when the table widths and heights
#' should be adjusted to fit the size of the content.
#'
#' The function does not let you adjust a content that is too
#' wide in a paginated document. It simply calculates the width
#' of the columns so that each content has the minimum width
#' necessary to display the content on one line.
#'
#' Note that this function is not related to 'Microsoft Word'
#' *Autofit* feature.
#'
#' There is an alternative to fixed-width layouts that works
#' well with HTML and Word output that can be set
#' with `set_table_properties(layout = "autofit")`, see
#' [set_table_properties()].
#' @param x flextable object
#' @param add_w extra width to add in inches
#' @param add_h extra height to add in inches
#' @param unit unit for add_h and add_w, one of "in", "cm", "mm".
#' @param part partname of the table (one of 'all', 'body', 'header' or 'footer')
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
#' @family flextable dimensions
autofit <- function(x, add_w = 0.1, add_h = 0.1, part = c("body", "header"),
                    unit = "in", hspans = "none") {
  add_w <- convin(unit = unit, x = add_w)
  add_h <- convin(unit = unit, x = add_h)

  stopifnot(inherits(x, "flextable"))
  stopifnot(length(hspans) == 1, hspans %in% c("none", "divided", "included"))

  parts <- match.arg(part, c("all", "body", "header", "footer"), several.ok = TRUE)
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




#' @importFrom gdtools m_str_extents
optimal_sizes <- function(x, hspans = "none") {
  sizes <- text_metric(x)

  nr <- nrow(x$spans$rows)
  rowspan <- data.frame(
    col_id = rep(x$col_keys, each = nr),
    ft_row_id = rep(seq_len(nr), length(x$col_keys)),
    rowspan = as.vector(x$spans$rows),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  sizes <- merge(sizes, rowspan, by = c("col_id", "ft_row_id"))

  if (hspans %in% "none") {
    sizes[sizes$rowspan != 1, "width"] <- 0
  } else if (hspans %in% "divided") {
    sizes[sizes$rowspan > 1, "width"] <- sizes[sizes$rowspan > 1, "width"] / sizes[sizes$rowspan > 1, "rowspan"]
    sizes[sizes$rowspan < 1, "width"] <- 0
  }

  sizes$col_id <- factor(sizes$col_id, levels = x$col_keys)
  sizes <- sizes[order(sizes$col_id, sizes$ft_row_id), ]
  widths <- as_wide_matrix_(data = sizes[, c("col_id", "width", "ft_row_id")], idvar = "ft_row_id", timevar = "col_id")
  dimnames(widths)[[2]] <- gsub("^width\\.", "", dimnames(widths)[[2]])
  heights <- as_wide_matrix_(data = sizes[, c("col_id", "height", "ft_row_id")], idvar = "ft_row_id", timevar = "col_id")
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
  x <- reshape(data = data, idvar = idvar, timevar = timevar, direction = "wide")
  x[[idvar]] <- NULL
  as.matrix(x)
}


dim_paragraphs <- function(x) {
  par_dim <- par_struct_to_df(x$styles$pars)
  par_dim$width <- as.vector(x$styles$pars[, , "padding.right"] + x$styles$pars[, , "padding.left"]) * (4 / 3) / 72
  par_dim$height <- as.vector(x$styles$pars[, , "padding.top"] + x$styles$pars[, , "padding.bottom"]) * (4 / 3) / 72
  selection_ <- c("ft_row_id", "col_id", "width", "height")
  par_dim[, selection_]

  list(
    widths = as_wide_matrix_(par_dim[, c("col_id", "width", "ft_row_id")], idvar = "ft_row_id", timevar = "col_id"),
    heights = as_wide_matrix_(par_dim[, c("col_id", "height", "ft_row_id")], idvar = "ft_row_id", timevar = "col_id")
  )
}

dim_cells <- function(x) {
  cell_dim <- cell_struct_to_df(x$styles$cells)
  cell_dim$width <- as.vector(x$styles$cells[, , "margin.right"] + x$styles$cells[, , "margin.left"]) * (4 / 3) / 72
  cell_dim$height <- as.vector(x$styles$cells[, , "margin.top"] + x$styles$cells[, , "margin.bottom"]) * (4 / 3) / 72
  selection_ <- c("ft_row_id", "col_id", "width", "height")
  cell_dim <- cell_dim[, selection_]

  cellwidths <- as_wide_matrix_(cell_dim[, c("col_id", "width", "ft_row_id")], idvar = "ft_row_id", timevar = "col_id")
  cellheights <- as_wide_matrix_(cell_dim[, c("col_id", "height", "ft_row_id")], idvar = "ft_row_id", timevar = "col_id")

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
  txt_data[, c("fake_row_id") := list(
    fcase(.SD$txt %in% "<br>", 1L, default = 0L)
  )]
  txt_data[, c("fake_row_id") := list(
    cumsum(.SD$fake_row_id)
  ), by = c("ft_row_id", "col_id")]
  txt_data[, c("fake_row_id") := list(
    rleid(.SD$fake_row_id)
  ), by = c("ft_row_id", "col_id")]


  # set new lines to blank
  txt_data$txt[txt_data$txt %in% "<br>"] <- ""
  # set tabs to 4 'm'
  txt_data$txt[txt_data$txt %in% "<tab>"] <- "mmmm"

  fontsize <- txt_data$font.size
  not_baseline <- !(txt_data$vertical.align %in% "baseline")
  fontsize[not_baseline] <- fontsize[not_baseline] / 2

  extents_values <- m_str_extents(
    txt_data$txt,
    fontname = txt_data$font.family,
    fontsize = fontsize,
    bold = txt_data$bold,
    italic = txt_data$italic
  ) / 72

  extents_values[, 1] <- ifelse(
    is.na(extents_values[, 1]) & !is.null(widths),
    widths, extents_values[, 1]
  )
  extents_values[, 2] <- ifelse(
    is.na(extents_values[, 2]) & !is.null(heights),
    heights, extents_values[, 2]
  )
  dimnames(extents_values) <- list(NULL, c("width", "height"))

  txt_data <- cbind(txt_data, extents_values)

  # swap width/height when cell is rotated
  td_data <- cell_struct_to_df(x$styles$cells)[, c("ft_row_id", "col_id", "text.direction")]
  txt_data <- merge(txt_data, td_data, by = c("ft_row_id", "col_id"))
  txt_data[txt_data$text.direction %in% c("tbrl", "btlr"), c("width", "height") := list(.SD$height, .SD$width)]

  txt_data <- txt_data[, c(list(width = sum(.SD$width, na.rm = TRUE), height = max(.SD$height, na.rm = TRUE))),
    by = c("ft_row_id", "fake_row_id", "col_id")
  ]
  txt_data <- txt_data[, c(list(width = max(.SD$width, na.rm = TRUE), height = sum(.SD$height, na.rm = TRUE))),
    by = c("ft_row_id", "col_id")
  ]
  setDF(txt_data)
  txt_data
}
