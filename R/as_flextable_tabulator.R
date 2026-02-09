# main -----

#' @export
#' @title Create pivot-style summary tables
#' @description It tabulates a data.frame representing an aggregation
#' which is then transformed as a flextable with
#' [as_flextable][as_flextable.tabulator]. The function
#' allows to define any display with the syntax of flextable in
#' a table whose layout is showing dimensions of the aggregation
#' across rows and columns.
#' \if{html}{\out{
#' <img src="https://www.ardata.fr/img/flextable-imgs/ft-0-7-2-001-square.png" alt="tabulator illustration" style="width:100\%;">
#' }}
#' @note
#' This is very first version of the function; be aware it
#' can evolve or change.
#' @param x an aggregated data.frame
#' @param rows column names to use in rows dimensions
#' @param columns column names to use in columns dimensions
#' @param datasup_first additional data that will be merged with
#' table and placed after the columns presenting
#' the row dimensions.
#' @param datasup_last additional data that will be merged with
#' table and placed at the end of the table.
#' @param hidden_data additional data that will be merged with
#' table, the columns are not presented but can be used
#' with [compose()] or [mk_par()] function.
#' @param row_compose a list of call to [as_paragraph()] - these
#' calls will be applied to the row dimensions (the name is
#' used to target the displayed column).
#' @param ... named arguments calling function [as_paragraph()].
#' The names are used as labels and the values are evaluated
#' when the flextable is created.
#' @return an object of class `tabulator`.
#' @examples
#' \dontrun{
#' set_flextable_defaults(digits = 2, border.color = "gray")
#'
#' library(data.table)
#' # example 1 ----
#' if (require("stats")) {
#'   dat <- aggregate(breaks ~ wool + tension,
#'     data = warpbreaks, mean
#'   )
#'
#'   cft_1 <- tabulator(
#'     x = dat, rows = "wool",
#'     columns = "tension",
#'     `mean` = as_paragraph(as_chunk(breaks)),
#'     `(N)` = as_paragraph(as_chunk(length(breaks), formatter = fmt_int))
#'   )
#'
#'   ft_1 <- as_flextable(cft_1)
#'   ft_1
#' }
#'
#' # example 2 ----
#' if (require("ggplot2")) {
#'   multi_fun <- function(x) {
#'     list(mean = mean(x), sd = sd(x))
#'   }
#'
#'   dat <- as.data.table(ggplot2::diamonds)
#'   dat <- dat[cut %in% c("Fair", "Good", "Very Good")]
#'
#'   dat <- dat[, unlist(lapply(.SD, multi_fun),
#'     recursive = FALSE
#'   ),
#'   .SDcols = c("z", "y"),
#'   by = c("cut", "color")
#'   ]
#'
#'   tab_2 <- tabulator(
#'     x = dat, rows = "color",
#'     columns = "cut",
#'     `z stats` = as_paragraph(as_chunk(fmt_avg_dev(z.mean, z.sd, digit2 = 2))),
#'     `y stats` = as_paragraph(as_chunk(fmt_avg_dev(y.mean, y.sd, digit2 = 2)))
#'   )
#'   ft_2 <- as_flextable(tab_2)
#'   ft_2 <- autofit(x = ft_2, add_w = .05)
#'   ft_2
#' }
#'
#' # example 3 ----
#' # data.table version
#' dat <- melt(as.data.table(iris),
#'   id.vars = "Species",
#'   variable.name = "name", value.name = "value"
#' )
#' dat <- dat[,
#'   list(
#'     avg = mean(value, na.rm = TRUE),
#'     sd = sd(value, na.rm = TRUE)
#'   ),
#'   by = c("Species", "name")
#' ]
#' # dplyr version
#' # library(dplyr)
#' # dat <- iris %>%
#' #   pivot_longer(cols = -c(Species)) %>%
#' #   group_by(Species, name) %>%
#' #   summarise(avg = mean(value, na.rm = TRUE),
#' #   sd = sd(value, na.rm = TRUE),
#' #   .groups = "drop")
#'
#' tab_3 <- tabulator(
#'   x = dat, rows = c("Species"),
#'   columns = "name",
#'   `mean (sd)` = as_paragraph(
#'     as_chunk(avg),
#'     " (", as_chunk(sd), ")"
#'   )
#' )
#' ft_3 <- as_flextable(tab_3)
#' ft_3
#'
#' init_flextable_defaults()
#' }
#' @importFrom rlang enquos enquo call_args
#' @importFrom data.table rleidv as.data.table
#' @seealso [as_flextable.tabulator()], [summarizor()],
#' [as_grouped_data()], [tabulator_colnames()]
tabulator <- function(x, rows, columns,
                      datasup_first = NULL,
                      datasup_last = NULL,
                      hidden_data = NULL,
                      row_compose = list(),
                      ...) {
  stopifnot(
    `rows can not be empty` = length(rows) > 0,
    `columns can not be empty` = length(columns) > 0
  )
  use_labels <- attr(x, "use_labels")
  n_by <- attr(x, "n_by")

  x <- as.data.frame(x)

  row_compose <- enquo(row_compose)
  row_compose <- call_args(row_compose)

  col_exprs <- enquos(...)
  data_colnames <- setdiff(colnames(x), c(rows, columns))
  col_expr_names <- names(col_exprs)

  hidden_columns <- map_hidden_columns(
    dat = x, columns = columns,
    rows = rows
  )

  x <- add_fake_columns(x, col_expr_names)
  supp_colnames <- setdiff(colnames(datasup_first), rows)
  supp_colnames_last <- setdiff(colnames(datasup_last), rows)
  visible_columns <- map_visible_columns(
    dat = x, columns = columns, rows = rows,
    supp_colnames = supp_colnames,
    supp_colnames_last = supp_colnames_last,
    value_names = col_expr_names
  )

  # check dimensions
  cts <- as.data.table(x)[, c("cts") := .N, by = c(columns, rows)]
  setDF(cts)
  cts <- cts[cts$cts > 1, ]
  if (nrow(cts) > 0) {
    all_dims <- paste0("`", c(columns, rows), "`", collapse = ", ")
    stop(sprintf(
      "number of rows is not unique for some combinations of rows and columns: %s.",
      all_dims
    ))
  }

  .formula <- paste(
    paste0("`", rows, "`", collapse = "+"),
    "~", paste0("`", columns, "`", collapse = "+")
  )
  value_vars <- c(data_colnames, col_expr_names)

  dat <- dcast(
    data = as.data.table(x),
    formula = .formula,
    value.var = value_vars, sep = "@"
  )
  setDF(dat)

  dat <- merge_additional_dataset(dat, datasup_first, rows = rows)
  dat <- merge_additional_dataset(dat, hidden_data, rows = rows)
  dat <- merge_additional_dataset(dat, datasup_last, rows = rows)
  setDF(dat)

  z <- list(
    data = dat,
    rows = rows,
    columns = columns,
    visible_columns = visible_columns,
    hidden_columns = hidden_columns,
    col_exprs = col_exprs,
    row_exprs = row_compose,
    use_labels = use_labels,
    n_by = n_by
  )

  class(z) <- "tabulator"

  z
}


