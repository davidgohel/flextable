#' @export
#' @title Transform a 'tables::tabular' object into a flextable
#' @description Produce a flextable from a 'tabular' object
#' produced with function [tables::tabular()].
#'
#' When `as_flextable.tabular=TRUE`, the first column is
#' used as row separator acting as a row title. It can
#' be formated with arguments `fp_p` (the formatting
#' properties of the paragraph) and `row_title` that
#' specifies the content and eventually formattings
#' of the content.
#'
#' Two hidden columns can be used for conditional formatting
#' after the creation of the flextable (use only when
#' `spread_first_col=TRUE`):
#'
#' - The column `.row_title` that contains the title label
#' - The column `.type` that can contain the following values:
#'   - "one_row": Indicates that there is only one row for this group. In this case, the row is not expanded with a title above.
#'   - "list_title": Indicates a row that serves as a title for the data that are displayed after it.
#'   - "list_data": Indicates rows that follow a title and contain data to be displayed.
#'
#' @param x object produced by [tables::tabular()].
#' @param spread_first_col if TRUE, first row is spread as a new line separator
#' instead of being a column. This helps to reduce the width and allows for
#' clear divisions.
#' @param fp_p paragraph formatting properties associated with row titles,
#' see [fp_par()].
#' @param row_title a call to [as_paragraph()] - it
#' will be applied to the row titles if any
#' when `spread_first_col=TRUE`.
#' @param add_tab adds a tab in front of "list_data"
#' label lines (located in column `.type`).
#' @param ... unused argument
#' @family as_flextable methods
#' @examples
#' if (require("tables")) {
#'   set.seed(42)
#'   genders <- c("Male", "Female")
#'   status <- c("low", "medium", "high")
#'   Sex <- factor(sample(genders, 100, rep = TRUE))
#'   Status <- factor(sample(status, 100, rep = TRUE))
#'   z <- rnorm(100) + 5
#'   fmt <- function(x) {
#'     s <- format(x, digits = 2)
#'     even <- ((1:length(s)) %% 2) == 0
#'     s[even] <- sprintf("(%s)", s[even])
#'     s
#'   }
#'   tab <- tabular(
#'     Justify(c) * Heading() * z *
#'       Sex * Heading(Statistic) *
#'       Format(fmt()) *
#'       (mean + sd) ~ Status
#'   )
#'   as_flextable(tab)
#' }
#'
#' if (require("tables")) {
#'   tab <- tabular(
#'     (Species + 1) ~ (n = 1) + Format(digits = 2) *
#'       (Sepal.Length + Sepal.Width) * (mean + sd),
#'     data = iris
#'   )
#'   as_flextable(tab)
#' }
#'
#' if (require("tables")) {
#'   x <- tabular((Factor(gear, "Gears") + 1)
#'   * ((n = 1) + Percent()
#'       + (RowPct = Percent("row"))
#'       + (ColPct = Percent("col")))
#'   ~ (Factor(carb, "Carburetors") + 1)
#'     * Format(digits = 1), data = mtcars)
#'
#'   ft <- as_flextable(
#'     x,
#'     spread_first_col = TRUE,
#'     row_title = as_paragraph(
#'       colorize("Gears: ", color = "#666666"),
#'       colorize(as_b(.row_title), color = "red")
#'     )
#'   )
#'   ft
#' }
#'
#' if (require("tables")) {
#'   tab <- tabular(
#'     (mean + mean) * (Sepal.Length + Sepal.Width) ~ 1,
#'     data = iris
#'   )
#'   as_flextable(tab)
#' }
as_flextable.tabular <- function(x,
                                 spread_first_col = FALSE,
                                 fp_p = fp_par(text.align = "center", padding.top = 4),
                                 row_title = as_paragraph(as_chunk(.row_title)),
                                 add_tab = FALSE,
                                 ...) {
  stopifnot(requireNamespace("tables", quietly = TRUE))

  body_data <- fortify_tabular_body(x)
  header_data <- fortify_tabular_header(x)
  text_align <- fortify_tabular_justify(x)
  vmerge_ins <- vmerge_instructions(x)
  hmerge_ins <- hmerge_instructions(x)
  .ncol <- ncol(tables::rowLabels(x))

  row_columns <- colnames(vmerge_ins)
  data_columns <- setdiff(colnames(body_data), row_columns)
  group_colname <- character()

  if (spread_first_col) {
    group_colname <- row_columns[1]
    row_columns <- setdiff(row_columns, group_colname)
    .ncol <- .ncol - length(group_colname)

    .is_list_title <- is_list_title(body_data[[group_colname]])
    .is_one_row <- is_one_row(body_data[[group_colname]])

    body_data <- expand_dataset(
      body_data = body_data,
      is_title = .is_list_title, is_single = .is_one_row,
      group_colname = group_colname
    )

    text_align$body <- expand_dataset(
      body_data = as.data.frame(text_align$body),
      is_title = .is_list_title, is_single = .is_one_row,
      group_colname = group_colname
    )
  } else {
    body_data$.type <- "list_data"
    body_data$.row_title <- FALSE
  }

  columns_keys <- setdiff(c(row_columns, data_columns), group_colname)

  vmerge_ins <- vmerge_ins[, setdiff(colnames(vmerge_ins), group_colname), drop = FALSE]
  text_align$header <- text_align$header[, setdiff(colnames(text_align$header), group_colname), drop = FALSE]
  text_align$body <- text_align$body[, setdiff(colnames(text_align$body), group_colname), drop = FALSE]

  if (length(group_colname)) {
    body_data$.row_title <- body_data[[group_colname]]
    body_data$.row_title[body_data$.type %in% "one_row"] <-
      body_data[[row_columns]][body_data$.type %in% "one_row"]
  }
  ft <- flextable(body_data, col_keys = columns_keys)

  ft <- set_header_df(ft, mapping = header_data)

  ft <- merge_v(ft, part = "header", j = row_columns)

  for (i in seq_along(hmerge_ins)) {
    hgroups <- split(seq_len(nrow(hmerge_ins)), hmerge_ins[[i]])
    for (hgroup in hgroups) {
      ft <- merge_at(ft, part = "header", j = hgroup + .ncol, i = i)
    }
  }
  if (spread_first_col) {
    for (j in setdiff(names(vmerge_ins), ".type")) {
      vgroups <- split(seq_len(nrow(vmerge_ins)), vmerge_ins[[j]])
      for (vgroup in vgroups) {
        ft <- merge_at(ft, part = "body", j = j, i = vgroup)
      }
    }
  }

  ft <- do.call(get_flextable_defaults()$theme_fun, list(ft))

  for (j in columns_keys) {
    ft <- align(ft, j = j, align = text_align$header[, j], part = "header")
    ft <- align(ft,
      j = j, i = ~ .type %in% c("one_row", "list_data"),
      align = text_align$body[, j], part = "body"
    )
  }

  ft <- valign(ft, valign = "top", part = "body")
  ft <- valign(ft, valign = "bottom", part = "header")

  # format functions can not be simply called
  # then, it looks easier to call format.tabular
  # and inject its trimmed values. That way we
  # preserve data types and can do conditionnal
  # formatting
  strmat <- format(x)
  colnames(strmat) <- data_columns
  for (j in data_columns) {
    rindex <- body_data$.type %in% c("one_row", "list_data")
    current_col_str <- ft[["body"]]$content$content$data[rindex, j]

    ft[["body"]]$content$content$data[rindex, j] <- mapply(
      function(obj, txt) {
        obj$txt <- txt
        obj
      },
      obj = current_col_str, txt = trimws(strmat[, j]),
      SIMPLIFY = FALSE
    )
  }
  if (any(body_data$.type %in% "list_title")) {
    ft <- merge_h_range(ft,
      i = ~ .type %in% c("list_title"),
      j1 = 1L, j2 = length(columns_keys)
    )
    ft <- mk_par(ft, i = body_data$.type %in% c("list_title", "one_row"), j = 1, value = {{ row_title }})
    ft <- style(ft, i = body_data$.type %in% c("list_title", "one_row"), j = 1, pr_p = fp_p, part = "body")
    if (add_tab) {
      ft <- prepend_chunks(ft, i = ~ .type %in% "list_data", j = 1, as_chunk("\t"))
    }
  }


  ft <- fix_border_issues(ft)
  best_widths_ <- dim_pretty(ft)$widths
  best_widths_[setdiff(seq_along(columns_keys), seq_len(.ncol))] <- max(best_widths_[setdiff(seq_along(columns_keys), seq_len(.ncol))])
  ft <- width(ft, width = best_widths_)

  ft$tabular_info <- list(
    row_columns = row_columns,
    data_columns = data_columns
  )

  ft
}

