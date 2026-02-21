#' @title Rename column labels in the header
#'
#' @description Change the display labels in the bottom row of the header.
#' Unlike [set_header_df()] which replaces the entire header structure,
#' this function only modifies column labels in the last header row.
#'
#' @inheritParams args_x_only
#' @param ... named arguments (names are data colnames), each element is a single character
#' value specifying label to use.
#' @param values a named list (names are data colnames), each element is a single character
#' value specifying label to use. If provided, argument `...` will be ignored.
#' It can also be a unamed character vector, in that case, it must have the same
#' length than the number of columns of the flextable.
#' @examples
#' ft <- flextable(head(iris))
#' ft <- set_header_labels(ft,
#'   Sepal.Length = "Sepal length",
#'   Sepal.Width = "Sepal width", Petal.Length = "Petal length",
#'   Petal.Width = "Petal width"
#' )
#'
#' ft <- flextable(head(iris))
#' ft <- set_header_labels(ft,
#'   values = list(
#'     Sepal.Length = "Sepal length",
#'     Sepal.Width = "Sepal width",
#'     Petal.Length = "Petal length",
#'     Petal.Width = "Petal width"
#'   )
#' )
#' ft
#'
#' ft <- flextable(head(iris))
#' ft <- set_header_labels(
#'   x = ft,
#'   values = c(
#'     "Sepal length",
#'     "Sepal width", "Petal length",
#'     "Petal width", "Species")
#' )
#' ft
#' @export
#' @family functions for row and column operations in a flextable
set_header_labels <- function(x, ..., values = NULL) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "set_header_labels()"))
  }

  if (is.null(values)) {
    values <- list(...)
    if (nrow_part(x, "header") < 1) {
      stop("there is no header row to be replaced")
    }
  }

  names_ <- names(values)
  if (is.null(names_)) {
    if (length(values) != ncol_keys(x)) {
      stop("if unamed, the labels must have the same length than col_keys.")
    }

    newcontent <- as_paragraph(as_chunk(values))
    newcontent <- as_chunkset_struct(
      l_paragraph = newcontent,
      keys = x$col_keys)
    x$header$content <- set_chunkset_struct_element(
      x = x$header$content,
      i = nrow_part(x, "header"),
      j = x$col_keys,
      value = newcontent
    )
  } else {
    names_ <- names_[names_ %in% x$col_keys]
    values <- values[names_]
    if (length(values) < 1) {
      return(x)
    }
    newcontent <- lapply(
      values,
      function(x) {
        as_paragraph(as_chunk(x, formatter = format_fun.default))
      }
    )

    newcontent <- as_chunkset_struct(
      l_paragraph = do.call(c, newcontent),
      keys = names_)

    x$header$content <- set_chunkset_struct_element(
      x = x$header$content,
      i = nrow_part(x, "header"),
      j = names_,
      value = newcontent
    )
  }

  x
}


#' @export
#' @title Delete flextable part
#'
#' @description indicate to not print a part of
#' the flextable, i.e. an header, footer or the body.
#'
#' @inheritParams args_x_part_no_all
#' @family functions for row and column operations in a flextable
#' @examples
#' ft <- flextable(head(iris))
#' ft <- delete_part(x = ft, part = "header")
#' ft
delete_part <- function(x, part = "header") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "delete_part()"))
  }
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE)
  nrow_ <- nrow(x[[part]]$dataset)
  x[[part]] <- complex_tabpart(
    data = x[[part]]$dataset[-seq_len(nrow_), , drop = FALSE],
    col_keys = x$col_keys,
    cwidth = x[[part]]$colwidths, cheight = x[[part]]$rowheights
  )
  x
}

delete_rows_from_part <- function(x, i) {
  # dataset rows
  x$dataset <- x$dataset[-i, ]
  # heights
  x$rowheights <- x$rowheights[-i]
  # hrules
  x$hrule <- x$hrule[-i]
  # spans — only reset if vertical spans are broken
  runs <- split(i, cumsum(c(1, diff(i) != 1)))
  has_broken_vspan <- any(vapply(runs, function(r) {
    any(colSums(x$spans$columns[r, , drop = FALSE]) != length(r))
  }, logical(1)))

  x$spans$rows <- x$spans$rows[-i, , drop = FALSE]
  x$spans$columns <- x$spans$columns[-i, , drop = FALSE]
  if (has_broken_vspan) {
    x <- span_free(x)
  }

  # styles
  x$styles$cells <- delete_style_row(x$styles$cells, i)
  x$styles$pars <- delete_style_row(x$styles$pars, i)
  x$styles$text <- delete_style_row(x$styles$text, i)

  # content
  x$content <- delete_row_from_fpstruct(x$content, i)

  x
}