#' @export
#' @title Transform a 'tabulator' object into a flextable
#' @description [tabulator()] object can be transformed as a flextable
#' with method [as_flextable()].
#' @param x result from [tabulator()]
#' @param separate_with columns used to sepatate the groups
#' with an horizontal line.
#' @param big_border,small_border big and small border properties defined
#' by a call to [fp_border_default()] or [officer::fp_border()].
#' @param rows_alignment,columns_alignment alignments to apply to
#' columns corresponding to `rows` and `columns`; see arguments
#' `rows` and `columns` in [tabulator()].
#' @param label_rows labels to use for the first column names, i.e.
#' the *row* column names. It must be a named vector, the values will
#' be matched based on the names.
#' @param spread_first_col if TRUE, first row is spread as a new line separator
#' instead of being a column. This helps to reduce the width and allows for
#' clear divisions.
#' @param expand_single if FALSE (the default), groups with only one
#' row will not be expanded with a title row. If TRUE,
#' single row groups and multi-row groups are all
#' restructured.
#' @param sep_w blank column separators'width to be used. If 0,
#' blank column separators will not be used.
#' @param unit unit of argument `sep_w`, one of "in", "cm", "mm".
#' @param ... unused argument
#' @family as_flextable methods
#' @seealso [summarizor()], [as_grouped_data()]
#' @examples
#' \dontrun{
#' library(flextable)
#'
#' set_flextable_defaults(digits = 2, border.color = "gray")
#'
#' if (require("stats")) {
#'   dat <- aggregate(breaks ~ wool + tension,
#'     data = warpbreaks, mean
#'   )
#'
#'   cft_1 <- tabulator(
#'     x = dat,
#'     rows = "wool",
#'     columns = "tension",
#'     `mean` = as_paragraph(as_chunk(breaks)),
#'     `(N)` = as_paragraph(
#'       as_chunk(length(breaks))
#'     )
#'   )
#'
#'   ft_1 <- as_flextable(cft_1, sep_w = .1)
#'   ft_1
#' }
#'
#' if (require("stats")) {
#'   set_flextable_defaults(
#'     padding = 1, font.size = 9,
#'     border.color = "orange"
#'   )
#'
#'   ft_2 <- as_flextable(cft_1, sep_w = 0)
#'   ft_2
#' }
#'
#' if (require("stats")) {
#'   set_flextable_defaults(
#'     padding = 6, font.size = 11,
#'     border.color = "white",
#'     font.color = "white",
#'     background.color = "#333333"
#'   )
#'
#'   ft_3 <- as_flextable(
#'     x = cft_1, sep_w = 0,
#'     rows_alignment = "center",
#'     columns_alignment = "right"
#'   )
#'   ft_3
#' }
#'
#' init_flextable_defaults()
#' }
as_flextable.tabulator <- function(
    x, separate_with = character(0),
    big_border = fp_border_default(width = 1.5),
    small_border = fp_border_default(width = .75),
    rows_alignment = "left", columns_alignment = "center",
    label_rows = x$rows, spread_first_col = FALSE,
    expand_single = FALSE,
    sep_w = .05, unit = "in", ...) {
  # get necessary element
  dat <- x$data

  rows <- x$rows
  columns <- x$columns

  if (spread_first_col) {
    dat <- as_grouped_data(dat, groups = rows[1], expand_single = expand_single)
  }

  visible_columns <- x$visible_columns
  hidden_columns <- x$hidden_columns

  col_exprs <- x$col_exprs

  if (sep_w < 0.001) {
    visible_columns <- visible_columns[!visible_columns[[".tab_columns"]] %in% "dummy", ]
  }

  visible_columns_keys <- visible_columns[
    visible_columns$.type. %in% "columns" &
      !visible_columns[[".tab_columns"]] %in% "dummy",
    "col_keys"
  ]
  blank_columns <- visible_columns[
    visible_columns[[".tab_columns"]] %in% "dummy", "col_keys"
  ]

  # create border_h_major from separate_with
  stopifnot(
    `separate_with is not part of rows` =
      length(separate_with) < 1 || all(separate_with %in% rows)
  )

  border_h_major <- integer()

  if (length(separate_with) > 0) {
    rle <- rleidv(dat[separate_with])
    border_h_major <- which(rle != c(-1, rle[-length(rle)])) - 1
    border_h_major <- setdiff(border_h_major, 0)
  }
  if (length(separate_with) > 0 && spread_first_col) {
    border_h_major <- setdiff(border_h_major, which(!is.na(dat[[rows[1]]])))
  }

  if (spread_first_col) {
    visible_columns <- visible_columns[-1, ]
  }

  # for later iteration, a list of visible columns
  # to use when filling the table
  visible_columns_mapping <- visible_columns[visible_columns$.type. %in% "columns" & !visible_columns[[".tab_columns"]] %in% "dummy", ]
  visible_columns_mapping$.type. <- NULL
  visible_columns_mapping <- split(visible_columns_mapping, visible_columns_mapping[columns], drop = TRUE)

  # for later iteration, a list of hidden columns that can
  # be used by expressions defined by the user
  hidden_columns_mapping <- split(hidden_columns, hidden_columns[columns], drop = TRUE)

  ft <- flextable(dat, col_keys = visible_columns$col_keys)
  ft <- border_remove(ft)

  labels_tab <- visible_columns
  labels_tab <- labels_tab[!labels_tab$.tab_columns %in% "dummy", ]
  if (length(col_exprs) > 1) {
    labels <- labels_tab$.tab_columns
    names(labels) <- labels_tab$col_keys
    ft <- set_header_labels(x = ft, values = labels)
  } else {
    labels <- labels_tab[[columns[length(columns)]]]
    names(labels) <- labels_tab$col_keys
    ft <- set_header_labels(x = ft, values = labels)
    columns <- columns[-length(columns)]
  }

  for (j in names(visible_columns_mapping)) {
    visible_columns_mapping_j <- visible_columns_mapping[[j]]
    replication_info <- hidden_columns_mapping[[j]]
    ft$body$dataset[as.character(replication_info$.user_columns)] <- ft$body$dataset[replication_info$col_keys]

    for (i in seq_len(nrow(visible_columns_mapping_j))) {
      colname <- visible_columns_mapping_j[i, "col_keys"]
      exp_name <- visible_columns_mapping_j[i, ".tab_columns"]
      ft <- mk_par(ft, j = colname, value = !!col_exprs[[exp_name]])
    }
    ft$body$dataset[as.character(replication_info$.user_columns)] <- rep(list(NULL), nrow(replication_info))
  }

  row_spanner <- character(length = 0L)
  if (spread_first_col) {
    row_spanner <- rows[1]
    rows <- rows[-1]

    # treatment of groups
    rleid_ <- do.call(rleid, dat[row_spanner])
    table_rleid <- table(rleid_[is.na(dat[[row_spanner]])])
    table_uid <- as.integer(names(table_rleid[table_rleid > 1])) - 1 # considered as title row for non single group

    # write title rows for non single groups
    sel <- rleid_ %in% table_uid
    row_spanner_labels <- dat[[row_spanner]][sel]
    ft <- mk_par(ft, i = sel, value = as_paragraph(row_spanner_labels))
    ft <- merge_h(ft, i = sel)

    # write title rows for single groups
    sna <- !is.na(dat[[row_spanner]])
    sna <- c(sna[-length(sna)] == sna[-1], FALSE) & sna
    row_spanner_labels <- dat[[row_spanner]][sna]
    ft <- mk_par(ft, i = sna, j = 1, value = as_paragraph(row_spanner_labels))
  }

  ft <- merge_v(ft, j = rows, part = "body")
  ft <- valign(ft, valign = "top", j = rows)

  for (j in names(x$row_exprs)) {
    if (!j %in% row_spanner) {
      ft <- mk_par(ft, i = !is.na(dat[[j]]), j = j, value = !!x$row_exprs[[j]])
    } else {
      ft <- mk_par(ft, i = !is.na(dat[[j]]), j = 1, value = !!x$row_exprs[[j]])
    }
  }

  for (column in rev(columns)) {
    rel_ <- rle(visible_columns[[column]])
    rel_$values[rel_$values %in% "dummy"] <- ""
    ft <- add_header_row(
      x = ft,
      values = rel_$values,
      colwidths = rel_$lengths, top = TRUE
    )
    ft <- hline(ft,
      i = 1, j = which(!visible_columns[[column]] %in% c("dummy", rows)),
      border = small_border,
      part = "header"
    )
    ft <- align(x = ft, i = 1, align = "center", part = "header")
  }

  rows_supp <- visible_columns$col_keys[
    visible_columns$.type. %in% c("rows_supp", "rows_supp_last") &
      !visible_columns$.tab_columns %in% "dummy"
  ]
  ft <- merge_v(
    x = ft,
    j = c(rows, rows_supp), part = "header"
  )

  ft <- valign(ft, valign = "bottom", j = c(rows, rows_supp), part = "header")
  ft <- valign(ft, valign = "top", part = "body")

  ft <- align(x = ft, j = visible_columns_keys, align = columns_alignment, part = "all")
  ft <- align(x = ft, j = c(rows, rows_supp), align = rows_alignment, part = "all")

  if (sep_w > 0) {
    ft <- padding(ft, j = blank_columns, padding = 0, part = "all")
  }

  # dummy as blank columns

  ft <- hline(ft, i = border_h_major, border = small_border)

  ft <- hline(ft,
    i = nrow_part(ft, part = "header"),
    j = setdiff(visible_columns$col_keys, blank_columns),
    border = big_border, part = "header"
  )
  ft <- hline_top(x = ft, border = big_border, part = "header")
  ft <- hline_bottom(x = ft, border = big_border, part = "body")

  if (sep_w > 0) {
    ft <- border(ft,
      j = blank_columns,
      border.top = fp_border_default(width = 0),
      border.bottom = fp_border_default(width = 0),
      part = "all"
    )
    ft <- bg(ft, j = blank_columns, bg = "transparent", part = "all")
    ft <- void(ft, j = blank_columns, part = "all")
    ft <- width(ft, j = blank_columns, width = sep_w, unit = unit)
  }

  if (!is.null(names(label_rows))) {
    j_labs <- names(label_rows)
    if (spread_first_col) {
      j_labs <- j_labs[!names(label_rows) %in% row_spanner]
      label_rows <- label_rows[!names(label_rows) %in% row_spanner]
    }
    ft <- mk_par(ft,
      i = 1, j = j_labs,
      value = as_paragraph(as.character(label_rows)),
      part = "header"
    )
  }

  if (spread_first_col) {
    ft <- align(x = ft, i = !is.na(dat[[row_spanner]]), align = columns_alignment)
  }

  if (!is.null(x$use_labels)) {
    for (labj in names(x$use_labels)) {
      if (labj %in% ft$col_keys) {
        ft <- labelizor(
          x = ft, j = labj,
          labels = x$use_labels[[labj]],
          part = "all"
        )
      }
    }
  }
  if (!is.null(x$n_by)) {
    sum_x <- visible_columns[
      visible_columns$.tab_columns %in% names(x$col_exprs)[1] &
        visible_columns$.type. %in% "columns", , drop = FALSE
    ]
    header_row <- length(x$columns)

    for (k in seq_len(nrow(x$n_by))) {
      mask <- rep(TRUE, nrow(sum_x))
      for (col in x$columns) {
        mask <- mask & as.character(sum_x[[col]]) == as.character(x$n_by[[col]][k])
      }
      if (any(mask)) {
        ft <- append_chunks(
          x = ft,
          j = sum_x[mask, "col_keys"][1],
          i = header_row, part = "header",
          as_chunk(x$n_by$n[k], formatter = fmt_header_n)
        )
      }
    }
  }


  ft <- autofit(ft, part = "all", add_w = .2, add_h = .0, unit = "cm")
  ft <- fix_border_issues(ft, part = "all")
  ft
}

