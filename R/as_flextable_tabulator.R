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
#' @param cols column names to use in columns dimensions
#' @param separate used to sepatate the groups with an horizontal
#' line.
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
#'     cols = "tension",
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
#'     cols = "clarity",
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
#'   cols = "name",
#'   separate = character(0),
#'   `mean (sd)` = as_paragraph( as_chunk(avg),  " (", as_chunk(sd),  ")")
#'   )
#' ft_3 <- as_flextable(tab_3)
#' ft_3
#' }
#'
#' init_flextable_defaults()
#' @section Illustrations:
#'
#' ft_1:
#'
#' \if{html}{\figure{fig_tabulator_1.png}{options: width=70\%}}
#'
#' ft_3:
#'
#' \if{html}{\figure{fig_tabulator_3.png}{options: width=70\%}}
#' @importFrom rlang enquos enquo call_args
#' @importFrom data.table rleidv as.data.table
#' @seealso [as_flextable.tabulator()], [summarizor()], [as_grouped_data()]
tabulator <- function(x, rows, cols,
                      separate = rows[1],
                      supp_data = NULL,
                      hidden_data = NULL,
                      row_compose = list(),
                      ...){

  stopifnot(`rows can not be empty` = length(rows)>0,
            `cols can not be empty` = length(cols)>0,
            `separate is not part of rows` = length(separate) < 1 || all(separate %in% rows)
            )
  x <- as.data.frame(x)

  row_compose <- enquo(row_compose)
  row_compose <- call_args(row_compose)

  call <- enquos(...)
  keep_columns <- setdiff(colnames(x), c(rows, cols))
  show_columns <- names(call)
  x <- add_fake_columns(x, show_columns)

  # check dimensions
  cts <- as.data.table(x)[, c("cts") := .N, by = c(cols, rows)]
  setDF(cts)
  cts <- cts[cts$cts> 1,]
  if(nrow(cts)>0){
    all_dims <- paste0(c(cols, rows), collapse = ", ")
    stop("the number of rows is not unique for some combinations of rows and columns: ",
         all_dims)
  }

  .formula <- paste(paste0("`", rows, "`", collapse = "+"), "~", paste0("`", cols, "`", collapse = "+"))
  dat <- dcast(as.data.table(x),
               formula = .formula,
               value.var = c(keep_columns, show_columns),
               sep = "@")
  setDF(dat)


  original_cols <- colnames(dat)
  if(!is.null(supp_data)){
    by <- intersect(rows, colnames(supp_data))
    dat <- merge(dat, supp_data, by = by,
                 all.x = TRUE, all.y = FALSE)
  }
  data_start_cols <- setdiff(colnames(dat), original_cols)

  if(!is.null(hidden_data)){
    by <- intersect(rows, colnames(hidden_data))
    dat <- merge(dat, hidden_data, by = by,
                 all.x = TRUE, all.y = FALSE)
  }

  setDF(dat)

  .dims <- dim_describe(
    x = x, display_data = dat,
    cols = cols, rows = rows,
    data_start_cols = data_start_cols,
    fake_columns = show_columns,
    keep_columns = keep_columns,
    separate = separate)

  z <- list(data = dat, .dims = .dims, .call = call, .row_compose = row_compose)
  class(z) <- "tabulator"
  z
}

