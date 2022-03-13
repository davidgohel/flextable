# main -----

#' @export
#' @title Tabulation of aggregations
#' @description It tabulates a data.frame representing an aggregation
#' which is then transformed as a flextable. The function
#' allows to define any display with the syntax of flextable in
#' a table whose layout is showing dimensions of the aggregation
#' across rows and columns.
#'
#' @note
#' This is very first version of the function; be aware it
#' can evolve or change.
#' @param x an aggregated data.frame
#' @param rows column names to use in rows dimensions
#' @param columns column names to use in columns dimensions
#' @param supp_data additional data that will be merged with
#' table and presented after the columns presenting
#' the row dimensions.
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
#' n_format <- function(z){
#'   x <- sprintf("%.0f", z)
#'   x[is.na(z)] <- "-"
#'   x
#' }
#'
#' set_flextable_defaults(digits = 2, border.color = "gray")
#'
#' if(require("stats")){
#'   dat <- aggregate(breaks ~ wool + tension,
#'     data = warpbreaks, mean)
#'
#'   cft_1 <- tabulator(
#'     x = dat, rows = "wool",
#'     columns = "tension",
#'     `mean` = as_paragraph(as_chunk(breaks)),
#'     `(N)` = as_paragraph(
#'       as_chunk(length(breaks), formatter = n_format ))
#'   )
#'
#'   ft_1 <- as_flextable(cft_1)
#'   ft_1
#' }
#'
#' if(require("data.table") && require("ggplot2")){
#'
#'   multi_fun <- function(x) {
#'     list(mean = mean(x),
#'          sd = sd(x))
#'   }
#'   myformat <- function(z){
#'     x <- sprintf("%.1f", z)
#'     x[is.na(z)] <- ""
#'     x
#'   }
#'
#'   grey_txt <- fp_text_default(color = "gray")
#'
#'   dat <- as.data.table(ggplot2::diamonds)
#'   dat <- dat[cut %in% c("Fair", "Good", "Very Good")]
#'   dat <- dat[clarity %in% c("I1", "SI1", "VS2")]
#'
#'   dat <- dat[, unlist(lapply(.SD, multi_fun),
#'                       recursive = FALSE),
#'              .SDcols = c("z", "y"),
#'              by = c("cut", "color", "clarity")]
#'
#'   tab_2 <- tabulator(
#'     x = dat, rows = c("cut", "color"),
#'     columns = "clarity",
#'     `z stats` = as_paragraph(
#'       as_chunk(z.mean, formatter = myformat)),
#'     `y stats` = as_paragraph(
#'       as_chunk(y.mean, formatter = myformat),
#'       as_chunk(" (\u00B1 ", props = grey_txt),
#'       as_chunk(y.sd, formatter = myformat, props = grey_txt),
#'       as_chunk(")", props = grey_txt)
#'       )
#'   )
#'   ft_2 <- as_flextable(tab_2)
#'   ft_2 <- autofit(x = ft_2, add_w = .05)
#'   ft_2
#' }
#'
#' if(require("data.table")){
#' #' # data.table version
#' dat <- melt(as.data.table(iris),
#'             id.vars = "Species",
#'             variable.name = "name",value.name = "value")[,
#'               list(avg = mean(value, na.rm = TRUE),
#'                    sd = sd(value, na.rm = TRUE)),
#'               by = c("Species", "name")
#'             ]
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
#'   `mean (sd)` = as_paragraph( as_chunk(avg),
#'      " (", as_chunk(sd),  ")")
#'   )
#' ft_3 <- as_flextable(tab_3, separate_with = character(0))
#' ft_3
#' }
#'
#' init_flextable_defaults()
#' @section Illustrations:
#'
#' ft_1 appears as:
#'
#' \if{html}{\figure{fig_tabulator_1.png}{options: width="300"}}
#'
#' ft_2 appears as:
#'
#' \if{html}{\figure{fig_tabulator_2.png}{options: width="500"}}
#' @importFrom rlang enquos enquo call_args
#' @importFrom data.table rleidv as.data.table
#' @seealso [as_flextable.tabulator()], [summarizor()], [as_grouped_data()]
tabulator <- function(x, rows, columns,
                      supp_data = NULL,
                      hidden_data = NULL,
                      row_compose = list(),
                      ...){

  stopifnot(`rows can not be empty` = length(rows)>0,
            `columns can not be empty` = length(columns)>0
  )

  x <- as.data.frame(x)

  row_compose <- enquo(row_compose)
  row_compose <- call_args(row_compose)

  col_exprs <- enquos(...)
  data_colnames <- setdiff(colnames(x), c(rows, columns))
  col_expr_names <- names(col_exprs)

  hidden_columns <- map_hidden_columns(
    dat = x, columns = columns,
    rows = rows)

  x <- add_fake_columns(x, col_expr_names)
  supp_colnames <- setdiff(colnames(supp_data), rows)
  visible_columns <- map_visible_columns(
    dat = x, columns = columns, rows = rows,
    supp_colnames = supp_colnames,
    value_names = col_expr_names)

  # check dimensions
  cts <- as.data.table(x)[, c("cts") := .N, by = c(columns, rows)]
  setDF(cts)
  cts <- cts[cts$cts> 1,]
  if(nrow(cts)>0){
    all_dims <- paste0(c(columns, rows), collapse = ", ")
    stop("the number of rows is not unique for some combinations ",
         "of rows and columns: ", all_dims)
  }

  .formula <- paste(paste0("`", rows, "`", collapse = "+"),
                    "~", paste0("`", columns, "`", collapse = "+"))
  value_vars <- c(data_colnames, col_expr_names)
  dat <- dcast(
    data = as.data.table(x),
    formula = .formula,
    value.var = value_vars, sep = "@")

  dat <- merge_additional_dataset(dat, supp_data, rows = rows)
  dat <- merge_additional_dataset(dat, hidden_data, rows = rows)
  setDF(dat)

  z <- list(
    data = dat,
    rows = rows,
    columns = columns,
    visible_columns = visible_columns,
    hidden_columns = hidden_columns,
    col_exprs = col_exprs,
    row_exprs = row_compose)

  class(z) <- "tabulator"

  z
}