#' @export
#' @title Delete flextable rows
#'
#' @description The function removes one or more rows
#' from a 'flextable'.
#' @details
#' Deleting one or more rows will result in the deletion
#' of any span parameters that may have been set previously.
#' They will have to be redone after this operation or
#' performed only after this deletion.
#' @inheritParams args_x_i_part
#' @examples
#' ft <- flextable(head(iris))
#' ft <- delete_rows(ft, i = 1:5, part = "body")
#' ft
delete_rows <- function(x, i = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "delete_rows()"))
  }

  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- delete_rows(x = x, i = i, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  if (length(i) < 1) {
    return(x)
  }
  x[[part]] <- delete_rows_from_part(x[[part]], i = i)
  x
}


delete_colums_from_part <- function(x, j) {
  j_idx <- which(x$col_keys %in% j)
  # heights
  x$colwidths <- x$colwidths[!x$col_keys %in% j]
  # spans — only reset if horizontal spans are broken
  runs <- split(j_idx, cumsum(c(1, diff(j_idx) != 1)))
  has_broken_hspan <- any(vapply(runs, function(r) {
    any(rowSums(x$spans$rows[, r, drop = FALSE]) != length(r))
  }, logical(1)))

  x$spans$rows <- x$spans$rows[, -j_idx, drop = FALSE]
  x$spans$columns <- x$spans$columns[, -j_idx, drop = FALSE]
  if (has_broken_hspan) {
    x <- span_free(x)
  }

  # styles
  x$styles$cells <- delete_style_col(x$styles$cells, j)
  x$styles$pars <- delete_style_col(x$styles$pars, j)
  x$styles$text <- delete_style_col(x$styles$text, j)

  # content
  x$content <- delete_col_from_fpstruct(x$content, j)
  x$col_keys <- x$content$keys
  x
}

#' @export
#' @title Delete flextable columns
#'
#' @description The function removes one or more columns
#' from a 'flextable'.
#' @details
#' Deleting one or more columns will result in the deletion
#' of any span parameters that may have been set previously.
#' They will have to be redone after this operation or
#' performed only after this deletion.
#' @inheritParams args_x_j
#' @family functions for row and column operations in a flextable
#' @examples
#' ft <- flextable(head(iris))
#' ft <- delete_columns(ft, j = "Species")
#' ft
delete_columns <- function(x, j = NULL) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "delete_columns()"))
  }
  cols <- NULL

  parts <- c("header", "body", "footer")
  for (part in parts) {
    if (nrow_part(x, part) > 0) {
      if (is.null(cols)) {
        cols <- get_columns_id(x[[part]], j)
        cols <- x$col_keys[cols]
      }
      x[[part]] <- delete_colums_from_part(x[[part]], j = cols)
    }
  }
  x$col_keys <- setdiff(x$col_keys, cols)
  x
}


as_new_data <- function(x, ..., values = NULL) {
  if (is.null(values)) {
    values <- list(...)
  } else if (is.atomic(values)) {
    values <- as.list(values)
  }

  if (!is.list(values)) {
    stop("argument 'values' must be a list")
  }

  args_ <- lapply(x$col_keys, function(x, n) rep(NA, n), n = length(values[[1]]))
  names(args_) <- x$col_keys
  args_[names(values)] <- values

  data.frame(as.list(args_), check.names = FALSE, stringsAsFactors = FALSE)
}

add_rows_to_tabpart <- function(x, rows, first = FALSE) {
  data <- x$dataset
  spans <- x$spans
  ncol <- length(x$col_keys)
  nrow <- nrow(rows)

  x$styles$cells <- add_rows_to_struct(x$styles$cells, nrows = nrow, first = first)
  x$styles$pars <- add_rows_to_struct(x$styles$pars, nrows = nrow, first = first)
  x$styles$text <- add_rows_to_struct(x$styles$text, nrows = nrow, first = first)
  x$content <- add_rows_to_chunkset_struct(x$content, nrows = nrow, first = first, rows)

  span_new <- matrix(1, ncol = ncol, nrow = nrow)
  rowheights <- x$rowheights
  hrule <- x$hrule

  if (!first) {
    data <- rbind_match_columns(list(data, rows))
    spans$rows <- rbind(spans$rows, span_new)
    spans$columns <- rbind(spans$columns, span_new)
    rowheights <- c(rowheights, rep(rev(rowheights)[1], nrow(rows)))
    hrule <- c(hrule, rep(rev(hrule)[1], nrow(rows)))
  } else {
    data <- rbind_match_columns(list(rows, data))
    spans$rows <- rbind(span_new, spans$rows)
    spans$columns <- rbind(span_new, spans$columns)
    rowheights <- c(rep(rowheights[1], nrow(rows)), rowheights)
    hrule <- c(rep(hrule[1], nrow(rows)), hrule)
  }
  x$rowheights <- rowheights
  x$dataset <- data
  x$spans <- spans
  x$hrule <- hrule
  x
}

