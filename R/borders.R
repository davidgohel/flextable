# borders format ----

#' @export
#' @title Set cell borders
#' @description change borders of selected rows and columns of a flextable.
#' This function is **not to be used by end user** (it requires careful
#' settings to avoid overlapping borders) but only for programming purposes.
#'
#' If you need to add borders, use instead other functions:
#'
#' These set borders for the whole table : [border_outer()],
#' [border_inner_h()] and [border_inner_v()].
#'
#' To add horizontal or vertical lines in the table at specific location,
#' use:
#'
#' - [hline()]: set bottom borders (inner horizontal)
#' - [vline()]: set right borders (inner vertical)
#'
#' To add following horizontal or vertical lines at
#' beginning or end of the table, use:
#'
#' - [hline_top()]: set the top border (outer horizontal)
#' - [hline_bottom()]: set the bottom border (outer horizontal)
#' - [vline_left()]: set the left border (outer vertical)
#' - [vline_right()]: set the right border (outer vertical)
#'
#' If you want to highlight specific cells with some borders, use
#' [surround()].
#' @note
#' pdf and pptx outputs do not support `border()` usage.
#' @inheritParams args_selectors_with_all
#' @param border border (shortcut for top, bottom, left and right)
#' @param border.top border top
#' @param border.bottom border bottom
#' @param border.left border left
#' @param border.right border right
#' @examples
#' library(officer)
#' ftab <- flextable(head(mtcars))
#' ftab <- border(ftab, border.top = fp_border(color = "orange"))
#' ftab
#' @keywords internal
border <- function(
  x,
  i = NULL,
  j = NULL,
  border = NULL,
  border.top = NULL,
  border.bottom = NULL,
  border.left = NULL,
  border.right = NULL,
  part = "body"
) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "border()"))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (!is.null(border)) {
    if (is.null(border.top)) {
      border.top <- border
    }
    if (is.null(border.bottom)) {
      border.bottom <- border
    }
    if (is.null(border.left)) {
      border.left <- border
    }
    if (is.null(border.right)) border.right <- border
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- border(
        x = x,
        i = i,
        j = j,
        border.top = border.top,
        border.bottom = border.bottom,
        border.left = border.left,
        border.right = border.right,
        part = p
      )
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if (!is.null(border.top)) {
    x[[part]]$styles$cells[["border.style.top"]]$data[i, j] <- border.top$style
    x[[part]]$styles$cells[["border.color.top"]]$data[i, j] <- border.top$color
    x[[part]]$styles$cells[["border.width.top"]]$data[i, j] <- border.top$width
  }
  if (!is.null(border.bottom)) {
    x[[part]]$styles$cells[["border.style.bottom"]]$data[
      i,
      j
    ] <- border.bottom$style
    x[[part]]$styles$cells[["border.color.bottom"]]$data[
      i,
      j
    ] <- border.bottom$color
    x[[part]]$styles$cells[["border.width.bottom"]]$data[
      i,
      j
    ] <- border.bottom$width
  }
  if (!is.null(border.left)) {
    x[[part]]$styles$cells[["border.style.left"]]$data[
      i,
      j
    ] <- border.left$style
    x[[part]]$styles$cells[["border.color.left"]]$data[
      i,
      j
    ] <- border.left$color
    x[[part]]$styles$cells[["border.width.left"]]$data[
      i,
      j
    ] <- border.left$width
  }
  if (!is.null(border.right)) {
    x[[part]]$styles$cells[["border.style.right"]]$data[
      i,
      j
    ] <- border.right$style
    x[[part]]$styles$cells[["border.color.right"]]$data[
      i,
      j
    ] <- border.right$color
    x[[part]]$styles$cells[["border.width.right"]]$data[
      i,
      j
    ] <- border.right$width
  }

  x
}


#' @title Remove borders
#' @description The function is deleting all borders of the flextable object.
#' @inheritParams args_x_only
#' @examples
#' dat <- iris[c(1:5, 51:55, 101:105), ]
#' ft_1 <- flextable(dat)
#' ft_1 <- theme_box(ft_1)
#' ft_1
#'
#' # remove all borders
#' ft_2 <- border_remove(x = ft_1)
#' ft_2
#' @export
#' @family borders management
border_remove <- function(x) {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "border_remove()"
    ))
  }
  x <- border(x = x, border = fp_border(width = 0), part = "all")
  x
}

