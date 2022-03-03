#' @export
#' @title add footnotes to flextable
#' @description add footnotes to a flextable object. A symbol is appened
#' where the footnote is defined and the note is appened in the footer part
#' of the table.
#' @param x a flextable object
#' @param i rows selection
#' @param j column selection
#' @param value a call to function [as_paragraph()].
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
#' \if{html}{\figure{fig_footnote_1.png}{options: width="400"}}
#'
#' \if{html}{\figure{fig_footnote_2.png}{options: width="400"}}
footnote <- function (x, i = NULL, j = NULL, value, ref_symbols = NULL, part = "body",
                      inline = FALSE, sep = "; ")
{
  if (!inherits(x, "flextable"))
    stop("footnote supports only flextable objects.")
  part <- match.arg(part, c("body", "header", "footer"),
                    several.ok = FALSE)

  if (nrow_part(x, part) < 1)
    return(x)
  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)
  if (is.null(ref_symbols)) {
    ref_symbols <- as.character(seq_along(value))
  }
  symbols_chunks <- rep(list(NULL), length(ref_symbols))
  for (symbi in seq_along(ref_symbols)) {
    symbols_chunks[[symbi]] <- as_sup(ref_symbols[symbi])
  }
  new <- mapply(function(x, y) {
    y$seq_index <- max(x$seq_index, na.rm = TRUE) + 1
    rbind.match.columns(list(x, y))
  }, x = x[[part]]$content[i, j], y = symbols_chunks, SIMPLIFY = FALSE)
  x[[part]]$content[i, j] <- new

  n_row <- nrow_part(x, "footer")
  new <- mapply(function(x, y) {
    x$seq_index <- min(y$seq_index, na.rm = TRUE) - 1
    x <- rbind.match.columns(list(x, y))
    x$seq_index <- order(x$seq_index)
    x
  }, x = symbols_chunks, y = value, SIMPLIFY = FALSE)

  if (inline){
    sep <- as_paragraph(sep)[[1]]
    new[-1] <-lapply(new[-1], function(x) rbind.match.columns(list(sep, x)))
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
