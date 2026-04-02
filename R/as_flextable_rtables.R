#' @export
#' @title Transform an rtables object into a flextable
#' @description produce a flextable from a `TableTree` or
#' `ElementaryTable` object produced with the
#' 'rtables' package.
#'
#' The conversion uses [formatters::matrix_form()] to extract the
#' formatted content, column spans, alignments, indentation
#' and footnotes, then maps them to flextable features.
#'
#' Indentation of row labels is rendered with left padding.
#'
#' Label rows (`LabelRow`) are displayed in bold in the first column.
#' Content rows (`ContentRow`) are displayed entirely in bold.
#'
#' When `LabelRow` groups exist, [paginate()] is applied so
#' that all rows belonging to the same group are kept together
#' on the same page in Word and RTF output.
#'
#' To paginate the resulting flextable into multiple pages, use
#' [split_to_pages()], [split_rows()], or [split_columns()] after
#' calling `as_flextable()`.
#' @param x a `TableTree` or `ElementaryTable` object produced
#'   by the 'rtables' package.
#' @param indent_padding base left padding in points per indentation
#'   level. Default is `4`.
#' @param ... unused arguments
#' @return a flextable object.
#' @seealso [split_to_pages()], [split_rows()], [split_columns()]
#' @examples
#' if (require("rtables", character.only = TRUE, quietly = TRUE)) {
#'   library(rtables)
#'
#'   lyt <- basic_table(title = "Demographic Summary") %>%
#'     split_cols_by("ARM") %>%
#'     split_rows_by("SEX") %>%
#'     analyze("AGE", afun = mean, format = "xx.x")
#'
#'   tbl <- build_table(lyt, DM)
#'   as_flextable(tbl)
#' }
as_flextable.TableTree <- function(
  x,
  indent_padding = 4,
  ...
) {
  rtables_to_flextable(
    x,
    indent_padding = indent_padding,
    ...
  )
}

#' @export
#' @rdname as_flextable.TableTree
as_flextable.ElementaryTable <- function(
  x,
  indent_padding = 4,
  ...
) {
  rtables_to_flextable(
    x,
    indent_padding = indent_padding,
    ...
  )
}