# add header/footer content ----

#' @export
#' @title Add body rows with one value per column
#'
#' @description
#' Add new rows to the body where each value maps to a named column,
#' preserving the original column data types.
#' Unlike [add_body_row()] where labels can span multiple columns,
#' here each value fills exactly one column.
#'
#' If some columns are not provided, they will be replaced by
#' `NA` and displayed as empty.
#' @inheritParams args_x_only
#' @param top should the rows be inserted at the top or the bottom.
#' @param ... named arguments (names are data colnames) of values
#' to add. It is important to insert data of the same type as the
#' original data, otherwise it will be transformed (probably
#' into strings if you add a `character` where a `double` is expected).
#' This makes possible to still format cell contents with the `colformat_*`
#' functions, for example [colformat_num()].
#' @param values a list of name-value pairs of labels or values,
#' names should be existing col_key values. This argument can be used
#' instead of `...` for programming purpose (If `values` is
#' supplied argument `...` is ignored).
#' @examples
#' ft <- flextable(head(iris),
#'   col_keys = c(
#'     "Species", "Sepal.Length", "Petal.Length",
#'     "Sepal.Width", "Petal.Width"
#'   )
#' )
#'
#' ft <- add_body(
#'   x = ft, Sepal.Length = 1:5,
#'   Sepal.Width = 1:5 * 2, Petal.Length = 1:5 * 3,
#'   Petal.Width = 1:5 + 10, Species = "Blah", top = FALSE
#' )
#'
#' ft <- theme_booktabs(ft)
#' ft
#' @family functions for row and column operations in a flextable
#' @seealso [flextable()]
add_body <- function(x, top = TRUE, ..., values = NULL) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "add_body()"))
  }

  new_data <- as_new_data(x = x, ..., values = values)
  x$body <- add_rows_to_tabpart(x$body, new_data, first = top)
  x
}



#' @export
#' @title Add header rows with one value per column
#'
#' @description
#' Add new rows to the header where each value maps to a named column.
#' Unlike [add_header_row()] where labels can span multiple columns,
#' here each value fills exactly one column.
#'
#' If some columns are not provided, they will be replaced by
#' `NA` and displayed as empty.
#'
#' \if{html}{\out{
#' <img src="https://www.ardata.fr/img/flextable-imgs/flextable-016.png" alt="add_header illustration" style="width:100\%;">
#' }}
#'
#' @note
#' when repeating values, they can be merged together with
#' function [merge_h()] and [merge_v()].
#' @inheritParams add_body
#' @examples
#' library(flextable)
#'
#' fun <- function(x) {
#'   paste0(
#'     c("min: ", "max: "),
#'     formatC(range(x))
#'   )
#' }
#' new_row <- list(
#'   Sepal.Length = fun(iris$Sepal.Length),
#'   Sepal.Width =  fun(iris$Sepal.Width),
#'   Petal.Width =  fun(iris$Petal.Width),
#'   Petal.Length = fun(iris$Petal.Length)
#' )
#'
#' ft_1 <- flextable(data = head(iris))
#' ft_1 <- add_header(ft_1, values = new_row, top = FALSE)
#' ft_1 <- append_chunks(ft_1, part = "header", i = 2, )
#' ft_1 <- theme_booktabs(ft_1, bold_header = TRUE)
#' ft_1 <- align(ft_1, align = "center", part = "all")
#' ft_1
#' @family functions for row and column operations in a flextable
add_header <- function(x, top = TRUE, ..., values = NULL) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "add_header()"))
  }

  header_data <- as_new_data(x = x, ..., values = values)
  x$header <- add_rows_to_tabpart(x$header, header_data, first = top)

  x
}

#' @export
#' @title Add footer rows with one value per column
#'
#' @description
#' Add new rows to the footer where each value maps to a named column.
#' Unlike [add_footer_row()] where labels can span multiple columns,
#' here each value fills exactly one column.
#'
#' If some columns are not provided, they will be replaced by
#' `NA` and displayed as empty.
#' @inheritParams add_body
#' @examples
#' new_row <- as.list(colMeans(iris[, -5]))
#' new_row$Species <- "Means"
#'
#' formatter <- function(x) sprintf("%.1f", x)
#'
#' ft <- flextable(data = head(iris))
#' ft <- add_footer(ft, values = new_row)
#'
#' # cosmetics
#' ft <- compose(
#'   x = ft, j = 1:4,
#'   value = as_paragraph(
#'     as_chunk(., formatter = formatter)
#'   ),
#'   part = "footer", use_dot = TRUE
#' )
#' ft <- align(ft, part = "footer", align = "right", j = 1:4)
#' ft
#' @family functions for row and column operations in a flextable
add_footer <- function(x, top = TRUE, ..., values = NULL) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "add_footer()"))
  }

  footer_data <- as_new_data(x = x, ..., values = values)

  if (nrow_part(x, "footer") < 1) {
    x$footer <- complex_tabpart(data = footer_data, col_keys = x$col_keys, cwidth = .75, cheight = .25)
  } else {
    x$footer <- add_rows_to_tabpart(x$footer, footer_data, first = top)
  }

  x
}

