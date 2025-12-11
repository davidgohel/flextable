#' @export
#' @title Transform a 'gt' object into a flextable
#' @description produce a flextable from a 'gt_tbl' object.
#'
#' This function extracts:
#' 1. The underlying data frame.
#' 2. The column labels (`cols_label`).
#' 3. The spanner column labels (`tab_spanner`).
#'
#' @param x a [gt::gt()] object
#' @param ... unused argument
#' @family as_flextable methods
as_flextable.gt_tbl <- function(x, ...) {
  if (!requireNamespace("gt", quietly = TRUE)) {
    stop("The 'gt' package is required.")
  }
  dat <- x[["_data"]]
  boxhead <- x[["_boxhead"]]

  ft <- flextable(dat)

  header_mapping <- data.frame(
    col_keys = boxhead$var,
    col_labels = unlist(lapply(boxhead$column_label, as.character)), # Handle list columns
    stringsAsFactors = FALSE
  )

  spanners <- x[["_spanners"]]
  if (!is.null(spanners) && nrow(spanners) > 0) {
    unique_levels <- sort(unique(spanners$spanner_level), decreasing = TRUE)
    for (lvl in unique_levels) {
      col_name <- paste0("span_lvl_", lvl)
      header_mapping[[col_name]] <- NA_character_
      current_spanners <- spanners[spanners$spanner_level == lvl, ]

      for (i in seq_len(nrow(current_spanners))) {
        span_label <- current_spanners$spanner_label[[i]] # It's often a list
        target_vars <- unlist(current_spanners$vars[[i]]) # Vars covered by this spanner

        header_mapping[header_mapping$col_keys %in% target_vars, col_name] <- as.character(span_label)
      }
    }

    span_cols <- grep("span_lvl_", names(header_mapping), value = TRUE)

    final_cols <- c("col_keys", span_cols, "col_labels")
    header_mapping <- header_mapping[, final_cols]

    ft <- set_header_df(ft, mapping = header_mapping, key = "col_keys")

    ft <- merge_h(ft, part = "header")
    ft <- merge_v(ft, part = "header")

  } else {
    labels <- setNames(header_mapping$col_labels, header_mapping$col_keys)
    valid_cols <- intersect(names(labels), colnames(dat))
    if (length(valid_cols) > 0) {
      ft <- set_header_labels(ft, values = labels[valid_cols])
    }
  }
  ft <- autofit(ft)
  ft
}