#' @export
#' @title tabulator to flextable
#' @description `tabulator` object can be transformed as a flextable
#' with method [as_flextable()].
#' @param x result from [tabulator()]
#' @param separate_with columns used to sepatate the groups
#' with an horizontal line.
#' @param big_border,small_border big and small border properties defined
#' by a call to [fp_border_default()] or [fp_border()].
#' @param rows_alignment,columns_alignment alignments to apply to
#' columns corresponding to `rows` and `columns`; see arguments
#' `rows` and `columns` in [tabulator()].
#' @param sep_w blank column separators'width to be used. If 0,
#' blank column separators will not be used.
#' @param unit unit of argument `sep_w`, one of "in", "cm", "mm".
#' @param ... unused argument
#' @family as_flextable methods
#' @seealso [summarizor()], [as_grouped_data()]
#' @examples
#' library(flextable)
#'
#' set_flextable_defaults(digits = 2, border.color = "gray")
#'
#' if(require("stats")){
#'   dat <- aggregate(breaks ~ wool + tension,
#'     data = warpbreaks, mean)
#'
#'   cft_1 <- tabulator(x = dat,
#'                      rows = "wool",
#'     columns = "tension",
#'     `mean` = as_paragraph(as_chunk(breaks)),
#'     `(N)` = as_paragraph(
#'       as_chunk(length(breaks) ))
#'   )
#'
#'   ft_1 <- as_flextable(cft_1, sep_w = .1)
#'   ft_1
#'
#'   set_flextable_defaults(padding = 1, font.size = 9, border.color = "orange")
#'   ft_2 <- as_flextable(cft_1, sep_w = 0)
#'   ft_2
#'
#'   set_flextable_defaults(padding = 6, font.size = 11,
#'                          border.color = "white", font.color = "white",
#'                          background.color = "#333333")
#'   ft_3 <- as_flextable(
#'     x = cft_1, sep_w = 0,
#'     rows_alignment = "center",
#'     columns_alignment = "right")
#'   ft_3
#' }
#'
#' init_flextable_defaults()
as_flextable.tabulator <- function(
    x, separate_with = character(0),
    big_border = fp_border_default(width = 1.5),
    small_border = fp_border_default(width = .75),
    rows_alignment = "left", columns_alignment = "center",
    sep_w = .05, unit = "in", ...) {

  # get necessary element
  dat <- x$data

  rows <- x$rows
  columns <- x$columns

  visible_columns <- x$visible_columns
  hidden_columns <- x$hidden_columns

  col_exprs <- x$col_exprs

  if(sep_w < 0.001){
    visible_columns <- visible_columns[!visible_columns[[".tab_columns"]] %in% "dummy",]
  }

  visible_columns_keys <- visible_columns[
    visible_columns$type %in% "columns" &
      !visible_columns[[".tab_columns"]] %in% "dummy",
    "col_keys"]
  blank_columns <- visible_columns[
    visible_columns[[".tab_columns"]] %in% "dummy", "col_keys"]

  # create border_h_major from separate_with
  stopifnot(
    `separate_with is not part of rows` =
      length(separate_with) < 1 || all(separate_with %in% rows)
  )

  border_h_major <- integer()

  if(length(separate_with)>0){
    rle <- rleidv(dat[separate_with])
    border_h_major <- which(rle != c(-1, rle[-length(rle)]))-1
    border_h_major <- setdiff(border_h_major, 0)
  }

  # for later iteration, a list of visible columns
  # to use when filling the table
  visible_columns_mapping <- visible_columns[visible_columns$type %in% "columns" & !visible_columns[[".tab_columns"]] %in% "dummy",]
  visible_columns_mapping$type <- NULL
  visible_columns_mapping <- split(visible_columns_mapping, visible_columns_mapping[columns], drop = TRUE)

  # for later iteration, a list of hidden columns that can
  # be used by expressions defined by the user
  hidden_columns_mapping <- split(hidden_columns, hidden_columns[columns], drop = TRUE)

  ft <- flextable(dat, col_keys = visible_columns$col_keys)
  ft <- border_remove(ft)

  labels_tab <- visible_columns
  labels_tab <- labels_tab[!labels_tab$.tab_columns %in% "dummy", ]
  if(length(col_exprs)>1){
    labels <- labels_tab$.tab_columns
    names(labels) <- labels_tab$col_keys
    ft <- set_header_labels(x = ft, values = labels)
  } else {
    labels <- labels_tab[[columns[length(columns)]]]
    names(labels) <- labels_tab$col_keys
    ft <- set_header_labels(x = ft, values = labels)
    columns <- columns[-length(columns)]
  }

  for(j in names(visible_columns_mapping)){
    visible_columns_mapping_j <- visible_columns_mapping[[j]]
    replication_info <- hidden_columns_mapping[[j]]

    ft$body$dataset[as.character(replication_info$.user_columns)] <- ft$body$dataset[replication_info$col_keys]

    for(i in seq_len(nrow(visible_columns_mapping_j))){
      colname <- visible_columns_mapping_j[i, "col_keys"]
      exp_name <- visible_columns_mapping_j[i, ".tab_columns"]
      ft <- mk_par(ft, j = colname, value = !!col_exprs[[exp_name]])
    }
    ft$body$dataset[as.character(replication_info$.user_columns)] <- rep(list(NULL), nrow(replication_info))
  }
  ft <- merge_v(ft, j = rows, part = "body")
  ft <- valign(ft, valign = "top", j = rows)

  for(j in names(x$row_exprs)){
    ft <- mk_par(ft, j = j, value = !!x$row_exprs[[j]])
  }

  ft <- autofit(ft, part = "all", add_w = .2, add_h = .0, unit = "cm")

  for(column in rev(columns)){
    rel_ <- rle(visible_columns[[column]])
    rel_$values[rel_$values %in% "dummy"] <- ""
    ft <- add_header_row(x = ft,
                         values = rel_$values,
                         colwidths = rel_$lengths, top = TRUE)
    ft <- hline(ft, i = 1, j = which(!visible_columns[[column]] %in% c("dummy", rows)),
                border = small_border,
                part = "header")
    ft <- align(x = ft, i = 1, align = "center", part = "header")

  }

  ft <- merge_v(
    x = ft,
    j = rows, part = "header")

  ft <- valign(ft, valign = "bottom", j = rows, part = "header")
  ft <- valign(ft, valign = "top", j = rows)

  ft <- align(x = ft, j = visible_columns_keys, align = columns_alignment, part = "all")
  ft <- align(x = ft, j = rows, align = rows_alignment, part = "all")

  if(sep_w > 0){
    ft <- padding(ft, j = blank_columns, padding = 0, part = "all")
  }

  # dummy as blank columns

  ft <- hline(ft, i = border_h_major, border = small_border)

  ft <- hline(ft,
              i = nrow_part(ft, part = "header"),
              j = setdiff(visible_columns$col_keys, blank_columns),
              border = big_border, part = "header")
  ft <- hline_top(x = ft, border = big_border, part = "header")
  ft <- hline_bottom(x = ft, border = big_border, part = "body")

  if(sep_w > 0){
    ft <- border(ft, j = blank_columns,
                 border.top = shortcuts$b_null(), border.bottom = shortcuts$b_null(), part = "all")
    ft <- bg(ft, j = blank_columns, bg = "transparent", part = "all")
    ft <- void(ft, j = blank_columns, part = "all")
    ft <- width(ft, j = blank_columns, width = sep_w, unit = unit)
  }

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
summary.tabulator <- function(object, ...){

  hidden_columns <- object$hidden_columns
  names(hidden_columns)[names(hidden_columns) %in% ".user_columns"] <- "column"
  hidden_columns$type <- "hidden"

  visible_columns <- object$visible_columns
  names(visible_columns)[names(visible_columns) %in% ".tab_columns"] <- "column"
  dat <- rbind(visible_columns, hidden_columns)
  dat
}

#' @export
print.tabulator <- function(x, ...){

  cat("layout:\n")
  cat("* row(s): ",
      paste0("`", x$rows, "`", collapse = ", "),
      "\n")
  cat("* column(s): ",
      paste0("`", x$columns, "`", collapse = ", "),
      "\n")
  cat("* content(s): ",
      paste0("`", names(x$col_exprs), "`", collapse = ", "),
      "\n")
  visible_columns <- x$visible_columns
  columns_keys <- visible_columns[visible_columns$type %in% "columns" & !visible_columns[[".tab_columns"]] %in% "dummy", "col_keys"]

  cat("\ncol_keys: c(",
    paste0(shQuote(columns_keys, type = "cmd"), collapse = ", "),
    ")\n", sep = "")

}


# utils -----
#' @importFrom rlang quo_text
check_filter_expr <- function(filter_expr, x){
  filter_varnames <- all.vars(filter_expr)
  missing_varnames <- setdiff(filter_varnames, colnames(x))

  if(length(missing_varnames) > 0){
    stop(quo_text(filter_expr), " is using unknown variable(s): ",
         paste0("`", missing_varnames, "`", collapse = ","),
         call. = FALSE)
  }
}

add_fake_columns <- function(x, fake_columns){
  x[fake_columns] <- rep(list(character(nrow(x))), length(fake_columns))
  x
}


merge_additional_dataset <- function(a, b, rows){
  if(!is.null(b)){
    by <- intersect(rows, colnames(b))
    a <- merge(a, b, by = by, all.x = TRUE, all.y = FALSE)
  }
  a
}

#' @importFrom data.table setorderv
map_visible_columns <- function(dat, columns, rows, value_names = character(0),
                                supp_colnames = character(0)){

  dat <- dat[c(columns, rows)]
  dat[value_names] <- lapply(value_names, function(x, n) character(n), n = nrow(dat))
  dat <- as.data.table(dat)
  dat <- melt(as.data.table(dat), id.vars = c(rows, columns),
              measure.vars = value_names, variable.name = ".tab_columns")
  setorderv(dat, cols = c(rows, columns))

  columns <- c(columns, ".tab_columns")
  ldims <- dat[,.SD, .SDcols = columns]
  ldims <- unique(ldims)
  uid_cols <- columns

  last_column <- columns[length(columns)]
  last_m1_column <- length(columns) -1
  ldims <- split(ldims, rleid(ldims[[last_m1_column]]))
  ldims <- lapply(ldims, function(x, j){
    x1 <- x[1,]
    x1[,j] <- "dummy"
    rbind(x, x1)
  }, j = seq(last_m1_column, length(columns), by = 1L))
  ldims <- do.call(rbind, ldims)

  sel_columns <- columns[seq_len(length(columns) - 2)]

  for(j in rev(seq_along(sel_columns))){
    ldims <- split(ldims, rleid(ldims[[j]]))
    ldims <- lapply(ldims, function(x, j){
      x[nrow(x),j] <- "dummy"
      x
    }, j = j)
    ldims <- do.call(rbind, ldims)
  }
  ldims <- ldims[-nrow(ldims), ]


  rdims <- lapply(rows, function(x, n) rep(x, n), n = ncol(ldims))
  rdims <- do.call(rbind, rdims)
  x1 <- rdims[1,]
  x1[] <- "dummy"
  rdims <- rbind(rdims, x1)
  colnames(rdims) <- names(ldims)
  rdims <- as.data.frame(rdims, row.names = FALSE)

  rdims_supp <- NULL
  if(length(supp_colnames) > 0){
    rdims_supp <- lapply(supp_colnames, function(x, n) rep(x, n), n = ncol(ldims))
    rdims_supp <- do.call(rbind, rdims_supp)
    x1 <- rdims_supp[1,]
    x1[] <- "dummy"
    rdims_supp <- rbind(rdims_supp, x1)
    colnames(rdims_supp) <- names(ldims)
    rdims_supp <- as.data.frame(rdims_supp, row.names = FALSE)
    rdims_supp$type <- "rows_supp"
  }


  ldims$type <- "columns"
  rdims$type <- "rows"
  last_column <- columns[length(columns)]
  dims <- rbind(rdims, rdims_supp, ldims)

  is_dummy <- dims[[last_column]] %in% "dummy"
  dims$col_keys <- do.call(paste, append(as.list(dims[uid_cols]), list(sep = "@")))
  if(length(value_names) > 1){
    dims$col_keys <- paste0(dims$.stat_name, "@", dims$col_keys)
  }
  dims$col_keys[is_dummy] <- paste0("dummy", seq_len(sum(is_dummy)))

  dims$col_keys[dims$type %in% "rows" & !is_dummy] <- dims[[last_column]][dims$type %in% "rows" & !is_dummy]
  dims$col_keys[dims$type %in% "rows_supp" & !is_dummy] <- dims[[last_column]][dims$type %in% "rows_supp" & !is_dummy]
  setDF(dims)
  dims
}

map_hidden_columns <- function(dat, columns, rows){
  user_columns <- setdiff(colnames(dat), c(columns, rows))
  dat <- as.data.table(dat)
  dat[, c(user_columns) :=
        lapply(.SD, function(x) character(length(x))), .SDcols = user_columns]
  dat <- melt(as.data.table(dat), id.vars = c(columns, rows),
              measure.vars = user_columns, variable.name = ".user_columns")
  columns <- c(columns, ".user_columns")
  dims <- dat[, .SD, .SDcols = columns]
  setDF(dat)
  dims <- unique(dims)
  dims$col_keys <- do.call(paste, append(as.list(dims[, .SD, .SDcols = columns[-length(columns)]]), list(sep = "@")))
  dims$col_keys <- paste0(dims$.user_columns, "@", dims$col_keys)
  setDF(dims)
  dims
}