# add spanned labels as a single row ----

#' @export
#' @title Add a body row with spanning labels
#'
#' @description Add a single row to the body where labels can span
#' multiple columns (merged cells) via the `colwidths` argument.
#'
#' Labels are associated with a number of columns
#' to merge that default to one if not specified.
#' In this case, you have to make sure that the
#' number of labels is equal to the number of columns displayed.
#'
#' The function can add only one single row by call.
#'
#' Labels can also be formatted with [as_paragraph()].
#'
#' @inheritParams args_x_only
#' @param top should the row be inserted at the top or the bottom.
#' @param values values to add. It can be a `list`, a `character()` vector
#' or a call to [as_paragraph()].
#'
#' If it is a list, it can be a named list with the names of the columns of the
#' original data.frame or the `colkeys`; this is the recommended method because
#' it allows to keep the original data types and therefore allows to perform
#' conditional formatting. If a character, columns of the original data.frame
#' stored in the flextable object are changed to `character()`; this is often
#' not an issue with footer and header but can be inconvenient if adding
#' rows into body as it will change data types to character and prevent
#' efficient conditional formatting.
#'
#' @param colwidths the number of columns to merge in the row for each label
#'
#' @examples
#' library(flextable)
#'
#' ft01 <- fp_text_default(color = "red")
#' ft02 <- fp_text_default(color = "orange")
#'
#' pars <- as_paragraph(
#'   as_chunk(c("(1)", "(2)"), props = ft02), " ",
#'   as_chunk(
#'     c(
#'       "My tailor is rich",
#'       "My baker is rich"
#'     ),
#'     props = ft01
#'   )
#' )
#'
#' ft_1 <- flextable(head(mtcars))
#' ft_1 <- add_body_row(ft_1,
#'   values = pars,
#'   colwidths = c(5, 6), top = FALSE
#' )
#' ft_1 <- add_body_row(ft_1,
#'   values = pars,
#'   colwidths = c(3, 8), top = TRUE
#' )
#' ft_1 <- theme_box(ft_1)
#' ft_1
#'
#' ft_2 <- flextable(head(airquality))
#' ft_2 <- add_body_row(ft_2,
#'   values = c("blah", "bleeeh"),
#'   colwidths = c(4, 2), top = TRUE
#' )
#' ft_2 <- theme_box(ft_2)
#' ft_2
#' @family functions for row and column operations in a flextable
#' @seealso [flextable()], [set_caption()]
add_body_row <- function(x, top = TRUE, values = list(), colwidths = integer(0)) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "add_body_row()"))
  }

  if (length(colwidths) < 1) {
    colwidths <- rep(1L, length(x$col_keys))
  }

  if (sum(colwidths) != length(x$col_keys)) {
    stop(sprintf(
      "sum of colwidths elements must be equal to the number of col_keys: %.0f.",
      length(x$col_keys)
    ))
  }
  if (is.atomic(values)) {
    values <- as.list(values)
  }

  row_span <- unlist(lapply(colwidths, function(x) {
    z <- integer(x)
    z[1] <- x
    z
  }))
  col_j <- which(row_span > 0)

  body_data <- x$body$dataset[nrow(x$body$dataset) + 1, ]

  if (inherits(values, "paragraph")) {
  } else if (!is.null(attr(values, "names"))) {
    body_data[, names(values)] <- values
  } else {
    body_data[, which(row_span > 0)] <- values
  }

  if (nrow_part(x, "body") < 1) {
    x$body <- complex_tabpart(
      data = body_data, col_keys = x$col_keys,
      cwidth = dim(x)$widths, cheight = .25
    )
  } else {
    x$body <- add_rows_to_tabpart(x$body, body_data, first = top)
  }

  i <- ifelse(top, 1, nrow_part(x, "body"))
  x$body$spans$rows[i, ] <- row_span

  if (inherits(values, "paragraph")) {
    for (j in seq_along(col_j)) {
      x <- mk_par(x, i = i, j = col_j[j], value = values[j], part = "body")
    }
  }

  x
}