# util methods -----

#' @export
#' @describeIn tabulator call `summary()` to get
#' a data.frame describing mappings between variables
#' and their names in the flextable. This data.frame contains
#' a column named `col_keys` where are stored the names that
#' can be used for further selections.
#' @param object an object returned by function
#' `tabulator()`.
summary.tabulator <- function(object, ...) {
  hidden_columns <- object$hidden_columns
  names(hidden_columns)[names(hidden_columns) %in% ".user_columns"] <- "column"
  hidden_columns$.type. <- "hidden"

  visible_columns <- object$visible_columns
  names(visible_columns)[names(visible_columns) %in% ".tab_columns"] <- "column"
  dat <- rbind(visible_columns, hidden_columns)
  dat
}

#' @export
#' @importFrom rlang quo_text
#' @title Column keys of tabulator objects
#' @description The function provides a way to get column keys
#' associated with the flextable corresponding to a [tabulator()]
#' object. It helps in customizing or programing with `tabulator`.
#'
#' The function is using column names from the original
#' dataset, eventually filters and returns the names
#' corresponding to the selection.
#' @param x a [tabulator()] object
#' @param columns column names to look for
#' @param type the type of column to look for, it can be:
#'
#' * 'columns': visible columns, corresponding to names provided
#' in the '...' arguments of your call to 'tabulator()'.
#' * 'hidden': unvisible columns, corresponding to names of
#' the original dataset columns.
#' * 'rows': visible columns used as 'row' content
#' * 'rows_supp': visible columns used as 'rows_supp' content
#' * NULL: any type of column
#' @param ... any filter conditions that use variables
#' names, the same than the argument `columns` of function [tabulator()]
#' (`tabulator(columns = c("col1", "col2"))`).
#' @seealso [tabulator()], [as_flextable.tabulator()]
#' @examples
#' library(flextable)
#'
#' cancer_dat <- data.frame(
#'   count = c(
#'     9L, 5L, 1L, 2L, 2L, 1L, 9L, 3L, 1L, 10L, 2L, 1L, 1L, 2L, 0L, 3L,
#'     2L, 1L, 1L, 2L, 0L, 12L, 4L, 1L, 7L, 3L, 1L, 5L, 5L, 3L, 10L,
#'     4L, 1L, 4L, 2L, 0L, 3L, 1L, 0L, 4L, 4L, 2L, 42L, 28L, 19L, 26L,
#'     19L, 11L, 12L, 10L, 7L, 10L, 5L, 6L, 5L, 0L, 3L, 4L, 3L, 3L,
#'     1L, 2L, 3L
#'   ),
#'   risktime = c(
#'     157L, 77L, 21L, 139L, 68L, 17L, 126L, 63L, 14L, 102L, 55L,
#'     12L, 88L, 50L, 10L, 82L, 45L, 8L, 76L, 42L, 6L, 134L, 71L,
#'     22L, 110L, 63L, 18L, 96L, 58L, 14L, 86L, 42L, 10L, 66L,
#'     35L, 8L, 59L, 32L, 8L, 51L, 28L, 6L, 212L, 130L, 101L,
#'     136L, 72L, 63L, 90L, 42L, 43L, 64L, 21L, 32L, 47L, 14L,
#'     21L, 39L, 13L, 14L, 29L, 7L, 10L
#'   ),
#'   time = rep(as.character(1:7), 3),
#'   histology = rep(as.character(1:3), 21),
#'   stage = rep(as.character(1:3), each = 21)
#' )
#'
#' datasup_first <- data.frame(
#'   time = factor(1:7, levels = 1:7),
#'   zzz = runif(7)
#' )
#'
#' z <- tabulator(cancer_dat,
#'   rows = "time",
#'   columns = c("histology", "stage"),
#'   datasup_first = datasup_first,
#'   n = as_paragraph(as_chunk(count))
#' )
#'
#' j <- tabulator_colnames(
#'   x = z, type = "columns",
#'   columns = c("n"),
#'   stage %in% 1
#' )
#'
#' src <- tabulator_colnames(
#'   x = z, type = "hidden",
#'   columns = c("count"),
#'   stage %in% 1
#' )
#'
#' if (require("scales")) {
#'   colourer <- col_numeric(
#'     palette = c("wheat", "red"),
#'     domain = c(0, 45)
#'   )
#'   ft_1 <- as_flextable(z)
#'   ft_1 <- bg(
#'     ft_1,
#'     bg = colourer, part = "body",
#'     j = j, source = src
#'   )
#'   ft_1
#' }
tabulator_colnames <- function(x, columns, ..., type = NULL) {
  dat <- summary(x)

  if (!is.null(type)) {
    dat <- dat[dat$.type. %in% type, ]
  }

  exprs <- enquos(...)
  exprs_evals <- lapply(exprs, function(expr_filter, dat) {
    check_filter_expr(expr_filter, dat)
    eval_tidy({{ expr_filter }}, data = dat)
  }, dat = dat)
  exprs_evals <- append(exprs_evals, list(dat$column %in% columns))
  keep <- Reduce(`&`, exprs_evals)

  dat["col_keys"][keep, ]
}


