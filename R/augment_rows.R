#' @title Set flextable's headers labels
#'
#' @description This function set labels for specified columns
#' in a single row header of a flextable.
#'
#' @param x a `flextable` object
#' @param ... named arguments (names are data colnames), each element is a single character
#' value specifying label to use.
#' @param values a named list (names are data colnames), each element is a single character
#' value specifying label to use. If provided, argument `...` will be ignored.
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
#' @export
#' @family functions to add rows in header or footer
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_set_header_labels_1.png}{options: width="400"}}
set_header_labels <- function(x, ..., values = NULL) {
  if (!inherits(x, "flextable")) stop("set_header_labels supports only flextable objects.")

  if (is.null(values)) {
    values <- list(...)
    if (nrow_part(x, "header") < 1) {
      stop("there is no header row to be replaced")
    }
  }

  values <- values[names(values) %in% names(x$header$dataset)]
  x$header$content[nrow_part(x, "header"), names(values)] <- as_paragraph(as_chunk(unlist(values)))

  x
}


#' @export
#' @title delete flextable part
#'
#' @description indicate to not print a part of
#' the flextable, i.e. an header, footer or the body.
#'
#' @param x a `flextable` object
#' @param part partname of the table to delete (one of 'body', 'header' or 'footer').
#' @examples
#' ft <- flextable(head(iris))
#' ft <- delete_part(x = ft, part = "header")
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_delete_part_1.png}{options: width="300"}}
delete_part <- function(x, part = "header") {
  if (!inherits(x, "flextable")) stop("delete_part supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE)
  nrow_ <- nrow(x[[part]]$dataset)
  x[[part]] <- complex_tabpart(
    data = x[[part]]$dataset[-seq_len(nrow_), , drop = FALSE],
    col_keys = x$col_keys,
    cwidth = x[[part]]$colwidths, cheight = x[[part]]$rowheights
  )
  x
}


as_new_data <- function(x, ..., values = NULL) {
  if (is.null(values)) {
    values <- list(...)
  }

  if (!is.list(values)) {
    stop("argument 'values' must be a list")
  }

  args_ <- lapply(x$col_keys, function(x, n) rep(NA, n), n = length(values[[1]]))
  names(args_) <- x$col_keys
  args_[names(values)] <- values

  data.frame(as.list(args_), check.names = FALSE, stringsAsFactors = FALSE)
}

# add header/footer content ----

#' @export
#' @title Add column values as new lines in body
#'
#' @description
#' The function adds a list of values to be inserted as
#' new rows in the body. The values are inserted in
#' existing columns of the input data of the flextable.
#' Rows can be inserted at the top or the bottom of
#' the body.
#'
#' If some columns are not provided, they will be replaced by
#' `NA` and displayed as empty.
#' @param x a flextable object
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
#' @family functions that add lines in the table
#' @seealso [flextable()]
add_body <- function(x, top = TRUE, ..., values = NULL) {
  if (!inherits(x, "flextable")) {
    stop("add_body supports only flextable objects.")
  }

  new_data <- as_new_data(x = x, ..., values = values)
  x$body <- add_rows(x$body, new_data, first = top)
  x
}



#' @export
#' @title Add column values as new lines in header
#'
#' @description
#' The function adds a list of values to be inserted as
#' new rows in the header. The values are inserted in
#' existing columns of the input data of the flextable.
#' Rows can be inserted at the top or the bottom of
#' the header.
#'
#' If some columns are not provided, they will be replaced by
#' `NA` and displayed as empty.
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
#' @family functions that add lines in the table
#' @family functions to add rows in header or footer
#' @section Illustrations:
#' \if{html}{\figure{fig_add_header_1.png}{options: width="300"}}
add_header <- function(x, top = TRUE, ..., values = NULL) {
  if (!inherits(x, "flextable")) {
    stop("add_header supports only flextable objects.")
  }

  header_data <- as_new_data(x = x, ..., values = values)
  x$header <- add_rows(x$header, header_data, first = top)

  x
}

#' @export
#' @title Add column values as new lines in footer
#'
#' @description
#' The function adds a list of values to be inserted as
#' new rows in the footer. The values are inserted in
#' existing columns of the input data of the flextable.
#' Rows can be inserted at the top or the bottom of
#' the footer.
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
#' @family functions that add lines in the table
#' @family functions to add rows in header or footer
#' @section Illustrations:
#' \if{html}{\figure{fig_add_footer_1.png}{options: width="300"}}
add_footer <- function(x, top = TRUE, ..., values = NULL) {
  if (!inherits(x, "flextable")) {
    stop("add_footer supports only flextable objects.")
  }

  footer_data <- as_new_data(x = x, ..., values = values)

  if (nrow_part(x, "footer") < 1) {
    x$footer <- complex_tabpart(data = footer_data, col_keys = x$col_keys, cwidth = .75, cheight = .25)
  } else {
    x$footer <- add_rows(x$footer, footer_data, first = top)
  }

  x
}

# add spanned labels as a single row ----

#' @export
#' @title Add body labels
#'
#' @description Add a row of new columns labels in body part.
#' Labels can be spanned along multiple columns, as merged cells.
#'
#' Labels are associated with a number of columns
#' to merge that default to one if not specified.
#' In this case, you have to make sure that the
#' number of labels is equal to the number of columns displayed.
#'
#' The function can add only one single row by call.
#' @param x a flextable object
#' @param top should the row be inserted at the top or the bottom.
#' @param values values to add (as a list).
#' @param colwidths the number of columns to merge in the row for each label
#'
#' @examples
#' ft <- flextable(head(iris))
#' ft <- add_body_row(ft, values = list(1000), colwidths = 5)
#' ft
#' @family functions that add lines in the table
#' @seealso [flextable()], [add_header_row()]
add_body_row <- function(x, top = TRUE, values = list(), colwidths = integer(0)) {
  if (!inherits(x, "flextable")) {
    stop("add_body_row supports only flextable objects.")
  }

  if (!is.list(values)) stop("values must be a list.")

  if (length(colwidths) < 1) {
    colwidths <- rep(1L, length(x$col_keys))
  }

  if (sum(colwidths) != length(x$col_keys)) {
    stop("colwidths' sum must be equal to the number of col_keys (", length(x$col_keys), ")")
  }

  if (any(sapply(values, length) > 1)) {
    stop("argument 'values' is expected to be made of elements of length 1")
  }

  values_ <- inverse.rle(structure(list(lengths = colwidths, values = values), class = "rle"))

  names(values_) <- x$col_keys
  body_data <- as.data.frame(values_, check.names = FALSE, stringsAsFactors = FALSE)

  if (nrow_part(x, "body") < 1) {
    x$body <- complex_tabpart(
      data = body_data, col_keys = x$col_keys,
      cwidth = dim(x)$widths, cheight = .25
    )
  } else {
    x$body <- add_rows(x$body, body_data, first = top)
  }

  row_span <- unlist(lapply(colwidths, function(x) {
    z <- integer(x)
    z[1] <- x
    z
  }))
  i <- ifelse(top, 1, nrow(x$body$dataset))
  x$body$spans$rows[i, ] <- row_span

  x
}

#' @export
#' @title Add header labels
#'
#' @description Add a row of new columns labels in header part.
#' Labels can be spanned along multiple columns, as merged cells.
#'
#' Labels are associated with a number of columns
#' to merge that default to one if not specified.
#' In this case, you have to make sure that the
#' number of labels is equal to the number of columns displayed.
#'
#' The function can add only one single row by call.
#'
#' @param x a flextable object
#' @param top should the row be inserted at the
#' top or the bottom. Default to TRUE.
#' @param values values to add, a character vector (as header rows
#' contains only character values/columns) or a list.
#' @param colwidths the number of columns used for each label
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- add_header_row(ft_1,
#'   values = "blah blah", colwidths = 5
#' )
#' ft_1 <- add_header_row(ft_1,
#'   values = c("blah", "blah"),
#'   colwidths = c(3, 2)
#' )
#' ft_1
#' @family functions that add lines in the table
#' @family functions to add rows in header or footer
#' @section Illustrations:
#' \if{html}{\figure{fig_add_header_row_1.png}{options: width="300"}}
add_header_row <- function(x, top = TRUE, values = character(0), colwidths = integer(0)) {
  if (!inherits(x, "flextable")) {
    stop("add_header_row supports only flextable objects.")
  }

  if (length(colwidths) < 1) {
    colwidths <- rep(1L, length(x$col_keys))
  }

  if (sum(colwidths) != length(x$col_keys)) {
    stop("colwidths'sum must be equal to the number of col_keys (", length(x$col_keys), ")")
  }
  if (is.list(values)) {
    values <- as.character(unlist(values))
  } else if (!is.character(values)) {
    stop("'values' must be a character vector or a list.")
  }

  values_ <- inverse.rle(structure(list(lengths = colwidths, values = values), class = "rle"))
  values_ <- as.list(values_)

  names(values_) <- x$col_keys
  header_data <- as.data.frame(values_, check.names = FALSE, stringsAsFactors = FALSE)

  if (nrow_part(x, "header") < 1) {
    x$header <- complex_tabpart(data = header_data, col_keys = x$col_keys, cwidth = dim(x)$widths, cheight = .25)
  } else {
    x$header <- add_rows(x$header, header_data, first = top)
  }


  row_span <- unlist(lapply(colwidths, function(x) {
    z <- integer(x)
    z[1] <- x
    z
  }))
  i <- ifelse(top, 1, nrow(x$header$dataset))
  x$header$spans$rows[i, ] <- row_span

  x
}

#' @export
#' @title Add footer labels
#'
#' @description Add a row of new columns labels in footer part.
#' Labels can be spanned along multiple columns, as merged cells.
#'
#' Labels are associated with a number of columns
#' to merge that default to one if not specified.
#' In this case, you have to make sure that the
#' number of labels is equal to the number of columns displayed.
#'
#' The function can add only one single row by call.
#' @inheritParams add_body_row
#' @family functions that add lines in the table
#' @family functions to add rows in header or footer
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- add_footer_row(ft_1,
#'   values = "blah blah", colwidths = 5
#' )
#' ft_1 <- add_footer_row(ft_1,
#'   values = c("blah", "blah"),
#'   colwidths = c(3, 2)
#' )
#' ft_1
#' @section Illustrations:
#' \if{html}{\figure{fig_add_footer_row_1.png}{options: width="300"}}
add_footer_row <- function(x, top = TRUE, values = list(), colwidths = integer(0)) {
  if (!inherits(x, "flextable")) {
    stop("add_footer_row supports only flextable objects.")
  }

  if (sum(colwidths) != length(x$col_keys)) {
    stop("colwidths' sum must be equal to the number of col_keys (", length(x$col_keys), ")")
  }

  if (is.character(values)) {
    values <- as.list(values)
  }

  if (!is.list(values)) stop("values must be a list.")

  values_ <- inverse.rle(structure(list(lengths = colwidths, values = values), class = "rle"))
  values_ <- as.list(values_)

  names(values_) <- x$col_keys

  footer_data <- as.data.frame(values_, check.names = FALSE, stringsAsFactors = FALSE)

  if (nrow_part(x, "footer") < 1) {
    x$footer <- complex_tabpart(data = footer_data, col_keys = x$col_keys, cwidth = dim(x)$widths, cheight = .25)
  } else {
    x$footer <- add_rows(x$footer, footer_data, first = top)
  }

  row_span <- unlist(lapply(colwidths, function(x) {
    z <- integer(x)
    z[1] <- x
    z
  }))
  i <- ifelse(top, 1, nrow(x$footer$dataset))
  x$footer$spans$rows[i, ] <- row_span

  x
}

# add labels as spanned rows ----

#' @export
#' @title Add labels as new rows in the header
#'
#' @description Add labels as new rows in the header,
#' where all columns are merged.
#'
#' This is a sugar function to be used when you need to
#' add labels in the header, most of the time it will
#' be used to adding titles on the top rows of the flextable.
#'
#' @param x a `flextable` object
#' @param values a character vector, each element will
#' be added as a new row.
#' @param top should the row be inserted at the top
#' or the bottom. Default to TRUE.
#' @family functions that add rows in the table
#' @family functions to add rows in header or footer
#' @section Illustrations:
#' \if{html}{\figure{fig_add_header_lines_1.png}{options: width="300"}}
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- add_header_lines(ft_1, values = "blah blah")
#' ft_1 <- add_header_lines(ft_1, values = c("blah 1", "blah 2"))
#' ft_1 <- autofit(ft_1)
#' ft_1
add_header_lines <- function(x, values = character(0), top = TRUE) {
  if (!inherits(x, "flextable")) {
    stop("add_header_lines supports only flextable objects.")
  }

  for (value in values) {
    x <- add_header_row(x, values = value, colwidths = length(x$col_keys), top = top)
  }
  x
}


#' @export
#' @title Add labels as new rows in the footer
#'
#' @description Add labels as new rows in the footer,
#' where all columns are merged.
#'
#' This is a sugar function to be used when you need to
#' add labels in the footer, a footnote for example.
#' @inheritParams add_header_lines
#' @family functions that add lines in the table
#' @family functions to add rows in header or footer
#' @section Illustrations:
#' \if{html}{\figure{fig_add_footer_lines_1.png}{options: width="300"}}
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- add_footer_lines(ft_1,
#'   values = c("blah 1", "blah 2")
#' )
#' ft_1
add_footer_lines <- function(x, values = character(0), top = FALSE) {
  if (!inherits(x, "flextable")) {
    stop("add_footer_lines supports only flextable objects.")
  }

  for (value in values) {
    x <- add_footer_row(x, values = value, colwidths = length(x$col_keys), top = top)
  }
  x
}




# add header/footer with reference table ----

set_part_df <- function(x, mapping = NULL, key = "col_keys", part) {
  keys <- data.frame(col_keys = x$col_keys, stringsAsFactors = FALSE)
  names(keys) <- key

  header_data <- merge(keys, mapping, by = key, all.x = TRUE, all.y = FALSE, sort = FALSE)
  header_data <- header_data[match(keys[[key]], header_data[[key]]), ]

  header_data[[key]] <- NULL

  header_data <- do.call(rbind, header_data)
  dimnames(header_data) <- NULL

  header_data <- as.data.frame(header_data, stringsAsFactors = FALSE)
  names(header_data) <- x$col_keys

  if (length(x$blanks)) {
    blank_ <- character(nrow(header_data))
    replace_ <- lapply(x$blanks, function(x, bl) bl, blank_)
    names(replace_) <- x$blanks
    header_data[x$blanks] <- replace_
  }


  colwidths <- x[[part]]$colwidths
  x[[part]] <- eval(call(class(x[[part]]), data = header_data, col_keys = x$col_keys, cwidth = .75, cheight = .25))
  cheight <- optimal_sizes(x[[part]])$heights

  x[[part]]$colwidths <- colwidths
  x[[part]]$rowheights <- cheight
  x
}

#' @export
#' @rdname set_header_footer_df
#' @name set_header_footer_df
#' @title Set flextable's header or footer rows
#'
#' @description Use a data.frame to specify flextable's header or footer rows.
#'
#' The data.frame must contain a column whose values match flextable
#' `col_keys` argument, this column will be used as join key. The
#' other columns will be displayed as header or footer rows. The leftmost column
#' is used as the top header/footer row and the rightmost column
#' is used as the bottom header/footer row.
#'
#' @param x a `flextable` object
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
#' @family functions to add rows in header or footer
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_set_header_footer_df_1.png}{options: width="400"}}
#'
#' \if{html}{\figure{fig_set_header_footer_df_2.png}{options: width="400"}}
set_header_df <- function(x, mapping = NULL, key = "col_keys") {
  if (!inherits(x, "flextable")) stop("set_header_labels supports only flextable objects.")
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
  if (!inherits(x, "flextable")) stop("set_header_labels supports only flextable objects.")
  set_part_df(x, mapping = mapping, key = key, part = "footer")
}