#' @export
#' @title Add a header row with spanning labels
#'
#' @description Add a single row to the header where labels can span
#' multiple columns (merged cells) via the `colwidths` argument.
#'
#' Labels are associated with a number of columns
#' to merge that default to one if not specified.
#' In this case, you have to make sure that the
#' number of labels is equal to the number of columns displayed.
#'
#' The function can add only one single row by call.
#'
#' Labels can also be formatted with [as_paragraph()].
#'
#' @inheritParams args_x_only
#' @param top should the row be inserted at the
#' top or the bottom. Default to TRUE.
#' @param values values to add, a character vector (as header rows
#' contains only character values/columns), a list
#' or a call to [as_paragraph()].
#' @param colwidths the number of columns used for each label
#' @examples
#' library(flextable)
#'
#' ft01 <- fp_text_default(color = "red")
#' ft02 <- fp_text_default(color = "orange")
#'
#' pars <- as_paragraph(
#'   as_chunk(c("(1)", "(2)"), props = ft02), " ",
#'   as_chunk(c(
#'     "My tailor is rich",
#'     "My baker is rich"
#'   ), props = ft01)
#' )
#'
#' ft_1 <- flextable(head(mtcars))
#' ft_1 <- add_header_row(ft_1,
#'   values = pars,
#'   colwidths = c(5, 6), top = FALSE
#' )
#' ft_1 <- add_header_row(ft_1,
#'   values = pars,
#'   colwidths = c(3, 8), top = TRUE
#' )
#' ft_1
#'
#' ft_2 <- flextable(head(airquality))
#' ft_2 <- add_header_row(ft_2,
#'   values = c("Measure", "Time"),
#'   colwidths = c(4, 2), top = TRUE
#' )
#' ft_2 <- theme_box(ft_2)
#' ft_2
#' @family functions for row and column operations in a flextable
#' @seealso [flextable()], [set_caption()]
add_header_row <- function(x, top = TRUE, values = character(0), colwidths = integer(0)) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "add_header_row()"))
  }

  if (length(colwidths) < 1) {
    colwidths <- rep(1L, length(x$col_keys))
  }

  if (sum(colwidths) != length(x$col_keys)) {
    stop(sprintf(
      "sum of colwidths elements must be equal to the number of col_keys: %.0f.",
      length(x$col_keys)
    ))
  }

  if (inherits(values, "paragraph")) {
    str_values <- vapply(values, function(x) paste0(x$txt, collapse = ""), FUN.VALUE = "")
  } else {
    str_values <- values
  }
  header_data <- data_from_char(values = str_values, colwidths = colwidths, col_keys = x$col_keys)

  if (nrow_part(x, "header") < 1) {
    x$header <- complex_tabpart(data = header_data, col_keys = x$col_keys, cwidth = dim(x)$widths, cheight = .25)
  } else {
    x$header <- add_rows_to_tabpart(x$header, header_data, first = top)
  }

  row_span <- unlist(lapply(colwidths, function(x) {
    z <- integer(x)
    z[1] <- x
    z
  }))
  i <- ifelse(top, 1, nrow(x$header$dataset))
  x$header$spans$rows[i, ] <- row_span

  if (inherits(values, "paragraph")) {
    if (top) {
      i <- 1
    } else {
      i <- nrow_part(x, "header")
    }

    col_j <- which(row_span > 0)

    for (j in seq_along(col_j)) {
      x <- mk_par(x, i = i, j = col_j[j], value = values[j], part = "header")
    }
  }

  x
}


#' @export
#' @title Add a footer row with spanning labels
#'
#' @description Add a single row to the footer where labels can span
#' multiple columns (merged cells) via the `colwidths` argument.
#'
#' Labels are associated with a number of columns
#' to merge that default to one if not specified.
#' In this case, you have to make sure that the
#' number of labels is equal to the number of columns displayed.
#'
#' The function can add only one single row by call.
#'
#' Labels can be formatted with [as_paragraph()].
#' @inheritParams add_body_row
#' @family functions for row and column operations in a flextable
#' @seealso [flextable()], [set_caption()]
#' @examples
#' library(flextable)
#'
#' ft01 <- fp_text_default(color = "red")
#' ft02 <- fp_text_default(color = "orange")
#'
#' pars <- as_paragraph(
#'   as_chunk(c("(1)", "(2)"), props = ft02), " ",
#'   as_chunk(
#'     c(
#'       "My tailor is rich",
#'       "My baker is rich"
#'     ),
#'     props = ft01
#'   )
#' )
#'
#' ft_1 <- flextable(head(mtcars))
#' ft_1 <- add_footer_row(ft_1,
#'   values = pars,
#'   colwidths = c(5, 6), top = FALSE
#' )
#' ft_1 <- add_footer_row(ft_1,
#'   values = pars,
#'   colwidths = c(3, 8), top = TRUE
#' )
#' ft_1
#'
#' ft_2 <- flextable(head(airquality))
#' ft_2 <- add_footer_row(ft_2,
#'   values = c("Measure", "Time"),
#'   colwidths = c(4, 2), top = TRUE
#' )
#' ft_2 <- theme_box(ft_2)
#' ft_2
add_footer_row <- function(x, top = TRUE, values = character(0), colwidths = integer(0)) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "add_footer_row()"))
  }

  if (sum(colwidths) != length(x$col_keys)) {
    stop(sprintf(
      "`colwidths` argument specify room for %.0f columns but %.0f are expected.",
      sum(colwidths), length(x$col_keys)
    ))
  }
  if (is.atomic(values)) {
    values <- as.list(values)
  }

  if (inherits(values, "paragraph")) {
    str_values <- vapply(values, function(x) paste0(x$txt, collapse = ""), FUN.VALUE = "")
  } else {
    str_values <- values
  }
  footer_data <- data_from_char(values = str_values, colwidths = colwidths, col_keys = x$col_keys)

  if (nrow_part(x, "footer") < 1) {
    x$footer <- complex_tabpart(data = footer_data, col_keys = x$col_keys, cwidth = dim(x)$widths, cheight = .25)
  } else {
    x$footer <- add_rows_to_tabpart(x$footer, footer_data, first = top)
  }

  row_span <- unlist(lapply(colwidths, function(x) {
    z <- integer(x)
    z[1] <- x
    z
  }))
  i <- ifelse(top, 1, nrow_part(x, "footer"))
  x$footer$spans$rows[i, ] <- row_span
  col_j <- which(row_span > 0)

  if (inherits(values, "paragraph")) {
    for (j in seq_along(col_j)) {
      x <- mk_par(x, i = i, j = col_j[j], value = values[j], part = "footer")
    }
  }

  x
}