#' @title Set outer borders
#' @description The function is applying a border to outer cells of one
#' or all parts of a flextable.
#' @inheritParams args_x_part
#' @param border border properties defined by a call to [officer::fp_border()]
#' @export
#' @examples
#' library(officer)
#' big_border <- fp_border(color = "red", width = 2)
#'
#' dat <- iris[c(1:5, 51:55, 101:105), ]
#' ft <- flextable(dat)
#' ft <- border_remove(x = ft)
#'
#' # add outer borders
#' ft <- border_outer(ft, part = "all", border = big_border)
#' ft
#' @family borders management
border_outer <- function(x, border = NULL, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "border_outer()"
    ))
  }

  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- border_outer(x = x, border = border, part = p)
    }
    return(x)
  }
  if (nrow_part(x, part) < 1) {
    return(x)
  }

  x <- hline_top(x, border = border, part = part)
  x <- hline_bottom(x, border = border, part = part)
  x <- vline_right(x, border = border, part = part)
  x <- vline_left(x, border = border, part = part)

  x
}

#' @export
#' @title Set inner horizontal borders
#' @description The function is applying a border to inner content of one
#' or all parts of a flextable.
#' @inheritParams border_outer
#' @examples
#' library(officer)
#' std_border <- fp_border(color = "orange", width = 1)
#'
#' dat <- iris[c(1:5, 51:55, 101:105), ]
#' ft <- flextable(dat)
#' ft <- border_remove(x = ft)
#'
#' # add inner horizontal borders
#' ft <- border_inner_h(ft, border = std_border)
#' ft
#' @family borders management
border_inner_h <- function(x, border = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "border_inner_h()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- border_inner_h(x = x, border = border, part = p)
    }
    return(x)
  }
  if ((nl <- nrow_part(x, part)) < 1) {
    return(x)
  }
  at <- seq_len(nl)
  at <- at[-length(at)]
  x <- hline(x, i = at, border = border, part = part)

  x
}

#' @export
#' @title Set inner vertical borders
#' @description The function is applying a vertical border to inner content of one
#' or all parts of a flextable.
#' @inheritParams border_outer
#' @examples
#' library(officer)
#' std_border <- fp_border(color = "orange", width = 1)
#'
#' dat <- iris[c(1:5, 51:55, 101:105), ]
#' ft <- flextable(dat)
#' ft <- border_remove(x = ft)
#'
#' # add inner vertical borders
#' ft <- border_inner_v(ft, border = std_border)
#' ft
#' @family borders management
border_inner_v <- function(x, border = NULL, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "border_inner_v()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- border_inner_v(x = x, border = border, part = p)
    }
    return(x)
  }
  if (nrow_part(x, part) < 1) {
    return(x)
  }
  at <- seq_along(x$col_keys)
  at <- at[-length(at)]
  x <- vline(x, j = at, border = border, part = part)

  x
}

#' @export
#' @title Set all inner borders
#' @description The function is applying a vertical and horizontal borders to inner content of one
#' or all parts of a flextable.
#' @inheritParams border_outer
#' @examples
#' library(officer)
#' std_border <- fp_border(color = "orange", width = 1)
#'
#' dat <- iris[c(1:5, 51:55, 101:105), ]
#' ft <- flextable(dat)
#' ft <- border_remove(x = ft)
#'
#' # add inner vertical borders
#' ft <- border_inner(ft, border = std_border)
#' ft
#' @family borders management
border_inner <- function(x, border = NULL, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "border_inner()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- border_inner(x = x, border = border, part = p)
    }
    return(x)
  }
  if ((nl <- nrow_part(x, part)) < 1) {
    return(x)
  }

  # v
  at <- seq_along(x$col_keys)
  at <- at[-length(at)]
  x <- vline(x, j = at, border = border, part = part)

  # h
  at <- seq_len(nl)
  at <- at[-length(at)]
  x <- hline(x, i = at, border = border, part = part)

  x
}

