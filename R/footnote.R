#' @export
#' @title add footnotes to flextable
#' @description add footnotes to a flextable object. A symbol is appened
#' where the footnote is defined and the note is appened in the footer part
#' of the table.
#' @param x a flextable object
#' @param i rows selection
#' @param j column selection
#' @param value a call to function \code{\link{as_paragraph}}.
#' @param ref_symbols character value, symbols to append that will be used
#' as references to notes.
#' @param part partname of the table (one of 'body', 'header', 'footer')
#' @param inline whether to add footnote on same line as previous footnote or not
#' @param sep inline = T, character string to use as a separator between footnotes
#' @examples
#' ft_1 <- flextable(head(iris))
#' ft_1 <- footnote( ft_1, i = 1, j = 1:3,
#'             value = as_paragraph(
#'               c("This is footnote one",
#'                 "This is footnote two",
#'                 "This is footnote three")
#'             ),
#'             ref_symbols = c("a", "b", "c"),
#'             part = "header")
#' ft_1 <- valign(ft_1, valign = "bottom", part = "header")
#' ft_1 <- autofit(ft_1)
#'
#' ft_2 <- flextable(head(iris))
#' ft_2 <- autofit(ft_2)
#' ft_2 <- footnote( ft_2, i = 1, j = 1:2,
#'                value = as_paragraph(
#'                 c("This is footnote one",
#'                    "This is footnote two")
#'                ),
#'                ref_symbols = c("a", "b"),
#'                part = "header", inline = TRUE)
#' ft_2 <- footnote( ft_2, i = 1, j = 3:4,
#'                value = as_paragraph(
#'                  c("This is footnote three",
#'                    "This is footnote four")
#'                ),
#'                ref_symbols = c("c","d"),
#'                part = "header", inline = TRUE)
#' ft_2
#' @export
#' @importFrom stats update
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_footnote_1.png}{options: width=70\%}}
#'
#' \if{html}{\figure{fig_footnote_2.png}{options: width=70\%}}
#'
#' @seealso \code{\link{footnote_multi_callout}}
#'
footnote <- function (x, i = NULL, j = NULL, value, ref_symbols = NULL, part = "body",
                      inline = FALSE, sep = "; ")
{
  if (!inherits(x, "flextable"))
    stop("footnote supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"),
                    several.ok = FALSE)
  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- compose(x = x, i = i, j = j, value = value,
                   part = p)
    }
    return(x)
  }
  if (nrow_part(x, part) < 1)
    return(x)

  if (is.null(ref_symbols)) {
    ref_symbols <- as.character(seq_along(value))
  }
  symbols_chunks <- rep(list(NULL), length(ref_symbols))
  for (symbi in seq_along(ref_symbols)) {
    symbols_chunks[[symbi]] <- as_sup(ref_symbols[symbi])
  }

  x <- footnote_callout(x, i, j, symbols_chunks, part)
  x <- footnote_value(x, value, ref_symbols, symbols_chunks, inline, sep)
  x
}