rtables_to_flextable <- function(
  x,
  indent_padding = 4,
  ...
) {
  stopifnot(
    requireNamespace("formatters", quietly = TRUE),
    requireNamespace("rtables", quietly = TRUE)
  )

  mf <- formatters::matrix_form(x, indent_rownames = TRUE)
  indent_size <- mf$indent_size
  str_mat <- formatters::mf_strings(mf)
  spans_mat <- formatters::mf_spans(mf)
  aligns_mat <- formatters::mf_aligns(mf)
  rinfo <- formatters::mf_rinfo(mf)
  nlh <- formatters::mf_nlheader(mf)

  nc <- ncol(str_mat)
  nr <- nrow(str_mat)
  n_body <- nr - nlh

  col_keys <- paste0("col_", seq_len(nc))

  header_rows <- seq_len(nlh)
  body_rows <- seq(nlh + 1, nr)

  base_padding <- get_flextable_defaults()$padding.left

  # --- body ---
  body_mat <- str_mat[body_rows, , drop = FALSE]
  body_df <- as.data.frame(body_mat, stringsAsFactors = FALSE)
  colnames(body_df) <- col_keys

  # strip leading spaces added by indent_rownames
  indents <- rinfo$indent
  body_df[[1]] <- trimws(body_df[[1]], which = "left")

  ft <- flextable(body_df, col_keys = col_keys)

  # apply left padding for indentation
  for (lvl in unique(indents[indents > 0])) {
    rows <- which(indents == lvl)
    ft <- padding(
      ft,
      i = rows,
      j = 1,
      padding.left = base_padding + lvl * indent_padding
    )
  }

  # --- header ---
  header_mat <- str_mat[header_rows, , drop = FALSE]

  # detect indent levels from leading spaces in column 1
  header_spaces <- nchar(header_mat[, 1]) -
    nchar(trimws(header_mat[, 1], which = "left"))
  header_indents <- header_spaces %/% indent_size
  header_mat[, 1] <- trimws(header_mat[, 1], which = "left")

  mapping <- as.data.frame(t(header_mat), stringsAsFactors = FALSE)
  colnames(mapping) <- paste0("V", seq_len(nlh))
  mapping$col_keys <- col_keys
  ft <- set_header_df(ft, mapping = mapping, key = "col_keys")

  # apply left padding for header indentation
  for (lvl in unique(header_indents[header_indents > 0])) {
    hdr_rows <- which(header_indents == lvl)
    ft <- padding(
      ft,
      i = hdr_rows,
      j = 1,
      padding.left = base_padding + lvl * indent_padding,
      part = "header"
    )
  }

  # --- header spans ---
  for (i in seq_len(nlh)) {
    spans_row <- spans_mat[i, ]
    j <- 1L
    while (j <= nc) {
      span <- spans_row[j]
      if (span > 1L) {
        ft <- merge_at(ft, part = "header", i = i, j = j:(j + span - 1L))
        j <- j + span
      } else {
        j <- j + 1L
      }
    }
  }

  # --- body spans ---
  for (i in seq_len(n_body)) {
    spans_row <- spans_mat[nlh + i, ]
    j <- 1L
    while (j <= nc) {
      span <- spans_row[j]
      if (span > 1L) {
        ft <- merge_at(ft, part = "body", i = i, j = j:(j + span - 1L))
        j <- j + span
      } else {
        j <- j + 1L
      }
    }
  }

  ft <- do.call(get_flextable_defaults()$theme_fun, list(ft))

  # --- alignments ---
  align_map <- c(
    "left" = "left",
    "right" = "right",
    "center" = "center",
    "decimal" = "right",
    "dec_right" = "right",
    "dec_left" = "left"
  )
  ft <- align(ft, align = align_map[aligns_mat[header_rows, ]], part = "header")
  ft <- align(ft, align = align_map[aligns_mat[body_rows, ]], part = "body")

  # --- style by node_class ---
  label_rows <- which(rinfo$node_class == "LabelRow")
  if (length(label_rows) > 0L) {
    ft <- bold(ft, i = label_rows, j = 1, part = "body")
    ft <- merge_h_range(ft, i = label_rows, j1 = 1, j2 = ncol_keys(ft))
  }

  # --- trailing separators (horizontal lines between groups) ---
  trailing_seps <- rinfo$trailing_sep
  sep_rows <- which(!is.na(trailing_seps))
  if (length(sep_rows) > 0L) {
    ft <- hline(ft, i = sep_rows, part = "body", border = fp_border_default())
  }

  # --- titles ---
  main_ttl <- formatters::main_title(mf)
  sub_ttls <- formatters::subtitles(mf)

  if (length(main_ttl) > 0L && any(nzchar(main_ttl))) {
    ft <- set_caption(ft, caption = paste(main_ttl, collapse = " "))
  }
  if (length(sub_ttls) > 0L && any(nzchar(sub_ttls))) {
    ft <- add_header_lines(ft, values = sub_ttls, top = TRUE)
  }

  # --- footnotes ---
  ref_fnotes <- formatters::mf_rfnotes(mf)
  if (length(ref_fnotes) > 0L) {
    ft <- add_footer_lines(ft, values = ref_fnotes)
  }

  main_ftr <- formatters::main_footer(mf)
  if (length(main_ftr) > 0L && any(nzchar(main_ftr))) {
    ft <- add_footer_lines(ft, values = main_ftr)
  }

  prov_ftr <- formatters::prov_footer(mf)
  if (length(prov_ftr) > 0L && any(nzchar(prov_ftr))) {
    ft <- add_footer_lines(ft, values = prov_ftr)
  }

  # --- finish ---
  ft <- autofit(ft)

  # --- paginate hints for Word/RTF ---
  if (length(label_rows) > 0L) {
    rows_grp_start <- intersect(which(indents < 1), label_rows)
    ft <- paginate(
      ft,
      hdr_ftr = TRUE,
      init = FALSE,
      group = rows_grp_start,
      group_def = "starts"
    )
  }

  ft
}