data_from_char <- function(values, colwidths, col_keys) {
  if (is.list(values)) {
    values <- as.character(unlist(values))
  } else if (!is.atomic(values)) {
    stop("'values' must be an atomic vector or a list.")
  }

  values_ <- inverse.rle(structure(list(lengths = colwidths, values = values), class = "rle"))
  values_ <- as.list(values_)

  names(values_) <- col_keys
  as.data.frame(values_, check.names = FALSE, stringsAsFactors = FALSE)
}

# add labels as spanned rows ----

#' @export
#' @title Add full-width rows to the header
#'
#' @description Add one or more rows to the header where each label
#' spans all columns (all cells merged into one). Useful for adding
#' titles or subtitles above the column headers.
#'
#' @inheritParams args_x_only
#' @param values a character vector or a call to [as_paragraph()]
#' to get formated content, each element will
#' be added as a new row.
#' @param top should the row be inserted at the top
#' or the bottom. Default to TRUE.
#' @family functions for row and column operations in a flextable
#' @examples
#' # ex 1----
#' ft_1 <- flextable(head(iris))
#' ft_1 <- add_header_lines(ft_1, values = "blah blah")
#' ft_1 <- add_header_lines(ft_1, values = c("blah 1", "blah 2"))
#' ft_1 <- autofit(ft_1)
#' ft_1
#'
#' # ex 2----
#' ft01 <- fp_text_default(color = "red")
#' ft02 <- fp_text_default(color = "orange")
#' ref <- c("(1)", "(2)")
#' pars <- as_paragraph(
#'   as_chunk(ref, props = ft02), " ",
#'   as_chunk(rep("My tailor is rich", length(ref)), props = ft01)
#' )
#'
#' ft_2 <- flextable(head(mtcars))
#' ft_2 <- add_header_lines(ft_2, values = pars, top = FALSE)
#' ft_2 <- add_header_lines(ft_2, values = ref, top = TRUE)
#' ft_2 <- add_footer_lines(ft_2, values = "blah", top = TRUE)
#' ft_2 <- add_footer_lines(ft_2, values = pars, top = TRUE)
#' ft_2 <- add_footer_lines(ft_2, values = ref, top = FALSE)
#' ft_2 <- autofit(ft_2)
#' ft_2
add_header_lines <- function(x, values = character(0), top = TRUE) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "add_header_lines()"))
  }
  values_map <- values
  if (top) values_map <- rev(values_map)

  if (inherits(values, "paragraph")) {
    for (ivalue in seq_len(length(values_map))) {
      x <- add_header_row(x, values = "", colwidths = length(x$col_keys), top = top)
      if (top) {
        i <- 1
      } else {
        i <- nrow_part(x, "header")
      }
      x <- mk_par(x, i = i, j = 1, value = values_map[ivalue], part = "header")
    }
  } else {
    for (value in values_map) {
      x <- add_header_row(x, values = value, colwidths = length(x$col_keys), top = top)
    }
  }


  x
}


