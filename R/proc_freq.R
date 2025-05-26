fmt_freq_table <- function(pctcol, pctrow, include.row_percent = TRUE, include.column_percent = TRUE) {
  out_cols <- rep("", length(pctcol))
  out_rows <- out_sep <- out_cols

  if (include.column_percent) {
    out_cols[!is.na(pctcol)] <- fmt_pct(pctcol[!is.na(pctcol)])
  }
  if (include.row_percent) {
    out_rows[!is.na(pctrow)] <- fmt_pct(pctrow[!is.na(pctrow)])
  }
  if (include.column_percent && include.row_percent) {
    out_sep[!is.na(pctcol) | !is.na(pctrow)] <- " ; "
  }

  paste0(out_cols, out_sep, out_rows)
}

add_level_total <- function(sdat, to_na = TRUE, lev = "Total") {
  z <- sdat[, lapply(.SD, function(x, lev) {
    if (is.factor(x)) {
      old_levs <- levels(x)
      new_levs <- c(old_levs, lev)
      levels(x) <- new_levs
      if (to_na && all(is.na(x))) x[] <- lev
    }
    x
  }, lev = lev)]
  z$grouping <- NULL
  z
}


#' @importFrom data.table groupingsets
fortified_freq <- function(dat, row = character(), column = character(), weight = character()) {
  by <- unique(c(row, column))
  sets <- list()
  if (length(by) > 1) {
    sets <- list(c(row, column), row, column, character())
  } else if (length(by) > 0) {
    sets <- list(by, character())
  }
  dataset <- as.data.table(dat)
  if (length(weight) == 1) {
    setnames(dataset, old = weight, new = ".weight.")
  } else {
    dataset$.weight. <- 1
  }

  # replace na with "Missing"
  dataset[, c(by) := lapply(.SD, function(x) {
    if (is.factor(x)) {
      old_levs <- levels(x)
      new_levs <- c(old_levs, "Missing")
      levels(x) <- new_levs
      x[is.na(x)] <- "Missing"
    } else if (is.character(x)) {
      x[is.na(x)] <- "Missing"
    }
    x
  }), .SDcols = by]

  freq_data <- groupingsets(
    x = dataset,
    j = c(list(count = sum(.SD$.weight., na.rm = TRUE))),
    by = by,
    sets = sets,
    id = TRUE
  )

  if (length(by) > 1) {
    row_sums <- add_level_total(freq_data[freq_data$grouping %in% 1, ])
    col_sums <- add_level_total(freq_data[freq_data$grouping %in% 2, ])
    all_sums <- add_level_total(freq_data[freq_data$grouping %in% 3, ])
    tab_ct <- add_level_total(freq_data[freq_data$grouping %in% 0, ])
    tab <- rbindlist(list(row_sums, col_sums, all_sums, tab_ct))

    setnames(row_sums, old = "count", new = "total_row")
    row_sums[[column]] <- NULL
    rtab <- merge(tab, row_sums, by = row)
    rtab[, c("pct_row", "total_row", "count") := list(.SD$count / .SD$total_row, NULL, NULL)]

    setnames(col_sums, old = "count", new = "total_col")
    col_sums[[row]] <- NULL
    ctab <- merge(tab, col_sums, by = column)
    ctab[, c("pct_col", "total_col", "count") := list(.SD$count / .SD$total_col, NULL, NULL)]

    tab_margins <- merge(ctab, rtab, by = by, all = FALSE)
    tab <- merge(tab, tab_margins, by = by, all = TRUE)
  } else if (length(by) > 0) {
    all_sums <- add_level_total(freq_data[freq_data$grouping %in% 1, ])
    tab_ct <- add_level_total(freq_data[freq_data$grouping %in% 0, ])
    tab <- rbindlist(list(all_sums, tab_ct))
  }
  tab[, c("pct") := list(.SD$count / all_sums$count)]
  setDF(tab)
  tab
}

relayout_freq_data <- function(x, order_by) {
  dat_pct_rowcol <- as.data.table(x)
  dat_pct_rowcol[, c("count", "pct", ".what.") := list(NULL, NULL, "mpct")]

  dat <- as.data.table(x)
  dat$.what. <- "count"
  dat[, c("pct_col", "pct_row") := NULL]

  dat <- rbindlist(list(dat_pct_rowcol, dat),
    fill = TRUE, use.names = TRUE
  )
  dat$.what. <- factor(dat$.what., c("count", "mpct"))
  setorderv(dat, c(order_by, ".what."))

  setDF(dat)
  dat
}