#' @export
#' @describeIn tabulator call `summary()` to get
#' a data.frame describing mappings between variables
#' and their names in the flextable. This data.frame can
#' then be then used when programming with flextable as
#' column names used by the resulting flextable
#' are available in the dataset.
#' @param object an object returned by function
#' `tabulator()`.
#' @importFrom data.table data.table as.data.table
summary.tabulator <- function(object, ...){
  allcolkeys <- data.table(colkey = colnames(object$data))
  mapping <- as.data.table(object$.dims$mapping)
  mapping$column_order <- seq_len(nrow(mapping))
  x <- merge(mapping, allcolkeys, by = "colkey", all = TRUE)
  setorderv(x, cols = "column_order")
  setDF(x)
  x
}
#' @export
print.tabulator <- function(x, ...){

  cat("layout:\n")
  cat("* row(s): ",
      paste0("`", x$.dims$rows, "`", collapse = ", "),
      "\n")
  cat("* column(s): ",
      paste0("`", x$.dims$cols, "`", collapse = ", "),
      "\n")
  cat("* content(s): ",
      paste0("`", names(x$.call), "`", collapse = ", "),
      "\n")

  cat("\ncol_keys: ",
    paste0("`", x$.dims$col_keys, "`", collapse = ", "),
    "\n")

  cat("\nsimple preview:\n")

  mapping <- na.omit(x$.dims$mapping)
  header <- mapping
  header$colkey <- NULL
  header <- t(header)
  dimnames(header) <- list(NULL, mapping$colkey)

  print(as.data.frame(header, row.names = NULL ))
  cat("...and ", nrow(x$dat), " rows of data\n" )
}
#' @export
#' @title tabulator to flextable
#' @description `tabulator` object can be transformed as a flextable
#' with method [as_flextable()].
#' @param x result from [tabulator()]
#' @param big_border,small_border big and small border properties defined
#' by a call to [fp_border_default()] or [fp_border()].
#' @param sep_w blank column separators' width to be used. If 0,
#' blank column separators will not be used.
#' @param ... unused argument
#' @family as_flextable methods
#' @seealso [summarizor()], [as_grouped_data()]
as_flextable.tabulator <- function(x,
    big_border = fp_border_default(width = 1.5),
    small_border = fp_border_default(width = .75),
    sep_w = .05, ...) {

  dat <- x$data
  .dims <- x$.dims
  ft_mapping <- .dims$ft_mapping
  .call <- x$.call

  ft <- flextable(dat, col_keys = .dims$col_keys)

  for(j in names(ft_mapping)){
    ft_mapping_j <- ft_mapping[[j]]

    replication_info <- .dims$add_mapping[[j]]
    ft$body$dataset[replication_info$y] <- ft$body$dataset[replication_info$colkey]

    for(i in seq_len(nrow(ft_mapping_j))){
      colname <- ft_mapping_j[i, "colkey"]
      exp_name <- ft_mapping_j[i, "y"]
      ft <- mk_par(ft, j = colname, value = !!.call[[exp_name]])
    }
    ft$body$dataset[replication_info$y] <- rep(list(NULL), nrow(replication_info))
  }


  for(j in names(x$.row_compose)){
    ft <- mk_par(ft, j = j, value = !!x$.row_compose[[j]])
  }

  ft <- set_header_labels(ft, values = .dims$header_labels)
  ft <- border_remove(ft)
  ft <- autofit(ft, part = "all", add_w = .3, add_h = .05)

  ft <- padding(ft, j = ft$blanks, padding = 0)
  for(col in rev(.dims$cols)){

    ft <- add_header_row(
      x = ft,
      values = .dims$header_labels_list[[col]]$values,
      colwidths = .dims$header_labels_list[[col]]$lengths,
      top = TRUE)
    ft <- bold(ft, i = 1, bold = FALSE, part = "header")

    has_hline <- !is.na(.dims$mapping[[col]])
    has_hline[1] <- FALSE
    ft <- align(ft, i = 1, align = "center", part = "header")
    ft <- align(ft, i = 1, j = 1, align = "right", part = "header")
    ft <- hline(ft, i = 1, j = has_hline, border = small_border,
                part = "header")
  }
  ft <- bold(ft, j = 1, part = "header")

  ft <- merge_v(ft, j = .dims$rows, part = "header")
  ft <- merge_v(ft, j = .dims$data_start_cols, part = "header")

  ft <- merge_v(ft, j = .dims$rows[-length(.dims$rows)], part = "body")
  ft <- valign(ft, valign = "top", j = .dims$rows)

  ft <- align(ft, j = .dims$rows, i = nrow_part(ft, "header"),
              align = "left", part = "header")
  ft <- align(ft, j = .dims$rows, align = "left", part = "body")
  ft <- align(ft, j = .dims$fake_keys, align = "right", part = "body")
  ft <- align(ft, j =  .dims$fake_keys, align = "right", part = "header", i = nrow_part(ft, "header"))

  # horizontal lines
  ft <- hline_bottom(x = ft, border = big_border, part = "header")
  ft <- hline(ft, i = .dims$border_h_major, border = small_border)
  ft <- empty_blanks(ft, width = sep_w, part = "body")

  ft <- hline_top(x = ft, border = big_border, part = "header")
  ft <- hline_bottom(x = ft, border = big_border, part = "body")
  ft <- fix_border_issues(ft)

  ft
}