# utils -----

expand_dataset <- function(
    body_data,
    is_title, is_single,
    group_colname = "COL1") {
  body_data$.fakeid <- seq_len(nrow(body_data))

  title_dat <- body_data[is_title, ]
  title_dat$.fakeid <- title_dat$.fakeid - .1
  title_dat <- title_dat[, c(".fakeid", group_colname)]
  title_dat$.type <- rep("list_title", nrow(title_dat))

  singlerow_dat <- body_data[is_single, ]
  singlerow_dat$.fakeid <- singlerow_dat$.fakeid - .1
  .col_dest <- head(setdiff(colnames(singlerow_dat), group_colname), 1)
  singlerow_dat[[.col_dest]] <- singlerow_dat[[group_colname]]
  singlerow_dat[[group_colname]] <- rep(NA_character_, nrow(singlerow_dat))
  singlerow_dat$.type <- rep("one_row", nrow(singlerow_dat))

  body_data <- body_data[!is_single, ]
  body_data[[group_colname]] <- rep(NA_character_, nrow(body_data))
  body_data$.type <- rep("list_data", nrow(body_data))

  dat <- rbindlist(list(title_dat, singlerow_dat, body_data), use.names = TRUE, fill = TRUE)
  dat <- dat[order(dat$.fakeid), ]
  dat$.fakeid <- NULL

  setDF(dat)
  dat
}

