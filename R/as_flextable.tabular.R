#' @export
#' @title convert tabular to flextable
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
#' Two hidden columns can be used after the creation of
#' the flextable (use only when `spread_first_col=TRUE`):
#'
#' - `.row_title` that contains the title label
#' - `.is_row_title` that contains TRUE if a row is
#' considered as a row title.
#'
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
#'
#'   tab <- tabular(
#'     (Species + 1) ~ (n = 1) + Format(digits = 2) *
#'       (Sepal.Length + Sepal.Width) * (mean + sd),
#'     data = iris
#'   )
#'   as_flextable(tab)
#'
#'   x <- tabular((Factor(gear, "Gears") + 1)
#'   * ((n = 1) + Percent()
#'       + (RowPct = Percent("row"))
#'       + (ColPct = Percent("col")))
#'   ~ (Factor(carb, "Carburetors") + 1)
#'     * Format(digits = 1), data = mtcars)
#'
#'   ft <- as_flextable(
#'     x, spread_first_col = TRUE,
#'     row_title = as_paragraph(
#'       colorize("Gears: ", color = "#666666"),
#'       colorize(as_b(.row_title), color = "red"))
#'   )
#'   ft
#'
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
                                 ...) {
  stopifnot(requireNamespace("tables", quietly = TRUE))

  body_data <- fortify_tabular_body(x)
  header_data <- fortify_tabular_header(x)
  text_align <- fortify_tabular_justify(x)
  vmerge_ins <- vmerge_instructions(x)
  hmerge_ins <- hmerge_instructions(x)
  .ncol <- ncol(tables::rowLabels(x))

  row_colkeys <- paste0("COL", seq_len(.ncol))

  group_colname <- character()

  is_title <- rep(FALSE, nrow(body_data))
  if(spread_first_col){
    group_colname <- row_colkeys[1]
    body_data <- expand_tabular_data(body_data)
    is_title <- !is.na(body_data$COL1)
  }

  colkeys <- setdiff(colnames(body_data), group_colname)
  row_colkeys <- setdiff(row_colkeys, group_colname)
  .ncol <- .ncol - length(group_colname)

  vmerge_ins <- vmerge_ins[, setdiff(colnames(vmerge_ins), group_colname), drop = FALSE]
  text_align$header <- text_align$header[, setdiff(colnames(text_align$header), group_colname), drop = FALSE]
  text_align$body <- text_align$body[, setdiff(colnames(text_align$body), group_colname), drop = FALSE]

  tabular_colnames <- setdiff(colnames(body_data), c(row_colkeys, group_colname))

  body_data$.is_row_title <- is_title
  if (length(group_colname)) {
    body_data$.row_title <- body_data[[group_colname]]
  }

  ft <- flextable(body_data, col_keys = colkeys)

  ft <- set_header_df(ft, mapping = header_data)

  ft <- merge_v(ft, part = "header", j = row_colkeys)

  for (i in seq_along(hmerge_ins)) {
    hgroups <- split(seq_len(nrow(hmerge_ins)), hmerge_ins[[i]])
    for (hgroup in hgroups) {
      ft <- merge_at(ft, part = "header", j = hgroup + .ncol, i = i)
    }
  }

  for (j in names(vmerge_ins)) {
    vgroups <- split(seq_len(nrow(vmerge_ins)), vmerge_ins[[j]])
    for (vgroup in vgroups) {
      ft <- merge_at(ft, part = "body", j = j, i = vgroup)
    }
  }

  ft <- do.call(get_flextable_defaults()$theme_fun, list(ft))

  for (j in colkeys) {
    ft <- align(ft, j = j, align = text_align$header[, j], part = "header")
    ft <- align(ft, j = j, i = ~ .is_row_title %in% FALSE,
                align = text_align$body[, j], part = "body")
  }

  ft <- valign(ft, valign = "top", part = "body")
  ft <- valign(ft, valign = "bottom", part = "header")

  # format functions can not be simply called
  # then, it looks easier to call format.tabular
  # and inject its trimmed values. That way we
  # preserve data types and can do conditionnal
  # formatting
  strmat <- format(x)
  colnames(strmat) <- tabular_colnames
  for (j in tabular_colnames) {
    current_col_str <- ft[["body"]]$content$content$data[!is_title, j]

    ft[["body"]]$content$content$data[!is_title, j] <-
      mapply(
        function(obj, txt) {
          obj$txt <- txt
          obj
        },
        current_col_str, trimws(strmat[, j]),
        SIMPLIFY = FALSE
      )
  }

  if (any(is_title)) {
    ft <- merge_h_range(ft, i = ~ .is_row_title %in% TRUE,
                        j1 = 1L, j2 = length(colkeys))
    ft <- mk_par(ft, i = is_title, j = 1, value = {{row_title}})
    ft <- style(ft, i = is_title, j = 1, pr_p = fp_p, part = "body")
  }

  ft <- fix_border_issues(ft)
  best_widths_ <- dim_pretty(ft)$widths
  best_widths_[setdiff(seq_along(colkeys), seq_len(.ncol))] <- max(best_widths_[setdiff(seq_along(colkeys), seq_len(.ncol))])
  ft <- width(ft, width = best_widths_)
  ft
}

# utils -----
expand_tabular_data <- function(body_data, group_colname = "COL1") {

  body_data$.fakeid <- seq_len(nrow(body_data))

  newdat <- body_data[!is.na(body_data[[group_colname]]),]
  newdat$.fakeid <- newdat$.fakeid - .1

  newdat <- newdat[, c(".fakeid", group_colname)]

  body_data[[group_colname]] <- NULL

  body_data <- rbindlist(list(newdat, body_data), use.names = TRUE, fill = TRUE)

  body_data <- body_data[order(body_data$.fakeid),]
  body_data$.fakeid <- NULL

  setDF(body_data)
  body_data
}

vmerge_instructions <- function(x) {
  label_data <- tables::rowLabels(x)
  label_data <- apply(label_data, 2, function(z) {
    notna <- !is.na(z)
    rleid(cumsum(notna))
  }, simplify = FALSE)
  label_data <- as.data.frame(label_data)
  colnames(label_data) <- sprintf("COL%.0f", seq_len(ncol(label_data)))
  label_data
}
hmerge_instructions <- function(x) {
  label_data <- tables::colLabels(x)
  label_data <- apply(label_data, 1, function(z) {
    notna <- !is.na(z)
    rleid(cumsum(notna))
  }, simplify = FALSE)
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
  }, simplify = FALSE)
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