# utils -----
cols_map <- function(x, cols, keys){
  # unique comb of cols become new col keys
  col_dims <- unique(x[cols])
  col_dims$key__ = 1L # for cross join
  setDT(col_dims)
  keys <- c("dummy", keys)
  key_dims <- data.table(y=keys, key__ = 1L)

  cols_mapping <- merge(key_dims, col_dims, by = "key__", all = TRUE, allow.cartesian = TRUE)

  cols_mapping[, c("key__") := NULL]
  cols_mapping[, c("colkey") := do.call(paste, append(as.list(.SD), list(sep = "@")))]

  setorderv(cols_mapping, cols)

  setDF(cols_mapping)
  setDF(key_dims)
  setDF(col_dims)
  cols_mapping
}

rows_map <- function(x, rows, cols){
  rowdims <- data.table(colkey = rows)
  rowdims[, c(cols, "y") := rows]
  setDF(rowdims)
  rowdims
}

rows_extra_map <- function(x, rows, cols){
  rows <- c("dummy", rows)
  rowdims <- data.table(y = rows)
  rowdims[, c(cols) := rows]
  rowdims[, c("colkey") := rows]
  setDF(rowdims)
  rowdims
}


columns_mapping <- function(x, cols, rows, keys, after_rows = character()){

  coldims <- cols_map(x = x, cols = cols, keys = keys)
  rowdims <- rows_map(x = x, cols = cols, rows = rows)

  if(length(after_rows)>0){
    after_rowdims <- rows_extra_map(x = x, cols = cols, rows = after_rows)
    rowdims_all <- rbind(rowdims, after_rowdims)
  } else {
    rowdims_all <- rowdims
  }

  dims <- rbind(rowdims_all, coldims)
  dims$y[is.na(dims$y)] <- ""
  setDT(dims)

  setcolorder(dims, c("colkey", cols, "y"))
  setDF(dims)

  header_labels_list <- prepare_header_val(dims, drop_first = nrow(rowdims))

  all_but_y <- setdiff(names(dims), c("colkey", "type"))
  dims[all_but_y] <- lapply(dims[all_but_y], function(x, where){
    x[where] <- NA_character_
    x
  }, where = dims$y %in% "dummy")

  attr(dims, "header_labels_list") <- header_labels_list

  dims
}

add_fake_columns <- function(x, fake_columns){
  x[fake_columns] <- rep(list(character(nrow(x))), length(fake_columns))
  x
}
prepare_header_val <- function(dims, drop_first = 1){
  dat <- as.data.frame(dims)
  col_to_scan <- setdiff(colnames(dat), c("y", "colkey"))

  mapply(FUN = function(x, label, is_dummy){
    x <- as.character(x)
    x[seq_len(drop_first)] <- " "
    x[1] <- label
    where_are_cut <- x != c(x[1], x[-length(x)])
    where_are_cut <- where_are_cut & is_dummy
    x[where_are_cut] <- ""
    z <- rle(x)
    z
  }, x = dat[col_to_scan],
  label = col_to_scan,
  SIMPLIFY = FALSE,
  MoreArgs = list(is_dummy = dims$y %in% "dummy"))
}
dim_describe <- function(x, display_data, cols, rows, fake_columns,
                         keep_columns, separate = rows[1],
                         data_start_cols = character()){

  border_h_major <- integer()

  if(length(separate)>0){
    rle <- rleidv(display_data[separate])
    border_h_major <- which(rle != c(-1, rle[-length(rle)]))-1
    border_h_major <- setdiff(border_h_major, 0)
  }

  hidden_dims <- columns_mapping(
    x = x, cols = cols, rows = character(),
    keys = keep_columns)

  mapping <- columns_mapping(
    x = x, cols = cols, rows = rows, after_rows = data_start_cols,
    keys = fake_columns)

  header_labels_list <- attr(mapping, "header_labels_list")
  attr(mapping, "header_labels_list") <- NULL

  setDF(mapping)

  target_dims <- mapping[mapping$y %in% fake_columns,]

  header_labels <- mapping$y
  names(header_labels) <- mapping$colkey

  list(mapping = mapping,
       add_mapping = split(hidden_dims,
                           hidden_dims[cols], drop = TRUE),
       ft_mapping = split(target_dims,
                          target_dims[cols], drop = TRUE),
       header_labels = header_labels,
       header_labels_list = header_labels_list,
       col_keys = mapping$colkey,
       fake_keys = target_dims$colkey,
       cols = cols, rows = rows, data_start_cols = data_start_cols,
       border_h_major = border_h_major
       )

}