vmerge_instructions <- function(x) {
  label_data <- tables::rowLabels(x)
  label_data <- apply(label_data[], 2, function(z) {
    notna <- !is.na(z)
    rleid(cumsum(notna))
  })
  label_data <- as.data.frame(label_data)
  colnames(label_data) <- sprintf("COL%.0f", seq_len(ncol(label_data)))
  label_data
}
hmerge_instructions <- function(x) {
  label_data <- tables::colLabels(x)
  label_data <- apply(label_data[], 1, function(z) {
    notna <- !is.na(z)
    rleid(cumsum(notna))
  })
  label_data <- as.data.frame(label_data)
  label_data
}

fortify_tabular_body <- function(x, ...) {
  row_labels <- as.data.frame(unclass(tables::rowLabels(x)))
  names(row_labels) <- sprintf("COL%.0f", seq_len(ncol(row_labels)))

  dims <- attr(x, "dim")
  celldata <- matrix(x[], nrow = dims[1], ncol = dims[2])
  celldata <- apply(celldata, 2, function(dat) {
    unlist(dat)
  })
  celldata <- as.data.frame(celldata)
  names(celldata) <- sprintf("COL%.0f", seq_len(ncol(celldata)) + ncol(row_labels))
  cbind(row_labels, celldata)
}

fortify_tabular_header <- function(x, ...) {
  col_labels <- as.data.frame(unclass(tables::colLabels(x)))
  row_labels <- matrix(
    rep(colnames(tables::rowLabels(x)), nrow(col_labels)),
    nrow = nrow(col_labels), byrow = TRUE
  )

  dat <- cbind(row_labels, col_labels)
  dat <- t(dat)
  dat <- as.data.frame(dat)
  dat$col_keys <- sprintf("COL%.0f", seq_len(nrow(dat)))
  dat
}

fortify_tabular_justify <- function(x, justification = "c", ...) {
  justify <- attr(x, "justification")
  rlabels <- tables::rowLabels(x)
  rjustify <- attr(rlabels, "justification")

  clabels <- tables::colLabels(x)
  cjustify <- attr(clabels, "justification")
  corjustify <- matrix(NA, nrow(clabels), ncol(rlabels))
  for (i in seq_len(ncol(rlabels))) {
    corjustify[nrow(clabels), i] <- rjustify[1, i]
  }
  justify <- rbind(
    cbind(corjustify, cjustify),
    cbind(rjustify, justify)
  )
  justify[is.na(justify)] <- justification
  justify[] <- c(l = "left", c = "center", r = "right", n = "left")[justify]
  colnames(justify) <- sprintf("COL%.0f", seq_len(ncol(justify)))

  list(
    header = justify[seq_len(nrow(clabels)), , drop = FALSE],
    body = justify[setdiff(seq_len(nrow(justify)), seq_len(nrow(clabels))), , drop = FALSE]
  )
}

is_list_title <- function(x) {
  lag_str <- c(tail(x, -1), "")
  !is.na(x) & is.na(lag_str)
}

is_one_row <- function(x) {
  lag_str <- c(tail(x, -1), "")
  !is.na(x) & !is.na(lag_str)
}

