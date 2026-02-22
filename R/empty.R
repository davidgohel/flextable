#' @title Clear the displayed content of selected columns
#' @description
#' `void()` replaces the visible text of the selected columns
#' with an empty string. The columns themselves (and their
#' headers) remain in the table, but the cell values are no
#' longer displayed.
#'
#' This is useful when a column should stay in the layout
#' (e.g. to preserve its width or to keep its header label)
#' but its body values should be hidden, for instance
#' after using [compose()] to build a richer display in a
#' neighbouring column that already incorporates those values.
#'
#' The underlying dataset is not modified; only the displayed
#' content is affected. To remove a column entirely, use
#' the `col_keys` argument of [flextable()] instead.
#' @inheritParams args_x_j_part
#' @examples
#' ftab <- flextable(head(mtcars))
#' ftab <- void(ftab, ~ vs + am + gear + carb)
#' ftab
#' @export
#' @family cell_content_composition
void <- function(x, j = NULL, part = "body") {
  if (!inherits(x, "flextable")) {
    stop(sprintf("Function `%s` supports only flextable objects.", "void()"))
  }
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE)

  if (part == "all") {
    for (p in c("header", "body", "footer")) {
      x <- void(x = x, j = j, part = p)
    }
    return(x)
  }

  if (nrow_part(x, part) < 1) {
    return(x)
  }

  j <- get_columns_id(x[[part]], j)
  j <- x$col_keys[j]
  newcontent <- as_chunkset_struct(
    l_paragraph = rep(
      as_paragraph(as_chunk(x = "", fp_text_default())),
      nrow_part(x, part)
    ),
    keys = j,
    i = seq_len(nrow_part(x, part)))
  x[[part]]$content <- set_chunkset_struct_element(
    x = x[[part]]$content,
    j = j,
    value = newcontent)

  x
}
