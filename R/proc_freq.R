fpct_mar <- function(z, digits = 1) {
  x <- fmt_pct(z, digits = digits)
  paste0("\n", x)
}

add_level_all <- function(sdat, to_na = TRUE, lev = "All") {
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

  freq_data <- groupingsets(
    x = dataset,
    j = c(list(count = sum(.SD$.weight., na.rm = TRUE))),
    by = by,
    sets = sets,
    id = TRUE
  )

  if (length(by) > 1) {
    row_sums <- add_level_all(freq_data[freq_data$grouping %in% 1, ])
    col_sums <- add_level_all(freq_data[freq_data$grouping %in% 2, ])
    all_sums <- add_level_all(freq_data[freq_data$grouping %in% 3, ])
    tab_ct <- add_level_all(freq_data[freq_data$grouping %in% 0, ])
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
    all_sums <- add_level_all(freq_data[freq_data$grouping %in% 1, ])
    tab_ct <- add_level_all(freq_data[freq_data$grouping %in% 0, ])
    tab <- rbindlist(list(all_sums, tab_ct))
  }
  tab[, c("pct") := list(.SD$count / all_sums$count)]
  setDF(tab)
  tab
}




#' @title Frequency table as flextable
#'
#' @description This function compute a two way contingency table
#' and make a flextable with the result.
#'
#' @param x `data.frame` object
#' @param row `characer` column names for row
#' @param col `characer` column names for column
#' @param include.row_percent `boolean` whether to include the row percents; defaults to `TRUE`
#' @param include.column_percent `boolean` whether to include the column percents; defaults to `TRUE`
#' @param include.table_percent `boolean` whether to include the table percents; defaults to `TRUE`
#' @param weight `character` column name for weight
#' @param ... unused arguments
#' @importFrom stats as.formula na.omit
#' @examples
#' proc_freq(mtcars, "vs", "gear")
#' proc_freq(mtcars, "gear", "vs", weight = "wt")
#' @export
proc_freq <- function(x, row = character(), col = character(),
                      include.row_percent = TRUE, include.column_percent = TRUE,
                      include.table_percent = TRUE,
                      weight = character(), ...) {
  if (length(row) && !is.factor(x[[row]])) {
    x[[row]] <- as.factor(x[[row]])
  }

  if (length(col) && !is.factor(x[[col]])) {
    x[[col]] <- as.factor(x[[col]])
  }
  by <- unique(c(row, col))
  if (!length(by) %in% 1:2) {
    stop("The `col` and `row` parameters do not allow for a univariate or bivariate count table.")
  }

  dat <- fortified_freq(x, row = row, column = col, weight = weight)

  if (length(by) > 1) {
    count <- pct <- pct_col <- pct_row <- NULL
    dat$.coltitle. <- col
    tab <- tabulator(
      x = dat,
      rows = row,
      columns = c(".coltitle.", col),
      stat = as_paragraph(
        if (include.table_percent) as_chunk(fmt_n_percent(count, pct)) else as_chunk(count, formatter = fmt_int),
        if (include.column_percent) as_chunk(pct_col, formatter = fpct_mar) else "",
        if (include.row_percent) as_chunk(pct_row, formatter = fpct_mar) else ""
      )
    )

    ft <- as_flextable(tab, columns_alignment = "right", sep_w = 0)
    ft <- hline(ft, i = as.formula(sprintf("~before(%s, 'All')", row)))
    ft <- vline(ft, j = ncol_keys(ft)-1)
    ft <- vline(ft, j = 1)

  } else {
    dat <- dat[do.call(order, dat[by]), ]
    ft <- flextable(dat)
    ft <- hline(ft, i = as.formula(sprintf("~before(%s, 'All')", by)))
    ft <- set_formatter(ft, pct = fmt_pct)
    ft <- set_header_labels(ft, count = "Count", pct = "Percent")
    ft <- autofit(ft)
  }
  ft

}
