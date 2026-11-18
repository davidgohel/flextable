#' @export
#' @title Fix border issues when cells are merged
#' @description When cells are merged, the rendered borders will be those
#' of the first cell. If a column is made of three merged cells, the bottom
#' border that will be seen will be the bottom border of the first cell in the
#' column. From a user point of view, this is wrong, the bottom should be the one
#' defined for cell 3. This function modify the border values to avoid that effect.
#'
#' Note since version `0.9.7` that the function is called automatically
#' before rendering, user should not have to call this function anymore.
#' @template params_x_part_all
#' @examples
#' library(officer)
#' dat <- data.frame(a = 1:5, b = 6:10)
#' ft <- flextable(dat)
#' ft <- theme_box(ft)
#' ft <- merge_at(ft, i = 4:5, j = 1, part = "body")
#' ft <- hline(ft,
#'   i = 5, part = "body",
#'   border = fp_border(color = "red", width = 5)
#' )
#' print(ft)
#' ft <- fix_border_issues(ft)
#' print(ft)
#' @keywords internal
fix_border_issues <- function(x, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "fix_border_issues()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- fix_border_issues(x = x, part = p)
    }
    x <- correct_hidden_bottom_border(x)
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  x[[part]] <- correct_h_border(x[[part]])
  x[[part]] <- correct_v_border(x[[part]])
  x
}

correct_h_border <- function(x) {
  span_cols <- as.list(as.data.frame(x$spans$columns))

  bool_to_be_corrected <- lapply(span_cols, function(x) x > 1)
  l_apply_bottom_border <- lapply(span_cols, function(x) {
    rle_ <- rle(x)
    from <- cumsum(rle_$lengths)[rle_$values < 1]
    to <- cumsum(rle_$lengths)[rle_$values > 1]
    list(from = from, to = to, dont = length(to) < 1)
  })

  for (j in seq_len(ncol(x$spans$columns))) {
    apply_bottom_border <- l_apply_bottom_border[[j]]

    if (apply_bottom_border$dont) {
      next
    }

    for (i in seq_along(apply_bottom_border$from)) {
      i_from <- apply_bottom_border$from[i]
      i_to <- apply_bottom_border$to[i]

      x$styles$cells$border.color.bottom$data[
        i_to,
        x$col_keys[j]
      ] <- x$styles$cells$border.color.bottom$data[i_from, x$col_keys[j]]
      x$styles$cells$border.width.bottom$data[
        i_to,
        x$col_keys[j]
      ] <- x$styles$cells$border.width.bottom$data[i_from, x$col_keys[j]]
      x$styles$cells$border.style.bottom$data[
        i_to,
        x$col_keys[j]
      ] <- x$styles$cells$border.style.bottom$data[i_from, x$col_keys[j]]
    }
  }

  x
}
correct_v_border <- function(x) {
  span_rows <- as.list(as.data.frame(t(x$spans$rows)))

  l_apply_right_border <- lapply(span_rows, function(x) {
    rle_ <- rle(x)
    from <- cumsum(rle_$lengths)[rle_$values < 1]
    to <- cumsum(rle_$lengths)[rle_$values > 1]
    list(from = from, to = to, dont = length(to) < 1)
  })

  for (i in seq_along(l_apply_right_border)) {
    apply_right_border <- l_apply_right_border[[i]]

    if (apply_right_border$dont) {
      next
    }

    for (j in seq_along(apply_right_border$from)) {
      colkeyto <- x$col_keys[apply_right_border$to[j]]
      colkeyfrom <- x$col_keys[apply_right_border$from[j]]
      x$styles$cells$border.color.right$data[
        i,
        colkeyto
      ] <- x$styles$cells$border.color.right$data[i, colkeyfrom]
      x$styles$cells$border.width.right$data[
        i,
        colkeyto
      ] <- x$styles$cells$border.width.right$data[i, colkeyfrom]
      x$styles$cells$border.style.right$data[
        i,
        colkeyto
      ] <- x$styles$cells$border.style.right$data[i, colkeyfrom]
    }
  }

  x
}

# A cell hidden by a horizontal merge is not drawn: its bottom border,
# set for example with hline() on some of the merged columns, would be lost.
# It is copied to the top border of the cell below (same part, or first row
# of the next part), which HTML, PowerPoint and grid draw; Word already
# draws the bottom border of the cell above as the top border of a cell.
correct_hidden_bottom_border <- function(x) {
  parts <- Filter(
    function(p) nrow_part(x, p) > 0,
    c("header", "body", "footer")
  )
  props <- c("width", "color", "style")
  for (k in seq_along(parts)) {
    part <- parts[k]
    n <- nrow_part(x, part)
    hidden <- which(x[[part]]$spans$rows < 1L, arr.ind = TRUE)
    if (nrow(hidden) < 1L) {
      next
    }
    for (h in seq_len(nrow(hidden))) {
      i <- hidden[h, 1]
      col <- x$col_keys[hidden[h, 2]]
      width <- x[[part]]$styles$cells$border.width.bottom$data[i, col]
      # the visible cell of the merge draws its bottom border over all the
      # merged columns: only a stronger border needs the cell below
      spans_i <- x[[part]]$spans$rows[i, ]
      first <- max(which(spans_i[seq_len(hidden[h, 2])] > 0))
      visible <- x[[part]]$styles$cells$border.width.bottom$data[
        i,
        x$col_keys[first]
      ]
      if (is.na(width) || width <= 0 || width <= visible) {
        next
      }
      if (i < n) {
        below_part <- part
        below_i <- i + 1L
      } else if (k < length(parts)) {
        below_part <- parts[k + 1L]
        below_i <- 1L
      } else {
        next
      }
      below <- x[[below_part]]$styles$cells
      if (below$border.width.top$data[below_i, col] >= width) {
        next
      }
      for (prop in props) {
        from <- paste0("border.", prop, ".bottom")
        to <- paste0("border.", prop, ".top")
        x[[below_part]]$styles$cells[[to]]$data[below_i, col] <-
          x[[part]]$styles$cells[[from]]$data[i, col]
      }
    }
  }
  x
}