#' @title Frequency table
#'
#' @description This function computes a one or two way
#' contingency table and creates a flextable from the result.
#'
#' The function is largely inspired by "PROC FREQ" from "SAS"
#' and was written with the intent to make it
#' as compact as possible.
#' @param x a `data.frame` object containing variable(s) to use for counts.
#' @param row `characer` column names for row
#' @param col `characer` column names for column
#' @param include.row_percent `boolean` whether to include the row percents; defaults to `TRUE`
#' @param include.column_percent `boolean` whether to include the column percents; defaults to `TRUE`
#' @param include.table_percent `boolean` whether to include the table percents; defaults to `TRUE`
#' @param include.table_count `boolean` whether to include the table counts; defaults to `TRUE`
#' @param weight `character` column name for weight
#' @param count_format_fun a function to format the count values,
#' defaults to [fmt_int].
#' @param ... unused arguments
#' @importFrom stats as.formula
#' @examples
#' proc_freq(mtcars, "vs", "gear")
#' proc_freq(mtcars, "gear", "vs", weight = "wt")
#' @export
proc_freq <- function(x, row = character(), col = character(),
                      include.row_percent = TRUE,
                      include.column_percent = TRUE,
                      include.table_percent = TRUE,
                      include.table_count = TRUE,
                      weight = character(),
                      count_format_fun = fmt_int,
                      ...) {

  list_lbls <- collect_labels(dataset = x, use_labels = TRUE)
  for(colname in names(list_lbls$values_labels)) {
    x[[colname]] <- factor(
      x = x[[colname]],
      levels = names(list_lbls$values_labels[[colname]]),
      labels = unname(list_lbls$values_labels[[colname]])
    )
  }

  if (length(row) && !is.factor(x[[row]])) {
    x[[row]] <- as.factor(x[[row]])
  }

  if (length(col) && !is.factor(x[[col]])) {
    x[[col]] <- as.factor(x[[col]])
  }
  by <- unique(c(row, col))
  if (!length(by) %in% 1:2) {
    stop("The `col` and `row` parameters do not allow to define a univariate or bivariate count table. It requires exactly one or two columns.")
  }

  dat <- fortified_freq(x, row = row, column = col, weight = weight)
  if (length(by) > 1) {
    dat <- relayout_freq_data(dat, order_by = by)
    dat <- dat[!(dat[[row]] %in% "Total" & dat[[".what."]] %in% c("mpct")), ]
    dat$.coltitle. <- col

    count <- pct <- pct_col <- pct_row <- NULL

    rows_set <- c(row, ".what.")
    first_vline <- 2
    fnote_lab <- NA_character_
    margins_label <- "Mar. pct"

    if (include.column_percent && include.row_percent) {
      fnote_lab <- " Columns and rows percentages"
    } else if (include.column_percent && !include.row_percent) {
      margins_label <- "Col. pct"
    } else if (!include.column_percent && include.row_percent) {
      margins_label <- "Row pct"
    } else {
      dat <- dat[!(dat[[".what."]] %in% c("mpct")), ]
      rows_set <- row
      first_vline <- 1
    }

    table_label <- "Count"
    if (!include.table_count && include.table_percent) {
      table_label <- "Percent"
    } else if (!include.table_count && !include.table_percent) {
      stop("At least one of the include.table_*  parameters must be TRUE.")
    }
    tab <- tabulator(
      x = dat,
      rows = rows_set,
      columns = c(".coltitle.", col),
      stat = as_paragraph(
        if (include.table_count & include.table_percent) {
          as_chunk(fmt_n_percent(count, pct))
        } else if (include.table_count) {
          as_chunk(count, formatter = count_format_fun)
        } else if (include.table_percent) {
          as_chunk(fmt_pct(pct))
        },
        as_chunk(fmt_freq_table(pct_col, pct_row,
          include.column_percent = include.column_percent,
          include.row_percent = include.row_percent
        ))
      )
    )

    ft <- as_flextable(tab, columns_alignment = "center", sep_w = 0)
    if (include.column_percent || include.row_percent) {
      ft <- labelizor(
        x = ft,
        labels = c(.what. = "", "count" = table_label, "mpct" = margins_label), j = ".what."
      )
      if (!is.na(fnote_lab)) {
        ft <- footnote(ft,
          ref_symbols = " (1)",
          j = ".what.",
          i = ~ .what. %in% "mpct" & !duplicated(.what.),
          value = as_paragraph(fnote_lab), part = "body"
        )
      }
    }
    ft <- hline(ft, i = as.formula(sprintf("~before(`%s`, 'Total')", row)))
    ft <- vline(ft, j = ncol_keys(ft) - 1)
    ft <- vline(ft, j = first_vline)
    ft <- autofit(ft)
  } else {
    dat <- dat[do.call(order, dat[by]), ]
    ft <- flextable(dat)
    ft <- hline(ft, i = as.formula(sprintf("~before(`%s`, 'Total')", by)))
    ft <- set_formatter(ft, pct = fmt_pct, count = fmt_int)
    ft <- set_header_labels(ft, count = "Count", pct = "Percent")
    ft <- autofit(ft)
  }

  ft
}