#' @export
print.tabulator <- function(x, ...) {
  cat("layout:\n")
  cat(
    "* row(s): ",
    paste0("`", x$rows, "`", collapse = ", "),
    "\n"
  )
  cat(
    "* column(s): ",
    paste0("`", x$columns, "`", collapse = ", "),
    "\n"
  )
  cat(
    "* content(s): ",
    paste0("`", names(x$col_exprs), "`", collapse = ", "),
    "\n"
  )
  visible_columns <- x$visible_columns
  columns_keys <- visible_columns[visible_columns$.type. %in% "columns" & !visible_columns[[".tab_columns"]] %in% "dummy", "col_keys"]

  cat("\ncol_keys: c(",
    paste0(shQuote(columns_keys, type = "cmd"), collapse = ", "),
    ")\n",
    sep = ""
  )

  print(as.data.table(x$data))
  invisible()
}


# utils -----
#' @importFrom rlang quo_text
check_filter_expr <- function(filter_expr, x) {
  filter_varnames <- all.vars(filter_expr)
  missing_varnames <- setdiff(filter_varnames, colnames(x))

  if (length(missing_varnames) > 0) {
    stop(
      sprintf(
        "`%s` is using unknown variable(s): %s",
        quo_text(filter_expr),
        paste0("`", missing_varnames, "`", collapse = ",")
      ),
      call. = FALSE
    )
  }
}