#' @export
#' @title Add full-width rows to the footer
#'
#' @description Add one or more rows to the footer where each label
#' spans all columns (all cells merged into one). Useful for adding
#' footnotes or source notes below the table.
#' @inheritParams add_header_lines
#' @family functions for row and column operations in a flextable
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- add_footer_lines(ft_1,
#'   values = c("blah 1", "blah 2")
#' )
#' ft_1
add_footer_lines <- function(x, values = character(0), top = FALSE) {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "add_footer_lines()"))
  }

  ivalues <- seq_len(length(values))
  if (top) {
    ivalues <- rev(ivalues)
  }

  if (inherits(values, "paragraph")) {
    for (ivalue in ivalues) {
      x <- add_footer_row(x, values = "", colwidths = length(x$col_keys), top = top)
      if (top) {
        i <- 1
      } else {
        i <- nrow_part(x, "footer")
      }
      x <- mk_par(x, i = i, j = 1, value = values[ivalue], part = "footer")
    }
  } else {
    for (ivalue in ivalues) {
      x <- add_footer_row(x,
        values = values[ivalue],
        colwidths = length(x$col_keys), top = top
      )
    }
  }

  x
}




# add header/footer with reference table ----

set_part_df <- function(x, mapping = NULL, key = "col_keys", part) {
  keys <- data.frame(
    col_keys = x$col_keys,
    stringsAsFactors = FALSE
  )
  names(keys) <- key

  part_data <- merge(keys, mapping, by = key, all.x = TRUE, all.y = FALSE, sort = FALSE)
  part_data <- part_data[match(keys[[key]], part_data[[key]]), ]

  part_data[[key]] <- NULL

  part_data <- do.call(rbind, part_data)
  dimnames(part_data) <- NULL

  part_data <- as.data.frame(part_data, stringsAsFactors = FALSE)
  names(part_data) <- x$col_keys

  if (length(x$blanks)) {
    blank_ <- character(nrow(part_data))
    replace_ <- lapply(x$blanks, function(x, bl) bl, blank_)
    names(replace_) <- x$blanks
    part_data[x$blanks] <- replace_
  }


  colwidths <- x[[part]]$colwidths
  x[[part]] <- eval(
    call(
      class(x[[part]]),
      data = part_data,
      col_keys = x$col_keys,
      cwidth = .75, cheight = .25
    )
  )
  cheight <- optimal_sizes(x[[part]])$heights

  x[[part]]$colwidths <- colwidths
  x[[part]]$rowheights <- cheight
  x
}

#' @export
#' @rdname set_header_footer_df
#' @name set_header_footer_df
#' @title Replace the entire header or footer from a data frame
#'
#' @description Replace all header or footer rows using a mapping data frame.
#' Unlike [set_header_labels()] which only renames the bottom header row,
#' this function rebuilds the entire header (or footer) structure.
#'
#' The data.frame must contain a column whose values match flextable
#' `col_keys` argument, this column will be used as join key. The
#' other columns will be displayed as header or footer rows. The leftmost column
#' is used as the top header/footer row and the rightmost column
#' is used as the bottom header/footer row.
#'
#' @inheritParams args_x_only
#' @param mapping a `data.frame` specyfing for each colname
#' content of the column.
#' @param key column to use as key when joigning data_mapping.
#' @examples
#' typology <- data.frame(
#'   col_keys = c(
#'     "Sepal.Length", "Sepal.Width", "Petal.Length",
#'     "Petal.Width", "Species"
#'   ),
#'   what = c("Sepal", "Sepal", "Petal", "Petal", "Species"),
#'   measure = c("Length", "Width", "Length", "Width", "Species"),
#'   stringsAsFactors = FALSE
#' )
#'
#' ft_1 <- flextable(head(iris))
#' ft_1 <- set_header_df(ft_1, mapping = typology, key = "col_keys")
#' ft_1 <- merge_h(ft_1, part = "header")
#' ft_1 <- merge_v(ft_1, j = "Species", part = "header")
#' ft_1 <- theme_vanilla(ft_1)
#' ft_1 <- fix_border_issues(ft_1)
#' ft_1
#' @family functions for row and column operations in a flextable
set_header_df <- function(x, mapping = NULL, key = "col_keys") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "set_header_df()"))
  }

  set_part_df(x, mapping = mapping, key = key, part = "header")
}

#' @rdname set_header_footer_df
#' @export
#' @examples
#'
#'
#' typology <- data.frame(
#'   col_keys = c(
#'     "Sepal.Length", "Sepal.Width", "Petal.Length",
#'     "Petal.Width", "Species"
#'   ),
#'   unit = c("(cm)", "(cm)", "(cm)", "(cm)", ""),
#'   stringsAsFactors = FALSE
#' )
#' ft_2 <- set_footer_df(ft_1, mapping = typology, key = "col_keys")
#' ft_2 <- italic(ft_2, italic = TRUE, part = "footer")
#' ft_2 <- theme_booktabs(ft_2)
#' ft_2 <- fix_border_issues(ft_2)
#' ft_2
set_footer_df <- function(x, mapping = NULL, key = "col_keys") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "set_footer_df()"))
  }

  set_part_df(x, mapping = mapping, key = key, part = "footer")
}

