#' @title Split a flextable into pages by columns
#'
#' @description Split a flextable into a list of flextables whose columns
#' fit within a given width (in inches). This is useful for paginating
#' wide tables in Word or PowerPoint output.
#'
#' @inheritParams args_x_only
#' @param max_width Maximum width for each page (in inches by default).
#' @param rep_cols Columns to repeat on every page. Can be a character
#'   vector of column names or an integer vector of column positions.
#'   `NULL` (default) means no repetition. Repeated columns appear at
#'   the beginning of each page in the order specified.
#' @param unit Unit for `max_width`, one of `"in"`, `"cm"`, `"mm"`.
#' @return A list of flextable objects. If no splitting is needed, a
#' single-element list is returned.
#' @family table_structure
#' @examples
#' ft <- flextable(head(mtcars))
#' ft_pages <- split_columns(ft, max_width = 5)
#' length(ft_pages)
#' @export
split_columns <- function(x, max_width, rep_cols = NULL, unit = "in") {
  max_width <- convin(unit = unit, x = max_width)
  all_keys <- x$col_keys

  if (is.null(rep_cols)) {
    rep_keys <- character(0)
  } else {
    ref_part <- if (nrow_part(x, "header") > 0L) x$header else x$body
    # as_col_keys validates and resolves formulas/logicals/indices to names
    resolved <- as_col_keys(ref_part, j = rep_cols, blanks = character())
    # preserve user-specified order (as_col_keys reorders to dataset order)
    if (is.character(rep_cols)) {
      rep_keys <- rep_cols[rep_cols %in% resolved]
    } else if (is.numeric(rep_cols)) {
      rep_keys <- all_keys[rep_cols[rep_cols >= 1L & rep_cols <= length(all_keys)]]
    } else {
      rep_keys <- resolved
    }
  }

  data_keys <- setdiff(all_keys, rep_keys)

  widths <- dim_pretty(x)$widths
  names(widths) <- all_keys
  rep_width <- sum(widths[rep_keys])
  data_widths <- widths[data_keys]
  available <- max_width - rep_width

  if (available <= 0) {
    warning("max_width is too small to fit the repeated columns, no pagination performed.")
    return(list(x))
  }

  # greedy packing
  pages <- list()
  current <- integer(0)
  current_sum <- 0
  for (k in seq_along(data_keys)) {
    if (current_sum + data_widths[k] > available && length(current) > 0L) {
      pages <- c(pages, list(current))
      current <- integer(0)
      current_sum <- 0
    }
    current <- c(current, k)
    current_sum <- current_sum + data_widths[k]
  }
  if (length(current) > 0L) {
    pages <- c(pages, list(current))
  }

  if (length(pages) <= 1L) return(list(x))

  lapply(pages, function(idx) {
    keep <- c(rep_keys, data_keys[idx])
    drop <- setdiff(all_keys, keep)
    if (length(drop) > 0L) {
      out <- delete_columns(x, j = drop)
    } else {
      out <- x
    }
    out$col_keys <- keep
    for (pt in c("header", "body", "footer")) {
      if (nrow_part(out, pt) > 0L) {
        out[[pt]]$col_keys <- keep
      }
    }
    out
  })
}

#' @title Split a flextable into pages by rows
#'
#' @description Split a flextable into a list of flextables whose body
#' rows fit within a given height (in inches). Header and footer are
#' repeated on every page. An optional `group` argument keeps row groups
#' together (no page break inside a group).
#'
#' @note Footnotes are currently repeated on every page, even when
#' they reference rows that only appear on a specific page. This
#' limitation will be resolved in a future version when footnotes
#' are restructured to track their association with body rows.
#'
#' @inheritParams args_x_only
#' @param max_height Maximum height for each page, including
#' header and footer (in inches by default).
#' @param group Integer vector of body row indices that start a new group.
#' Rows belonging to the same group are kept together on a single page.
#' Default is `integer(0)` (no grouping, every row is independent).
#' @param unit Unit for `max_height`, one of `"in"`, `"cm"`, `"mm"`.
#' @return A list of flextable objects. If no splitting is needed, a
#' single-element list is returned.
#' @family table_structure
#' @examples
#' ft <- flextable(iris)
#' ft_pages <- split_rows(ft, max_height = 3)
#' length(ft_pages)
#' @export
split_rows <- function(x, max_height, group = integer(0), unit = "in") {
  max_height <- convin(unit = unit, x = max_height)
  heights <- dim_pretty(x)$heights
  n_hdr <- nrow_part(x, "header")
  n_ftr <- nrow_part(x, "footer")
  n_body <- nrow_part(x, "body")

  hdr_height <- sum(heights[seq_len(n_hdr)])
  if (n_ftr > 0L) {
    ftr_height <- sum(heights[seq(n_hdr + n_body + 1L, length(heights))])
  } else {
    ftr_height <- 0
  }
  body_heights <- heights[seq(n_hdr + 1L, n_hdr + n_body)]
  available <- max_height - hdr_height - ftr_height

  if (available <= 0) {
    warning("max_height is too small to fit header and footer, no pagination performed.")
    return(list(x))
  }

  # Build groups from group starts (indices of group starts in body)
  if (length(group) > 0L) {
    if (is.unsorted(group, strictly = TRUE)) {
      stop("group must be a strictly increasing vector of row indices.", call. = FALSE)
    }
    if (any(group < 1L | group > n_body)) {
      stop("group indices must be between 1 and ", n_body, ".", call. = FALSE)
    }
    group_ids <- findInterval(seq_len(n_body), group)
  } else {
    group_ids <- seq_len(n_body)
  }

  # Greedy packing of groups into pages
  pages <- list()
  current <- integer(0)
  current_height <- 0
  for (g in unique(group_ids)) {
    rows_in_group <- which(group_ids == g)
    group_height <- sum(body_heights[rows_in_group])
    if (current_height + group_height > available && length(current) > 0L) {
      pages <- c(pages, list(current))
      current <- integer(0)
      current_height <- 0
    }
    current <- c(current, rows_in_group)
    current_height <- current_height + group_height
  }
  if (length(current) > 0L) {
    pages <- c(pages, list(current))
  }

  if (length(pages) <= 1L) return(list(x))

  # Split via delete_rows (spans preserved when no vertical span is broken)
  lapply(pages, function(keep_rows) {
    drop_rows <- setdiff(seq_len(n_body), keep_rows)
    if (length(drop_rows) > 0L) {
      delete_rows(x, i = drop_rows, part = "body")
    } else {
      x
    }
  })
}
