# helpers ----

.levels_summary <- function(x, max_levels) {
  if (length(x) > max_levels) {
    paste0(
      paste0("'", head(x, n = max_levels), "'", collapse = ", "),
      ", ..."
    )
  } else {
    paste0("'", x, "'", collapse = ", ")
  }
}

.col_summary <- function(col, nm, max_levels) {
  na_count <- sum(is.na(col))
  non_na <- sum(!is.na(col))

  out <- data.frame(
    col_name = nm,
    col_type = NA_character_,
    n = NA_integer_,
    na_count = na_count,
    min_val = NA_real_,
    max_val = NA_real_,
    str_val = NA_character_,
    data_kind = NA_character_,
    stringsAsFactors = FALSE
  )

  if (is.logical(col)) {
    out$col_type <- "logical"
    out$n <- non_na
    out$data_kind <- "logical"
    if (non_na > 0L) {
      out$str_val <- paste0(
        "TRUE: ",
        sum(col, na.rm = TRUE),
        ", FALSE: ",
        sum(!col, na.rm = TRUE)
      )
    }
  } else if (is.numeric(col)) {
    out$col_type <- if (is.integer(col)) "integer" else "numeric"
    out$n <- non_na
    out$data_kind <- "numeric"
    if (non_na > 0L) {
      out$min_val <- min(col, na.rm = TRUE)
      out$max_val <- max(col, na.rm = TRUE)
    }
  } else if (is.factor(col)) {
    levs <- levels(droplevels(col))
    out$col_type <- "factor"
    out$n <- length(levs)
    out$data_kind <- "discrete"
    if (length(levs) > 0L) {
      out$str_val <- .levels_summary(levs, max_levels = max_levels)
    }
  } else if (is.character(col)) {
    vals <- sort(unique(na.omit(col)))
    out$col_type <- "character"
    out$n <- length(vals)
    out$data_kind <- "discrete"
    if (length(vals) > 0L) {
      out$str_val <- .levels_summary(vals, max_levels = max_levels)
    }
  } else if (
    inherits(col, "Date") ||
      inherits(col, "POSIXt") ||
      inherits(col, "hms") ||
      inherits(col, "difftime")
  ) {
    out$col_type <- if (inherits(col, "Date")) {
      "Date"
    } else if (inherits(col, "POSIXt")) {
      "POSIXct"
    } else {
      "hms"
    }
    out$n <- non_na
    out$data_kind <- "range"
    if (non_na > 0L) {
      out$str_val <- paste0(
        format(min(col, na.rm = TRUE)),
        " - ",
        format(max(col, na.rm = TRUE))
      )
    }
  } else {
    return(NULL)
  }
  out
}

# main ----

#' @export
#' @title Compact Summary of a Dataset
#' @description
#' Produces a compact summary of a data.frame. Each row of the
#' result describes one column of the input with a type-specific
#' synopsis.
#'
#' Supported types and their summaries:
#'
#' - **numeric / integer**: count of non-`NA` values, min and max.
#' - **character**: number of unique values, first values listed.
#' - **factor**: number of levels, levels listed.
#' - **logical**: count of non-`NA` values, counts of `TRUE` and
#'   `FALSE`.
#' - **Date**: count of non-`NA` values, date range.
#' - **POSIXct / POSIXlt**: count of non-`NA` values, datetime
#'   range.
#' - **hms / difftime**: count of non-`NA` values, time range.
#'
#' Character and factor columns share the same summary layout
#' but report a different type label.
#'
#' The result has class `"compact_summary"` and can be converted
#' into a flextable with [as_flextable()].
#' @param x A data.frame.
#' @param show_type If `TRUE`, a *Type* column is added when the
#'   object is rendered as a flextable.
#' @param show_na If `TRUE`, a *NA* column showing the count of
#'   missing values per column is added when rendered as a
#'   flextable.
#' @param max_levels Maximum number of levels or unique values
#'   displayed for factor and character columns. Additional
#'   values are replaced by `", ..."`.
#' @return A data.frame with additional class `"compact_summary"`.
#' @examples
#' z <- compact_summary(iris)
#' as_flextable(z)
#'
#' z <- compact_summary(iris, show_type = TRUE, show_na = TRUE)
#' as_flextable(z)
#' @family as_flextable methods
#' @seealso [as_flextable.compact_summary()]
compact_summary <- function(
  x,
  show_type = FALSE,
  show_na = FALSE,
  max_levels = 10L
) {
  if (!is.data.frame(x)) {
    stop("compact_summary() expects a data.frame.", call. = FALSE)
  }

  summaries <- mapply(
    .col_summary,
    col = x,
    nm = names(x),
    MoreArgs = list(max_levels = max_levels),
    SIMPLIFY = FALSE
  )
  result <- rbindlist(Filter(Negate(is.null), summaries))
  setDF(result)

  if (is.null(result)) {
    result <- data.frame(
      col_name = character(0),
      col_type = character(0),
      n = integer(0),
      na_count = integer(0),
      min_val = numeric(0),
      max_val = numeric(0),
      str_val = character(0),
      data_kind = character(0),
      stringsAsFactors = FALSE
    )
  }
  rownames(result) <- NULL

  attr(result, "show_type") <- show_type
  attr(result, "show_na") <- show_na
  class(result) <- c("compact_summary", class(result))
  result
}

#' @export
#' @title Transform a 'compact_summary' object into a flextable
#' @description `compact_summary` objects can be transformed into
#' a flextable with method [as_flextable()].
#'
#' Numeric columns are formatted with [formatC()] using the
#' `digits` value stored in the object and the current
#' flextable defaults for `big.mark` and `decimal.mark`.
#' @param x A `compact_summary` object produced by
#'   [compact_summary()].
#' @param ... unused arguments.
#' @return A [flextable()] object.
#' @examples
#' z <- compact_summary(iris, show_type = TRUE, show_na = TRUE)
#' as_flextable(z)
#' @family as_flextable methods
as_flextable.compact_summary <- function(x, ...) {
  show_type <- attr(x, "show_type")
  show_na <- attr(x, "show_na")

  z <- get_flextable_defaults()
  format_num <- function(val) {
    formatC(
      val,
      format = "f",
      big.mark = z$big.mark,
      digits = z$digits,
      decimal.mark = z$decimal.mark
    )
  }

  col_keys <- "col_name"
  if (isTRUE(show_type)) {
    col_keys <- c(col_keys, "col_type")
  }
  col_keys <- c(col_keys, "n")
  if (isTRUE(show_na)) {
    col_keys <- c(col_keys, "na_count")
  }
  col_keys <- c(col_keys, "Values")

  ft <- flextable(x, col_keys = col_keys)
  ft <- set_header_labels(
    ft,
    col_name = "Column",
    col_type = "Type",
    n = "N",
    na_count = "NA",
    Values = "Values"
  )

  is_num <- which(x$data_kind %in% "numeric")
  if (length(is_num) > 0L) {
    ft <- mk_par(
      ft,
      i = is_num,
      j = "Values",
      value = as_paragraph(
        "Min: ",
        as_chunk(min_val, formatter = format_num),
        ", Max: ",
        as_chunk(max_val, formatter = format_num)
      )
    )
  }

  is_str <- which(!x$data_kind %in% "numeric")
  if (length(is_str) > 0L) {
    ft <- mk_par(
      ft,
      i = is_str,
      j = "Values",
      value = as_paragraph(as_chunk(str_val))
    )
  }

  ft <- colformat_int(ft, j = "n")
  if (isTRUE(show_na)) {
    ft <- colformat_int(ft, j = "na_count")
  }

  autofit(ft)
}