#' @importFrom data.table tstrsplit
#' @export
#' @title Split column names using a separator into multiple rows
#' @description This function is used to separate and place individual
#' labels in their own rows if your variable names contain multiple
#' delimited labels.
#' \if{html}{\out{
#' <img src="https://www.ardata.fr/img/flextable-imgs/flextable-016.png" alt="add_header illustration" style="width:100\%;">
#' }}
#' @inheritParams args_x_only
#' @param opts Optional treatments to apply to the resulting header part.
#' This should be a character vector with support for multiple values.
#'
#' Supported values include:
#'
#' - "span-top": This operation spans empty cells with the first non-empty
#' cell, applied column by column.
#' - "center-hspan": Center the cells that are horizontally spanned.
#' - "bottom-vspan": Aligns to the bottom the cells treated at the  when "span-top" is applied.
#' - "default-theme": Applies the theme set in `set_flextable_defaults(theme_fun = ...)` to the new header part.
#' @param split a regular expression (unless `fixed = TRUE`)
#' to use for splitting.
#' @param fixed logical. If TRUE match `split` exactly,
#' otherwise use regular expressions.
#' @family functions for row and column operations in a flextable
#' @examples
#' library(flextable)
#'
#' x <- data.frame(
#'   Species = as.factor(c("setosa", "versicolor", "virginica")),
#'   Sepal.Length_mean = c(5.006, 5.936, 6.588),
#'   Sepal.Length_sd = c(0.35249, 0.51617, 0.63588),
#'   Sepal.Width_mean = c(3.428, 2.77, 2.974),
#'   Sepal.Width_sd = c(0.37906, 0.3138, 0.3225),
#'   Petal.Length_mean = c(1.462, 4.26, 5.552),
#'   Petal.Length_sd = c(0.17366, 0.46991, 0.55189),
#'   Petal.Width_mean = c(0.246, 1.326, 2.026),
#'   Petal.Width_sd = c(0.10539, 0.19775, 0.27465)
#' )
#'
#' ft_1 <- flextable(x)
#' ft_1 <- colformat_double(ft_1, digits = 2)
#' ft_1 <- theme_box(ft_1)
#' ft_1 <- separate_header(
#'   x = ft_1,
#'   opts = c("span-top", "bottom-vspan")
#' )
#' ft_1
separate_header <- function(x,
                            opts = c(
                              "span-top", "center-hspan",
                              "bottom-vspan", "default-theme"
                            ),
                            split = "[_\\.]",
                            fixed = FALSE) {
  if (nrow_part(x, "header") > 1) {
    stop("the flextable object already have additional row(s),\nrun `separate_header()` before any header row augmentation")
  }

  ref_list <- tstrsplit(x$col_keys, split = split, fill = "", fixed = fixed)
  ref_list <- rev(ref_list)
  last_names <- ref_list[[1]]
  names(last_names) <- x$col_keys
  x <- set_header_labels(x, values = last_names)
  add_labels <- ref_list[-1]
  for (labels in add_labels) {
    # dont span ""
    tmp_labels <- labels
    tmp_labels[tmp_labels %in% ""] <-
      paste0("dummy-", seq_len(sum(tmp_labels %in% "")))
    rle_labs <- rle(tmp_labels)
    rle_labs$values[grepl("^dummy\\-", rle_labs$values)] <- ""

    x <- add_header_row(
      x = x, top = TRUE,
      values = rle_labs$values,
      colwidths = rle_labs$lengths
    )
  }
  names(ref_list) <- letters[seq_along(ref_list)]
  ref_list <- matrix(unlist(ref_list) %in% "", ncol = length(ref_list))

  if ("default-theme" %in% opts) {
    tmp <- do.call(
      get_flextable_defaults()$theme_fun,
      list(x)
    )
    x$header <- tmp$header
  }

  if ("span-top" %in% opts) {
    for (j in seq_len(nrow(ref_list))) {
      if (ref_list[j, 1]) {
        to <- rle(ref_list[j, ])$lengths[1] + 1
        if (all(x$header$spans$rows[seq(1, to), j] %in% 1)) {#can be v-merged
          x <- merge_at(
            x = x, i = seq(1, to), j = j,
            part = "header"
          )
        }

        if ("bottom-vspan" %in% opts) {
          x <- valign(
            x = x, i = seq(1, to), j = j,
            valign = "bottom", part = "header"
          )
        }
      }
    }
  }

  if ("center-hspan" %in% opts) {
    nr <- nrow(x[["header"]]$spans$rows)
    header_spans <- fortify_span(x, parts = "header")
    header_spans <- header_spans[header_spans$rowspan > 1, ]
    header_spans <- split(header_spans$.col_id, header_spans$.row_id)
    for (i in seq_along(header_spans)) {
      x <- align(
        x = x, i = i, j = as.character(header_spans[[i]]),
        align = "center", part = "header"
      )
    }
  }
  fix_border_issues(x)
}
