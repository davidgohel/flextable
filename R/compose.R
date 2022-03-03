#' @export
#' @importFrom rlang eval_tidy enquo quo_name
#' @title Define flextable displayed values
#' @description Modify flextable displayed values. Function is
#' handling complex formatting as well as image insertion.
#'
#' Function `mk_par` is another name for `compose` as
#' there is an unwanted conflict with package `purrr`.
#' @param x a flextable object
#' @param i rows selection
#' @param j column selection
#' @param value a call to function [as_paragraph()].
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @param use_dot by default `use_dot=FALSE`; if `use_dot=TRUE`,
#' `value` is evaluated within a data.frame augmented of a column named `.`
#' containing the `j`th column.
#' @examples
#' library(officer)
#' ft <- flextable(head( mtcars, n = 10))
#' ft <- compose(ft, j = "carb", i = ~ drat > 3.5,
#'   value = as_paragraph("carb is ", as_chunk( sprintf("%.1f", carb)) )
#'   )
#' ft <- autofit(ft)
#' @export
#' @family cells formatters
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_compose_1.png}{options: width="500"}}
compose <- function(x, i = NULL, j = NULL, value , part = "body", use_dot = FALSE){

  if( !inherits(x, "flextable") ) stop("compose supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- compose(x = x, i = i, j = j, value = value, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  defused_value <- enquo(value)
  call_label <- quo_name(defused_value)
  if(!grepl("as_paragraph", call_label)){
    stop("argument `value` is expected to be a call to `as_paragraph()` but the value is: `", call_label, "`")
  }

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  tmp_data <- x[[part]]$dataset[i, , drop = FALSE]
  if( use_dot ){
    for(jcol in j){
      tmp_data$. <- tmp_data[,jcol]
      x[[part]]$content[i, jcol] <- eval_tidy(defused_value, data = tmp_data)
    }
  } else {
    x[[part]]$content[i, j] <- eval_tidy(defused_value, data = tmp_data)
  }

  x
}

#' @rdname compose
#' @export
mk_par <- compose

