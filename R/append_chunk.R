#' @export
#' @title append chunks to flextable content
#' @description append chunks (for example chunk [as_chunk()])
#' in a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j column selection
#' @param ... chunks to be appened, see [as_chunk()], [gg_chunk()] and other
#' chunk elements for paragraph.
#' @param part partname of the table (one of 'body', 'header', 'footer')
#' @examples
#' library(flextable)
#'
#' f1 <- function(x) {
#'   formatC(x, digits = 1,
#'           format = "f")
#' }
#' f2 <- function(x) {
#'   paste0(
#'     " (",
#'     formatC(x, digits = 1,
#'             format = "f"), ")")
#' }
#'
#' ft_1 <- flextable(
#'   data = head(mtcars),
#'   col_keys = c("am", "gear", "carb", "mycol")
#' )
#' ft_1 <- merge_v(ft_1, j = "am")
#' ft_1 <- valign(ft_1, valign = "top")
#' ft_1 <- theme_vanilla(ft_1)
#' ft_1 <- mk_par(ft_1,
#'   j = "mycol", part = "body",
#'   value = as_paragraph(
#'     as_chunk(mpg, formatter = f1), " ",
#'     colorize(as_chunk(wt, formatter = f2), "gray")
#'   )
#' )
#'
#' ft_1 <-
#'   append_chunks(ft_1,
#'     i = 1, j = "mycol", part = "header",
#'     as_chunk("mpg "),
#'     colorize(as_bracket("wt"), "gray")
#'   )
#'
#' ft_1 <- align(
#'   x = ft_1, j = c("am", "gear", "carb"),
#'   align = "center", part = "all")
#' ft_1 <- align(
#'   x = ft_1, j = "mycol",
#'   align = "right", part = "all")
#'
#' ft_1 <- autofit(ft_1)
#'
#' ft_1
append_chunks <- function (x, i = NULL, j = NULL, ..., part = "body"){
  if (!inherits(x, "flextable"))
    stop("append_chunks supports only flextable objects.")
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
    if(nrow(value) == 1L && nrow(value) < nrow(tmp_data)){
      value <- rep(list(value), nrow(tmp_data))
      value <- rbind.match.columns(value)
    }
    value <- split(value, i)

    new <- mapply(function(x, y) {
      y$seq_index <- max(x$seq_index, na.rm = TRUE) + 1
      rbind.match.columns(list(x, y))
    }, x = x[[part]]$content[i, j], y = value, SIMPLIFY = FALSE)
    x[[part]]$content[i, j] <- new
  }

  x
}