#' @export
#' @title Set horizontal borders below selected rows
#' @description
#' `hline()` draws a horizontal line **below** each selected row by
#' setting the bottom border of cells at row `i` (and the top border
#' of cells at row `i + 1` so that the line renders consistently
#' across output formats).
#'
#' Use the `i` selector to target specific rows (e.g. a formula
#' such as `~ before(col, "Total")`). When `i` is `NULL` (the
#' default) the border is added below every row, which produces
#' a full grid of inner horizontal lines.
#'
#' For the **outer** edges of the table, use [hline_top()] and
#' [hline_bottom()] instead; those always target the very first
#' or very last row of a part.
#' @inheritParams args_selectors_with_all
#' @param border border properties defined by a call to
#' [officer::fp_border()]
#' @examples
#' library(officer)
#' std_border <- fp_border(color = "gray")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add horizontal borders below every row
#' ft <- hline(ft, part = "all", border = std_border)
#' ft
#' @family borders management
hline <- function(x, i = NULL, j = NULL, border = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "hline()"))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- hline(
        x = x,
        i = i,
        j = j,
        border = border,
        part = p
      )
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)
  x <- border(x, i = i, j = j, border.bottom = border, part = part)

  ii <- i + 1
  ii <- ii[ii > 1 & ii <= nrow_part(x, part)]

  if (length(ii) > 0) {
    x <- border(x, i = ii, j = j, border.top = border, part = part)
  }
  x
}

#' @export
#' @title Set the top border of a table part
#' @description
#' `hline_top()` draws a horizontal line at the **very top** of a
#' table part. It does not accept a row selector `i` because it
#' always targets the first row.
#'
#' When the part above exists (e.g. header above body), the line
#' is stored as the bottom border of that adjacent part so that
#' it renders seamlessly.
#'
#' Unlike [hline()], which adds inner lines below arbitrary rows,
#' `hline_top()` is meant for the outer top edge of a part.
#' @inheritParams args_x_j_part
#' @param border border properties defined by a call to
#' [officer::fp_border()]
#' @examples
#' library(officer)
#' big_border <- fp_border(color = "orange", width = 3)
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add a thick line on top of each part
#' ft <- hline_top(ft, part = "all", border = big_border)
#' ft
#' @family borders management
hline_top <- function(x, j = NULL, border = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "hline_top()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- hline_top(x = x, j = j, border = border, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  j <- get_columns_id(x[[part]], j)

  if (part %in% "body" && nrow_part(x, "header") > 0) {
    x <- border(
      x,
      i = nrow_part(x, "header"),
      j = j,
      border.bottom = border,
      part = "header"
    )
  } else if (part %in% "footer" && nrow_part(x, "body") > 0) {
    x <- border(
      x,
      i = nrow_part(x, "body"),
      j = j,
      border.bottom = border,
      part = "body"
    )
  } else {
    x <- border(x, i = 1, j = j, border.top = border, part = part)
  }

  x
}

#' @export
#' @title Set the bottom border of a table part
#' @description
#' `hline_bottom()` draws a horizontal line at the **very bottom**
#' of a table part. It does not accept a row selector `i` because
#' it always targets the last row.
#'
#' Unlike [hline()], which adds inner lines below arbitrary rows,
#' `hline_bottom()` is meant for the outer bottom edge of a part.
#' @inheritParams hline_top
#' @examples
#' library(officer)
#' big_border <- fp_border(color = "orange", width = 3)
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add a thick line at the bottom of the body
#' ft <- hline_bottom(ft, part = "body", border = big_border)
#' ft
#' @family borders management
hline_bottom <- function(x, j = NULL, border = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "hline_bottom()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- hline_bottom(x = x, j = j, border = border, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  j <- get_columns_id(x[[part]], j)
  x <- border(
    x,
    i = nrow_part(x, part),
    j = j,
    border.bottom = border,
    part = part
  )
  x
}