#' @export
#' @title add a footnote with multiple callouts to a flextable
#'
#' @description add a footnotes to a flextable object. A symbol is appened
#' in all the locations where the footnote is defined (the callout) and the
#' note is appended in the footer part of the table.
#' Unlike \code{\link{footnote}}, this function can only create one footnote,
#' which may be referenced in several cells within the same part of the table.
#'
#' @param x a flextable object
#' @param i_list a list of rows selections
#' @param j_list a list of column selections
#' @param value a call to function \code{\link{as_paragraph}}.
#' @param ref_symbol character value. The symbol to append that will be used
#' as references to notes.
#' @param part partname of the table (one of 'body', 'header', 'footer')
#' @param inline whether to add footnote on same line as previous footnote or not
#' @param sep inline = T, character string to use as a separator between footnotes
#' @examples
#' ft1 <- flextable(head(iris))
#' ft1 <- footnote_multi_callout(ft1,
#'                              i_list = list(1, 6, 3),
#'                              j_list = list(1, 2, 3),
#'                              value = as_paragraph("This is one footnote"),
#'                              ref_symbol = "(a)")
#' ft1 <- valign(ft1, valign = "bottom", part = "header")
#' autofit(ft1)
#'
#' ft2 <- flextable(head(iris))
#' ft2 <- footnote_multi_callout(ft2,
#'                              i_list = list(1, 3, ~ Petal.Length == 1.7),
#'                              j_list = list(1, 2, "Petal.Length"),
#'                              value = as_paragraph("This is footnote one"),
#'                              ref_symbol = "(a)",
#'                              inline = TRUE)
#' ft2 <- footnote_multi_callout(ft2, i_list = list(1, 5), j_list = list(1, 2),
#'                              value = as_paragraph("This is footnote two"),
#'                              ref_symbol = "(b)",
#'                              inline = TRUE)
#' ft2 <- valign(ft2, valign = "bottom", part = "header")
#' autofit(ft2)
#'
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_footnote_multi_callout_1.png}{options: width=70\%}}
#'
#' \if{html}{\figure{fig_footnote_multi_callout_2.png}{options: width=70\%}}
#'
#' @seealso \code{\link{footnote}}
#'
footnote_multi_callout <- function(x, i_list, j_list, value, ref_symbol = NULL,
                              part = "body", inline = FALSE, sep = "; ") {
  if (!inherits(x, "flextable"))
    stop("footnote_multi_callout supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"),
                    several.ok = FALSE)
  if (nrow_part(x, part) < 1)
    return(x)
  if (length(value) > 1) {
    stop("footnote_multi_callout supports only a single value.")
  }
  if (length(ref_symbol) > 1) {
    stop("footnote_multi_callout supports only a single value of ref_symbols.")
  }
  if (length(i_list) != length(j_list)) {
    stop("i_list and j_list must be the same length.")
  }

  if (is.null(ref_symbol)) {
    ref_symbol <- as.character(1)
  }
  symbols_chunks <- list(as_sup(ref_symbol))

  for (indexi in seq_along(i_list)) {
    i <- i_list[[indexi]]
    j <- j_list[[indexi]]
    x <- footnote_callout(x, i, j, symbols_chunks, part)
  }
  x <- footnote_value(x, value, ref_symbol, symbols_chunks, inline, sep)
  x
}

footnote_callout <- function(x, i, j, symbols_chunks, part) {
  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  new <- mapply(function(x, y) {
    y$seq_index <- max(x$seq_index, na.rm = TRUE) + 1
    rbind.match.columns(list(x, y))
  }, x = x[[part]]$content[i, j], y = symbols_chunks, SIMPLIFY = FALSE)
  x[[part]]$content[i, j] <- new
  x
}

footnote_value <- function(x, value, ref_symbols, symbols_chunks, inline, sep) {
  n_row <- nrow_part(x, "footer")
  new <- mapply(function(x, y) {
    x$seq_index <- min(y$seq_index, na.rm = TRUE) - 1
    x <- rbind.match.columns(list(x, y))
    x$seq_index <- order(x$seq_index)
    x
  }, x = symbols_chunks, y = value, SIMPLIFY = FALSE)

  if (inline){
    sep <- as_paragraph(sep)[[1]]
    new[-1] <- lapply(new[-1], function(x) rbind.match.columns(list(sep, x)))
    new_inline <- list(rbind.match.columns(new))
    new_inline[[1]]$seq_index <- seq_len(nrow(new_inline[[1]]))

    if(n_row > 0){
      new_inline <- list(x[["footer"]]$content[n_row, 1][[1]],
                         sep,new_inline[[1]])
      new_inline <- rbind.match.columns(new_inline)
      new_inline$seq_index <- seq_len(nrow(new_inline))
      new_inline <- list(new_inline)
      footer.rows <- n_row
    } else {
      x <- add_footer_lines(x,values="")
      footer.rows <- 1
    }
    new <- new_inline
  } else {
    x <- add_footer_lines(x, values = ref_symbols)
    footer.rows <- n_row + seq_len(length(new))
  }
  x[["footer"]]$content[footer.rows, 1] <- new
  x
}