add_fake_columns <- function(x, fake_columns) {
  x[fake_columns] <- rep(list(character(nrow(x))), length(fake_columns))
  x
}

merge_additional_dataset <- function(a, b, rows) {
  if (!is.null(b)) {
    by <- intersect(rows, colnames(b))
    a$.keep_order_a <- seq_len(nrow(a))
    b$.keep_order_b <- seq_len(nrow(b))
    z <- merge(a, b, by = by, all.x = TRUE, all.y = FALSE)
    z <- z[order(z$.keep_order_a, z$.keep_order_b), ]
    z[c(".keep_order_a", ".keep_order_b")] <- list(NULL, NULL)
    a <- z
  }
  a
}

#' @importFrom data.table setorderv
map_visible_columns <- function(dat, columns, rows, value_names = character(0),
                                supp_colnames = character(0),
                                supp_colnames_last = character(0)) {
  dat <- dat[c(columns, rows)]
  dat[value_names] <- lapply(value_names, function(x, n) character(n), n = nrow(dat))
  dat <- as.data.table(dat)
  dat <- melt(as.data.table(dat),
    id.vars = c(rows, columns),
    measure.vars = value_names, variable.name = ".tab_columns"
  )
  setorderv(dat, cols = c(rows, columns))

  columns <- c(columns, ".tab_columns")
  ldims <- dat[, .SD, .SDcols = columns]
  ldims <- unique(ldims)
  setorderv(ldims, cols = columns[-length(columns)]) # important - order matters
  uid_cols <- columns

  last_m1_column <- length(columns) - 1
  ldims <- split(ldims, rleid(ldims[[last_m1_column]]))
  ldims <- lapply(ldims, function(x, j) {
    x1 <- x[1, ]
    x1[, j] <- "dummy"
    rbind(x, x1)
  }, j = seq(last_m1_column, length(columns), by = 1L))
  ldims <- do.call(rbind, ldims)

  sel_columns <- columns[seq_len(length(columns) - 2)]

  for (j in rev(seq_along(sel_columns))) {
    # Check if any group has more than 1 row (only then do we need separators)
    group_sizes <- table(rleid(ldims[[j]]))
    if (all(group_sizes <= 1)) next

    ldims <- split(ldims, rleid(ldims[[j]]))
    ldims <- lapply(ldims, function(x, j) {
      x[nrow(x), j] <- "dummy"
      x
    }, j = j)
    ldims <- do.call(rbind, ldims)
  }
  ldims <- ldims[-nrow(ldims), ]


  rdims <- lapply(rows, function(x, n) rep(x, n), n = ncol(ldims))
  rdims <- do.call(rbind, rdims)
  x1 <- rdims[1, ]
  x1[] <- "dummy"
  rdims <- rbind(rdims, x1)
  colnames(rdims) <- names(ldims)
  rdims <- as.data.frame(rdims, row.names = FALSE)

  rdims_supp <- NULL
  if (length(supp_colnames) > 0) {
    rdims_supp <- lapply(supp_colnames, function(x, n) rep(x, n), n = ncol(ldims))
    rdims_supp <- do.call(rbind, rdims_supp)
    x1 <- rdims_supp[1, ]
    x1[] <- "dummy"
    rdims_supp <- rbind(rdims_supp, x1)
    colnames(rdims_supp) <- names(ldims)
    rdims_supp <- as.data.frame(rdims_supp, row.names = FALSE)
    rdims_supp$.type. <- "rows_supp"
  }

  rdims_supp_last <- NULL
  if (length(supp_colnames_last) > 0) {
    rdims_supp_last <- lapply(supp_colnames_last, function(x, n) rep(x, n), n = ncol(ldims))
    rdims_supp_last <- do.call(rbind, rdims_supp_last)
    x1 <- rdims_supp_last[1, ]
    x1[] <- "dummy"
    rdims_supp_last <- rbind(x1, rdims_supp_last)
    colnames(rdims_supp_last) <- names(ldims)
    rdims_supp_last <- as.data.frame(rdims_supp_last, row.names = FALSE)
    rdims_supp_last$.type. <- "rows_supp_last"
  }


  ldims$.type. <- "columns"
  rdims$.type. <- "rows"
  last_column <- columns[length(columns)]
  dims <- rbind(rdims, rdims_supp, ldims, rdims_supp_last)

  is_dummy <- dims[[last_column]] %in% "dummy"
  dims$col_keys <- do.call(paste, append(as.list(dims[uid_cols]), list(sep = "@")))
  if (length(value_names) > 1) {
    dims$col_keys <- paste0(dims$.stat_name, "@", dims$col_keys)
  }
  dims$col_keys[is_dummy] <- paste0("dummy", seq_len(sum(is_dummy)))

  dims$col_keys[dims$.type. %in% "rows" & !is_dummy] <- dims[[last_column]][dims$.type. %in% "rows" & !is_dummy]
  dims$col_keys[dims$.type. %in% "rows_supp" & !is_dummy] <- dims[[last_column]][dims$.type. %in% "rows_supp" & !is_dummy]
  dims$col_keys[dims$.type. %in% "rows_supp_last" & !is_dummy] <- dims[[last_column]][dims$.type. %in% "rows_supp_last" & !is_dummy]
  setDF(dims)
  dims
}

map_hidden_columns <- function(dat, columns, rows) {
  user_columns <- setdiff(colnames(dat), c(columns, rows))
  dat <- as.data.table(dat)
  dat[, c(user_columns) :=
    lapply(.SD, function(x) character(length(x))), .SDcols = user_columns]
  dat <- melt(as.data.table(dat),
    id.vars = c(columns, rows),
    measure.vars = user_columns, variable.name = ".user_columns"
  )
  columns <- c(columns, ".user_columns")
  dims <- dat[, .SD, .SDcols = columns]
  setDF(dat)
  dims <- unique(dims)
  dims$col_keys <- do.call(paste, append(as.list(dims[, .SD, .SDcols = columns[-length(columns)]]), list(sep = "@")))
  dims$col_keys <- paste0(dims$.user_columns, "@", dims$col_keys)
  setDF(dims)
  dims
}