#' @export
#' @title Set vertical borders to the right of selected columns
#' @description
#' `vline()` draws a vertical line to the **right** of each
#' selected column by setting the right border of cells at
#' column `j` (and the left border of cells at column `j + 1`
#' so that the line renders consistently across output formats).
#'
#' Use the `j` selector to target specific columns. When `j` is
#' `NULL` (the default) the border is added to the right of every
#' column, producing a full grid of inner vertical lines.
#'
#' For the **outer** edges of the table, use [vline_left()] and
#' [vline_right()] instead; those always target the very first
#' or very last column.
#' @inheritParams args_selectors_with_all
#' @param border border properties defined by a call to
#' [officer::fp_border()]
#' @examples
#' library(officer)
#' std_border <- fp_border(color = "orange")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add vertical borders to the right of every column
#' ft <- vline(ft, border = std_border)
#' ft
#' @family borders management
vline <- function(x, i = NULL, j = NULL, border = NULL, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "vline()"))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- vline(x = x, i = i, j = j, border = border, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)
  x <- border(x, i = i, j = j, border.right = border, part = part)
  j <- setdiff(j, length(x$col_keys))
  if (length(j) > 0) {
    x <- border(x, i = i, j = j + 1, border.left = border, part = part)
  }
  x
}

#' @export
#' @title Set the left border of the table
#' @description
#' `vline_left()` draws a vertical line along the **left edge**
#' of the table by setting the left border of the first column.
#' It does not accept a column selector `j` because it always
#' targets column 1.
#'
#' An optional row selector `i` lets you restrict the line to
#' specific rows (e.g. only the body, or only certain rows).
#'
#' Unlike [vline()], which adds inner lines to the right of
#' arbitrary columns, `vline_left()` is meant for the outer
#' left edge of the table.
#' @inheritParams args_x_i_part
#' @param border border properties defined by a call to
#' [officer::fp_border()]
#' @examples
#' library(officer)
#' std_border <- fp_border(color = "orange")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add a border on the left edge of the table
#' ft <- vline_left(ft, border = std_border)
#' ft
#' @family borders management
vline_left <- function(x, i = NULL, border = NULL, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "vline_left()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- vline_left(x = x, i = i, border = border, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  x <- border(x, j = 1, i = i, border.left = border, part = part)
  x
}

