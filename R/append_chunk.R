#' @export
#' @title append chunks to flextable content
#' @description append chunks (for example chunk [as_chunk()])
#' in a flextable.
#' @param x a flextable object
#' @param ... chunks to be appened, see [as_chunk()], [gg_chunk()] and other
#' chunk elements for paragraph.
#' @param i rows selection
#' @param j column selection
#' @param part partname of the table (one of 'body', 'header', 'footer')
#' @seealso [as_chunk()], [as_sup()], [as_sub()], [colorize()]
#' @family functions for mixed content paragraphs
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_append_chunks_1.png}{options: width="100"}}
#' @examples
#' library(flextable)
#' img.file <- file.path(R.home("doc"), "html", "logo.jpg")
#'
#' ft_1 <- flextable(head(cars))
#'
#' ft_1 <- append_chunks(ft_1,
#'   # where to append
#'   i = c(1, 3, 5),
#'   j = 1,
#'   # what to append
#'   as_chunk(" "),
#'   as_image(src = img.file, width = .20, height = .15)
#' )
#' ft_1 <- set_table_properties(ft_1, layout = "autofit")
#' ft_1
append_chunks <- function (x, ..., i = NULL, j = NULL, part = "body"){
  if (!inherits(x, "flextable")){
    stop(sprintf("Function `%s` supports only flextable objects.", "append_chunks()"))
  }
  part <- match.arg(part, c("body", "header", "footer"),
                    several.ok = FALSE)

  if (nrow_part(x, part) < 1)
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  col_exprs <- enquos(...)

  tmp_data <- x[[part]]$dataset[i, , drop = FALSE]

  for(col_expr in col_exprs){

    value <- eval_tidy(col_expr, data = tmp_data)

    if(is.data.frame(value) && nrow(value) == 1L && nrow(value) < nrow(tmp_data)){
      value <- rep(list(value), nrow(tmp_data))
      value <- rbind.match.columns(value)
    }

    if(is.data.frame(value))
      value <- split(value, i)

    new <- mapply(function(x, y) {
      y$seq_index <- max(x$seq_index, na.rm = TRUE) + 1
      rbind.match.columns(list(x, y))
    }, x = x[[part]]$content[i, j], y = value, SIMPLIFY = FALSE)
    x[[part]]$content[i, j] <- new
  }

  x
}
#' @export
#' @title prepend chunks to flextable content
#' @description prepend chunks (for example chunk [as_chunk()])
#' in a flextable.
#' @param x a flextable object
#' @param ... chunks to be prepended, see [as_chunk()], [gg_chunk()] and other
#' chunk elements for paragraph.
#' @param i rows selection
#' @param j column selection
#' @param part partname of the table (one of 'body', 'header', 'footer')
#' @family functions for mixed content paragraphs
#' @examples
#' x <- flextable(head(iris))
#' x <- prepend_chunks(
#'   x,
#'   i = 1, j = 1,
#'   colorize(as_b("Hello "), color = "red"),
#'   colorize(as_i("World"), color = "magenta")
#' )
#' x
prepend_chunks <- function (x, ..., i = NULL, j = NULL, part = "body"){
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "prepend_chunks()"))
  }
  part <- match.arg(part, c("body", "header", "footer"),
                    several.ok = FALSE)

  if (nrow_part(x, part) < 1)
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i)
  j <- get_columns_id(x[[part]], j)

  col_exprs <- enquos(...)

  tmp_data <- x[[part]]$dataset[i, , drop = FALSE]

  for(expr_index in rev(seq_along(col_exprs))){
    col_expr <- col_exprs[[expr_index]]
    value <- eval_tidy(col_expr, data = tmp_data)

    if(is.data.frame(value) && nrow(value) == 1L && nrow(value) < nrow(tmp_data)){
      value <- rep(list(value), nrow(tmp_data))
      value <- rbind.match.columns(value)
    }

    if(is.data.frame(value))
      value <- split(value, i)

    new <- mapply(function(x, y, seq_index) {
      y$seq_index <- seq_index
      z <- rbind.match.columns(list(y, x))
      z <- z[order(z$seq_index),]
      z$seq_index <- rleid(z$seq_index)
      z
    }, x = x[[part]]$content[i, j], y = value, SIMPLIFY = FALSE, MoreArgs = list(seq_index=-expr_index))
    x[[part]]$content[i, j] <- new
  }
  x
}
