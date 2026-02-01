#' @export
#' @title Add footnotes to flextable
#' @description The function let add footnotes to a flextable object
#' by adding some symbols in the flextable and associated notes in
#' the footer of the flextable.
#'
#' Symbols are added to the cells designated by the selection `i`
#' and `j`. If you use i = c(1,3) and j = c(2,5), then you will
#' add the symbols (or the repeated symbol) to cells `[1,2]`
#' and `[3,5]`.
#'
#' \if{html}{\out{
#' <img src="https://www.ardata.fr/img/flextable-imgs/flextable-016.png" alt="add_footer illustration" style="width:100\%;">
#'
#' See https://www.ardata.fr/en/flextable-gallery/2022-06-23-separate-headers/ for the example
#' shown
#' }}
#' @inheritParams args_selectors_without_all
#' @param value a call to function [as_paragraph()].
#' @param ref_symbols character value, symbols to append that will be used
#' as references to notes.
#' @param inline whether to add footnote on same line as previous footnote or not
#' @param sep used only when inline = TRUE, character string to use as
#' a separator between footnotes.
#' @param symbol_sep separator to insert between multiple
#' footnote symbols in the same cell (e.g. `","` to
#' produce `1,2` instead of `12`). Default is `""`
#' (no separator, backward compatible).
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- footnote(ft_1,
#'   i = 1, j = 1:3,
#'   value = as_paragraph(
#'     c(
#'       "This is footnote one",
#'       "This is footnote two",
#'       "This is footnote three"
#'     )
#'   ),
#'   ref_symbols = c("a", "b", "c"),
#'   part = "header"
#' )
#' ft_1 <- valign(ft_1, valign = "bottom", part = "header")
#' ft_1 <- autofit(ft_1)
#'
#' ft_2 <- flextable(head(iris))
#' ft_2 <- autofit(ft_2)
#' ft_2 <- footnote(ft_2,
#'   i = 1, j = 1:2,
#'   value = as_paragraph(
#'     c(
#'       "This is footnote one",
#'       "This is footnote two"
#'     )
#'   ),
#'   ref_symbols = c("a", "b"),
#'   part = "header", inline = TRUE
#' )
#' ft_2 <- footnote(ft_2,
#'   i = 1, j = 3:4,
#'   value = as_paragraph(
#'     c(
#'       "This is footnote three",
#'       "This is footnote four"
#'     )
#'   ),
#'   ref_symbols = c("c", "d"),
#'   part = "header", inline = TRUE
#' )
#' ft_2
#'
#' ft_3 <- flextable(head(iris))
#' ft_3 <- autofit(ft_3)
#' ft_3 <- footnote(
#'   x = ft_3, i = 1:3, j = 1:3,
#'   ref_symbols = "a",
#'   value = as_paragraph("This is footnote one")
#' )
#' ft_3
#' @export
#' @importFrom stats update
footnote <- function(x, i = NULL, j = NULL, value,
                     ref_symbols = NULL, part = "body",
                     inline = FALSE, sep = "; ",
                     symbol_sep = "") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "footnote()"))
  }
  if (!inherits(value, "paragraph")) {
    stop("`value` must be a paragraph.")
  }

  part <- match.arg(part, c("body", "header", "footer"),
    several.ok = FALSE
  )

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  if (length(i) < 1) {
    return(x)
  }

  if (is.null(ref_symbols)) {
    symbols_str <- as.character(seq_along(value))
  } else {
    symbols_str <- ref_symbols
  }

  if (any(symbols_str %in% "")) {
    long_msg <- c(
      "Usage of empty symbol '' with footnote should not happen, ",
      "use `add_footer_lines()` instead, it does not require any symbol. "
    )
    long_msg <- paste0(long_msg, collapse = "\n")
    stop(long_msg)
  }

  sep_str <- rep(sep, length(value))

  cell_index <- data.frame(i = i, j = j)
  if (length(symbols_str) == 1) {
    symbols_str <- rep(symbols_str, nrow(cell_index))
  }
  # Assert that either one footnote, or that footnote symbol length matches number
  # of cells to tag
  stopifnot(length(symbols_str) == nrow(cell_index))

  for (index_num in seq_len(nrow(cell_index))) {
    i_cell <- cell_index[["i"]][index_num]
    j_cell <- cell_index[["j"]][index_num]
    if (nzchar(symbol_sep)) {
      cell_para <- get_fpstruct_elements(
        x = x[[part]]$content,
        i = i_cell,
        j = x$col_keys[j_cell]
      )[[1, 1]]
      last_valign <- cell_para$vertical.align[
        nrow(cell_para)
      ]
      if (isTRUE(last_valign == "superscript")) {
        x <- append_chunks(x,
          i = i_cell, j = j_cell,
          part = part,
          as_sup(symbol_sep)
        )
      }
    }
    x <- append_chunks(x,
      i = i_cell, j = j_cell,
      part = part,
      as_sup(symbols_str[index_num])
    )
  }



  if (inline) {
    # init a new line
    if (nrow_part(x, "footer") < 1) {
      x <- add_footer_lines(x, values = "")
      n_row <- 1
    } else {
      n_row <- nrow_part(x, "footer")
      target_par <- get_fpstruct_elements(
        x = x[["footer"]]$content,
        i = n_row,
        j = 1)[[1,1]]
    }

    paras <- mapply(rbind,
      as_paragraph(as_sup(ref_symbols)),
      value,
      as_paragraph(sep_str),
      SIMPLIFY = FALSE
    )
    paras <- rbind_match_columns(paras)
    paras$.chunk_index <- NULL
    for(i in seq_len(nrow(paras))) {
      x[["footer"]]$content <-
        append_chunkset_struct_element(
          x = x[["footer"]]$content,
          i = n_row,
          j = 1,
          chunk_data = paras[i,]
        )
    }
  } else {
    # init new lines
    n_row <- nrow_part(x, "footer")
    x <- add_footer_lines(x, values = rep("", length(value)))
    newcontent <- as_chunkset_struct(
      l_paragraph = value, keys = x$col_keys[1])
    x[["footer"]]$content <- set_chunkset_struct_element(
      x = x[["footer"]]$content,
      i = n_row + seq_along(value), j = 1,
      value = newcontent
    )
    for (v in seq_along(value)) {
      x <- prepend_chunks(
        x = x, i = n_row + v, j = 1,
        part = "footer",
        as_sup(symbols_str[v])
      )
    }
  }
  x
}