#' @export
#' @title Set the right border of the table
#' @description
#' `vline_right()` draws a vertical line along the **right edge**
#' of the table by setting the right border of the last column.
#' It does not accept a column selector `j` because it always
#' targets the last column.
#'
#' An optional row selector `i` lets you restrict the line to
#' specific rows.
#'
#' Unlike [vline()], which adds inner lines to the right of
#' arbitrary columns, `vline_right()` is meant for the outer
#' right edge of the table.
#' @inheritParams vline_left
#' @examples
#' library(officer)
#' std_border <- fp_border(color = "orange")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#'
#' # add a border on the right edge of the table
#' ft <- vline_right(ft, border = std_border)
#' ft
#' @family borders management
vline_right <- function(x, i = NULL, border = NULL, part = "all") {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "vline_right()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (is.null(border)) {
    border <- fp_border(color = flextable_global$defaults$border.color)
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- vline_right(x = x, i = i, border = border, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  x <- border(
    x,
    j = length(x$col_keys),
    i = i,
    border.right = border,
    part = part
  )
  x
}


#' @export
#' @title Detect rows before a given value
#' @description Returns a logical vector indicating which elements
#' of `x` appear before the first occurrence of any of the
#' `entries` values. Useful as a row selector in [hline()] to
#' insert a border above a summary row such as `"Total"`.
#' @param x an atomic vector of values to be tested
#' @param entries a sequence of items to be searched in `x`.
#' @seealso [hline()]
#' @examples
#' library(flextable)
#' library(officer)
#'
#' dat <- data.frame(
#'   stringsAsFactors = FALSE,
#'   check.names = FALSE,
#'   Level = c("setosa", "versicolor", "virginica", "<NA>", "Total"),
#'   Freq = as.integer(c(50, 50, 50, 0, 150)),
#'   `% Valid` = c(
#'     100 / 3,
#'     100 / 3, 100 / 3, NA, 100
#'   ),
#'   `% Valid Cum.` = c(100 / 3, 100 * 2 / 3, 100, NA, 100),
#'   `% Total` = c(
#'     100 / 3,
#'     100 / 3, 100 / 3, 0, 100
#'   ),
#'   `% Total Cum.` = c(
#'     100 / 3,
#'     100 * 2 / 3, 100, 100, 100
#'   )
#' )
#'
#' ft <- flextable(dat)
#' ft <- hline(ft,
#'   i = ~ before(Level, "Total"),
#'   border = fp_border_default(width = 2)
#' )
#' ft
before <- function(x, entries) {
  z <- rep(FALSE, length(x))
  index <- which(x %in% entries) - 1
  index <- index[is.finite(index) & index > 0]
  z[index] <- TRUE
  z
}

#' @export
#' @title Surround cells with borders
#' @description
#' `surround()` draws borders around specific cells, highlighting
#' them individually.
#'
#' To set borders for the whole table, use [border_outer()],
#' [border_inner_h()] and [border_inner_v()].
#'
#' All the following functions also support the
#' row and column selector `i` and `j`:
#'
#' * [hline()]: set bottom borders (inner horizontal)
#' * [vline()]: set right borders (inner vertical)
#' * [hline_top()]: set the top border (outer horizontal)
#' * [vline_left()]: set the left border (outer vertical)
#'
#' @inheritParams border
#' @family borders management
#' @examples
#' library(officer)
#' library(flextable)
#'
#' # cell to highlight
#' vary_i <- 1:3
#' vary_j <- 1:3
#'
#' std_border <- fp_border(color = "orange")
#'
#' ft <- flextable(head(iris))
#' ft <- border_remove(x = ft)
#' ft <- border_outer(x = ft, border = std_border)
#'
#' for (id in seq_along(vary_i)) {
#'   ft <- bg(
#'     x = ft,
#'     i = vary_i[id],
#'     j = vary_j[id], bg = "yellow"
#'   )
#'   ft <- surround(
#'     x = ft,
#'     i = vary_i[id],
#'     j = vary_j[id],
#'     border.left = std_border,
#'     border.right = std_border,
#'     part = "body"
#'   )
#' }
#'
#' ft <- autofit(ft)
#' ft
#' # # render
#' # print(ft, preview = "pptx")
#' # print(ft, preview = "docx")
#' # print(ft, preview = "pdf")
#' # print(ft, preview = "html")
surround <- function(
  x,
  i = NULL,
  j = NULL,
  border = NULL,
  border.top = NULL,
  border.bottom = NULL,
  border.left = NULL,
  border.right = NULL,
  part = "body"
) {
  if (!inherits(x, "flextable")) {
    stop(sprintf(
      "Function `%s` supports only flextable objects.",
      "surround()"
    ))
  }
  part <- match.arg(
    part,
    c("all", "body", "header", "footer"),
    several.ok = FALSE
  )

  if (!is.null(border)) {
    if (is.null(border.top)) {
      border.top <- border
    }
    if (is.null(border.bottom)) {
      border.bottom <- border
    }
    if (is.null(border.left)) {
      border.left <- border
    }
    if (is.null(border.right)) border.right <- border
  }

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- surround(
        x = x,
        i = i,
        j = j,
        border.top = border.top,
        border.bottom = border.bottom,
        border.left = border.left,
        border.right = border.right,
        part = p
      )
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if (!is.null(border.top)) {
    itop <- setdiff(i, 1) - 1
    x <- hline(x, i = itop, j = j, part = part, border = border.top)
    if (1 %in% i) {
      x <- hline_top(x, j = j, part = part, border = border.top)
    }
  }
  if (!is.null(border.bottom)) {
    x <- hline(x, i = i, j = j, part = part, border = border.bottom)
  }
  if (!is.null(border.left)) {
    jleft <- setdiff(j, 1) - 1
    x <- vline(x, i = i, j = jleft, part = part, border = border.left)
    if (1 %in% j) {
      x <- vline_left(x, i = i, part = part, border = border.left)
    }
  }
  if (!is.null(border.right)) {
    x <- vline(x, i = i, j = j, part = part, border = border.right)
  }

  x
}
